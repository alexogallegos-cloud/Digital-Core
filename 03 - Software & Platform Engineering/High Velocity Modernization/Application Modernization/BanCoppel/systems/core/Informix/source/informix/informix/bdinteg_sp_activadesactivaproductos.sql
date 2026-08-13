CREATE PROCEDURE "informix".sp_activadesactivaproductos(
psEmpresa CHAR(3), 
piTipo INTEGER, 
psTipoOrigen CHAR(1), 
psCodigo CHAR(4), 
psProducto CHAR(4), 
psSistema CHAR(2),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5); -- Código de retorno

-- Declaración de variables
DEFINE vsCodRet					CHAR(5);
DEFINE viSqlErr					INTEGER;
DEFINE viSamErr					INTEGER;
DEFINE vsErrorInfo				CHAR(60);
DEFINE vsSucursales				CHAR(4);
DEFINE viExiste					INTEGER;
DEFINE vsFlagAltaU				CHAR(1);
DEFINE vsNombreSuc				CHAR(40);
DEFINE viAuxiliar				INTEGER;

DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE viDesactivadas		INTEGER;
DEFINE vsiTipo				INTEGER;
LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET viDesactivadas		= 0;
LET vsiTipo 			= 0;

-- Asignación variables
LET vsCodRet				= '00000';
LET viSqlErr				= 0;
LET viSamErr				= 0;
LET vsErrorInfo				= '';
LET vsSucursales			= '';
LET viExiste				= 0;
LET vsFlagAltaU				= '';
LET vsNombreSuc				= '';

BEGIN

ON EXCEPTION SET viSqlErr, viSamErr, vsErrorInfo
	LET vsCodRet = viSqlErr;
	RETURN vsCodRet;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_activadesactivaproductos.sql";
--TRACE ON;
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

LET vsiTipo = piTipo;

