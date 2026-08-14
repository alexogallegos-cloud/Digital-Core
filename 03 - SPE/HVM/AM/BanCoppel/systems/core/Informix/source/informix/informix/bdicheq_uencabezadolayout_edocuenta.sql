CREATE PROCEDURE "informix".uencabezadolayout_edocuenta (pempresa char(3),pnum_credito char(20))
RETURNING CHAR(3);

--DECLARACION DE VARIABLES

DEFINE v_fechahoy      date;
DEFINE v_id_registro       char(3);
DEFINE v_marca		   char(3);
DEFINE v_fecha_corte       char(15);

DEFINE v_numcte            char(20);
DEFINE v_nombre1           char(26);
DEFINE v_nombre2           char(26);
DEFINE v_apell_paterno     char(26);
DEFINE v_apell_materno     char(26);
DEFINE v_calle             char(40);
DEFINE v_colonia           char(60);
DEFINE v_municipio         char(5);
DEFINE v_estado            char(2);
DEFINE v_cod_postal        char(5);
DEFINE v_num_tarjeta       char(20);
DEFINE v_num_credito       char(20);
DEFINE v_nombre            char(40);
DEFINE v_gerente           char(40);
DEFINE v_telefono1         char(14);
DEFINE v_numero_ext        char(10);
DEFINE v_numero_int        char(10);
DEFINE v_rfc               char(13);
DEFINE v_nombre_calle      char(456);
DEFINE v_nombre_colonia    char(376);
DEFINE v_nombre_ciudad     char(376);


DEFINE v_maecredito        char(20);
DEFINE v_maecliente        char(20);
DEFINE v_sucursal          char(4);
DEFINE v_ruta          	   char(30);


DEFINE v_estado_cp         char(376);
DEFINE v_calle_num         char(456);
DEFINE v_cl_cobra          char(36);
DEFINE v_cliente           char(150); 

DEFINE v_dia_corte	   smallint;   
DEFINE v_mes           	   char(5);
DEFINE v_ano               char(5);
DEFINE cod_ret             char(3);
DEFINE sql_err             integer;

--INICIALIZO VARIABLES

LET v_nombre1       = "";
LET v_nombre2       = "";
LET v_apell_paterno = "";
LET v_apell_materno = "";
LET v_calle         = "";
LET v_colonia       = "";
LET v_municipio     = "";
LET v_estado        = "";
LET v_cod_postal    = "";
LET v_numcte        = "";
LET v_nombre        = "";
LET v_gerente       = "";
LET v_telefono1     = "";
LET v_num_tarjeta   = "";
LET v_num_credito   = "";
LET v_maecredito    = "";
LET v_maecliente    = "";
LET v_sucursal      = "";
LET v_fecha_corte   = "";
LET v_nombre_calle  = "";
LET v_nombre_colonia= "";
LET v_nombre_ciudad = "";
LET v_estado_cp     = "";
LET v_numero_ext    = "";
LET v_numero_int    = "";
LET v_calle_num     = "";
LET v_id_registro   = "";
LET v_marca         = "";
LET v_cliente       = ""; 
LET v_rfc           = "";
LET v_cl_cobra      = "";
LET v_mes           = 0;
LET v_ano           = 0;
LET v_ruta           = "";



