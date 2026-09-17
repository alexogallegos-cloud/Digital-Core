CREATE PROCEDURE "informix".sp_consultaprodactdes(
psEmpresa CHAR(3),
psTipoBusqueda CHAR(1),
psCodigo CHAR(4)
)

RETURNING CHAR(5) AS codret, CHAR(4) AS producto, CHAR(60) AS descripcion, CHAR(2) AS sistema, CHAR(1) AS flagactdes;

--***********************************************************************************************************
-- DESCRIPCION: Consulta productos activos para sucursales por estado, division, region, sucursal por una o todas.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bdinteg
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE viDesactivadas		INTEGER;
DEFINE vsDescripcion		CHAR(40);
DEFINE vsFlagActDes			CHAR(1);
DEFINE vsProducto			CHAR(4);
DEFINE vsSistema			CHAR(2);
DEFINE vsSucursal			CHAR(4);

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET viDesactivadas		= 0;
LET vsDescripcion		= "";
LET vsFlagActDes		= "";
LET vsProducto			= "";
LET vsSistema			= "";
LET vsSucursal			= "";

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_consultaprodactdes.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF (viSqlErr <> 0) THEN
		RETURN viSqlErr, vsProducto, vsDescripcion, vsSistema, vsFlagActDes;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--Se realiza consulta por estado.
IF (psTipoBusqueda == "E") THEN --Consulta las sucursales por estado, obtiene la cantidad de sucursales del estado indicado.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(id_ptf)
	INTO viCantidadSuc 
	FROM bdinteg:"informix".si_ptf
	INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo 
	WHERE si_sucursales.empresa = psEmpresa 
	AND si_ptf.cve_estado = psCodigo 
	AND si_ptf.tipo <> 'C' 
	AND si_sucursales.tpo_sucursal = "S";
	/*SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S";*/
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, 
             bdinteg:"informix".si_estados AS siest
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer AND ptf.cve_estado = siest.estado
		AND ptf.cve_estado = psCodigo  
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo = sisuc.tipo
        AND ptf.tipo <> 'C'
        AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_estados AS siest
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer AND sisuc.estado = siest.estado
		AND sisuc.estado = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   si_ptf.id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf
			INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal  AND si_ptf.tipo = si_sucursales.tipo
			WHERE si_sucursales.empresa = psEmpresa AND si_ptf.cve_estado = psCodigo AND si_ptf.tipo <> 'C' AND si_sucursales.tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, 
             bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, 
             bdinteg:"informix".si_estados AS siest
		WHERE sddef.empresa = psEmpresa 
        AND sddef.empresa = sstram.empresa 
        AND sddef.num_producto = sstram.prod_ofrecer 
        AND ptf.cve_estado = siest.estado
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo <> 'C'
        AND ptf.tipo = sisuc.tipo
		AND ptf.cve_estado = psCodigo AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_estados AS siest
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa AND sddef.num_producto = sstram.prod_ofrecer AND sisuc.estado = siest.estado 
		AND sisuc.estado = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   si_ptf.id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf
			INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal  AND si_ptf.tipo = si_sucursales.tipo
			WHERE si_sucursales.empresa = psEmpresa AND si_ptf.cve_estado = psCodigo AND si_ptf.tipo <> 'C' AND si_sucursales.tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_estados siest
		WHERE svins.empresa = psEmpresa 
        AND svins.empresa = sstram.empresa 
        AND svins.cod_instrum = sstram.prod_ofrecer 
        AND ptf.cve_estado = siest.estado
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo = sisuc.tipo
        AND ptf.tipo <> 'C'
		AND ptf.cve_estado = psCodigo AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_estados siest
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer AND sisuc.estado = siest.estado
		AND sisuc.estado = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf
			INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal  AND si_ptf.tipo = si_sucursales.tipo
			WHERE si_sucursales.empresa = psEmpresa AND si_ptf.cve_estado = psCodigo AND si_ptf.tipo <> 'C' AND si_sucursales.tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
