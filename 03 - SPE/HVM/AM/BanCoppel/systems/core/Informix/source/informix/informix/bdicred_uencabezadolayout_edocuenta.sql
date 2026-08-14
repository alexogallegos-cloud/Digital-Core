CREATE PROCEDURE "informix".uencabezadolayout_edocuenta (
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)
RETURNING CHAR(5);

--DECLARACION DE VARIABLES



DEFINE cod_ret             char(5);
DEFINE sql_err             integer;

DEFINE v_numcte            char(20);
DEFINE v_num_tarjeta       char(20);
DEFINE v_cliente           char(150);
DEFINE v_calle_num         char(456);
DEFINE v_nombre_colonia    char(376);
DEFINE v_nombre_ciudad     char(376);
DEFINE v_estado_cp         char(376);
DEFINE v_nombre            char(40);
DEFINE v_gerente           char(40);
DEFINE v_telefono1         char(14);
DEFINE v_rfc               char(13);
DEFINE v_cl_cobra          char(51);
DEFINE v_cod_postal        char(5);
DEFINE v_ruta          	   char(47);
DEFINE v_entre_calles      char(40);
DEFINE v_observaciones     char(80);



DEFINE v_sucursal          char(4);
DEFINE v_secuencia		   integer;



--INICIALIZO VARIABLES

LET cod_ret = "000";

LET v_numcte        = "";
LET v_num_tarjeta   = "";
LET v_cliente       = "";
LET v_calle_num     = "";
LET v_nombre_colonia= "";
LET v_nombre_ciudad = "";
LET v_estado_cp     = "";
LET v_nombre        = "";
LET v_gerente       = "";
LET v_telefono1     = "";
LET v_rfc           = "";
LET v_cl_cobra      = "";
LET v_cod_postal    = "";
LET v_ruta           = "";
LET v_entre_calles   = "";
LET v_observaciones  = "";


LET v_sucursal      = "";
LET v_secuencia 	= 1;

