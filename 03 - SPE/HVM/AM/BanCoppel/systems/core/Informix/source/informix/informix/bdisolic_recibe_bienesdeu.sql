CREATE PROCEDURE "informix".recibe_bienesdeu(r_empresa CHAR(3),
				 r_num_solicitud CHAR(20),
				 r_col1_1  SMALLINT,      -- secuencia REG 1
				 r_col2_1  CHAR(1),       -- tipo prestatario
				 r_col3_1  CHAR(3),       -- cod conccepto
				 r_col4_1  VARCHAR(200),  -- DESC1 
				 r_col5_1  VARCHAR(200),  -- DESC2 
				 r_col6_1  VARCHAR(200),  -- DESC3 
				 r_col7_1  VARCHAR(200),  -- DESC4 
				 r_col8_1  MONEY(14,2),   -- importe 
				 r_col1_2  SMALLINT,      -- secuencia REG 2
				 r_col2_2  CHAR(1),       -- tipo prestatario
				 r_col3_2  CHAR(3),       -- cod conccepto
				 r_col4_2  VARCHAR(200),  -- DESC1 
				 r_col5_2  VARCHAR(200),  -- DESC2 
				 r_col6_2  VARCHAR(200),  -- DESC3 
				 r_col7_2  VARCHAR(200),  -- DESC4 
				 r_col8_2  MONEY(14,2),   -- importe 
				 r_col1_3  SMALLINT,      -- secuencia REG 3
				 r_col2_3  CHAR(1),       -- tipo prestatario
				 r_col3_3  CHAR(3),       -- cod conccepto
				 r_col4_3  VARCHAR(200),  -- DESC1 
				 r_col5_3  VARCHAR(200),  -- DESC2 
				 r_col6_3  VARCHAR(200),  -- DESC3 
				 r_col7_3  VARCHAR(200),  -- DESC4 
				 r_col8_3  MONEY(14,2),   -- importe 
				 r_col1_4  SMALLINT,      -- secuencia REG 4
				 r_col2_4  CHAR(1),       -- tipo prestatario
				 r_col3_4  CHAR(3),       -- cod conccepto
				 r_col4_4  VARCHAR(200),  -- DESC1 
				 r_col5_4  VARCHAR(200),  -- DESC2 
				 r_col6_4  VARCHAR(200),  -- DESC3 
				 r_col7_4  VARCHAR(200),  -- DESC4 
				 r_col8_4  MONEY(14,2),   -- importe 
				 r_col1_5  SMALLINT,      -- secuencia REG 5
				 r_col2_5  CHAR(1),       -- tipo prestatario
				 r_col3_5  CHAR(3),       -- cod conccepto
				 r_col4_5  VARCHAR(200),  -- DESC1 
				 r_col5_5  VARCHAR(200),  -- DESC2 
				 r_col6_5  VARCHAR(200),  -- DESC3 
				 r_col7_5  VARCHAR(200),  -- DESC4 
				 r_col8_5  MONEY(14,2))   -- importe 
RETURNING CHAR(5);

-- *************************************************************************
-- *                       DEFINICION DE VARIABLES                         *
-- *************************************************************************
DEFINE vcod_ret  CHAR(5);
DEFINE vsqlerr   INTEGER;

DEFINE V_VENCIDO_1 INTEGER;
DEFINE V_VENCIDO_2 INTEGER;
DEFINE V_VENCIDO_3 INTEGER;
DEFINE V_VENCIDO_4 INTEGER;
DEFINE V_VENCIDO_5 INTEGER;

-- *************************************************************************
-- *                       ASIGNACION DE VARIABLES                         *
-- *************************************************************************
LET vcod_ret = "00000";
LET vsqlerr  = 0;

LET V_VENCIDO_1 = 0;
LET V_VENCIDO_2 = 0;
LET V_VENCIDO_3 = 0;
LET V_VENCIDO_4 = 0;
LET V_VENCIDO_5 = 0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcod_ret=vsqlerr;
      RETURN vcod_ret;
   END IF;
END EXCEPTION;