BEGIN


  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;
	    RETURN cod_ret;
	END IF
   END EXCEPTION;

   LET cod_ret = "000";

  -------------------OBTENGO LA FECHA DE PROCESO-------------------------------------------------------------------

  SELECT FIRST 1 '04/20/2007' INTO v_fechahoy FROM sd_fechas;

  -------------------OBTIENE LA CLAVE DE DISTRIBUCION DE COBRANZA--------------------
	SELECT 	LPAD(a.numerociudad,4,'0')||
			LPAD(b.centro,6,'0')||
			LPAD(b.jefegrupozona,8,'0')||
			LPAD(b.supervisorzona,8,'0')|| 
			LPAD(a.numerocolonia,4,'0')
	INTO v_ruta
	FROM bdinteg:si_direcciones a
	    INNER JOIN bdinteg:si_catzonas b 
	        ON a.numerociudad = b.numerociudad 
	            AND a.numerocolonia = b.numerocolonia
	            WHERE a.numcte = pnum_credito  
                AND a.secuencia =( SELECT MAX(secuencia) 
                	FROM bdinteg:si_direcciones  WHERE numcte = pnum_credito);


	IF v_ruta = "" OR v_ruta IS NULL THEN
	    RETURN '231';
	END IF

  -------------------SE GENERA UNA LINEA PARA QUE ESTA POSTERIORMENTE SEA EL ARCHIVO DE CABECERA--------------------

  LET v_id_registro = "000";
  LET v_marca       = "0";


  IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_id_registro) THEN
		     INSERT INTO sd_encabezado_edocta(
		     				fecha_emision,      
		     				num_credito,       
		     				numcte,               
		     				num_tarjeta, 
						    nombre_cte,         
						    direccion_cn,      
						    direccion_col,        
						    direccion_del, 
					        edo_cd,             
					        sucursal_nombre,   
					        sucursal_gerente,     
					        sucursal_tel,
						    fecha_corte,        
						    rfc,               
						    cl_cobra,             
						    CP)
		  		       VALUES(
		  		       		v_fechahoy,         
		  		       		v_id_registro,     
		  		       		v_marca,              
		  		       		"0","0","0","0",
		  		       		"0","0","0","0",                  
		  		       		"0",v_fechahoy,"0","0",
		  		       		"0");
  END IF

  -------------------CONTROL DEL ARCHIVO-------------------------------------------------------------------------

  LET v_id_registro = "100";
  LET v_marca       = "0";

  IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_id_registro AND numcte = v_marca) THEN
		     INSERT INTO sd_encabezado_edocta(
		     				fecha_emision,      
		     				num_credito,       
		     				numcte,               
		     				num_tarjeta, 
						    nombre_cte,         
						    direccion_cn,      
						    direccion_col,        
						    direccion_del, 
					        edo_cd,             
					        sucursal_nombre,   
					        sucursal_gerente,     
					        sucursal_tel,
						    fecha_corte,        
						    rfc,               
						    cl_cobra,             
						    CP,
						    ruta)
			  		     VALUES(
			  		       	v_fechahoy,         
			  		       	v_id_registro,     
			  		       	v_marca,              
			  		       	"0", "0","0","0",                  
			  		       	"0", "0","0","0",                  
			  		       	"0",v_fechahoy,"0","0",
			  		       	"0",v_ruta);
  END IF



  ----------------------------------TRAIGO LOS DATOS DEL CLIENTE Y SUCURSAL:------------------------------------

  FOREACH SELECT num_credito,numcte,sucursal 
	    	INTO v_maecredito,v_maecliente, v_sucursal 
	      	FROM sd_maecredcont 
			WHERE empresa = pempresa AND 
				num_credito = pnum_credito AND 
				fecha = '04/30/2007'

	-----------------------OBTENGO LOS DATOS GENERALES DEL CLIENTE:-------------------------------------


	SELECT a.numcte,         a.nombre1,     a.nombre2,       a.apell_paterno, 
	       a.apell_materno,  b.numerocalle, b.numerocolonia, b.numerociudad,  
	       b.estado,         b.cod_postal,  c.num_tarjeta,   c.num_credito,   
	       d.nombre,         d.gerente,     d.telefono1,     b.numeroextcalle,
	       b.numerointcalle, a.rfc,		e.nombre,	 f.nombrecalle, 
	       g.nombrezona,	 h.nombreciudad
	INTO   v_numcte,         v_nombre1,     v_nombre2,       v_apell_paterno, 
	       v_apell_materno,  v_calle,       v_colonia,       v_municipio,
	       v_estado,         v_cod_postal,  v_num_tarjeta,   v_num_credito,   
	       v_nombre,         v_gerente,     v_telefono1,     v_numero_ext,
	       v_numero_int,     v_rfc,		v_estado_cp, v_nombre_calle, 
 	       v_nombre_colonia, v_nombre_ciudad
	FROM   bdinteg:si_cliente a, bdinteg:si_direcciones b, 
	       sd_tarjeta c, bdinteg:si_sucursales d,
	       bdinteg:si_estados e, bdinteg:si_catcalles f,
	       bdinteg:si_catzonas g, bdinteg:si_catciudades h
	WHERE  a.numcte      = v_maecliente and 
	       b.numcte      = v_maecliente and 
	       c.num_credito = v_maecredito and 
	       d.sucursal    = v_sucursal   and
	       e.estado      = b.estado     and 
	       f.numerocalle = b.numerocalle and
	       (g.numerociudad = b.numerociudad and g.numerocolonia = b.numerocolonia) and
	       h.numerociudad = b.numerociudad and
	       b.secuencia   = '1';


	LET v_calle_num = Trim(v_nombre_calle) || " " || Trim(v_numero_ext) || " " || Trim(v_numero_int); 

	----------------------EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA:------------------------------------

	LET v_cl_cobra = "";

	EXECUTE PROCEDURE cobranza(Trim(v_maecredito)) INTO cod_ret,v_cl_cobra;
	IF cod_ret <> "000" THEN
	    RETURN cod_ret;
	END IF

	-----------------------VALIDO SI EXISTE EL REGISTRO DE SER ASI SE REPORCESA :---------------------------------------------------
