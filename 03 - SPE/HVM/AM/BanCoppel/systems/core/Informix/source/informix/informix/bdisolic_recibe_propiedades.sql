CREATE PROCEDURE "informix".recibe_propiedades(r_empresa CHAR(3),
				    r_num_solicitud CHAR(20),
				    r_col1_1  SMALLINT,     -- secuencia REG 1
				    r_col2_1  CHAR(1),      -- tipo prestatario
				    r_col3_1  VARCHAR(200), -- direccion 
				    r_col4_1  CHAR(2),      -- tipo propiedad
				    r_col5_1  MONEY(14,2),  -- valor actual
				    r_col6_1  MONEY(14,2),  -- cont hipo y grav
				    r_col7_1  MONEY(14,2),  -- ing bruto alq
				    r_col8_1  MONEY(14,2),  -- pagos hipot
				    r_col9_1  MONEY(14,2),  -- seg mtto imp otr
				    r_col10_1  MONEY(14,2),  -- ing neto alq
				    r_col1_2  SMALLINT,     -- secuencia REG 2
				    r_col2_2  CHAR(1),      -- tipo prestatario
				    r_col3_2  VARCHAR(200), -- direccion 
				    r_col4_2  CHAR(2),      -- tipo propiedad
				    r_col5_2  MONEY(14,2),  -- valor actual
				    r_col6_2  MONEY(14,2),  -- cont hipo y grav
				    r_col7_2  MONEY(14,2),  -- ing bruto alq
				    r_col8_2  MONEY(14,2),  -- pagos hipot
				    r_col9_2  MONEY(14,2),  -- seg mtto imp otr
				    r_col10_2  MONEY(14,2),  -- ing neto alq
				    r_col1_3  SMALLINT,     -- secuencia REG 3
				    r_col2_3  CHAR(1),      -- tipo prestatario
				    r_col3_3  VARCHAR(200), -- direccion 
				    r_col4_3  CHAR(2),      -- tipo propiedad
				    r_col5_3  MONEY(14,2),  -- valor actual
				    r_col6_3  MONEY(14,2),  -- cont hipo y grav
				    r_col7_3  MONEY(14,2),  -- ing bruto alq
				    r_col8_3  MONEY(14,2),  -- pagos hipot
				    r_col9_3  MONEY(14,2),  -- seg mtto imp otr
				    r_col10_3  MONEY(14,2),  -- ing neto alq
				    r_col1_4  SMALLINT,     -- secuencia REG 4
				    r_col2_4  CHAR(1),      -- tipo prestatario
				    r_col3_4  VARCHAR(200), -- direccion 
				    r_col4_4  CHAR(2),      -- tipo propiedad
				    r_col5_4  MONEY(14,2),  -- valor actual
				    r_col6_4  MONEY(14,2),  -- cont hipo y grav
				    r_col7_4  MONEY(14,2),  -- ing bruto alq
				    r_col8_4  MONEY(14,2),  -- pagos hipot
				    r_col9_4  MONEY(14,2),  -- seg mtto imp otr
				    r_col10_4  MONEY(14,2),  -- ing neto alq
				    r_col1_5  SMALLINT,     -- secuencia REG 5
				    r_col2_5  CHAR(1),      -- tipo prestatario
				    r_col3_5  VARCHAR(200), -- direccion 
				    r_col4_5  CHAR(2),      -- tipo propiedad
				    r_col5_5  MONEY(14,2),  -- valor actual
				    r_col6_5  MONEY(14,2),  -- cont hipo y grav
				    r_col7_5  MONEY(14,2),  -- ing bruto alq
				    r_col8_5  MONEY(14,2),  -- pagos hipot
				    r_col9_5  MONEY(14,2),  -- seg mtto imp otr
				    r_col10_5  MONEY(14,2))  -- ing neto alq
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
	INSERT INTO ss_propiedades
	  (empresa,          num_solicitud,     secuencia,        
           tipo_prestatario, direccion,         tipo_propiedad ,
           valor_actual,     cont_hipo_y_grav,  ing_bruto_alq,
           pagos_hipot,      seg_mtto_imp_otros,ing_neto_alq)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_1,        
	   r_col2_1,     r_col3_1,          r_col4_1,
	   r_col5_1,     r_col6_1,          r_col7_1,
	   r_col8_1,     r_col9_1,          r_col10_1);
     END IF 
	
	-- Inserta Ocurrencia 2
     IF r_col1_2 <> 0 THEN
	INSERT INTO ss_propiedades
	  (empresa,          num_solicitud,     secuencia,        
           tipo_prestatario, direccion,         tipo_propiedad ,
           valor_actual,     cont_hipo_y_grav,  ing_bruto_alq,
           pagos_hipot,      seg_mtto_imp_otros,ing_neto_alq)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_2,        
	   r_col2_2,     r_col3_2,          r_col4_2,
	   r_col5_2,     r_col6_2,          r_col7_2,
	   r_col8_2,     r_col9_2,          r_col10_2);
     END IF 
	
	-- Inserta Ocurrencia 3
     IF r_col1_3 <> 0 THEN
	INSERT INTO ss_propiedades
	  (empresa,          num_solicitud,     secuencia,        
           tipo_prestatario, direccion,         tipo_propiedad ,
           valor_actual,     cont_hipo_y_grav,  ing_bruto_alq,
           pagos_hipot,      seg_mtto_imp_otros,ing_neto_alq)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_3,        
	   r_col2_3,     r_col3_3,          r_col4_3,
	   r_col5_3,     r_col6_3,          r_col7_3,
	   r_col8_3,     r_col9_3,          r_col10_3);
     END IF 
	
	-- Inserta Ocurrencia 4
     IF r_col1_4 <> 0 THEN
	INSERT INTO ss_propiedades
	  (empresa,          num_solicitud,     secuencia,        
           tipo_prestatario, direccion,         tipo_propiedad ,
           valor_actual,     cont_hipo_y_grav,  ing_bruto_alq,
           pagos_hipot,      seg_mtto_imp_otros,ing_neto_alq)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_4,        
	   r_col2_4,     r_col3_4,          r_col4_4,
	   r_col5_4,     r_col6_4,          r_col7_4,
	   r_col8_4,     r_col9_4,          r_col10_4);
     END IF 
	
	-- Inserta Ocurrencia 5
     IF r_col1_5 <> 0 THEN
	INSERT INTO ss_propiedades
	  (empresa,          num_solicitud,     secuencia,        
           tipo_prestatario, direccion,         tipo_propiedad ,
           valor_actual,     cont_hipo_y_grav,  ing_bruto_alq,
           pagos_hipot,      seg_mtto_imp_otros,ing_neto_alq)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_5,        
	   r_col2_5,     r_col3_5,          r_col4_5,
	   r_col5_5,     r_col6_5,          r_col7_5,
	   r_col8_5,     r_col9_5,          r_col10_5);
     END IF 

END
	RETURN vcod_ret;

END PROCEDURE;