ELIF (psTipoBusqueda == "R") THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(ptf.id_ptf) 
	INTO viCantidadSuc 
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	bdinteg:"informix".si_ciudades AS siciu,
	bdinteg:"informix".si_catciudades AS sicat, 
	bdinteg:"informix".si_regiones AS sireg
		WHERE ptf.id_ptf = sisuc.sucursal
	    AND ptf.tipo = sisuc.tipo
	    AND ptf.tipo <> 'C'
	    AND sisuc.tpo_sucursal = "S"
	    AND ptf.cve_ciudad = siciu.ciudad 
	    AND ptf.cve_pais = siciu.pais 
	    AND ptf.cve_estado = siciu.estado
		AND siciu.ciudad_coppel = sicat.numerociudad 
	    AND sicat.numero_region = sireg.numero_region 
	    AND sireg.numero_region = psCodigo;
	/*SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
	WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo;*/
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
	        INTO vsProducto, vsDescripcion, vsSistema
	        FROM bdicheq:"informix".sc_producto AS scpro, 
	             bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
	             bdinteg:"informix".si_ptf AS ptf,
	             bdinteg:"informix".si_sucursales AS sisuc, 
	             bdinteg:"informix".si_ciudades AS siciu,
	             bdinteg:"informix".si_catciudades AS sicat, 
	             bdinteg:"informix".si_regiones AS sireg
	        WHERE scpro.empresa = psEmpresa
	        AND scpro.empresa = sstram.empresa 
	        AND scpro.producto = sstram.prod_ofrecer 
	        AND ptf.id_ptf = sisuc.sucursal
	        AND ptf.tipo = sisuc.tipo
	        AND ptf.tipo <> 'C'
	        AND sisuc.tpo_sucursal = 'S'
	        AND ptf.cve_ciudad = siciu.ciudad 
	        AND ptf.cve_pais = siciu.pais 
	        AND ptf.cve_estado = siciu.estado 
	        AND siciu.ciudad_coppel = sicat.numerociudad 
	        AND sicat.numero_region = sireg.numero_region 
	        AND sireg.numero_region = psCodigo
		/*SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
			 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer AND sisuc.tpo_sucursal = 'S'
		AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado AND siciu.ciudad_coppel = sicat.numerociudad 
		AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
               +INDEX(bdinteg:si_sucursales idx_sucursal)}
               id_ptf 
		INTO vsSucursal 
		    FROM bdinteg:"informix".si_ptf AS ptf,
		         bdinteg:"informix".si_sucursales AS sisuc, 
		         bdinteg:"informix".si_ciudades AS siciu, 
		         bdinteg:"informix".si_catciudades AS sicat, 
		         bdinteg:"informix".si_regiones AS sireg
		    WHERE ptf.id_ptf = sisuc.sucursal
		    AND ptf.tipo = sisuc.tipo
		    AND ptf.tipo <> 'C'
		    AND sisuc.tpo_sucursal = "S" 
		    AND ptf.cve_ciudad = siciu.ciudad 
		    AND ptf.cve_pais = siciu.pais
		    AND ptf.cve_estado = siciu.estado
		    AND siciu.ciudad_coppel = sicat.numerociudad 
		    AND sicat.numero_region = sireg.numero_region
		    AND sireg.numero_region = psCodigo
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
        INTO vsProducto, vsDescripcion, vsSistema
        FROM bdicred:"informix".sd_definicion AS sddef, 
             bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
             bdinteg:"informix".si_sucursales AS sisuc, 
             bdinteg:"informix".si_ciudades AS siciu,
             bdinteg:"informix".si_catciudades AS sicat, 
             bdinteg:"informix".si_regiones AS sireg
        WHERE sddef.empresa = psEmpresa 
        AND sddef.empresa = sstram.empresa 
        AND sddef.num_producto = sstram.prod_ofrecer 
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo = sisuc.tipo
        AND ptf.tipo <> 'C'
        AND sisuc.tpo_sucursal = 'S'
        AND ptf.cve_ciudad = siciu.ciudad 
        AND ptf.cve_pais = siciu.pais 
        AND ptf.cve_estado = siciu.estado 
        AND siciu.ciudad_coppel = sicat.numerociudad 
        AND sicat.numero_region = sireg.numero_region 
        AND sireg.numero_region = psCodigo
		/*SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
			 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa AND sddef.num_producto = sstram.prod_ofrecer AND sisuc.tpo_sucursal = 'S'
		AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado AND siciu.ciudad_coppel = sicat.numerociudad 
		AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   ptf.id_ptf 
			INTO vsSucursal 
			        FROM bdinteg:"informix".si_ptf AS ptf,
			             bdinteg:"informix".si_sucursales AS sisuc, 
			             bdinteg:"informix".si_ciudades AS siciu,
			             bdinteg:"informix".si_catciudades AS sicat, 
			             bdinteg:"informix".si_regiones AS sireg
			        WHERE ptf.id_ptf = sisuc.sucursal 
			        AND ptf.tipo = sisuc.tipo
			        AND ptf.tipo <> 'C'
			        AND sisuc.tpo_sucursal = "S" 
			        AND ptf.cve_ciudad = siciu.ciudad 
			        AND ptf.cve_pais = siciu.pais 
			        AND ptf.cve_estado = siciu.estado
			        AND siciu.ciudad_coppel = sicat.numerociudad 
			        AND sicat.numero_region = sireg.numero_region 
			        AND sireg.numero_region = psCodigo
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
			 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer
        AND ptf.id_ptf = sisuc.sucursal AND ptf.tipo = sisuc.tipo AND ptf.tipo <> 'C'
		AND ptf.cve_ciudad = siciu.ciudad AND ptf.cve_pais = siciu.pais AND ptf.cve_estado = siciu.estado AND siciu.ciudad_coppel = sicat.numerociudad 
		AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
			 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer 
		AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado AND siciu.ciudad_coppel = sicat.numerociudad 
		AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   id_ptf 
			INTO vsSucursal 
	        FROM si_ptf AS ptf,
	        	 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
	        	 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
	        WHERE ptf.id_ptf = sisuc.sucursal
	        AND ptf.tipo = sisuc.tipo
	        AND ptf.tipo <> 'C'
	        AND sisuc.tpo_sucursal = "S" 
	        AND ptf.cve_ciudad = siciu.ciudad 
	        AND ptf.cve_pais = siciu.pais 
	        AND ptf.cve_estado = siciu.estado
	        AND siciu.ciudad_coppel = sicat.numerociudad 
	        AND sicat.numero_region = sireg.numero_region 
	        AND sireg.numero_region = psCodigo
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
ELIF (psTipoBusqueda == "S") AND (psCodigo <> "") THEN --Consulta por sucursal individual.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer
		IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = psCodigo AND num_producto = vsProducto)THEN
			LET vsFlagActDes = "V";
		ELSE
			LET vsFlagActDes = "F";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa AND sddef.num_producto = sstram.prod_ofrecer
		IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = psCodigo AND num_producto = vsProducto)THEN
			LET vsFlagActDes = "V";
		ELSE
			LET vsFlagActDes = "F";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema 
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer
		IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = psCodigo AND num_producto = vsProducto)THEN
			LET vsFlagActDes = "V";
		ELSE
			LET vsFlagActDes = "F";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
	END FOREACH;
ELIF (psTipoBusqueda == "S") AND (psCodigo == "") THEN --Consulta todas las sucursales, Obtiene la cantidad total de sucursales tipo "S".
		SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer
		UNION 
		SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa AND sddef.num_producto = sstram.prod_ofrecer
		UNION
		SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer

		SELECT  count(ptf.id_ptf),
        SUM(CASE WHEN ptf.id_ptf = prod.sucursal THEN 1 ELSE 0 END),
        SUM(CASE WHEN prod.sucursal IS NULL THEN 1 ELSE 0 END)  desactivada
        INTO viCantidadSuc,viActivadas,viDesactivadas
        FROM bdinteg:"informix".si_ptf AS ptf,
             bdinteg:"informix".si_sucursales suc, 
             OUTER bdinteg:"informix".si_prod_sucursal prod 
        WHERE ptf.id_ptf = prod.sucursal
        AND ptf.id_ptf = suc.sucursal
        AND ptf.tipo = suc.tipo
        AND ptf.tipo <> 'C'
        AND suc.tpo_sucursal = 'S' 
        AND prod.num_producto = vsProducto;

		/*SELECT count(suc.sucursal),
		SUM(CASE WHEN suc.sucursal = prod.sucursal THEN 1 ELSE 0 END),
		SUM(CASE WHEN prod.sucursal IS NULL THEN 1 ELSE 0 END)  desactivada
		INTO viCantidadSuc,viActivadas,viDesactivadas
		FROM bdinteg:"informix".si_sucursales suc, OUTER bdinteg:"informix".si_prod_sucursal prod 
		WHERE suc.sucursal= prod.sucursal AND suc.tpo_sucursal = 'S' AND prod.num_producto = vsProducto;*/
	
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
	  
	RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
