CREATE PROCEDURE "informix".sp_ferrara_relojes(psEmpresa CHAR(3))

RETURNING CHAR(5) AS codret, CHAR(65) AS mensaje;

--Declara Variables
DEFINE vsCodRet				CHAR(5);
DEFINE vsMensajeRet			CHAR(65);
DEFINE viSqlErr				INTEGER;

DEFINE vsFecIniCamp			CHAR(100);
DEFINE vsFecIniCamp2		CHAR(100);
DEFINE vsMontoMin			CHAR(100);
DEFINE vsMontoMin2			CHAR(100);
DEFINE vsPorCaja			CHAR(100);
DEFINE vsCuenta				CHAR(100);
DEFINE vsSucursal			CHAR(4);
DEFINE vsZonaBancoppel		CHAR(50);
DEFINE vsEstado				CHAR(30);
DEFINE vsCiudadMunicipio	VARCHAR(60,1);
DEFINE vsNombreSucursal		CHAR(40);
DEFINE viNoDepositosAcum	INTEGER;
DEFINE vdImporteAcum		DECIMAL(18,2);
DEFINE viOtorgadosCte		INTEGER;
DEFINE viEntregadosSuc		INTEGER;
DEFINE vdDonativoProm		DECIMAL(18,2);
DEFINE viRelojesExistentes 	INTEGER;
DEFINE viResiduo 			DECIMAL(18,2);

DEFINE vsCodPlaza			CHAR(3);
DEFINE vsCodEstado			CHAR(2);
DEFINE vsCodCiudad			CHAR(3);
DEFINE vsNombre				CHAR(60);
DEFINE vsFecUltEjec			CHAR(10);

DEFINE vmMontoMin			MONEY(14,2);
DEFINE vmMontoMin2			MONEY(14,2);

--Inicializa Variables
LET vsCodRet				= '00000';
LET vsMensajeRet			= '';
LET viSqlErr				= 0;

LET vsFecIniCamp 			= '';
LET vsFecIniCamp2			= '';
LET vsMontoMin 				= '';
LET vsMontoMin2				= '';
LET vsPorCaja				= '';
LET vsCuenta				= '';
LET vsSucursal				= '';
LET vsZonaBancoppel			= '';
LET vsEstado				= '';
LET vsCiudadMunicipio		= '';
LET vsNombreSucursal		= '';
LET viNoDepositosAcum		= 0;
LET vdImporteAcum			= 0.00;
LET viOtorgadosCte			= 0;
LET viEntregadosSuc			= 0;
LET vdDonativoProm			= 0.00;
LET viRelojesExistentes 	= 0;
LET viResiduo 				= 0;

LET vsCodPlaza				= '';
LET vsCodEstado				= '';
LET vsCodCiudad				= '';
LET vsNombre				= '';
LET vsFecUltEjec			= '';

LET vmMontoMin				=0.0;
LET vmMontoMin2				=0.0;

--SET DEBUG FILE TO "/tmp/moises/ferrara/sp_ferrara_relojesout.out";
--SET DEBUG FILE TO '/informix/PRISCILLA/sp_ferrara_relojesout.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		RETURN viSqlErr, vsMensajeRet;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsFecUltEjec FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '7';
IF(LENGTH(vsFecUltEjec) = 10)THEN
	LET vsFecUltEjec = SUBSTRING(vsFecUltEjec FROM 4 FOR 3) || SUBSTRING(vsFecUltEjec FROM 1 FOR 3) || SUBSTRING(vsFecUltEjec FROM 7 FOR 4);
END IF;


IF(vsFecUltEjec = CURRENT::DATE)THEN
	LET vsCodRet = '00002';
	LET vsMensajeRet = 'El proceso ya ha sido ejecutado en este dia.';
