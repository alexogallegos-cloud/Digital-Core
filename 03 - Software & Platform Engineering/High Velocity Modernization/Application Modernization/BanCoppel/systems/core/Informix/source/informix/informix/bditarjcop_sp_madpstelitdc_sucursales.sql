CREATE PROCEDURE "informix".sp_madpstelitdc_sucursales(
psEmpresa CHAR(3),
psTipoBusqueda CHAR(2),
psNumProducto CHAR(4)
)

RETURNING CHAR(5) AS CodRet, CHAR(4) AS cvesucursal, CHAR(40) AS Descripcion, CHAR(1) AS ActDes, CHAR(30) AS FechaActAU;

--***********************************************************************************************************
-- DESCRIPCION: Consulta sucursales activadas o desactivadas en alta única
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE vsClaveSuc			CHAR(4);
DEFINE vsDescripcion		CHAR(40);
DEFINE vsFlagActAU		CHAR(1);
DEFINE vsFlagActOS		CHAR(1); 
DEFINE vsFechaActAU			CHAR(30);

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET vsClaveSuc = "";
LET vsDescripcion = "";
LET vsFlagActAU = "";
LET vsFlagActOS = "";
LET vsFechaActAU = "";

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_madpstelitdc_sucursales.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsClaveSuc, vsDescripcion, "", vsFechaActAU;
	END IF;
END EXCEPTION;

--Se realiza consulta por sucursal.
IF(psTipoBusqueda == "AU")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, sucursal ||" - " ||nombre,
		NVL((SELECT cajaunica FROM bditarjcop:"informix".sucursalescajaunica  WHERE cvesucursal = sucursal),'F'), 
		NVL((SELECT fechaactcu FROM bditarjcop:"informix".sucursalescajaunica WHERE cvesucursal = sucursal),'1900-01-01 00:00:00.0')
		INTO vsClaveSuc, vsDescripcion, vsFlagActAU, vsFechaActAU
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND tpo_sucursal = "S" 
		ORDER BY sucursal
		
		RETURN vsCodRet, NVL(vsClaveSuc, ""), NVL(vsDescripcion, ""), NVL(vsFlagActAU, ""), NVL(vsFechaActAU, "") WITH RESUME;
	END FOREACH
ELIF(psTipoBusqueda == "OS")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, sucursal ||" - " ||nombre,
		NVL((SELECT ostelefonica FROM bditarjcop:"informix".prodostelefonica  WHERE cvesucursal = sucursal AND numproducto = psNumProducto),'F')
		INTO vsClaveSuc, vsDescripcion, vsFlagActOS
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND tpo_sucursal = "S" 
		ORDER BY sucursal
			
		RETURN vsCodRet, NVL(vsClaveSuc, ""), NVL(vsDescripcion, ""), NVL(vsFlagActOS, ""), "" WITH RESUME;
	END FOREACH
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta sucursales activadas o desactivadas en alta única',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_regclaugruposuctarcop(
psEmpresa CHAR(3),
psRegClau CHAR(1),
psCierraInv CHAR(1),
psTipoRegistro CHAR(1),
psCodigo CHAR(4),
pdFechaActSuc DATE,
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret, CHAR(4) AS sucursal;

--***********************************************************************************************************
-- DESCRIPCION: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsSucursal CHAR(4);
DEFINE vsNombreSuc	CHAR(40);

LET viSqlErr = 0;
LET vsCodRet = '';
LET vsSucursal = '';
LET vsNombreSuc = '';

--SET DEBUG FILE TO "/informix/tmp/sp_regclaugruposuctarcop.out";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsSucursal;
	END IF;
END EXCEPTION;

IF(psTipoRegistro = 'E')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, nombre
		INTO vsSucursal, vsNombreSuc
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND estado = psCodigo 
		AND tpo_sucursal = 'S'
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH
ELIF(psTipoRegistro = 'R')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
									   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
		AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH;
ELIF(psTipoRegistro = 'S')THEN
	IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, psCodigo, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psCodigo, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
	ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, psCodigo) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psCodigo, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
	END IF;
	RETURN vsCodRet, NVL(psCodigo, '') WITH RESUME;
