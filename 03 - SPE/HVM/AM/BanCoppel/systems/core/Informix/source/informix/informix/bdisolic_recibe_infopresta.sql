CREATE PROCEDURE "informix".recibe_infopresta(r_empresa CHAR(3),
				   r_num_solicitud CHAR(20),
				   r_col1_1  SMALLINT,    -- secuencia REG 1
				   r_col2_1  CHAR(1),     -- tp prestatario
				   r_col3_1  VARCHAR(60), -- nombre
				   r_col4_1  VARCHAR(20), -- no_imss
				   r_col5_1  VARCHAR(15), -- telefono
				   r_col6_1  SMALLINT,    -- edad
				   r_col7_1  VARCHAR(2),  -- anios aduca
				   r_col8_1  CHAR(1),     -- edo civil
				   r_col9_1  SMALLINT,    -- nro depend
				   r_col10_1 VARCHAR(40), -- calle
				   r_col11_1 CHAR(3),     -- ciudad
				   r_col12_1 CHAR(2),     -- estado
				   r_col13_1 VARCHAR(11), -- cod postal
				   r_col14_1 CHAR(1),     -- prop inqui
				   r_col15_1 SMALLINT,    -- no anios
				   r_col1_2  SMALLINT,    -- secuencia REG 2
				   r_col2_2  CHAR(1),     -- tp prestatario
				   r_col3_2  VARCHAR(60), -- nombre
				   r_col4_2  VARCHAR(20), -- no_imss
				   r_col5_2  VARCHAR(15), -- telefono
				   r_col6_2  SMALLINT,    -- edad
				   r_col7_2  VARCHAR(2),  -- anios aduca
				   r_col8_2  CHAR(1),     -- edo civil
				   r_col9_2  SMALLINT,    -- nro depend
				   r_col10_2 VARCHAR(40), -- calle
				   r_col11_2 CHAR(3),     -- ciudad
				   r_col12_2 CHAR(2),     -- estado
				   r_col13_2 VARCHAR(11), -- cod postal
				   r_col14_2 CHAR(1),     -- prop inqui
				   r_col15_2 SMALLINT,    -- no anios
				   r_col1_3  SMALLINT,    -- secuencia REG 3
				   r_col2_3  CHAR(1),     -- tp prestatario
				   r_col3_3  VARCHAR(60), -- nombre
				   r_col4_3  VARCHAR(20), -- no_imss
				   r_col5_3  VARCHAR(15), -- telefono
				   r_col6_3  SMALLINT,    -- edad
				   r_col7_3  VARCHAR(2),  -- anios aduca
				   r_col8_3  CHAR(1),     -- edo civil
				   r_col9_3  SMALLINT,    -- nro depend
				   r_col10_3 VARCHAR(40), -- calle
				   r_col11_3 CHAR(3),     -- ciudad
				   r_col12_3 CHAR(2),     -- estado
				   r_col13_3 VARCHAR(11), -- cod postal
				   r_col14_3 CHAR(1),     -- prop inqui
				   r_col15_3 SMALLINT,    -- no anios
				   r_col1_4  SMALLINT,    -- secuencia REG 4
				   r_col2_4  CHAR(1),     -- tp prestatario
				   r_col3_4  VARCHAR(60), -- nombre
				   r_col4_4  VARCHAR(20), -- no_imss
				   r_col5_4  VARCHAR(15), -- telefono
				   r_col6_4  SMALLINT,    -- edad
				   r_col7_4  VARCHAR(2),  -- anios aduca
				   r_col8_4  CHAR(1),     -- edo civil
				   r_col9_4  SMALLINT,    -- nro depend
				   r_col10_4 VARCHAR(40), -- calle
				   r_col11_4 CHAR(3),     -- ciudad
				   r_col12_4 CHAR(2),     -- estado
				   r_col13_4 VARCHAR(11), -- cod postal
				   r_col14_4 CHAR(1),     -- prop inqui
				   r_col15_4 SMALLINT,    -- no anios
				   r_col1_5  SMALLINT,    -- secuencia REG 5
				   r_col2_5  CHAR(1),     -- tp prestatario
				   r_col3_5  VARCHAR(60), -- nombre
				   r_col4_5  VARCHAR(20), -- no_imss
				   r_col5_5  VARCHAR(15), -- telefono
				   r_col6_5  SMALLINT,    -- edad
				   r_col7_5  VARCHAR(2),  -- anios aduca
				   r_col8_5  CHAR(1),     -- edo civil
				   r_col9_5  SMALLINT,    -- nro depend
				   r_col10_5 VARCHAR(40), -- calle
				   r_col11_5 CHAR(3),     -- ciudad
				   r_col12_5 CHAR(2),     -- estado
				   r_col13_5 VARCHAR(11), -- cod postal
				   r_col14_5 CHAR(1),     -- prop inqui
				   r_col15_5 SMALLINT)    -- no anios
