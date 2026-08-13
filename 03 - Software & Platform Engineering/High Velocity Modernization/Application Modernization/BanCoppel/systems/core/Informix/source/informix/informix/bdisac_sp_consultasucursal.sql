CREATE PROCEDURE "informix".sp_consultasucursal(vnumsucursal CHAR (4))
             RETURNING CHAR(5), CHAR(3), CHAR(15), CHAR(15), CHAR(3), CHAR (3);
	--************************************************************--
	--**	Elaboró: F.R.G.                                     **--
	--**	Actividad: Consulta Parámetros de bdisac:sac_param  **--
	--**	Solicito: Código Test                               **--
	--**	Fecha: 03/12/10                                     **--
	--**    Detalle: Este SP hace una consulta a la tabla de    **--
	--**             parametros bdisac:sac_param                **--
	--**             Para obtener los datos parametrizados de   **--
	--**             los mensajes QRYI, PAYI y REVI que viajan  **--
	--**             de BCP a BTS.                              **--
	--**             Si algún parámetro es incorrecto o no      **--
	--**             encontrado en la consulta, manda un código **--
	--**             de error = 99999.                          **--
        --**                                                        **--
	--**                                                        **--
	--************************************************************--
	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE agcode		        CHAR(3);
	DEFINE region_sd	        CHAR(15);
	DEFINE branch_sd		CHAR(15);
	DEFINE cod_estado	        CHAR(3);
	DEFINE country_cd	        CHAR(3);
	DEFINE estado_bdi               CHAR(2);

	DEFINE numerosucursal		CHAR(4);

	DEFINE vparametro1		CHAR(5);
	DEFINE vparametro4		CHAR(5);

	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);		

	LET cod_err			= "00000";
	LET vparametro1                 = 87005;
	LET vparametro4                 = 87008;

	LET numerosucursal              = TRIM (vnumsucursal);
	LET branch_sd	                = TRIM (vnumsucursal);
    LET region_sd= '001'; -- FIJO. JGP / 01/07/2011
	
	LET agcode = '';
	LET cod_estado = '';
	LET country_cd = '';
	LET estado_bdi = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';	

--------------------------------------------------------------------------
--	SET DEBUG FILE TO "/ids10_1uc5/tmp/bts/sp_consultasucursal.out";
--	TRACE ON;
--------------------------------------------------------------------------

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
	    RETURN cod_err, agcode, region_sd, branch_sd, cod_estado, country_cd;
      END IF;
END EXCEPTION;


    SELECT valor
	INTO agcode
    FROM BDISAC:sac_param
    WHERE
    	cod_param = vparametro1;
		
		/*optimizacion solicitada para vobo de base de datos*/
		LET agcode = trim(agcode);
		/*fin de optimizacion*/

    IF agcode is null
    	THEN
        	LET cod_err = '99999';
    END IF;

--    SELECT 	a.plaza  
--	INTO region_sd	--	, branch_sd
 --   FROM
 --   	bdinteg:si_sucursales a,
--    	bdinteg:si_plazas b
--    WHERE
--    	a.sucursal = vnumsucursal and
--    	a.plaza = b.plaza;



    IF region_sd is null
    	THEN
        	LET cod_err = '99999';
    END IF;

    IF branch_sd is null
    	THEN
        	LET cod_err = '99999';
    END IF;

---       +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++       ---

    SELECT valor
	INTO country_cd
    FROM BDISAC:sac_param
    WHERE cod_param = vparametro4;
	
	/*optimizacion solicitada para vobo de base de datos*/
		LET country_cd = trim(country_cd);
	/*fin de optimizacion*/

    IF country_cd is null
    	THEN
        	LET cod_err = '99999';
    END IF;
	/*
	SELECT estado
	INTO estado_bdi
	FROM bdinteg:si_sucursales
	where
	sucursal = numerosucursal;
	*/
	execute procedure bdisac:"informix".sp_sac_consucursales(TRIM(numerosucursal)) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
	IF cSPCodRet <> '00000' THEN
		LET cod_err = '99999';
		RETURN cod_err, agcode, region_sd, branch_sd, cod_estado, country_cd;
	ELSE
		LET estado_bdi = ccve_estado;
	END IF;

	IF estado_bdi is null
    		THEN
        	LET cod_err = '99999';
        END IF;


    SELECT state_cd
	INTO cod_estado
    FROM bdisac:sac_bts_catestados
    WHERE
    	cve_estado = estado_bdi;

    	IF cod_estado is null
    		THEN
        	LET cod_err = '99999';
    	END IF;

    	RETURN cod_err, agcode, region_sd, branch_sd, cod_estado, country_cd;
   END;
END PROCEDURE;