ELIF(psTipoRegistro = 'D')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH;
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel.',
'Fecha: 2011/12/27',
'Version: 20111227.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_regclaugruposuctarcopos(
psEmpresa CHAR(3),
psTipoRegistro CHAR(1),
psCodigo CHAR(4),
psFlagActDesact CHAR(1),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret, CHAR(4) AS sucursal;

--***********************************************************************************************************
-- DESCRIPCION: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsSucursal CHAR(4);
DEFINE vsNombreSuc	CHAR(40);
DEFINE vsActDesact CHAR(13);

LET viSqlErr = 0;
LET vsCodRet = '';
LET vsSucursal = "";
LET vsNombreSuc = "";
LET vsActDesact = "";

--SET DEBUG FILE TO "/dbexport/sp_regclaugruposuctarcopos.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsSucursal;
	END IF;
END EXCEPTION;

IF((psEmpresa <> "") OR (psEmpresa IS NOT NULL)) AND ((psCodigo <> "") OR (psCodigo IS NOT NULL)) AND ((psFlagActDesact <> "") OR (psFlagActDesact IS NOT NULL))THEN
	IF(psTipoRegistro == "E")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre
			INTO vsSucursal, vsNombreSuc
			FROM bdinteg:"informix".si_sucursales 
			WHERE empresa = psEmpresa 
			AND estado = psCodigo 
			AND tpo_sucursal = "S"
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH
	ELIF(psTipoRegistro == "R")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
											   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH;
	ELIF(psTipoRegistro == "S")THEN
		EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, psCodigo, psFlagActDesact) INTO vsCodRet;
		IF (vsCodRet == "00000") THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
			IF (psFlagActDesact == "V") THEN
				LET vsActDesact = "Activación";
			ELIF (psFlagActDesact == "F") THEN
				LET vsActDesact = "Desactivación";
			END IF;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END IF;
		RETURN vsCodRet, NVL(psCodigo, "") WITH RESUME;
	ELIF(psTipoRegistro == "D")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = "S"
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH;
	END IF;
	
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel.',
'Fecha: 2011/12/27',
'Version: 201090129.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_reportemovtoshis(
cTipo_Con CHAR(2),
dFecha_ini DATE,
dFecha_fin DATE
)

RETURNING VARCHAR(6), VARCHAR(80), VARCHAR(4), VARCHAR(40), VARCHAR(2), VARCHAR(15), DATE, VARCHAR(40), VARCHAR(9), VARCHAR(40), DATETIME YEAR TO FRACTION(5);

DEFINE  SQL_ERR           INTEGER;
DEFINE  ISAM_ERR          INTEGER;
DEFINE  ERROR_INFO        VARCHAR(80);
DEFINE  P_COD_RET         VARCHAR(6);
DEFINE  P_MENSAJE         VARCHAR(80);

DEFINE vc_cve_sucursal 	  VARCHAR(4);
DEFINE vc_nom_sucursal    VARCHAR(40);
DEFINE vc_tipo_consulta   VARCHAR(2);
DEFINE vc_tipo_cambio     VARCHAR(15);
DEFINE vc_fecha_prog      CHAR(10); 
DEFINE vc_producto        VARCHAR(40);
DEFINE vc_cve_usuario     VARCHAR(9);
DEFINE vc_nom_usuario     VARCHAR(40);
DEFINE vd_fecha_reg       DATETIME YEAR TO FRACTION(5); 


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      
		RETURN P_COD_RET, P_MENSAJE,vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			   vc_cve_usuario,vc_nom_usuario,vd_fecha_reg;
   END EXCEPTION;

--	SET debug file to '/tmp/sp_reportemovtoshis.sql';
--	TRACE ON;

