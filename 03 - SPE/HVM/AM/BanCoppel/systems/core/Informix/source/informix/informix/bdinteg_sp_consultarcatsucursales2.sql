CREATE PROCEDURE "informix".sp_consultarcatsucursales2(p_sEmpresa CHAR(3), p_sSucursal CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(6) AS retorno,
				CHAR(3) AS empresa, 
				CHAR(4) AS sucursal, 
				CHAR(40) AS nombre, 
				CHAR(40) AS direccion1, 
				CHAR(40) AS direccion2, 
				CHAR(14) AS telefono,
				CHAR(40) AS gerente, 
				CHAR(40) AS subgerente, 
				CHAR(2) AS tpo_sucursal;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(6);
	DEFINE v_sEmpresa 		CHAR(3);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sNombre		CHAR(40);
	DEFINE v_sDireccion1	CHAR(40);
	DEFINE v_sDireccion2	CHAR(40);
	DEFINE v_sTelefono1		CHAR(14);
	DEFINE v_sGerente		CHAR(40);
	DEFINE v_sSubgerente	CHAR(40);	
	DEFINE v_sTipo_sucursal	CHAR(2);
	DEFINE v_sMin           CHAR(4);
	DEFINE v_sMax           CHAR(4);

	------------------------------------------------------------------------------------------
	--Creado por Erick Zamora 03/Agosto/2009
	--Obtiene los datos de la sucursal especificada, o de todas las sucursales del catalogo
	--Caso de uso asociado: PCU-bdinteg\CU-0103-ConsultarCatSucursales-SPL
		
	--AUTOR: L. Montserrat LeÃÂ³n Amador
	--FECHA 08/04/2019
	--DESCRIPCION: Se realiza clonaciÃÂ³n de spl sp_consultarcatsucursales para implementar paginado.
	
	--SET DEBUG FILE TO "/tmp/sp_consultarcatsucursales2.out"; 
	--TRACE ON;
	------------------------------------------------------------------------------------------
	LET v_sValRetorno = '000001';
		
	BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			RETURN iSqlErr,'','','','','','','','','';
		END IF;
	END EXCEPTION;

	--- SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivo_cecoban.out";
	--- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;
	
	-- // DEBE PROPORCIONARSE LA EMPRESA
	IF NVL(p_sEmpresa,'') = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
		RETURN v_sValRetorno,'','','','','','','','','';
	END IF;
	
	IF p_sSucursal is null THEN
		LET p_sSucursal = '';
	END IF;

	IF p_sSucursal = '' THEN
		SELECT MIN(sucursal), MAX(sucursal)
		  INTO v_sMin, v_sMax
		  FROM bdinteg:si_sucursales;
		
		FOREACH
			SELECT {+INDEX(bdinteg:si_sucursales idx_sucursal2)}  
			       SKIP pRegistros FIRST pRecuperacion suc.empresa, ptf.id_ptf, suc.nombre,ptf.calle||' NUM '||ptf.num_ext AS direccion1, 'COL. '||loc.desc_colonia||' C.P. '||loc.cp AS direccion2, ptf.tel1, suc.gerente, suc.subger, ptf.tipo
			  INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
			  FROM bdinteg:si_sucursales suc
			 INNER JOIN bdinteg:si_ptf ptf ON ( ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo )
			  LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_col = ptf.cve_col )
			 WHERE sucursal BETWEEN v_sMin AND v_sMax
			   AND empresa = p_sEmpresa
			   AND tpo_sucursal = 'S'

			LET v_sValRetorno = '000000';

			RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
		END FOREACH;
	ELSE
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion suc.empresa, ptf.id_ptf, suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1, 'COL. '||loc.desc_colonia||' C.P. '||loc.cp as direccion2, ptf.tel1, suc.gerente, suc.subger, ptf.tipo
			  INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
			  FROM bdinteg:si_sucursales suc
			 INNER JOIN bdinteg:si_ptf ptf ON ( ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo )
			  LEFT OUTER JOIN bdinteg:si_localidades loc ON (loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_col = ptf.cve_col )
			 WHERE suc.sucursal = p_sSucursal

			LET v_sValRetorno = '000000';

			RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
		END FOREACH;
	END IF;
	
	END;
	
END PROCEDURE;