-- *************************************************************************

   --VERIFICA QUE NINGUN CREDITO ASICIADO ESTE VENCIDO
   --************************************************
   IF r_col1_1 <> 0 and r_col3_1 = '075' THEN
     SELECT COUNT(*) INTO V_VENCIDO_1
     FROM   BDICRED:SD_MAECRED 
     WHERE  SUBSTR(STATUS_CRED,1,1) <> 'A'
     AND    EMPRESA = R_EMPRESA
     AND    NUM_CREDITO = TRIM(R_COL4_1);
   END IF;

   IF r_col1_2 <> 0 and r_col3_2 = '075' THEN
     SELECT COUNT(*) INTO V_VENCIDO_2
     FROM   BDICRED:SD_MAECRED 
     WHERE  SUBSTR(STATUS_CRED,1,1) <> 'A'
     AND    EMPRESA = R_EMPRESA
     AND    NUM_CREDITO = TRIM(R_COL4_2);
   END IF;

   IF r_col1_3 <> 0 and r_col3_3 = '075' THEN
     SELECT COUNT(*) INTO V_VENCIDO_3
     FROM   BDICRED:SD_MAECRED 
     WHERE  SUBSTR(STATUS_CRED,1,1) <> 'A'
     AND    EMPRESA = R_EMPRESA
     AND    NUM_CREDITO = TRIM(R_COL4_3);
   END IF;

   IF r_col1_4 <> 0 and r_col3_4 = '075' THEN
     SELECT COUNT(*) INTO V_VENCIDO_4
     FROM   BDICRED:SD_MAECRED 
     WHERE  SUBSTR(STATUS_CRED,1,1) <> 'A'
     AND    EMPRESA = R_EMPRESA
     AND    NUM_CREDITO = TRIM(R_COL4_4);
   END IF;

   IF r_col1_5 <> 0 and r_col3_5 = '075' THEN
     SELECT COUNT(*) INTO V_VENCIDO_5
     FROM   BDICRED:SD_MAECRED 
     WHERE  SUBSTR(STATUS_CRED,1,1) <> 'A'
     AND    EMPRESA = R_EMPRESA
     AND    NUM_CREDITO = TRIM(R_COL4_5);
   END IF;
   
{   IF V_VENCIDO_1 > 0 OR V_VENCIDO_2 > 0 OR V_VENCIDO_3 > 0 OR
      V_VENCIDO_4 > 0 OR V_VENCIDO_5 > 0 THEN

      LET VCOD_RET = '357';
      RETURN VCOD_RET;
   END IF;}
   --************************************************

	-- Inserta Ocurrencia 1
   IF r_col1_1 <> 0 THEN
	INSERT INTO ss_bienes_deudas
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  desc1,
	   desc2,            desc3,         desc4,
           importe)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_1,        
	   r_col2_1,     r_col3_1,          r_col4_1,
	   r_col5_1,     r_col6_1,          r_col7_1,
           r_col8_1);
   END IF
	
	-- Inserta Ocurrencia 2
   IF r_col1_2 <> 0 THEN
	INSERT INTO ss_bienes_deudas
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  desc1,
	   desc2,            desc3,         desc4,
           importe)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_2,        
	   r_col2_2,     r_col3_2,          r_col4_2,
	   r_col5_2,     r_col6_2,          r_col7_2,
           r_col8_2);
   END IF
	
	-- Inserta Ocurrencia 3
   IF r_col1_3 <> 0 THEN
	INSERT INTO ss_bienes_deudas
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  desc1,
	   desc2,            desc3,         desc4,
           importe)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_3,        
	   r_col2_3,     r_col3_3,          r_col4_3,
	   r_col5_3,     r_col6_3,          r_col7_3,
           r_col8_3);
   END IF
	
	-- Inserta Ocurrencia 4
   IF r_col1_4 <> 0 THEN
	INSERT INTO ss_bienes_deudas
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  desc1,
	   desc2,            desc3,         desc4,
           importe)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_4,        
	   r_col2_4,     r_col3_4,          r_col4_4,
	   r_col5_4,     r_col6_4,          r_col7_4,
           r_col8_4);
   END IF
	
	-- Inserta Ocurrencia 5
   IF r_col1_5 <> 0 THEN
	INSERT INTO ss_bienes_deudas
	  (empresa,          num_solicitud, secuencia,        
	   tipo_prestatario, cod_concepto,  desc1,
	   desc2,            desc3,         desc4,
           importe)
	 VALUES
	  (r_empresa,    r_num_solicitud,   r_col1_5,        
	   r_col2_5,     r_col3_5,          r_col4_5,
	   r_col5_5,     r_col6_5,          r_col7_5,
           r_col8_5);
   END IF

END
	RETURN vcod_ret;

END PROCEDURE;