--SET DEBUG FILE TO  'encabezadonuevo.out';
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;
	    RETURN cod_ret;
	END IF
   END EXCEPTION;


   LET cod_ret = "000";
   LET pempresa = pempresa;
   LET pnum_credito = pnum_credito;

    -------------------------------------------------------------
    --SE OBTIENEN LOS DATOS DEL CLIENTE Y SUCURSAL
    -------------------------------------------------------------

	select a.numcte,a. sucursal,b.num_tarjeta
        into v_numcte,v_sucursal,v_num_tarjeta
	from sd_maecred a, sd_tarjeta b
	where a.empresa = pempresa
	and a.num_credito = pnum_credito
	and a.num_credito = b.num_credito
	and b.tipo_tarjeta = "T" and status_tar = "A";

    IF v_numcte is NULL THEN  
    	--------------------------------------------------------
    	--TRAIGO LA ULTIMA TARJETA DEL CLIENTE
    	--------------------------------------------------------
		SELECT MAX(secuencia)
		INTO v_secuencia
		FROM sd_tarjeta
			WHERE empresa = pempresa
			AND num_credito = pnum_credito
			AND tipo_tarjeta="T";
    	--------------------------------------------------------
    	--TRAIGO LOS DATOS DEL CLIENTE Y SUCURSAL:
    	--------------------------------------------------------
	  	SELECT a.numcte,a.sucursal,b.num_tarjeta
	  	INTO   v_numcte,v_sucursal,v_num_tarjeta
	  	FROM sd_maecred a INNER JOIN sd_tarjeta b
			ON a.empresa =  b.empresa
			AND a.num_credito = b.num_credito
	 	 WHERE a.empresa = pempresa
		    AND a.num_credito = pnum_credito
		    AND b.tipo_tarjeta="T"
		    AND b.secuencia = v_secuencia; 
    END IF
    --------------------------------------------------------
    --TRAIGO LS ULTIMA DIRECCION DEL CLIENTE:
    --------------------------------------------------------
	SELECT MAX(secuencia)
		INTO v_secuencia
	FROM bdinteg:si_direcciones
		WHERE numcte = v_numcte
		AND tipo_dir="1";
    --------------------------------------------------------
    --OBTENGO LOS DATOS GENERALES DEL CLIENTE:
    --------------------------------------------------------
	SELECT Trim(a.nombre1) || " " ||
		   Trim(a.nombre2) || " " ||
		   Trim(a.apell_paterno) || " " ||
		   Trim(a.apell_materno),
		   Trim(c.nombrecalle) || " " ||
		   Trim(b.numeroextcalle) || " " ||
		   Trim(b.numerointcalle),
	       d.nombrezona,
	       e.nombreciudad,
	       f.nombre,
	       a.rfc,
	       b.cod_postal,
	       b.secuencia,
	       b.entre_calles,
	       b.observaciones,
		   LPAD(b.numerociudad,4,'0')||"/"||
		   LPAD(d.centro,6,'0')||"/"||
		   LPAD(d.jefegrupozona,8,'0')||"/"||
		   LPAD(d.supervisorzona,8,'0')||"/"||
		   LPAD(b.numerocolonia,4,'0')||"/"||
		   LPAD(b.numerocalle,6,'0')||"/"||
		   LPAD(TRIM(b.numeroextcalle),5,'0')
	INTO   v_cliente,
		   v_calle_num,
		   v_nombre_colonia,
		   v_nombre_ciudad,
		   v_estado_cp,
		   v_rfc,
		   v_cod_postal,
		   v_secuencia,
		   v_entre_calles,
		   v_observaciones,
		   v_ruta
	FROM bdinteg:si_cliente a
		LEFT JOIN bdinteg:si_direcciones b
			ON a.numcte = b.numcte
		LEFT JOIN bdinteg:si_catcalles c
			ON b.numerocalle = c.numerocalle
		LEFT JOIN bdinteg:si_catzonas d
			ON  b.numerociudad = d.numerociudad
			AND b.numerocolonia = d.numerocolonia
		LEFT JOIN bdinteg:si_catciudades e
			ON  b.numerociudad = e.numerociudad
		LEFT JOIN bdinteg:si_estados f
			ON b.estado      = f.estado
	WHERE  a.numcte      = v_numcte
			AND b.secuencia = v_secuencia;
    --------------------------------------------------------
    --VALIDO LA GENERACION DE LA CLAVE RUTA
    --------------------------------------------------------
	IF v_ruta = "" OR v_ruta IS NULL THEN
		IF cod_ret = "000" THEN
	    	LET cod_ret = '231';
	    END IF
	END IF
    --------------------------------------------------------
    --OBTENGO LOS DATOS GENERALES DE LA SUCURSAL:
    --------------------------------------------------------
	SELECT d.nombre,d.gerente,d.telefono1
		INTO v_nombre,v_gerente,v_telefono1
	FROM bdinteg:si_sucursales d
		WHERE d.sucursal    = v_sucursal
		AND   d.empresa = pempresa;
    --------------------------------------------------------
    --EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA
    --------------------------------------------------------
	LET v_cl_cobra = "";
	EXECUTE PROCEDURE cobranza(pempresa,Trim(pnum_credito),pfechahoy)
		INTO cod_ret,v_cl_cobra;
    --------------------------------------------------------
    --VERIFICO QUE TODOS LOS CAMPOS CONTENGAN INFORMACION CONDICION
    --------------------------------------------------------
	IF 	NOT (v_numcte      	IS NOT NULL  AND v_num_tarjeta  	IS NOT NULL
		AND v_calle_num   	IS NOT NULL  AND v_nombre_colonia 	IS NOT NULL
		AND v_nombre_ciudad IS NOT NULL  AND v_estado_cp     	IS NOT NULL
		AND v_nombre        IS NOT NULL  AND v_gerente       	IS NOT NULL
		AND v_telefono1     IS NOT NULL  AND v_cod_postal       IS NOT NULL
		AND pnum_credito    IS NOT NULL)  THEN

		IF cod_ret = "000" THEN
	    	LET cod_ret = "230";
	    END IF

	END IF;

    --------------------------------------------------------
    --GENERO EL ENCABEZADO DEL ESTAOD DE CUENTA
    --------------------------------------------------------
     INSERT INTO sd_encabezado_edocta
     				(
     				fecha_emision,num_credito,numcte,
     				num_tarjeta,nombre_cte,direccion_cn,
				    direccion_col,direccion_del,edo_cd,
			        sucursal_nombre,sucursal_gerente,sucursal_tel,
				    fecha_corte,rfc,cl_cobra,
				    CP,ruta,entre_calles,
				    observaciones
				    )
	  		 VALUES(
	  		       	pfechahoy,NVL(Trim(pnum_credito),''),NVL(Trim(v_numcte),''),
	  		       	NVL(Trim(v_num_tarjeta),''),NVL(Trim(v_cliente),''),NVL(Trim(v_calle_num),''),
				    NVL(Trim(v_nombre_colonia),''),NVL(Trim(v_nombre_ciudad),''),NVL(Trim(v_estado_cp),''),
				    NVL(Trim(v_nombre),''),NVL(Trim(v_gerente),''),NVL(Trim(v_telefono1),''),
				    pfechahoy,Trim(v_rfc),Trim(v_cl_cobra),
				    Trim(v_cod_postal),TRIM(v_ruta),TRIM(v_entre_calles),
				    TRIM(v_observaciones)
				    );





  END;

  RETURN cod_ret;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".arr_edocta(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE vMinimo DECIMAL(14,2);
