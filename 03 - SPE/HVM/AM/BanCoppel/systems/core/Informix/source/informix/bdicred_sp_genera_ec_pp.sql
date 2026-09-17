CREATE PROCEDURE "informix".sp_genera_ec_pp()
--EXECUTE PROCEDURE sp_genera_ec_pp();

RETURNING CHAR(5);

--DECLARACION
DEFINE vCodRet			CHAR(05);
DEFINE cMensaje    	 	CHAR(100); 
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE vMes				CHAR(02);
DEFINE vMesAnt			CHAR(02);
DEFINE vAnio			CHAR(04);
DEFINE vFechaAnt		DATE;
DEFINE vFechaHoy		DATE;
DEFINE contador_ec  	INTEGER;
DEFINE numero_cre  		VARCHAR(20,1);
DEFINE fecha_emi  		DATE;
DEFINE centro_imp_var  	CHAR(06);
DEFINE centro_imptemp  	CHAR(06);
DEFINE centro_impanterior CHAR(06);
DEFINE numero_reg  		INTEGER;
DEFINE contador_aux 	CHAR(06);
DEFINE vCentroDis		INTEGER;
DEFINE ciudad_impanterior	CHAR(06);
DEFINE ciudad_imp_var	CHAR(06);

DEFINE v_num_credito	CHAR(20);
DEFINE v_numcte			CHAR(20);
DEFINE v_ruta          	CHAR(47);
DEFINE v_numerociudad 	SMALLINT;
DEFINE v_numerocolonia 	INTEGER;
DEFINE v_numerocalle 	INTEGER;
DEFINE v_numeroextcalle CHAR(10);
DEFINE v_centro			INTEGER;
DEFINE v_jefegrupozona	INTEGER;
DEFINE v_supervisorzona	INTEGER;
DEFINE v_numerociudadCoppel	SMALLINT;
DEFINE v_numerocoloniaCoppel	INTEGER;
DEFINE v_tipo_dir		CHAR(1);

DEFINE vFechaEmision	DATE;
DEFINE vNumCredito		CHAR(20);
DEFINE VNumCte			CHAR(20);
DEFINE vSucursal		INTEGER;
DEFINE vNumRegion		CHAR(02);
DEFINE vNumCiudadBanco	CHAR(04);
DEFINE vNumCiudadCoppel	CHAR(03);
DEFINE cNumRegion		CHAR(02);
DEFINE cNumCiudadBanco	CHAR(04);
DEFINE cNumCiudadCoppel	CHAR(03);
DEFINE vNumCentroImpr	CHAR(02);


--INICIALIZACION
LET vCodRet        	= '00000';
LET cMensaje    	= 'Ejecucion Exitosa';
LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET vMes			= '';
LET vMesAnt			= '';
LET vAnio			= '';
LET vFechaAnt		= date(1);
LET vFechaHoy		= date(1);
LET contador_ec  	= 0;
LET numero_cre 		= "";
LET fecha_emi 		= DATE(1);
LET centro_imp_var 	= '';
LET centro_impanterior 	= '';
LET centro_imptemp 	= '';
LET numero_reg 		= 0;
LET contador_aux 	= '0';
LET vCentroDis		= 0;
LET centro_impanterior 	= "";
LET ciudad_imp_var	= '0';

LET v_num_credito	= '';
LET v_numcte		= '';
LET v_ruta			= '';
LET v_numerociudad	= 0;
LET v_numerocolonia	= '';
LET v_numerocalle	= 0;
LET v_numeroextcalle	= '';
LET v_centro		= 0;
LET v_jefegrupozona	= 0;
LET v_supervisorzona	= 0;
LET v_numerociudadCoppel	= 0;
LET v_numerocoloniaCoppel	= 0;
LET v_tipo_dir		= '';

LET vFechaEmision	= DATE(1);
LET vNumCredito		= '';
LET VNumCte			= '';
LET vSucursal		= 0;
LET vNumRegion		= '0';
LET vNumCiudadBanco	= '0';
LET vNumCiudadCoppel	= '0';
LET cNumRegion		= '0';
LET cNumCiudadBanco	= '0';
LET cNumCiudadCoppel	= '0';
LET vNumCentroImpr	= '00';