--  	IF EXISTS(SELECT * FROM sd_encabezado_edocta 
--	   	WHERE fecha_emision = v_fechahoy AND num_credito = v_maecredito) THEN 
	   	DELETE FROM sd_encabezado_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_num_credito;
-- 	END IF


	-----------------------CALCULO LA FECHA DE CORTE:---------------------------------------------------

	SELECT dia_corte INTO   v_dia_corte 
		FROM sd_maecredanexo WHERE  num_credito = v_maecredito;

	SELECT MONTH(fecha_hoy), YEAR(fecha_hoy) INTO v_mes,v_ano
		FROM sd_fechas WHERE  empresa = pempresa;

	LET v_fecha_corte = Trim(v_mes) || "/" || v_dia_corte || "/" || Trim(v_ano);


	----------------------VERIFICO QUE TODOS LOS CAMPOS CONTENGAN INFORMACION CONDICION:---------------------
	
	IF v_numcte        IS NOT NULL  AND v_nombre_calle  IS NOT NULL  AND v_nombre_colonia IS NOT NULL AND 
	   v_nombre_ciudad IS NOT NULL  AND v_estado_cp     IS NOT NULL  AND v_cod_postal     IS NOT NULL AND 
	   v_num_tarjeta   IS NOT NULL  AND v_num_credito   IS NOT NULL  AND v_nombre         IS NOT NULL AND 
	   v_gerente       IS NOT NULL  AND v_telefono1     IS NOT NULL THEN
		 
	
		LET v_cliente = Trim(v_nombre1) || " " || Trim(v_nombre2) || " " || Trim(v_apell_paterno) || " " || Trim(v_apell_materno);
	
	     INSERT INTO sd_encabezado_edocta(
	     				fecha_emision,
	     				num_credito,
	     				numcte,
	     				num_tarjeta, 
					    nombre_cte,
					    direccion_cn,
					    direccion_col,
					    direccion_del,
				        edo_cd,
				        sucursal_nombre,
				        sucursal_gerente,
				        sucursal_tel,
					    fecha_corte,
					    rfc,
					    cl_cobra,
					    CP)
		  		 VALUES(
		  		       	v_fechahoy,
		  		       	Trim(v_num_credito),
		  		       	Trim(v_numcte),
		  		       	Trim(v_num_tarjeta),
					    Trim(v_cliente),
					    Trim(v_calle_num),
					    Trim(v_nombre_colonia),
					    Trim(v_nombre_ciudad),
					    Trim(v_estado_cp),
					    Trim(v_nombre),
					    Trim(v_gerente),
					    Trim(v_telefono1),
					    Trim(v_fecha_corte),
					    Trim(v_rfc),
					    Trim(v_cl_cobra),
					    Trim(v_cod_postal));

	ELSE

    	   LET cod_ret = "230";

	END IF;


  END FOREACH;

  END;

  RETURN cod_ret;
END PROCEDURE ;