--************************************************************
-- Creado por Manuel Osuna Valencia (23-01-2012)
-- Guarda reporte de activacion o desactivacion de productos o sucursales en alta unica, ostelefonica
-- Proyecto  Alta Única
--************************************************************

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';
	LET vc_cve_sucursal = '';
	LET vc_nom_sucursal    = '';
	LET vc_tipo_consulta   = '';
	LET vc_tipo_cambio     = '';
	LET vc_fecha_prog      = '01-01-1900'; 
	LET vc_producto        = '';
	LET vc_cve_usuario     = '';
	LET vc_nom_usuario     = '';
	LET vd_fecha_reg       = CURRENT;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    FOREACH
		SELECT cve_sucursal, nom_sucursal, tipo_consulta, tipo_cambio, fecha_prog, producto, cve_usuario, nom_usuario, fecha_reg
		INTO vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			 vc_cve_usuario, vc_nom_usuario, vd_fecha_reg
		FROM bditarjcop:"informix".reportetarcop
		WHERE tipo_consulta = cTipo_Con AND fecha_reg::DATE BETWEEN dFecha_ini AND dFecha_fin
		
		RETURN P_COD_RET, P_MENSAJE,vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			   vc_cve_usuario,vc_nom_usuario,vd_fecha_reg WITH RESUME;                 
	END FOREACH;

	IF (TRIM(vc_cve_sucursal) = '') THEN
		LET P_COD_RET = '00001';
		LET P_MENSAJE = 'NO EXISTEN DATOS';
		RETURN P_COD_RET, P_MENSAJE, vc_cve_sucursal, vc_nom_sucursal, vc_tipo_consulta, vc_tipo_cambio, null, vc_producto,
		vc_cve_usuario, vc_nom_usuario, null;
	END IF;
   
END;
END PROCEDURE
DOCUMENT
'AUTOR: MANUEL OSUNA VALENCIA',
'Proyecto: Alta Única',
'Descripcion: Guarda reporte de activacion o desactivacion de productos o sucursales en alta unica, ostelefonica.',
'Fecha: 2012/01/23',
'Version: 20120123.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Se modifica para que las fechas en el return no muestren dato en caso de no existir registros',
'Fecha: 2012/02/14',
'Versión: 20120214.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se modifico tipo de fecha_prog de DATE a CHAR.',
'Fecha: 2012/06/18',
'Versión: 20120618.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_validasucprodaltaunica(
psEmpresa CHAR(3),
psTipoOrigen CHAR(1),
psCodigo CHAR(4),
psProducto CHAR(4)
)

RETURNING CHAR(5); -- Código de retorno

DEFINE vsCodRet					CHAR(5);
DEFINE viSqlErr					INTEGER;
DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE vsSucursales				CHAR(4);

LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET vsCodRet				= '';
LET viSqlErr				= 0;
LET vsSucursales			= '';

--SET DEBUG FILE TO "/dbexport/sp_validasucprodaltaunica.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr;
	END IF;
END EXCEPTION;

IF (psProducto == "6500") THEN --Valida Producto TDC
	IF (psTipoOrigen = "E") THEN
		--Obtiene cantidad de sucursales del estado.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal del estado.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S"
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "R") THEN
		--Obtiene cantidad de sucursales por region.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
		AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal de la region.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "S") AND (psCodigo == "") THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND tpo_sucursal = "S"
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "S") AND (psCodigo <> "") THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
		--Obtiene la sucursal.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
		--Valida si esta activada en altaunica.
		IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
			LET viActivadas = viActivadas + 1;
		END IF;
	ELIF (psTipoOrigen == "D") THEN
		--Obtiene cantidad de sucursales por division.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal de la division.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	END IF;
	--Si la cantidad de sucursales activadas en alta unica del estado coincide con la cantidad total de sucursales de ese estado, continua...
	IF (viActivadas == viCantidadSuc) THEN
		LET vsCodRet = "00000";
	ELSE
		LET vsCodRet = "00003";
	END IF;
ELSE
	LET vsCodRet = "00000";
END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Valida que la(s) sucursal(es) esten activadas en alta única antes de ofertar el producto 6500 TDC coppel.',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_clausurarsucursaltarcop(
psEmpresa CHAR(3),
psCierraInv CHAR(1),
psClaveSucursal CHAR(4)
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Desactivar la opción de caja única de una sucursal y bloquear el manejo de tarjetas coppel.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 03/02/2009
-- BD: bditarjcop
-- SISTEMA : Caja Unica
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsEmpresa CHAR(3);
DEFINE vsCveSucursal CHAR(5);
DEFINE vsTipoTarjeta CHAR(1);
DEFINE vsNumEnvio CHAR(9);
DEFINE vdFechaSurt DATETIME YEAR TO FRACTION(5);
DEFINE viCantidadRec INTEGER;
DEFINE viRangoIni INTEGER;
DEFINE viRangoFin INTEGER;
DEFINE vdFechaRec DATETIME YEAR TO FRACTION(5);
DEFINE vsEnvioDisponible CHAR(1);
DEFINE vsEmpleadoRec CHAR(9);
DEFINE vsNumGuia CHAR(25);
DEFINE vdFechaGuia DATETIME YEAR TO FRACTION(5);
DEFINE vsTipoSurtido CHAR(2);