RETURNING CHAR(5);

-- *************************************************************************
-- *                       DEFINICION DE VARIABLES                         *
-- *************************************************************************
DEFINE vcod_ret  CHAR(5);
DEFINE vsqlerr   INTEGER;
-- *************************************************************************
-- *                       ASIGNACION DE VARIABLES                         *
-- *************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      RETURN vcod_ret;
   END IF;
END EXCEPTION;

-- *************************************************************************

	-- Inserta Ocurrencia 1
     IF r_col1_1 <> 0 THEN
	INSERT INTO ss_info_prestatario
	  (empresa,         num_solicitud, secuencia,        tipo_prestatario, 
           nombre,          no_imss,       telefono,         edad,      
           anios_educacion, estado_civil,  nro_dependientes, calle, 
           ciudad,          estado,        codigo_postal,    prop_inquilino, 
           no_anios)
	 VALUES
	  (r_empresa,       r_num_solicitud,r_col1_1,        r_col2_1, 
           r_col3_1,        r_col4_1,       r_col5_1,        r_col6_1, 
           r_col7_1,        r_col8_1,       r_col9_1,        r_col10_1,
           r_col11_1,       r_col12_1,      r_col13_1,       r_col14_1,
           r_col15_1);
     END IF 
	
	-- Inserta Ocurrencia 2
     IF r_col1_2 <> 0 THEN
	INSERT INTO ss_info_prestatario
	  (empresa,         num_solicitud, secuencia,        tipo_prestatario, 
           nombre,          no_imss,       telefono,         edad,      
           anios_educacion, estado_civil,  nro_dependientes, calle, 
           ciudad,          estado,        codigo_postal,    prop_inquilino, 
           no_anios)
	 VALUES
	  (r_empresa,       r_num_solicitud,r_col1_2,        r_col2_2, 
           r_col3_2,        r_col4_2,       r_col5_2,        r_col6_2, 
           r_col7_2,        r_col8_2,       r_col9_2,        r_col10_2,
           r_col11_2,       r_col12_2,      r_col13_2,       r_col14_2,
           r_col15_2);
     END IF 
	
	-- Inserta Ocurrencia 3
     IF r_col1_3 <> 0 THEN
	INSERT INTO ss_info_prestatario
	  (empresa,         num_solicitud, secuencia,        tipo_prestatario, 
           nombre,          no_imss,       telefono,         edad,      
           anios_educacion, estado_civil,  nro_dependientes, calle, 
           ciudad,          estado,        codigo_postal,    prop_inquilino, 
           no_anios)
	 VALUES
	  (r_empresa,       r_num_solicitud,r_col1_3,        r_col2_3, 
           r_col3_3,        r_col4_3,       r_col5_3,        r_col6_3, 
           r_col7_3,        r_col8_3,       r_col9_3,        r_col10_3,
           r_col11_3,       r_col12_3,      r_col13_3,       r_col14_3,
           r_col15_3);
     END IF 
	
	-- Inserta Ocurrencia 4
     IF r_col1_4 <> 0 THEN
	INSERT INTO ss_info_prestatario
	  (empresa,         num_solicitud, secuencia,        tipo_prestatario, 
           nombre,          no_imss,       telefono,         edad,      
           anios_educacion, estado_civil,  nro_dependientes, calle, 
           ciudad,          estado,        codigo_postal,    prop_inquilino, 
           no_anios)
	 VALUES
	  (r_empresa,       r_num_solicitud,r_col1_4,        r_col2_4, 
           r_col3_4,        r_col4_4,       r_col5_4,        r_col6_4, 
           r_col7_4,        r_col8_4,       r_col9_4,        r_col10_4,
           r_col11_4,       r_col12_4,      r_col13_4,       r_col14_4,
           r_col15_4);
     END IF 
	
	-- Inserta Ocurrencia 5
     IF r_col1_5 <> 0 THEN
	INSERT INTO ss_info_prestatario
	  (empresa,         num_solicitud, secuencia,        tipo_prestatario, 
           nombre,          no_imss,       telefono,         edad,      
           anios_educacion, estado_civil,  nro_dependientes, calle, 
           ciudad,          estado,        codigo_postal,    prop_inquilino, 
           no_anios)
	 VALUES
	  (r_empresa,       r_num_solicitud,r_col1_5,        r_col2_5, 
           r_col3_5,        r_col4_5,       r_col5_5,        r_col6_5, 
           r_col7_5,        r_col8_5,       r_col9_5,        r_col10_5,
           r_col11_5,       r_col12_5,      r_col13_5,       r_col14_5,
           r_col15_5);
     END IF 

END
	RETURN vcod_ret;

END PROCEDURE;