ELIF (psTipoBusqueda == "D") THEN --Consulta por division.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(ptf.id_ptf) 
	INTO viCantidadSuc 
	FROM si_ptf ptf
	     INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo
	WHERE suc.empresa = psEmpresa AND suc.plaza = psCodigo AND ptf.tipo <> 'C' AND suc.tpo_sucursal = "S";
	/*SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S";*/
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer 
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo = sisuc.tipo
        AND ptf.tipo <> 'C'
        AND sisuc.plaza = sipla.plaza
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(scpro.producto), scpro.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicheq:"informix".sc_producto AS scpro, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE scpro.empresa = psEmpresa AND scpro.empresa = sstram.empresa AND scpro.producto = sstram.prod_ofrecer AND sisuc.plaza = sipla.plaza
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   ptf.id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf ptf
			    INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo
			WHERE suc.empresa = psEmpresa AND suc.plaza = psCodigo AND suc.tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa 
        AND sddef.num_producto = sstram.prod_ofrecer 
        AND ptf.id_ptf = sisuc.sucursal
        AND ptf.tipo = sisuc.tipo
        AND sisuc.plaza = sipla.plaza 
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'
		
		/*SELECT DISTINCT(sddef.num_producto), sddef.nombre_prod, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdicred:"informix".sd_definicion AS sddef, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE sddef.empresa = psEmpresa AND sddef.empresa = sstram.empresa AND sddef.num_producto = sstram.prod_ofrecer AND sisuc.plaza = sipla.plaza 
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf 
			INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo AND si_ptf.tipo <> 'C'
			WHERE empresa = psEmpresa AND plaza = psCodigo  AND tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
             bdinteg:"informix".si_ptf AS ptf,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa 
        AND svins.cod_instrum = sstram.prod_ofrecer 
        AND ptf.id_ptf = sisuc.sucursal AND ptf.tipo = sisuc.tipo
        AND ptf.tipo <> 'C'
        AND sisuc.plaza = sipla.plaza
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'
		/*SELECT DISTINCT(svins.cod_instrum), svins.nombre, sstram.sistema
		INTO vsProducto, vsDescripcion, vsSistema
		FROM bdinvers:"informix".sv_instrum AS svins, bdisolic:"informix".ss_tramite_productos_clasif AS sstram,
			 bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_plazas AS sipla
		WHERE svins.empresa = psEmpresa AND svins.empresa = sstram.empresa AND svins.cod_instrum = sstram.prod_ofrecer AND sisuc.plaza = sipla.plaza
		AND sisuc.plaza = psCodigo AND sisuc.tpo_sucursal = 'S'*/
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                   +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   id_ptf 
			INTO vsSucursal 
			FROM bdinteg:"informix".si_ptf
			    INNER JOIN bdinteg:"informix".si_sucursales ON si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo AND si_ptf.tipo <> 'C' 
			WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"
			/*SELECT sucursal INTO vsSucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"*/
			IF EXISTS(SELECT sucursal FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursal AND num_producto = vsProducto)THEN
				LET viActivadas = viActivadas + 1;
			ELSE
				LET viDesactivadas = viDesactivadas + 1;
			END IF;
		END FOREACH;
		IF(viActivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "V";
		ELIF(viDesactivadas = viCantidadSuc)THEN
			LET vsFlagActDes = "F";
		ELSE
			LET vsFlagActDes = "W";
		END IF;
		RETURN vsCodRet, NVL(vsProducto, ""), NVL(vsDescripcion, ""), NVL(vsSistema, ""), NVL(vsFlagActDes, "") WITH RESUME;
		LET viActivadas = 0;
		LET viDesactivadas = 0;
	END FOREACH;
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta grupo de prodcutos activos o no para un grupo de sucursales',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_importarcatalogozonas(pSeparador CHAR(1), pNomArch CHAR(30), pEjecucion CHAR(1))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err                 	INTEGER;
DEFINE isam_err                	INTEGER;
DEFINE error_info              	CHAR(80);
DEFINE cCod_ret                	CHAR(6);
DEFINE cMensaje                	CHAR(80);

DEFINE cCadena                 	CHAR (500);
DEFINE vPath                   	CHAR(50);

DEFINE vNumerociudad           	SMALLINT;
DEFINE vNumerocolonia		   	SMALLINT;
DEFINE vNomzona              	CHAR(32);

--A.L.L.
DEFINE vfechahoy               	DATE;
DEFINE vTotalzonasRecibidas		INTEGER;

DEFINE vNumCiudad				INTEGER;
DEFINE vNumColonia				INTEGER; 
DEFINE vNombreZona				CHAR(32);
DEFINE vPoblacionZona			CHAR(27);
DEFINE vMunicipioZona			CHAR(27);
DEFINE vCodigoPostalZona		INTEGER;
DEFINE vNumeroCiudadCoppel		INTEGER;
DEFINE vNumeroColoniaCoppel		INTEGER;
DEFINE vNombreZonaCoppel		CHAR(32);
DEFINE iExisteTabla           INTEGER;
DEFINE iExisteIndice          INTEGER;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creado: José de Jesús Almeida
-- Fecha: 21 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de obtener el total o una parcialidad de las zonas del catalogo
---Nota: Este sp falla cuando se corre desde el visualizer pero funciona ok desde dbaccess.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: MACF
-- Fecha: 08/06/2010
-- Agregar parámetro pEjecucion para determinar si es Automática o Manual
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham López L.
-- Fecha: 09/05/2012
-- Eliminar llaves primarias de la tabla y eliminar registros repetidos.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham Lopez Lopez
-- Fecha: 25-07-2012
-- Se insertan registros duplicados, erroneos y relacionados a la tabla si_catzonas_bcpl_cpl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

LET vNumerociudad  = 0;
LET vNumerocolonia = 0;
LET vNombrezona    = '';
LET iExisteTabla   = 0;
LET iExisteIndice  = 0;

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cMensaje;
        END EXCEPTION;

 --SET DEBUG FILE TO "/ifxsif01/macf/sp_importarcatalogozonas.out";
 --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

-- A.L.L.* OBTENEMOS LA FECHA DE HOY------------------------------------------------------------
    SELECT prox_fecha        --fecha_hoy 
      INTO vfechahoy
      FROM bdinteg:si_fechas where empresa = '001';

    --IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'si_catzonas_coppel'  AND dbsname = 'bdinteg') THEN
    --   DROP TABLE si_catzonas_coppel;
    --END IF;

    SELECT count(*) into iExisteTabla
		  FROM sysmaster:systabnames 
      WHERE tabname= 'si_catzonas_coppel' 
       AND dbsname = 'bdinteg';
 
    if iExisteTabla > 0 then 
       DROP TABLE si_catzonas_coppel;
    end if;
       
    CREATE TABLE si_catzonas_coppel(
    numerociudad        smallint not null ,
    numerocolonia       smallint not null ,
    nombrezona          char(32),
    poblacionzona       char(27),
    municipiozona       char(27),
    codigopostalzona    integer,
    supervisorzona      integer,
    choferzona          integer,
    jefegrupozona       integer,
    gerentezona         integer,
    abogadozona         integer,
    centro              integer,
    ciudadcobranzas     integer,
    numerocobranzas     smallint,
    numerociudadcoppel  integer,
    numerocoloniacoppel integer,
    nombrezonacoppel    char(32)--,  A.L.L. SE ELIMINAN LLAVES PRIMARIAS PARA QUE META CIUDADES Y ZONAS REPETIDAS CAMBIO DEL 09/05/2012 YA EN PRODUCCION
   -- primary key (numerociudad, numerocolonia) constraint pk_si_catzonas_coppel
  );

  SELECT count(*) into iExisteIndice 
    FROM sysindices 
   WHERE idxname = 'idx_cuenta_tmp';
     
   IF iExisteIndice > 0 THEN
      DROP INDEX idx_si_catzonas_coppel_numcd_numcol;
   END IF; 

  begin;
      create index idx_si_catzonas_coppel_numcd_numcol on 
       si_catzonas_coppel(numerociudad, numerocolonia) online;
  commit;
  update statistics medium for table si_catzonas_coppel;
  
    IF pEjecucion = 'A' THEN
            SELECT valor INTO vPath 
            FROM bdinteg:si_param_dom 
            WHERE empresa = '001' AND cod_param = 12;
		  
		  LET cCadena = 'echo "FILE '|| SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,LENGTH(pNomArch))  || ' DELIMITER '''||'|'||''' 17; insert into "informix".si_catzonas_coppel; " > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  let cCadena = '';
		  
		  LET cCadena = 'dbload -d bdinteg -c ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql -l ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.log -n 1000 -k';
		  System SUBSTR(cCadena,1,LENGTH(cCadena));
		  let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql';

    ELSE
	
	LET cCadena = 'echo "FILE '|| '/tmp/' || SUBSTR(pNomArch,1,LENGTH(pNomArch))  || ' DELIMITER '''||'|'||''' 17; insert into "informix".si_catzonas_coppel; " > /tmp/importa_si_catzonas.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
	let cCadena = '';
	  
	LET cCadena = 'dbload -d bdinteg -c /tmp/importa_si_catzonas.sql -l /tmp/importa_si_catzonas.log -n 1000 -k';
	System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	let cCadena = '';
	let cCadena = '/usr/bin/rm /tmp/importa_si_catzonas.sql'; 
	System SUBSTR(cCadena,1,LENGTH(cCadena));
	
END IF; 

	--A.L.L.* BORRAMOS LOS DATOS DE LA TABLA PARA INSERTAR NUEVOS CONCILIADOS ERRONEOS Y DUPLICADOS.
        TRUNCATE TABLE si_catzonas_bcpl_cpl;  --NOTA: Se le quitaron las llaves primarias a esta tabla.

--A.L.L.* SELECCIONAMOS LAS CIUDADES INCORRECTAS LA CUALES SON CIUDAD = 0 COLONIA = 0
	FOREACH
		SELECT numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel
		INTO vNumCiudad, vNumColonia, vNombreZona, vPoblacionZona, vMunicipioZona, vCodigoPostalZona, vNumeroCiudadCoppel, vNumeroColoniaCoppel, vNombreZonaCoppel
		FROM bdinteg:si_catzonas_coppel
		WHERE numerociudad = 0 
		AND numerocolonia = 0
	
		IF vNumCiudad = 0 AND vNumColonia = 0 THEN
		                                     
		INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad,fecha_conciliacion,numerocolonia,numerociudadcoppel,numerocoloniacoppel,nombrezonacoppel,tipo_actualizacion) 
										VALUES 
												(vNumCiudad, vfechaHoy, vNumColonia, vNumeroCiudadCoppel, vNumeroColoniaCoppel, vNombreZonaCoppel, 'E' );
	END IF;
END FOREACH;
	--A.L.L. BORRAMOS LAS ZONAS ERRONEAS LAS CUALES TIENEN NUMEROCIUDAD CERO Y NUMEROCOLONIA CERO
		DELETE si_catzonas_coppel WHERE numerociudad = 0 AND numerocolonia = 0; 

--A.L.L. CONSULTAMOS REGISTROS DUPLICADOS
	FOREACH
		SELECT numerociudad, numerocolonia
			INTO vNumerociudad, vNumerocolonia
			FROM bdinteg:si_catzonas_coppel 
		GROUP BY numerociudad, numerocolonia HAVING COUNT(*) > 1
		
		IF vNumerociudad >= 0  THEN
	--A.L.L. INSERTAMOS LOS REGISTROS DUPLICADOS EN LA TABLA si_catzonas_bcpl_cpl
		INSERT INTO BDINTEG:si_catzonas_bcpl_cpl
		SELECT numerociudad, numerocolonia, vfechaHoy, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, 'D' 
		FROM bdinteg:si_catzonas_coppel
		WHERE numerociudad = vNumerociudad 
		AND numerocolonia = vNumerocolonia;
		
		--A.L.L. PARA ELIMINAR DUPLICADAS UNA VEZ QUE SE INSERTARON EN LA TABLA si_catzonas_bcpl_cpl
			DELETE FROM bdinteg:si_catzonas_coppel 
				WHERE numerociudad = vNumerociudad 
				AND numerocolonia = vNumerocolonia;
		
	END IF;
END FOREACH;

    ALTER TABLE si_catzonas_coppel ADD b_conciliado CHAR(1) DEFAULT 'F';

RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;