DEFINE vdFecha DATETIME YEAR TO FRACTION(5);
DEFINE vsFechaMesAct CHAR(7);
DEFINE viConsumo INTEGER;
DEFINE viExistencia INTEGER;

LET viSqlErr = 0;
LET vsCodRet = "00000";
LET vsEmpresa = '';
LET vsCveSucursal = '';
LET vsTipoTarjeta = '';
LET vsNumEnvio = '';
LET vdFechaSurt = CURRENT;
LET viCantidadRec = 0;
LET viRangoIni = 0;
LET viRangoFin = 0;
LET vdFechaRec = CURRENT;
LET vsEnvioDisponible = '';
LET vsEmpleadoRec = '';
LET vsNumGuia = '';
LET vdFechaGuia = CURRENT;
LET vsTipoSurtido = '';

LET vdFecha = CURRENT;
LET vsFechaMesAct = '';
LET viConsumo = 0;
LET viExistencia = 0;

--SET DEBUG FILE TO "/tmp/sp_ClausurarSucursalTarCop.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	END IF;
END EXCEPTION;

--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este en operacion.
IF EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
	--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este con la opcion de caja unica activa.
	IF EXISTS(SELECT empresa, cvesucursal, cajaunica FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND cajaunica = 'V')THEN
		--El Sistema Inventario Caja Unica actualiza la opcion de caja unica de la sucursal a estatus inactiva y reinicia la fecha de activacion.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjcop:"informix".sucursalescajaunica SET cajaunica = 'F', fechaactcu = '1900-01-01 00:00:00.0' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
		--El Sistema Inventario Caja Unica marca como "Cancelado" a todos los envios asignados a la sucursal indicada por el Sistema de operaciones.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjcop:"informix".enviostarcop SET enviodisponible = 'C' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
		--El Sistema Inventario Caja Unica guarda en el histórico el inventario actual de la sucursal indicada por el Sistema de operaciones.
		IF(psCierraInv == "V")THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT empresa, cvesucursal, tipotarjeta, numenvio, fechasurt, cantidadrec, rangoini, rangofin, fecharec, enviodisponible, empleadorec, numguia, fechaguia, tiposurtido
				INTO vsEmpresa, vsCveSucursal, vsTipoTarjeta, vsNumEnvio, vdFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vdFechaRec, vsEnvioDisponible, vsEmpleadoRec, vsNumGuia, vdFechaGuia, vsTipoSurtido
				FROM bditarjcop:"informix".enviostarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal
				
				INSERT INTO bditarjcop:"informix".envioshisttarcop(
				empresa, cvesucursal, tipotarjeta, numenvio, fechasurt, cantidadrec, rangoini, rangofin, fecharec, enviodisponible, empleadorec, numguia, fechaguia, tiposurtido)
				VALUES(
				vsEmpresa, vsCveSucursal, vsTipoTarjeta, vsNumEnvio, vdFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vdFechaRec, vsEnvioDisponible, vsEmpleadoRec, vsNumGuia, vdFechaGuia, vsTipoSurtido);
			END FOREACH;
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			DELETE bditarjcop:"informix".enviostarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--Verifica si el consumo y la existencia de esta sucursal se encuentra en cero.
			IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND consumo = 0 AND existencia = 0)THEN
				--El Sistema Inventario Caja Unica guarda en el histórico el inventario actual de la sucursal indicada por el Sistema de operaciones.
				LET vdFecha = CURRENT MONTH TO MONTH;
				LET vsFechaMesAct = SUBSTRING(vdFecha FROM 6 FOR 2) || '/' || SUBSTRING(vdFecha FROM 1 FOR 4);
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				FOREACH
				SELECT empresa, cvesucursal, consumo, existencia, tipotarjeta
				INTO vsEmpresa, vsCveSucursal, viConsumo, viExistencia, vsTipoTarjeta
				FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal
				
				INSERT INTO bditarjcop:"informix".estadisticahisttarcop(
				empresa, cvesucursal, consumo, existencia, fecha, tipotarjeta)
				VALUES(
				vsEmpresa, vsCveSucursal, viConsumo, viExistencia, vsFechaMesAct, vsTipoTarjeta);
				END FOREACH;
			END IF;
			--El Sistema Inventario Caja Unica elimina del inventario todos los registros de la sucursal indicada por el Sistema de operaciones.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			DELETE bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--La operación se realizo de manera exitosa.
			LET vsCodRet = '00000';
		END IF;
	--La sucursal no existe en caja unica.
	ELSE
		LET vsCodRet = '01400';
	END IF;
	--La sucursal no esta en operacion.
