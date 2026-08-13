CREATE PROCEDURE "informix".sp_cons_estados_ciudades_iccat(pnumest char(2), pNumRegistros SMALLINT)
RETURNING char(9),char(2),char(30), char(3), char(60);   

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info char(60); 
DEFINE isql_err integer;
DEFINE cnum_estado char(2);
DEFINE cdesc_estado char(30);
DEFINE cnum_ciudad char(3);
DEFINE cdesc_ciudad char(60);


LET ccodret = "000000001"; -- No existe informacion
LET error_info = ""; 
LET cnum_estado = "";
LET cdesc_estado = "";
LET cnum_ciudad = "";
LET cdesc_ciudad = "";
LET isam_err = 0;
LET isql_err = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info 
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cdesc_ciudad = error_info;
			RETURN ccodret, cnum_estado,cdesc_estado,cnum_ciudad,cdesc_ciudad;
		END IF;
	END EXCEPTION;
   	
	--SET DEBUG FILE TO '/tmp/JoseLuisPolanco/sp_cons_estados_ciudades_iccat.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;

	IF (TRIM(NVL(pnumest,'')) = '') THEN 
		--regresa todos los estados
		FOREACH
			SELECT SKIP pNumRegistros FIRST 50 estado,nombre 
				INTO cnum_estado,cdesc_estado
			FROM "informix".si_estados 
			ORDER BY nombre ASC

			LET ccodret = "000000000";

			RETURN ccodret, cnum_estado,cdesc_estado,cnum_ciudad,cdesc_ciudad WITH RESUME;
		END FOREACH;
		IF pNumRegistros <> 0 AND cdesc_estado = '' THEN
			LET ccodret = "999999999"; --termino de realizar busquedas paginadas
		END IF;
	ELSE 
		--regresa las ciudades del estado de interes
		FOREACH
			SELECT SKIP pNumRegistros FIRST 50 est.estado,est.nombre,ciu.ciudad,ciu.nombre 
				INTO cnum_estado,cdesc_estado,cnum_ciudad,cdesc_ciudad
			FROM "informix".si_estados AS est 
				INNER JOIN "informix".si_ciudades AS ciu
					ON(ciu.pais = est.pais 
						AND est.estado = ciu.estado) 
					WHERE est.estado = pnumest 
					ORDER BY ciu.nombre ASC

			LET ccodret = "000000000";

			RETURN ccodret, cnum_estado,cdesc_estado,cnum_ciudad,cdesc_ciudad WITH RESUME;
		END FOREACH;
		IF pNumRegistros <> 0 AND cdesc_ciudad = '' THEN
			LET ccodret = "999999999"; --termino de realizar busquedas paginadas
		END IF;
	END IF;

	IF (ccodret <> '000000000') THEN
		RETURN ccodret, cnum_estado,cdesc_estado,cnum_ciudad,cdesc_ciudad;
	END IF;
		
END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar los estados o las ciudades del estado de interes',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/08/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		bdinteg';

CREATE PROCEDURE "informix".sp_obt_direcciones_sucursales(pNumTarj char(16), pNumEst char(2),pNumCiu char(3), pBusc char(40),pNumRegistros SMALLINT)
   RETURNING char(9), char(4), char(40), char(30), char(60), char(100), char(6), char(100), char(5), char(14);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************

	DEFINE cod_ret char(9);
	DEFINE isam_err integer;
	DEFINE error_info char(40);
	DEFINE sql_err integer;
	DEFINE cnum_sucursal char(4);
	DEFINE cnom_sucursal char(40);
	DEFINE cciudad char(30);
	DEFINE cestado char(60);
	DEFINE calle char(100);
	DEFINE cnum char(6);
	DEFINE ccolonia char(100);
	DEFINE ccp char(5);
	DEFINE telefono char(14);
	DEFINE cSucursal integer;
	DEFINE cloccp CHAR(5);
	DEFINE cloccol CHAR(8);
	DEFINE clocestados CHAR(5);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************

   	LET cod_ret  = '000000001'; --No existe direccion origen
	LET cnum_sucursal = '';
	LET cnom_sucursal = '';
	LET cciudad = '';
	LET cestado = '';
	LET calle = '';
	LET cnum = '';
	LET ccolonia = '';
	LET ccp = '';
	LET telefono = '';
	LET isam_err = 0; 
	LET error_info = '';
	LET cloccp='' ;
	LET cloccol='' ;
	LET clocestados='' ;
	LET cSucursal = '';
	