ELSE
	DELETE {+INDEX(si_ferrara_relojes_tabla idx_si_ferrara_relojes_tabla)} bdinteg:"informix".si_ferrara_relojes_tabla;
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);

	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsFecIniCamp FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '1';
	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsMontoMin FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '2';
	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsPorCaja FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '3';
	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsCuenta FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '4';
	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsMontoMin2 FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '8';
	SELECT {+INDEX(si_ferrara_relojes_param idx_si_ferrara_relojes_param)} valor INTO vsFecIniCamp2 FROM bdinteg:"informix".si_ferrara_relojes_param WHERE id_param = '9';
	
	LET vmMontoMin = CAST(vsMontoMin AS MONEY(14,2));
	LET vmMontoMin2 = CAST(vsMontoMin2 AS MONEY(14,2));

	LET vsFecIniCamp = SUBSTRING(vsFecIniCamp FROM 4 FOR 3) || SUBSTRING(vsFecIniCamp FROM 1 FOR 3) || SUBSTRING(vsFecIniCamp FROM 7 FOR 4);
	LET vsFecIniCamp2 = SUBSTRING(vsFecIniCamp2 FROM 4 FOR 3) || SUBSTRING(vsFecIniCamp2 FROM 1 FOR 3) || SUBSTRING(vsFecIniCamp2 FROM 7 FOR 4);
	
	
	INSERT INTO bdinteg:"informix".si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados)	
	SELECT ptf.id_ptf,
		SUM(CASE WHEN movdia.sucursal = ptf.id_ptf THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movdia.sucursal = ptf.id_ptf THEN movdia.monto_tot ELSE 0 END) AS monto, 
		SUM(CASE WHEN (movdia.monto_tot >= vmMontoMin AND (movdia.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1)))  
					THEN movdia.monto_tot / vmMontoMin
		         WHEN (movdia.monto_tot >= vmMontoMin2 AND (movdia.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					THEN movdia.monto_tot / vmMontoMin2 
		    ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	OUTER bdicheq:"informix".sc_movdia AS movdia
		WHERE movdia.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movdia.cuenta = vsCuenta
		AND movdia.monto_tot >= vmMontoMin2 
		AND movdia.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movdia.cancelad <> 'S'
		AND ptf.id_ptf = sisuc.sucursal
		AND ptf.tipo = sisuc.tipo
		AND ptf.tipo <> 'C'
		AND sisuc.tpo_sucursal = 'S'
		AND ptf.id_ptf = movdia.sucursal
		GROUP BY ptf.id_ptf;
	/*SELECT sisuc.sucursal,
		SUM(CASE WHEN movdia.sucursal = sisuc.sucursal THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movdia.sucursal = sisuc.sucursal THEN movdia.monto_tot ELSE 0 END) AS monto, 
		SUM(CASE WHEN (movdia.monto_tot >= vmMontoMin AND (movdia.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1)))  
					THEN movdia.monto_tot / vmMontoMin
		         WHEN (movdia.monto_tot >= vmMontoMin2 AND (movdia.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					THEN movdia.monto_tot / vmMontoMin2 
		    ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_sucursales AS sisuc, OUTER bdicheq:"informix".sc_movdia AS movdia
		WHERE movdia.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movdia.cuenta = vsCuenta
		AND movdia.monto_tot >= vmMontoMin2 
		AND movdia.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movdia.cancelad <> 'S'
		AND sisuc.tpo_sucursal = 'S'
		AND sisuc.sucursal = movdia.sucursal
		GROUP BY sisuc.sucursal;*/
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);

	INSERT INTO bdinteg:"informix".si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados)
	--SELECT {+INDEX(bdinteg:si_sucursales idx_sucursal2),+INDEX(bdicheq:sc_movhis idx_movhisnew1)} sisuc.sucursal,
	SELECT ptf.id_ptf,
		SUM(CASE WHEN movhis.sucursal = ptf.id_ptf THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movhis.sucursal = ptf.id_ptf THEN movhis.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movhis.monto_tot >= vmMontoMin AND (movhis.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1)))
					 THEN movhis.monto_tot / vmMontoMin 
				 WHEN (movhis.monto_tot >= vmMontoMin2 AND (movhis.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movhis.monto_tot / vmMontoMin2 
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	OUTER bdicheq:"informix".sc_movhis AS movhis
		WHERE movhis.empresa = psEmpresa
		AND movhis.cuenta = vsCuenta
		AND movhis.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movhis.monto_tot >= vmMontoMin2
		AND movhis.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movhis.cancelad <> 'S'
		AND ptf.id_ptf = sisuc.sucursal
		AND ptf.tipo = sisuc.tipo
		AND ptf.tipo <> 'C'
		AND sisuc.tpo_sucursal = 'S'
		AND ptf.id_ptf = movhis.sucursal		
		GROUP BY ptf.id_ptf;
	/*SELECT sisuc.sucursal,
		SUM(CASE WHEN movhis.sucursal = sisuc.sucursal THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movhis.sucursal = sisuc.sucursal THEN movhis.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movhis.monto_tot >= vmMontoMin AND (movhis.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1)))
					 THEN movhis.monto_tot / vmMontoMin 
				 WHEN (movhis.monto_tot >= vmMontoMin2 AND (movhis.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movhis.monto_tot / vmMontoMin2 
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_sucursales AS sisuc, OUTER bdicheq:"informix".sc_movhis AS movhis
		WHERE movhis.empresa = psEmpresa
		AND movhis.cuenta = vsCuenta
		AND movhis.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movhis.monto_tot >= vmMontoMin2
		AND movhis.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movhis.cancelad <> 'S'
		AND sisuc.tpo_sucursal = 'S'
		AND sisuc.sucursal = movhis.sucursal		
		GROUP BY sisuc.sucursal;*/
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);

	INSERT INTO bdinteg:"informix".si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados)
	SELECT ptf.id_ptf,
		SUM(CASE WHEN movhisold.sucursal = ptf.id_ptf THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movhisold.sucursal = ptf.id_ptf THEN movhisold.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movhisold.monto_tot >= vmMontoMin AND (movhisold.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movhisold.monto_tot / vmMontoMin
				 WHEN (movhisold.monto_tot >= vmMontoMin2 AND (movhisold.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movhisold.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	OUTER bdicheq:"informix".sc_movhis_old AS movhisold
		WHERE movhisold.empresa = psEmpresa
		AND movhisold.cuenta = vsCuenta
		AND movhisold.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movhisold.monto_tot >= vmMontoMin2
		AND movhisold.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movhisold.cancelad <> 'S'
		AND ptf.id_ptf = sisuc.sucursal
		AND ptf.tipo = sisuc.tipo
		AND ptf.tipo <> 'C'
		AND sisuc.tpo_sucursal = 'S'
		AND ptf.id_ptf = movhisold.sucursal
		GROUP BY ptf.id_ptf;
	/*SELECT sisuc.sucursal,
		SUM(CASE WHEN movhisold.sucursal = sisuc.sucursal THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movhisold.sucursal = sisuc.sucursal THEN movhisold.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movhisold.monto_tot >= vmMontoMin AND (movhisold.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movhisold.monto_tot / vmMontoMin
				 WHEN (movhisold.monto_tot >= vmMontoMin2 AND (movhisold.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movhisold.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_sucursales AS sisuc, OUTER bdicheq:"informix".sc_movhis_old AS movhisold
		WHERE movhisold.empresa = psEmpresa
		AND movhisold.cuenta = vsCuenta
		AND movhisold.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movhisold.monto_tot >= vmMontoMin2
		AND movhisold.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movhisold.cancelad <> 'S'
		AND sisuc.tpo_sucursal = 'S'
		AND sisuc.sucursal = movhisold.sucursal
		GROUP BY sisuc.sucursal;*/
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);
	
	--Se agrega consulta de tabla sc_movhis_old2 y sc_movhis_old3
	INSERT INTO bdinteg:"informix".si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados)
	SELECT ptf.id_ptf,
		SUM(CASE WHEN movishold2.sucursal = ptf.id_ptf THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movishold2.sucursal = ptf.id_ptf THEN movishold2.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movishold2.monto_tot >= vmMontoMin AND (movishold2.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movishold2.monto_tot / vmMontoMin
				 WHEN (movishold2.monto_tot >= vmMontoMin2 AND (movishold2.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movishold2.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	OUTER bdicheq:"informix".sc_movhis_old2 AS movishold2
		WHERE movishold2.empresa = psEmpresa
		AND movishold2.cuenta = vsCuenta
		AND movishold2.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movishold2.monto_tot >= vmMontoMin2
		AND movishold2.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movishold2.cancelad <> 'S'
		AND ptf.id_ptf = sisuc.sucursal
		AND ptf.tipo = sisuc.tipo
		AND ptf.tipo <> 'C'
		AND sisuc.tpo_sucursal = 'S'
		AND ptf.id_ptf = movishold2.sucursal
		GROUP BY ptf.id_ptf;
	/*SELECT sisuc.sucursal,
		SUM(CASE WHEN movishold2.sucursal = sisuc.sucursal THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movishold2.sucursal = sisuc.sucursal THEN movishold2.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movishold2.monto_tot >= vmMontoMin AND (movishold2.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movishold2.monto_tot / vmMontoMin
				 WHEN (movishold2.monto_tot >= vmMontoMin2 AND (movishold2.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movishold2.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_sucursales AS sisuc, OUTER bdicheq:"informix".sc_movhis_old2 AS movishold2
		WHERE movishold2.empresa = psEmpresa
		AND movishold2.cuenta = vsCuenta
		AND movishold2.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movishold2.monto_tot >= vmMontoMin2
		AND movishold2.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movishold2.cancelad <> 'S'
		AND sisuc.tpo_sucursal = 'S'
		AND sisuc.sucursal = movishold2.sucursal
		GROUP BY sisuc.sucursal;*/
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);
	
	INSERT INTO bdinteg:"informix".si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados)
	SELECT ptf.id_ptf,
		SUM(CASE WHEN movishold3.sucursal = ptf.id_ptf THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movishold3.sucursal = ptf.id_ptf THEN movishold3.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movishold3.monto_tot >= vmMontoMin AND (movishold3.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movishold3.monto_tot / vmMontoMin
				 WHEN (movishold3.monto_tot >= vmMontoMin2 AND (movishold3.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movishold3.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_ptf AS ptf,
	bdinteg:"informix".si_sucursales AS sisuc, 
	OUTER bdicheq:"informix".sc_movhis_old3 AS movishold3
		WHERE movishold3.empresa = psEmpresa
		AND movishold3.cuenta = vsCuenta
		AND movishold3.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movishold3.monto_tot >= vmMontoMin2
		AND movishold3.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movishold3.cancelad <> 'S'
		AND ptf.id_ptf = sisuc.sucursal
		AND ptf.tipo = sisuc.tipo
		AND ptf.tipo <> 'C'
		AND sisuc.tpo_sucursal = 'S'
		AND ptf.id_ptf = movishold3.sucursal
		GROUP BY ptf.id_ptf;
	/*SELECT sisuc.sucursal,
		SUM(CASE WHEN movishold3.sucursal = sisuc.sucursal THEN 1 ELSE 0 END) AS suc,
		SUM(CASE WHEN movishold3.sucursal = sisuc.sucursal THEN movishold3.monto_tot ELSE 0 END) AS monto,
		SUM(CASE WHEN (movishold3.monto_tot >= vmMontoMin AND (movishold3.fech_alt BETWEEN vsFecIniCamp::DATE AND (vsFecIniCamp2::DATE  - 1))) 
					 THEN movishold3.monto_tot / vmMontoMin
				 WHEN (movishold3.monto_tot >= vmMontoMin2 AND (movishold3.fech_alt BETWEEN vsFecIniCamp2::DATE AND (CURRENT::DATE -1)))
					 THEN movishold3.monto_tot / vmMontoMin2
			ELSE 0 END) AS otrgds
	FROM bdinteg:"informix".si_sucursales AS sisuc, OUTER bdicheq:"informix".sc_movhis_old3 AS movishold3
		WHERE movishold3.empresa = psEmpresa
		AND movishold3.cuenta = vsCuenta
		AND movishold3.fech_alt BETWEEN vsFecIniCamp AND CURRENT::DATE - 1
		AND movishold3.monto_tot >= vmMontoMin2
		AND movishold3.transacc_suc IN('5555', '0201', '0204', '0215', '0250', '0700', '0252', '0253')
		AND movishold3.cancelad <> 'S'
		AND sisuc.tpo_sucursal = 'S'
		AND sisuc.sucursal = movishold3.sucursal
		GROUP BY sisuc.sucursal;*/
	UPDATE STATISTICS HIGH FOR TABLE si_ferrara_relojes_tabla(sucursal,monto,monto_tot,relojes_otorgados);
	
	FOREACH
		
		SELECT {+INDEX(si_ferrara_relojes_tabla idx_si_ferrara_relojes_tabla)} sucursal, sum(monto) as suma, sum(monto_tot) as monto, sum(relojes_otorgados) as otorgados
		INTO vsSucursal, viNoDepositosAcum, vdImporteAcum, viOtorgadosCte
		FROM bdinteg:"informix".si_ferrara_relojes_tabla
		GROUP BY sucursal


		SELECT plaza INTO vsCodPlaza FROM bdinteg:"informix".si_sucursales WHERE sucursal = vsSucursal;
		SELECT nombre INTO vsNombre FROM bdinteg:"informix".si_plazas WHERE plaza = vsCodPlaza;

		LET vsZonaBancoppel = vsNombre;

		SELECT cve_estado INTO vsCodEstado FROM bdinteg:"informix".si_ptf WHERE id_ptf = vsSucursal AND tipo <> 'C';
		--SELECT estado INTO vsCodEstado FROM bdinteg:"informix".si_sucursales WHERE sucursal = vsSucursal;
		SELECT nombre INTO vsNombre FROM bdinteg:"informix".si_estados WHERE estado = vsCodEstado;

		LET vsEstado = vsNombre;

		SELECT cve_ciudad INTO vsCodCiudad FROM bdinteg:"informix".si_ptf WHERE id_ptf = vsSucursal AND tipo <> 'C';
		/*SELECT ciudad INTO vsCodCiudad FROM bdinteg:"informix".si_sucursales WHERE sucursal = vsSucursal;*/
		SELECT nombre INTO vsNombre FROM bdinteg:"informix".si_ciudades WHERE ciudad = vsCodCiudad AND estado = vsCodEstado;

		LET vsCiudadMunicipio = vsNombre;

		SELECT nombre INTO vsNombre FROM bdinteg:"informix".si_sucursales WHERE sucursal = vsSucursal;

		LET vsNombreSucursal = vsNombre;
		LET viResiduo = (viOtorgadosCte / vsPorCaja);
		LET viEntregadosSuc = viResiduo;
		IF ((viResiduo - viEntregadosSuc) > 0) THEN
			LET viEntregadosSuc = viEntregadosSuc + 1;
		END IF;
		LET viEntregadosSuc = (viEntregadosSuc * vsPorCaja);
		IF(viEntregadosSuc = 0)THEN
			LET viEntregadosSuc = vsPorCaja;
		END IF;
		LET vdDonativoProm = 0.00;
		IF (viNoDepositosAcum > 0) THEN
			LET vdDonativoProm = (vdImporteAcum / viNoDepositosAcum);
		END IF;
		LET viRelojesExistentes = (viEntregadosSuc - viOtorgadosCte);

		INSERT INTO bdinteg:"informix".si_ferrara_relojes
		(sucursal, zona_bancoppel, estado, ciudad_municipio, nombre_sucursal, no_depositos_acum,
		 importe_acum, otorgados_cte, entregados_suc, donativo_prom, relojes_existentes, fecha_reporte)
		VALUES
		(vsSucursal, vsZonaBancoppel, vsEstado, vsCiudadMunicipio, vsNombreSucursal, viNoDepositosAcum,
		 vdImporteAcum::MONEY(18,2), viOtorgadosCte, viEntregadosSuc, vdDonativoProm::MONEY(18,2), viRelojesExistentes, CURRENT::DATE);
	END FOREACH
	
	DELETE {+INDEX(si_ferrara_relojes_tabla idx_si_ferrara_relojes_tabla)} bdinteg:"informix".si_ferrara_relojes_tabla;	
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vsCodRet = "00001";
		LET vsMensajeRet = "Ocurrio algun error durante la consulta y/o al insertar datos.";
	ELSE
		LET vsFecUltEjec = SUBSTRING(CURRENT::DATE FROM 4 FOR 3) || SUBSTRING(CURRENT::DATE FROM 1 FOR 3) || SUBSTRING(CURRENT::DATE FROM 7 FOR 4);
		UPDATE bdinteg:"informix".si_ferrara_relojes_param SET valor = vsFecUltEjec WHERE id_param = '7';
	END IF;
END IF;

RETURN vsCodRet, vsMensajeRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Procesa tablas mov_dia, mov_his, mov_his_old para generar informacion relacionada a los donativos.',
'FECHA: 2012/08/09',
'VERSIÃN: 20120809.1800',
'BD: bdinteg',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Se agregaron condiciones e indices para optimizar consulta, se procesaran sucursales sin donativos.',
'FECHA: 2012/08/28',
'VERSIÃN: 20120828.1800',
'BD: bdinteg',
'MODIFICO: MoisÃ©s Eduardo Soriano Guerrero',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Se agregaron condiciones para aceptar diferentes parametros conforme a una fecha determinada.',
'FECHA: 2013/01/22',
'VERSIÃN: 20130122.1800',
'BD: bdinteg',
'MODIFICO: MoisÃ©s Eduardo Soriano Guerrero',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Se redujo el costo de busquedas secuenciales',
'FECHA: 2013/02/05',
'VERSIÃN: 20130205.1800',
'BD: bdinteg',
'MODIFICO: Walber Castro',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Se eliminaron las bÃºsquedas secuenciales',
'FECHA: 2013/02/14',
'VERSIÃN: 20130214.1430',
'BD: bdinteg',
'MODIFICO: MoisÃ©s Eduardo Soriano Guerrero',
'PROYECTO: Donativos FundaciÃ³n Ferrara',
'SOLICITÃ: JosÃ© Arturo Cruz Espino',
'DESCRIPCIÃN: Se agregaron busquedas a nuevas tablas historicas.',
'FECHA: 2013/03/22',
'VERSIÃN: 20130322.1729',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actulizatipocliente (psEmpresa CHAR(3), psNumCliente CHAR(20), piTipoEjecucion INTEGER, pComprobante CHAR(1), pIdentificacion CHAR(1) )
RETURNING	 CHAR(5) AS Retorno

	DEFINE iSqlErr            INTEGER;
	DEFINE cCodRet            CHAR(5);
	DEFINE cCodIdentifi       CHAR(2);
	DEFINE cNumIdentifi       CHAR(30);
	DEFINE iIdentOficial      INTEGER;
	DEFINE iComDomicilio      INTEGER;
	DEFINE dFecha             DATE;
	DEFINE dFechaNacimiento   DATE;
	DEFINE cCodRetFecha       CHAR(5);
	DEFINE iEdad              INTEGER;
	DEFINE iBandera           INTEGER;

	----Varibles Mensaje Afore
	DEFINE cNumEmpleado		  CHAR(8);
	DEFINE cSucursal		  CHAR(4);
	DEFINE cCurp		 	  CHAR(18);
	DEFINE cApellPaterno	  CHAR(26);
	DEFINE cApellMaterno	  CHAR(26);
	DEFINE cNombre1	 		  CHAR(26);
	DEFINE cNombre2	  		  CHAR(26);
	DEFINE dFechaNac		  DATE;
	DEFINE cEntidadNac		  CHAR(2);
	DEFINE cSexo			  CHAR(1);
	DEFINE cAvisoCte		  CHAR(1);
	DEFINE cSucursalEjecut	  CHAR(4);
    DEFINE sTieneDireccion    CHAR(1);
    DEFINE sTieneHuella       CHAR(1);
    DEFINE sProducto          CHAR(1);
    DEFINE sAutorizacion      CHAR(1);
    DEFINE sMensajeAfore      CHAR(1);



	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Felipe Urias
	-- FECHA: 14/08/2012
	-- DESCRIPCION: Realiza la validaciones necesarias para que un cliente sea considerado titulas y de
	--              cumplir con estas realiza la actualizacion del tipo de cliente.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Felipe Urias
	-- FECHA:       02/01/2013
	-- DESCRIPCION: se agrega consultas de fecha de nacimiento del cliente y consulta de la fecha actual
	--              se agrega validacion de edad  para que los menores no validen identificacion.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Rodolfo Tortolero
	-- FECHA:       22/02/2013
	-- DESCRIPCION: se agrega la misma funcionalidad que se utiliza en el sp_valida_aviso_privacidad
	--              para validar si el cliente tiene el aviso de privacidad.
	--              Se modifica para que consulte los documentos digitalizados en la tabla
	--              bdidigital@coppelimg_tcp:dg_expediente_img.
	--              Se agrega validaciÃ??Ã?ÃÂ³n para clientes menores de edad no sea abligatorio el campo
	--              nÃ??Ã?ÃÂ¹mero identificaciÃ??Ã?ÃÂ³n.
	------------------------------------------------------------------------------------------------------

	LET iSqlErr          = 0;
	LET cCodRet          = '00000';
	LET cCodIdentifi     = '';
	LET cNumIdentifi     = '';
	LET iIdentOficial    = 0;
	LET iComDomicilio    = 0;
	LET dFecha           = '';
	LET dFechaNacimiento = '';
	LET cCodRetFecha     = '00000';
	LET iEdad            = 0;
	LET iBandera         = 0;

	LET cNumEmpleado  = '';
	LET cSucursal	  = '';
	LET cCurp		  = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombre1	  = '';
	LET cNombre2	  = '';
	LET dFechaNac	  = DATE(1);
	LET cEntidadNac	  = '';
	LET cSexo		  = '';
	LET cAvisoCte	  = '';
	LET cSucursalEjecut = '';
    LET sTieneDireccion ='';
    LET sTieneHuella ='';
    LET sProducto ='0';
    LET sAutorizacion = '';
    LET sMensajeAfore = '0';





	--SET DEBUG FILE TO "/tmp/sp_actulizatipocliente_pba.sql";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = CAST(iSqlErr AS CHAR(5));
				RETURN cCodRet;
			END IF;
		END EXCEPTION;


        SELECT 1 INTO sTieneDireccion
        FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1;


        SELECT codidentifi, numidentifi, fecha_nac, curp, lugar_nac, sexo
		INTO cCodIdentifi, cNumIdentifi, dFechaNacimiento, cCurp, cEntidadNac, cSexo
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = psEmpresa
		AND numcte = psNumCliente;


        --IF  EXISTS(SELECT 1 FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1 AND secuencia = (SELECT MAX(secuencia) FROM si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1))THEN
        IF  sTieneDireccion = '1' THEN

            SELECT fecha_hoy
            INTO dFecha
            FROM bdinteg:"informix".si_fechas
			WHERE empresa = psEmpresa;

			EXECUTE PROCEDURE sp_ObtenerEdadPersona(dFecha, NVL(dFechaNacimiento, '1900/01/01') )
			INTO cCodRetFecha, iEdad;

		    IF TRIM(cCodRetFecha) = '000' THEN
			    IF iEdad >=18 THEN
				    IF TRIM (NVL(cCodIdentifi,'')) <> '' AND TRIM (NVL(cNumIdentifi, '')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    ELSE
			        IF TRIM (NVL(cCodIdentifi,'')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    END IF;
			END IF;

			IF iBandera = 1 THEN


                SELECT 1 INTO sTieneHuella
                    FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A';

				--IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A' AND secuencia = (SELECT MAX(secuencia)	FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A')) THEN
                IF sTieneHuella = '1' THEN



                   /* SELECT NVL(num_cte,'0') INTO sProducto
                    FROM bdicheq:"informix".sc_maechq  WHERE empresa = psEmpresa AND num_cte = psNumCliente;

                    IF sProducto <> '1' THEN
                        SELECT NVL(numcte,'0') INTO sProducto
                        FROM bdisolic:"informix".ss_solicitudes WHERE empresa = psEmpresa AND numcte  = psNumCliente;
                        IF sProducto <> '1' THEN
                            SELECT NVL(num_cte,'0') INTO sProducto
                            FROM bdinvers:"informix".sv_maeinv WHERE empresa = psEmpresa AND num_cte = psNumCliente;
                            IF sProducto <> '1' THEN
                               SELECT NVL(numcte,'0')  INTO sProducto
                               FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1';
                            END IF;
                        END IF;
                    END IF;*/


					--IF sProducto = '1' THEN
						IF piTipoEjecucion = 2 THEN
                            LET iIdentOficial = pIdentificacion;
                            LET iComDomicilio = pComprobante;

							IF iIdentOficial = 1 AND iComDomicilio = 1 THEN
								UPDATE bdinteg:"informix".si_cliente
								SET tipo_cliente = '1'
								WHERE empresa = psEmpresa
								AND numcte = psNumCliente;
								LET cCodRet = '00000';
							END IF;
						ELIF piTipoEjecucion = 1 THEN
							UPDATE bdinteg:"informix".si_cliente
							SET tipo_cliente = '1'
							WHERE empresa = psEmpresa
							AND numcte = psNumCliente;
							LET cCodRet = '00000';
						END IF;
					--END IF;
				END IF;
			END IF;
		END IF;

		IF cCodRet = '00000' THEN


            SELECT 1 INTO sAutorizacion
            FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1';

            --IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1') THEN
			IF sAutorizacion = '1' THEN


                SELECT count(numcte) INTO sMensajeAfore
                FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente;

				--IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente) THEN
                IF sMensajeAfore = '0' THEN

					--Obtenemos los datos del cliente
					SELECT  c.ejecutivo,c.sucursal,c.apell_paterno,c.apell_materno,c.nombre1,c.nombre2
					INTO cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2
					FROM  bdinteg:"informix".si_cliente c
					WHERE c.numcte =  psNumCliente
					AND c.empresa =  psEmpresa;

                    select first 1 sucursal
                    into cSucursal from bdinteg:si_ejecut where empresa=psEmpresa and ejecutivo=cNumEmpleado;

					-- Notifica a afore
					INSERT INTO "informix".si_ws_mensajeafore(numcte,ejecutivo,sucursal,apell_paterno,apell_materno,nombre1,nombre2,curp,fecha_nac,lugar_nac,sexo,fecha_insert)
					VALUES(psNumCliente,cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cCurp,dFechaNac,cEntidadNac,cSexo,CURRENT);
				END IF;
			END IF;
		END IF;

		RETURN cCodRet;

	END
END PROCEDURE;