ELSE
	LET vsCodRet = '01400';
END IF;

RETURN vsCodRet;

END 
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Desactivar la opción de caja única de una sucursal y bloquear el manejo de tarjetas coppel.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Se agrega flag para cerrar o no, el inventario existente para la sucursal a clausurar en alta única.',
'Fecha: 2012/01/06',
'Version: 20120106.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_conslotepend(pSucursal CHAR(4), pEmpresa CHAR(3))

RETURNING CHAR(5), CHAR(4), CHAR(1), INTEGER, INTEGER, INTEGER, CHAR(1), DATE;

	-- Autor: Manuel Ramos Figueroa
	-- Actividad: Consulta los envios de lotes de tarjetas por sucursal.
	-- Fecha de Solicitud: 05/11/2012

	DEFINE iSqlErr, iIsamErr	INTEGER;
	DEFINE cCodRetorno			CHAR(5);
	DEFINE cSucursal			CHAR(4);
	DEFINE cTipoTarjeta			CHAR(1);
    DEFINE iNumEnvio			INTEGER;
	DEFINE iRangoIni			INTEGER;
	DEFINE iRangoFin			INTEGER;
    DEFINE cStatus				CHAR(1);
	DEFINE dFechaSurtido		DATE;
	DEFINE cAux					CHAR(4);
	DEFINE cAux2				CHAR(4);
	DEFINE iTotalN				INTEGER;
	DEFINE iTotalR				INTEGER;

    LET cCodRetorno		= "00000";
	LET cSucursal		= "";
	LET cTipoTarjeta	= "";
    LET iNumEnvio		= 0;
	LET iRangoIni		= 0;
	LET iRangoFin		= 0;
    LET cStatus			= "";
	LET dFechaSurtido	= "";
	LET cAux			= "";
	LET cAux2			= "";
	LET iTotalN			= 0;
	LET iTotalR			= 0;

   --SET DEBUG FILE TO "/informix/lflores/sp_conslotepend.out";
   --TRACE ON;

    BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRetorno = iSqlErr;
				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT LIMIT 1 cvesucursal INTO cAux FROM bditarjcop:"informix".enviostarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;
		SELECT LIMIT 1 cvesucursal INTO cAux2 FROM bditarjcop:"informix".envioshisttarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;

		IF (cAux <> "" OR cAux2 <> "") THEN			
			FOREACH
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				INTO cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido 
				FROM bditarjcop:"informix".enviostarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal
				AND enviodisponible <> ''
				
				UNION ALL
				
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				FROM bditarjcop:"informix".envioshisttarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal 
				AND enviodisponible <> ''
				ORDER BY numenvio DESC, tipotarjeta

				IF (cTipoTarjeta == "N") THEN
					LET iTotalN = iTotalN + 1;
					IF iTotalN > 5 THEN
						CONTINUE FOREACH;
					END IF;
				ELIF (cTipoTarjeta == "R") THEN
					LET iTotalR = iTotalR + 1;
					IF iTotalR > 5 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;

				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido WITH RESUME;
			END FOREACH;
		ELSE
			--No existe la sucursal
			LET cCodRetorno = "00001";
			RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
		END IF;
    END;
END PROCEDURE;