BEGIN

   ON EXCEPTION SET sql_err, isam_err, error_info 
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
			LET cnom_sucursal = error_info;
            RETURN cod_ret,cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,ccolonia,ccp,telefono;
      END IF ;
   END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET lock mode to wait 3;

    --SET DEBUG FILE TO '/tmp/JoseLuisPolanco/sp_obt_direcciones_sucursales.out';
	--TRACE ON;
	
    --Se formatean los parametros
    IF NVL(pNumCiu,'') = '' THEN
    	LET pNumCiu = '%';
    END IF;
    
    LET pNumTarj = NVL(pNumTarj,'');
    LET pNumEst = NVL(pNumEst,'');
    LET pBusc = NVL(pBusc,'');
    IF pNumTarj <> '' THEN	--Se busca domicilio de la sucursal origen
		SELECT FIRST 1 clave_sucursal
		INTO cSucursal
		FROM intercard:"informix".detalle_maquila
		WHERE numtarjeta = pNumTarj;
		
	    FOREACH
			SELECT FIRST 1 suc.sucursal,suc.nombre,ciu.nombre,est.nombre,ptf.calle,ptf.num_ext,suc.telefono1,ptf.cp,ptf.cve_col,ptf.cve_estado
			INTO cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,telefono,cloccp,cloccol,clocestados
			FROM "informix".si_sucursales AS suc 
				INNER JOIN "informix".si_ptf AS ptf 
					ON (suc.sucursal = ptf.id_ptf AND ptf.cve_pais = suc.pais AND ptf.tipo='S')
				INNER JOIN "informix".si_estados AS est 
					ON(est.pais = suc.pais AND est.estado = suc.estado)
				INNER JOIN "informix".si_ciudades AS ciu 
					ON(ciu.pais = est.pais AND ciu.estado = est.estado AND ciu.ciudad = suc.ciudad)
				WHERE suc.sucursal = cSucursal
			
			SELECT {+INDEX (bdinteg:si_localidades idx_silocalidades)}
			FIRST 1 desc_colonia,cp 
			INTO ccolonia,ccp
			FROM "informix".si_localidades
			WHERE cp = cloccp AND cve_estado = clocestados AND cve_col = cloccol;
			
			IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
				LET cod_ret = "000000000"; --Ejecucion exitosa
				RETURN cod_ret,cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,ccolonia,ccp,telefono WITH RESUME;
			END IF;
			
		END FOREACH;
	ELSE	--se busca domicilio de la sucursal segun los criterios enviados
		LET pBusc = TRIM(pBusc);
		FOREACH
			SELECT SKIP pNumRegistros FIRST 50 suc.sucursal,suc.nombre,ciu.nombre,est.nombre,ptf.calle,ptf.num_ext,suc.telefono1,ptf.cp,ptf.cve_col,ptf.cve_estado
			INTO cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,telefono,cloccp,cloccol,clocestados
			FROM "informix".si_sucursales AS suc 
				INNER JOIN "informix".si_ptf AS ptf ON (suc.sucursal = ptf.id_ptf AND ptf.cve_pais = suc.pais AND ptf.tipo='S')
				INNER JOIN "informix".si_localidades AS loc ON (loc.cve_col = ptf.cve_col AND loc.cve_estado = ptf.cve_estado AND loc.cp = ptf.cp)
				INNER JOIN "informix".si_estados AS est ON(est.pais = suc.pais AND est.estado = suc.estado)
				INNER JOIN "informix".si_ciudades AS ciu ON(ciu.pais = est.pais AND ciu.estado = est.estado AND ciu.ciudad = suc.ciudad)
				WHERE (pNumEst <> '' AND suc.estado LIKE pNumEst AND suc.ciudad LIKE pNumCiu )
				OR (pNumEst = '' AND (
					UPPER(TRIM(suc.nombre)) LIKE pBusc
					))	
				ORDER BY suc.sucursal ASC

			SELECT {+INDEX (bdinteg:si_localidades idx_silocalidades)}
			FIRST 1 desc_colonia,cp 
			INTO ccolonia,ccp
			FROM "informix".si_localidades
			WHERE cp = cloccp AND cve_estado = clocestados AND cve_col = cloccol;

			IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
				LET cod_ret = "000000000"; --Ejecucion exitosa
				RETURN cod_ret,cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,ccolonia,ccp,telefono WITH RESUME;
			END IF;

		END FOREACH;
		--Se verifica si se llego al limite de los registros
		IF pNumRegistros<>0 AND cnum_sucursal='' AND cestado='' THEN
			LET cod_ret = "999999999"; --termino de realizar busquedas paginadas
		END IF;
	END IF;
	IF (pNumTarj ='' AND cod_ret = '000000001') THEN
		LET cod_ret = "000000002"; --No existen direcciones
	END IF;
	IF cod_ret <> '000000000' THEN
		RETURN cod_ret,cnum_sucursal,cnom_sucursal,cciudad,cestado,calle,cnum,ccolonia,ccp,telefono;
	END IF;
END

END PROCEDURE
DOCUMENT
'Folio: 451.1 - RQM 10 802 - Cancelación de Tarjetas Débito y Crédito Clásica, Oro y Platino a través del CAT.',
'Autor: Arturo Astorga',
'BD: bdinteg',
'Fecha: 15/08/2018',
'Solicitó: jose luis polanco',
'Descripcion: Obtiene la direccion de las sucursales segun el tipo de busqueda.';

CREATE PROCEDURE "informix".sp_depura_tabla_sw_detallemonitorps() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/sp_depura_tabla_sw_detallemonitorps.out";
		--TRACE ON;
	
	
	SELECT COUNT(*) INTO nContador FROM "informix".sw_detallemonitorps;
	
	IF nContador <> 0 THEN 
	
	TRUNCATE TABLE "informix".sw_detallemonitorps;
	
	LET vCodRet ='00000';
	
	
	
		
	END IF;
	return vCodRet;
END;
END PROCEDURE ;