DEFINE vMinAnt DECIMAL(14,2);
DEFINE vCred   CHAR(20);
DEFINE vVigente DECIMAL(14,2);
DEFINE vVencido DECIMAL(14,2);
DEFINE vInsoluto DECIMAL(14,2);
DEFINE vclcobra CHAR(51);
DEFINE vcodret CHAR(3);

LET vcodret = "000";

FOREACH SELECT a.num_credito, sdo_capital + cap_tras_no_venci,
	       monto_vencido + mto_venc_trasp, sdo_cap_insoluto
	  INTO vCred, vVigente, Vvencido, vInsoluto
	  FROM sd_maecred a, sd_maesdos b
	 WHERE a.num_credito = b.num_credito
	   AND a.empresa = b.empresa
	   AND NOT a.id_unidad_prod IS NULL

	SELECT sdo_trab4 INTO vMinAnt
	  FROM sd_maesdoshist
	 WHERE fecha = "12/20/2007"
	   AND empresa = eEmpresa
	   AND num_credito = vCred;

	LET vMinimo = ROUND(((vVigente / 10) + vVencido),0);

	IF vMinimo < vMinAnt THEN
		LET vMinimo = vMinAnt;
	END IF

	IF vInsoluto < vMinimo THEN
		LET vMinimo = vInsoluto;
	END IF

	UPDATE sd_maesdoshist
	   SET monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE fecha = "12/20/2007"
	   AND empresa = eEmpresa
	   AND num_credito = vCred;

	UPDATE sd_maesdos
	   SET monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE num_credito = vCred
	   AND empresa = eEmpresa;


	UPDATE sd_encabezado2_edocta
	   SET sdo_pagar = vMinimo
	 WHERE fecha_emision = "12/20/2007"
	   AND num_credito = vCred;



END FOREACH

LET vCred = " ";

FOREACH  SELECT num_credito INTO vCred
	   FROM sd_encabezado_edocta
	 WHERE fecha_emision = "12/20/2007"

         LET vclcobra = "";
         EXECUTE PROCEDURE cobranza(eEmpresa,vCred,"12/20/2007")
                 INTO vcodret,vclcobra;

	 UPDATE sd_encabezado_edocta
	   SET cl_cobra = vclcobra
	 WHERE num_credito = vCred
         AND   fecha_emision = "12/20/2007";
END FOREACH
RETURN vcodret;
END PROCEDURE;