IF (vsiTipo = 1) THEN --Activación
	IF (psTipoOrigen = 'E') THEN --Activacion de productos para Estado
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT ptf.id_ptf, suc.nombre INTO vsSucursales, vsNombreSuc 
				FROM bdinteg:"informix".si_ptf ptf
				INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
				WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S' AND ptf.tipo <> 'C'
				/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S'*/
				SELECT COUNT(*) INTO viAuxiliar FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto;
				IF (viAuxiliar = 0) THEN
				/*IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN*/
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF (psTipoOrigen = 'R') THEN --Activacion de productos para Region
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT ptf.id_ptf, sisuc.nombre INTO vsSucursales, vsNombreSuc 
				FROM bdinteg:"informix".si_ptf AS ptf,
					 bdinteg:"informix".si_sucursales AS sisuc, 
					 bdinteg:"informix".si_ciudades AS siciu,
					 bdinteg:"informix".si_catciudades AS sicat, 
					 bdinteg:"informix".si_regiones AS sireg
				WHERE ptf.id_ptf = sisuc.sucursal AND ptf.tipo = sisuc.tipo
				AND sisuc.tpo_sucursal = 'S' AND ptf.tipo <> 'C'AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
				AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
				/*SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
											   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
				WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
				AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
				SELECT COUNT (*) INTO viAuxiliar
				FROM bdinteg:"informix".si_prod_sucursal 
				WHERE sucursal = vsSucursales AND num_producto = psProducto;
				IF (viAuxiliar = 0) THEN 
				/*IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN*/
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo <> '')) THEN --Activacion de productos para Sucursal
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			SELECT si_ptf.id_ptf, si_sucursales.nombre INTO vsSucursales, vsNombreSuc 
			FROM bdinteg:"informix".si_ptf
			INNER JOIN bdinteg:"informix".si_sucursales ON (si_ptf.id_ptf = si_sucursales.sucursal AND si_ptf.tipo = si_sucursales.tipo)
			WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S' AND si_ptf.tipo <> 'C';
			/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';*/
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			SELECT COUNT(num_producto) INTO viExiste FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = psCodigo AND num_producto = psProducto;
			IF (viExiste = 0) THEN
				INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
				VALUES (psEmpresa, psCodigo, psProducto, psSistema);
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;

			SELECT COUNT(*) INTO viAuxiliar FROM bdisolic:"informix".ss_control_parametricos where empresa = psEmpresa AND sucursal = psCodigo AND num_producto = psProducto;
			IF (viAuxiliar = 0) THEN
			/*IF NOT EXISTS(SELECT * FROM bdisolic:"informix".ss_control_parametricos where empresa = psEmpresa AND sucursal = psCodigo AND num_producto = psProducto) THEN*/
				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6001', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix',TODAY);

				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6600', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix', TODAY);

				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6300', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix', TODAY);

                INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6500', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix', TODAY);
			END IF;
		END IF;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo = '')) THEN --Activacion de productos para todas las Sucursales
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT ptf.id_ptf, nombre INTO vsSucursales, vsNombreSuc 
				FROM bdinteg:"informix".si_ptf ptf
				INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
				WHERE tpo_sucursal = 'S' AND ptf.tipo <> 'C'
				/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = 'S'*/

				SELECT COUNT(*) INTO viAuxiliar FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto;
				IF (viAuxiliar = 0) THEN
				/*IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN*/
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF (psTipoOrigen = 'D') THEN --Activacion de productos para Division
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			--SET LOCK MODE TO WAIT 3;
			--SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT ptf.id_ptf, nombre INTO vsSucursales, vsNombreSuc 
				FROM bdinteg:"informix".si_ptf ptf
				INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
				WHERE plaza = psCodigo AND tpo_sucursal = 'S' AND ptf.tipo <> 'C'
				/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'*/

				SELECT COUNT (*) INTO viAuxiliar FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto;
				IF (viAuxiliar = 0) THEN
				/*IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN*/
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	END IF;
ELIF (vsiTipo = 0) THEN--Desactivacion
	IF (psTipoOrigen = 'E') THEN --Desactivacion de productos para Estado
		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ptf.id_ptf, nombre INTO vsSucursales, vsNombreSuc 
			FROM bdinteg:"informix".si_ptf ptf
			INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
			WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S' AND ptf.tipo <> 'C'
			/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S'*/
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF (psTipoOrigen = 'R') THEN --Desactivacion de productos para Region
		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ptf.id_ptf, sisuc.nombre INTO vsSucursales, vsNombreSuc 
			FROM bdinteg:"informix".si_ptf AS ptf,
				 bdinteg:"informix".si_sucursales AS sisuc, 
				 bdinteg:"informix".si_ciudades AS siciu,
				 bdinteg:"informix".si_catciudades AS sicat, 
				 bdinteg:"informix".si_regiones AS sireg
			WHERE ptf.id_ptf = sisuc.sucursal AND ptf.tipo = sisuc.tipo
			AND sisuc.tpo_sucursal = 'S' AND ptf.tipo <> 'C' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			/*SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
										   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo*/
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo <> '')) THEN --Desactivacion de productos para Sucursal
		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		SELECT ptf.id_ptf, suc.nombre INTO vsSucursales, vsNombreSuc 
		FROM bdinteg:"informix".si_ptf ptf
		INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
		WHERE sucursal = psCodigo AND tpo_sucursal = 'S' AND ptf.tipo <> 'C';
		/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = psCodigo AND tpo_sucursal = 'S';*/
		DELETE FROM bdinteg:"informix".si_prod_sucursal 
		WHERE empresa = psEmpresa AND sucursal = psCodigo AND num_producto = psProducto AND sistema = psSistema;
		EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo = '')) THEN --Desactivacion de productos para todas las Sucursales
		---SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ptf.id_ptf, nombre INTO vsSucursales, vsNombreSuc 
			FROM bdinteg:"informix".si_ptf ptf
			INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
			WHERE tpo_sucursal = 'S' AND ptf.tipo <> 'C'
			/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = 'S'*/
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF (psTipoOrigen = 'D') THEN --Desactivacion de productos para Division
		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT ptf.id_ptf, nombre INTO vsSucursales, vsNombreSuc 
			FROM bdinteg:"informix".si_ptf ptf
			INNER JOIN bdinteg:"informix".si_sucursales suc ON (ptf.id_ptf = suc.sucursal AND ptf.tipo = suc.tipo)
			WHERE plaza = psCodigo AND tpo_sucursal = 'S' AND ptf.tipo <> 'C'
			/*SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'*/
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	END IF;
END IF;