--SET DEBUG FILE TO "/informix/ulises/INC_EDC_EC/generacion_ec_pp.out";
--TRACE ON; 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet;
		END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Recupera la fecha para PP
	LET vFechaAnt = MDY(month(date(monthadd(today, -1))),17,year((monthadd(today, -1)))); 
    LET vFechaHoy = MDY(MONTH(today),17,YEAR(today)); 
	
	--LET vFechaAnt = MDY(01,17,2022); -- para pruebas
	--LET vFechaHoy = MDY(02,17,2022); -- para pruebas
	
	---- FUNCIONALIDAD ACTUALIZACION DE RUTA
	SELECT num_credito,numcte,ruta, num_region, num_ciudad_banco, num_ciudad_coppel
	FROM bdicred:"informix".sd_encabezado_edoctacrd 
	WHERE fecha_emision > vFechaAnt and fecha_emision <= vFechaHoy AND num_producto IN('6300','6400','7600','7700','6800','9100','9300')
	AND num_credito NOT IN('6300100','6400100','7600100','7700100','6800100','9100100','9300100')
	INTO TEMP pp_act_ruta WITH NO LOG;
	
	FOREACH WITH HOLD
	
	SELECT num_credito,		numcte,				ruta,
		   num_region,		num_ciudad_banco,	num_ciudad_coppel 
	  INTO v_num_credito,	v_numcte,			v_ruta,
		   vNumRegion,		vNumCiudadBanco,	vNumCiudadCoppel
	FROM pp_act_ruta
	
	UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE fecha_emision > vFechaAnt and fecha_emision <= vFechaHoy AND num_credito = v_num_credito;
	
	-- SI_DIRECCIONES TIPO 1 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir = "1";
	 
	IF v_tipo_dir = '1' THEN
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy 
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;

	-- SI_DIRECCIONES TIPO 2 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir = "2" ;
	
	IF v_tipo_dir = '2' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy 
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;
	
	-- SI_DIRECCIONES TIPO 3 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir >= "3" ;
	
	IF v_tipo_dir >= '3' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy 
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;
	
	END FOREACH; 
	

	--- FUNCIONALIDAD PARA GENERAR EC
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir, a.ruta
	FROM bdicred:sd_encabezado_edoctacrd a 
	INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte AND b.tipo_dir = '1' 
	INNER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision > vFechaAnt and a.fecha_emision <= vFechaHoy AND a.num_producto IN('6300','6400','7600','7700','6800','9100','9300')
	AND a.num_credito NOT IN('6300100','6400100','7600100','7700100','6800100','9100100','9300100')
	AND c.centro is not null and c.numerociudadcoppel is not null and c.numerocoloniacoppel is not null
	INTO TEMP creditospp_ec WITH NO LOG;
	
	INSERT INTO creditospp_ec
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir, a.ruta
	FROM bdicred:sd_encabezado_edoctacrd a 
	LEFT OUTER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte --AND b.tipo_dir = 1 
	LEFT OUTER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision > vFechaAnt and a.fecha_emision <= vFechaHoy and a.num_producto IN('6300','6400','7600','7700','6800','9100','9300')
	AND a.num_credito NOT IN('6300100','6400100','7600100','7700100','6800100','9100100','9300100')
	and c.centro is not null and c.numerociudadcoppel is not null and c.numerocoloniacoppel is not null
	AND a.num_credito NOT IN(select num_credito from creditospp_ec);
	
	SELECT num_credito, fecha_emision, numerociudadcoppel, centro, jefegrupozona, supervisorzona, numerocoloniacoppel,
		   numerocalle, numeroextcalle, tipo_dir, ruta
	FROM creditospp_ec --where num_credito NOT IN('6300100','7600100','7700100','6800100')
	group by centro, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle, tipo_dir, fecha_emision, num_credito, ruta
	INTO TEMP tmpNumeroRegistroscrd WITH NO LOG;


	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro, numerociudadcoppel INTO numero_cre, fecha_emi, centro_imp_var, ciudad_imp_var FROM tmpNumeroRegistroscrd
		--ORDER BY centro::INTEGER, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle
		ORDER BY centro::INTEGER, numerociudadcoppel::INTEGER, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, to_char(ruta), numeroextcalle
		
	
	BEGIN;
	
		IF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior = ciudad_imp_var) THEN

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

			LET contador_aux = contador_aux + 1;
			
		ELIF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior != ciudad_imp_var) THEN

			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		ELSE
		
			LET centro_impanterior = centro_imp_var;
			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		END IF;
	COMMIT;

	END FOREACH; 
	
	
	-- FUNCIONALIDAD PARA CUENTAS QUE TIENEN CIUDAD EN SI_DIRECCIONES_ACTUAL, PERO SIN CENTRO EN SI_CATZONAS  ******************************
	CREATE TEMP TABLE ctaspp_x_cd(
	fecha_emision	DATE,
	num_credito		CHAR(20),
	numcte			CHAR(20),
	centro			INTEGER,
	numerociudad	SMALLINT,
	numerocalle		INTEGER,
	numeroextcalle	CHAR(10));
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte
	INTO vFechaEmision, vNumCredito, VNumCte
	FROM "informix".sd_encabezado_edoctacrd 
	WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy and num_credito NOT IN('6300100','6400100','7600100','7700100','6800100','9100100','9300100')
	AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND ec_edocta IS NULL
	
	--UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE fecha_emision = vFechaEmision AND num_credito = vNumCredito ;
	
	LET v_centro 			= 999999;
	LET v_jefegrupozona 	= 00000000;
	LET v_supervisorzona 	= 00000000;
	LET v_numerocolonia 	= 0000;
	LET cNumCiudadBanco	= '0000';
	LET contador_ec		= 0;
	LET contador_aux	= 0;
	LET ciudad_imp_var	= '0';
	LET ciudad_impanterior = '';
	LET centro_impanterior 	= "";
	LET vNumCentroImpr	= '00';
	LET v_ruta	= '';
	
	-- SI_DIRECCIONES TIPO 1 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = VNumCte AND tipo_dir = "1";
	
	IF v_tipo_dir = '1' THEN
	
		LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
						 LPAD(v_centro,6,'0')||"/"||
						 LPAD(v_jefegrupozona,8,'0')||"/"||
						 LPAD(v_supervisorzona,8,'0')||"/"||
						 LPAD(v_numerocolonia,4,'0')||"/"||
						 LPAD(v_numerocalle,6,'0')||"/"||
						 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') and num_credito = vNumCredito;
		COMMIT;
		
		SELECT LPAD(NVL(num_region,0),2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_coppel = v_numerociudad
		GROUP BY num_region;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudad,3,0)
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = vNumCredito;
		COMMIT;
		
		BEGIN;
			INSERT INTO ctaspp_x_cd (fecha_emision, num_credito, numcte, centro, numerociudad, numerocalle, numeroextcalle)
				VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro, v_numerociudad, v_numerocalle, v_numeroextcalle);
		COMMIT;
	
	END IF;	
	
	-- SI_DIRECCIONES TIPO 2 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = VNumCte AND tipo_dir = "2" ;
	
	IF v_tipo_dir = '2' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
	
		LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
							 LPAD(v_centro,6,'0')||"/"||
							 LPAD(v_jefegrupozona,8,'0')||"/"||
							 LPAD(v_supervisorzona,8,'0')||"/"||
							 LPAD(v_numerocolonia,4,'0')||"/"||
							 LPAD(v_numerocalle,6,'0')||"/"||
							 LPAD(TRIM(v_numeroextcalle),5,'0');
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') and num_credito = vNumCredito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_coppel = v_numerociudad
		GROUP BY num_region;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudad,3,0)
			WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
			AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = vNumCredito;
		COMMIT;
		
		BEGIN;
			INSERT INTO ctaspp_x_cd (fecha_emision, num_credito, numcte, centro, numerociudad, numerocalle, numeroextcalle)
				VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro, v_numerociudad, v_numerocalle, v_numeroextcalle);
		COMMIT;
	
	END IF;
	
	
	END FOREACH;
	
	---- FUNCIONALIDAD PARA GENERAR EC CONSECUTIVO
	
	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro, numerociudad INTO vNumCredito, vFechaEmision, v_centro, ciudad_imp_var FROM ctaspp_x_cd
		ORDER BY centro::INTEGER, numerociudad::INTEGER, numerocalle, numeroextcalle
		
	
	BEGIN;
	
		IF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior = ciudad_imp_var) THEN

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

			LET contador_aux = contador_aux + 1;
			
		ELIF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior != ciudad_imp_var) THEN

			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

		ELSE
		
			LET centro_impanterior = centro_imp_var;
			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

		END IF;
	COMMIT;

	END FOREACH; 
	
	
	---- FUNCIONALIDAD PARA COMPLEMENTAR CTAS SIN CIUDAD Y SIN CENTRO ******************************
	CREATE TEMP TABLE cred_sec_pp(
	fecha_emision	DATE,
	num_credito	CHAR(20),
	numcte		CHAR(20),
	centro	INTEGER);
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte, num_region, num_ciudad_banco, num_ciudad_coppel 
	INTO vFechaEmision, vNumCredito, VNumCte, cNumRegion, cNumCiudadBanco, cNumCiudadCoppel
	FROM "informix".sd_encabezado_edoctacrd 
	WHERE fecha_emision > vFechaAnt and fecha_emision <= vFechaHoy and num_credito NOT IN('6300100','6400100','7600100','7700100','6800100','9100100','9300100')
	AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND ec_edocta IS NULL
	
	--UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE num_credito = vNumCredito;
	
	LET v_numerociudadCoppel 	= '004';
	LET v_centro 				= 999999;
	LET v_jefegrupozona 		= 00000000;
	LET v_supervisorzona 		= 00000000;
	LET v_numerocoloniaCoppel 	= 0000;
	LET v_numerocalle			= 000000;
	LET v_numeroextcalle 		= '00000';
	LET contador_ec		= 0;
	LET contador_aux	= 0;
	LET cNumRegion		= '00';
	LET cNumCiudadBanco	= '0000';
	
	BEGIN;
	INSERT INTO cred_sec_pp (fecha_emision, num_credito, numcte, centro)
		VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro);
	COMMIT;
		
	LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
				 LPAD(v_centro,6,'0')||"/"||
				 LPAD(v_jefegrupozona,8,'0')||"/"||
				 LPAD(v_supervisorzona,8,'0')||"/"||
				 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
				 LPAD(v_numerocalle,6,'0')||"/"||
				 LPAD(TRIM(v_numeroextcalle),5,'0');
				 
	BEGIN;
		UPDATE "informix".sd_encabezado_edoctacrd 
		SET num_region = LPAD(cNumRegion,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
		WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy
		AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND num_credito = vNumCredito AND NVL(ruta,'') = '';
	COMMIT;
	
	BEGIN;
		UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'') WHERE fecha_emision > vFechaAnt AND fecha_emision <= vFechaHoy 
		AND num_producto IN('6300','6400','7600','7700','6800','9100','9300') AND ec_edocta is nulL AND num_credito = vNumCredito;
	COMMIT;
	
	END FOREACH;
	
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte INTO vFechaEmision, vNumCredito, VNumCte FROM cred_sec_pp 
	ORDER BY centro,fecha_emision,num_credito
	
	LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

			LET contador_aux = contador_aux + 1;
			
	END FOREACH;

	DROP TABLE IF EXISTS creditospp_ec;
	DROP TABLE IF EXISTS tmpNumeroRegistroscrd;
	DROP TABLE IF EXISTS cred_sec_pp;
	
	
	END;

	RETURN vCodRet;

END PROCEDURE;