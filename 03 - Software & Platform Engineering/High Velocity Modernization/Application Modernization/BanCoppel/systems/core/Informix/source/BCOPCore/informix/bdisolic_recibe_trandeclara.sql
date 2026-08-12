CREATE PROCEDURE "informix".recibe_trandeclara(r_empresa CHAR(3),
				    r_num_solicitud CHAR(20),
				    r_col1_1  SMALLINT,    -- secuencia REG 1
				    r_col2_1  CHAR(1),     -- cod concepto
				    r_col3_1  CHAR(3),     -- Tipo pestatario
				    r_col4_1  VARCHAR(20), -- valor 
				    r_col1_2  SMALLINT,    -- secuencia REG 2
				    r_col2_2  CHAR(1),     -- cod concepto
				    r_col3_2  CHAR(3),     -- Tipo pestatario
				    r_col4_2  VARCHAR(20), -- valor 
				    r_col1_3  SMALLINT,    -- secuencia REG 3
				    r_col2_3  CHAR(1),     -- cod concepto
				    r_col3_3  CHAR(3),     -- Tipo pestatario
				    r_col4_3  VARCHAR(20), -- valor 
				    r_col1_4  SMALLINT,    -- secuencia REG 4
				    r_col2_4  CHAR(1),     -- cod concepto
				    r_col3_4  CHAR(3),     -- Tipo pestatario
				    r_col4_4  VARCHAR(20), -- valor 
				    r_col1_5  SMALLINT,    -- secuencia REG 5
				    r_col2_5  CHAR(1),     -- cod concepto
				    r_col3_5  CHAR(3),     -- Tipo pestatario
				    r_col4_5  VARCHAR(20)) -- valor 
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
	INSERT INTO ss_tran_declara
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  valor)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_1,        
	   r_col2_1,     r_col3_1,          r_col4_1);
    END IF 
	
	-- Inserta Ocurrencia 2
    IF r_col1_2 <> 0 THEN
	INSERT INTO ss_tran_declara
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  valor)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_2,        
	   r_col2_2,     r_col3_2,          r_col4_2);
    END IF 
	
	-- Inserta Ocurrencia 3
    IF r_col1_3 <> 0 THEN
	INSERT INTO ss_tran_declara
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  valor)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_3,        
	   r_col2_3,     r_col3_3,          r_col4_3);
    END IF 
	
	-- Inserta Ocurrencia 4
    IF r_col1_4 <> 0 THEN
	INSERT INTO ss_tran_declara
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  valor)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_4,        
	   r_col2_4,     r_col3_4,          r_col4_4);
    END IF 
	
	-- Inserta Ocurrencia 5
    IF r_col1_5 <> 0 THEN
	INSERT INTO ss_tran_declara
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  valor)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_5,        
           r_col2_5,     r_col3_5,          r_col4_5);
    END IF 

END
	RETURN vcod_ret;

END PROCEDURE;