RETURN vsCodRet;
	
END;
END PROCEDURE




DOCUMENT
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Activa y desactiva productos por grupo de sucursales o individual.',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bdinteg',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se modifico tipo de parametro de cha a smallint.',
'Fecha: 2012/06/18',
'Versión: 20120618.1800',
'BD: bditarjcop''MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se agrego Set lock mode to wait a Desactivacion de productos para Sucursal.',
'Fecha: 2012/07/06',
'Versión: 20120706.1800',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacatsucursales(pDesde INTEGER, pHasta INTEGER)
RETURNING CHAR(6), CHAR(80), CHAR(2), CHAR(3), CHAR(4), CHAR(40), CHAR(81), CHAR(14), CHAR(14);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err                      INTEGER;
DEFINE isam_err                     INTEGER;
DEFINE error_info                   CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);

DEFINE v_estado         CHAR(2);
DEFINE v_ciudad         CHAR(3);
DEFINE v_sucursal      CHAR(4);
DEFINE v_nombre      CHAR(40);
DEFINE v_direccion     CHAR(81);
DEFINE v_telefono1       CHAR(14);
DEFINE v_telefono2       CHAR(14);

------------------------------------------------------------

-- Creado: Walber Castro
-- Fecha: 28 de mayo de 2010
-- Crear en BDINTEG
-- Se crea con el objetivo de consultar el catalogo de sucursales.
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';

LET v_estado = '';
LET v_ciudad = '';
LET v_sucursal  ='';
LET v_nombre = '';
LET v_direccion = '';
LET v_telefono1 = '';
LET v_telefono2 = '';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
          LET cCod_ret = sql_err;
            LET cMensaje = error_info;
      RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2;
      END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_consultacatsucursales.out";
--TRACE ON;
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

foreach
    /*SELECT SKIP pDesde FIRST pHasta NVL(estado,''), NVL(ciudad,''), NVL(sucursal,''), TRIM(NVL(nombre,'')), TRIM(NVL(direccion1,'')) || ' ' ||  TRIM(NVL(direccion2,'')), TRIM(NVL(telefono1,'')), TRIM( NVL(telefono2,'')) 
   INTO v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2
    FROM bdinteg:si_sucursales ORDER BY estado, ciudad, sucursal*/

    SELECT SKIP pDesde FIRST pHasta NVL(ptf.cve_estado,''), NVL(ptf.cve_ciudad,''), NVL(id_ptf,''), TRIM(NVL(suc.nombre,'')), TRIM(NVL(ptf.calle||' NUM '||ptf.num_ext,'')) || ' ' ||  TRIM(NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp,'')), TRIM(NVL(tel1,'')), TRIM( NVL(tel2,'')) 
           INTO v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2
    FROM bdinteg:si_ptf ptf 
    INNER JOIN bdinteg:si_sucursales suc ON (ptf.id_ptf =  suc.sucursal AND ptf.tipo = suc.tipo)
    LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
    WHERE ptf.tipo <> 'C'
    ORDER BY ptf.cve_estado, ptf.cve_ciudad, ptf.id_ptf

    RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2 WITH RESUME;
    LET cCod_ret = '';
    LET cMensaje = '';
END foreach;

END;
END PROCEDURE;