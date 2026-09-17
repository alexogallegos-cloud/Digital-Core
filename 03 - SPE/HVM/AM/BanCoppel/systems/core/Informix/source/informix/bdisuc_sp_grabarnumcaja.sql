CREATE PROCEDURE "informix".sp_grabarnumcaja(p_sEmpresa CHAR(3), 
											p_sNumeroCaja CHAR(10), 
											p_sSucursal CHAR(4),
											p_dFechaRegistro DATE, 
											p_iTipoPaquete SMALLINT, 
											pcEstatus CHAR(10),
											pcUsuarioalta CHAR(10),
											pcFechaalta DATE,
											cSucursalCrea  CHAR(4))
	RETURNING CHAR(6) AS retorno;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_dFechaInsercion				DATE;

	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_GrabarNumCaja_out.sql";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno = '000001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		--dsb-29/08/2012
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumeroCaja,'') = '' OR NVL(p_sSucursal,'') = ''
		OR NVL(p_dFechaRegistro ,'') = '' OR NVL(p_iTipoPaquete ,'') = '' OR NVL(cSucursalCrea, '') = '' THEN

			RETURN v_sValRetorno;

		END IF;

		--SI NO EXISTE GUARDA, SI EXISTE MANDA UN ERROR
		IF NOT EXISTS (SELECT 1 FROM bdisuc:"informix".ss_numcajas WHERE empresa = p_sEmpresa
						AND numerocaja = p_sNumeroCaja AND numsucursal = p_sSucursal) THEN
			--dsb-29/08/2012
			INSERT INTO bdisuc:"informix".ss_numcajas(empresa, numerocaja, numsucursal, tipopaquete, fecha_insert, estatus,usuarioalta,fechaalta,numsuc_crea)
			VALUES (p_sEmpresa, p_sNumeroCaja, p_sSucursal, p_iTipoPaquete, p_dFechaRegistro, pcEstatus,pcUsuarioalta,pcFechaalta, cSucursalCrea);
			LET v_sValRetorno = '000000';
		ELSE
			LET v_sValRetorno = '000003';
		END IF;
		RETURN v_sValRetorno;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Vladimir Félix Gálvez',
'FECHA: 05-Agosto-2009',
'CASO DE USO: PCU-bdisuc\CU-0018-GrabarNumCaja-SPL',
'DESCRIPCION: Guarda la información de las cajas en el catalogo de las cajas registradas.',
'MODIFICO: Josue Zepeda',
'FECHA: 18-Abril-2012',
'DESCRIPCION: Se agregaron parametros pcEstatus, pcUsuarioalta, pcFechaalta para que sea insertado en tabla ss_numcajas',
'BD: bdisuc',
'MODIFICADO: Victor Hugo Nuñez',
'FECHA: 29-Agosto-2012',
'DESCRIPCION: Se guarda la sucursal que crea la caja.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_sucrelacionada(cEmpresa CHAR(3),
												cSucursalMat		CHAR(4),
												cSucursalRel		CHAR(4),
												cCaja				CHAR(10),
												cStatusRel			CHAR(1),
												cUsuario 			CHAR(8),
												iRegistro			INTEGER,
												iTipoModo			INTEGER)

RETURNING 			CHAR(6)		AS retorno, 
					CHAR(4)		AS sucursal_relacion,
					CHAR(40)	AS nombre_suc,
					CHAR(1)		AS estatus,
					DATE		AS fecha_alta,
					DATE		AS fecha_cambio,
					CHAR(8)		AS usuario_alta,
					CHAR(8)		AS usuario_cambio;
	
	DEFINE iSqlErr				INTEGER;
	DEFINE cCodret				CHAR(6);
	DEFINE cSucursal			CHAR(4);
	DEFINE cSucRelacion			CHAR(4);
	DEFINE cEstatus				CHAR(1);
	DEFINE dAlta				DATE;
	DEFINE dCambio				DATE;
	DEFINE cUsrAlta				CHAR(8);
	DEFINE cUsrCambio			CHAR(8);
	DEFINE cNombre				CHAR(40);
	DEFINE cTipo				CHAR(1);
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_sucrelacionada.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	
	LET iSqlErr			= 0;
	LET cCodret			= '000000';
	LET cSucursal		= '';
	LET cSucRelacion	= '';
	LET cEstatus		= '';
	LET dAlta			= MDY(01,01,1900);
	LET dCambio			= MDY(01,01,1900); 
	LET cUsrAlta		= '';
	LET cUsrCambio		= '';
	LET cNombre			= '';
	LET cTipo			= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--EL PARAMETRO NO PUEDE SER NULO
		IF NVL(cSucursalMat,'') = '' OR NVL(cEmpresa,'') = '' OR NVL(iTipoModo,'') = '' THEN
			LET cCodret = '000001';
			RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
		END IF;
		
		IF iTipoModo = 0 THEN --CONSULTA
			IF NVL(cSucursalRel,'') = '' THEN --TRAER TODAS LAS SUCURSALES
				LET cCodret = '000002';
				FOREACH
					SELECT SKIP iRegistro 
					rel.empresa, rel.sucursal_matriz, rel.sucursal_relacionada, rel.status_relacion, rel.fecha_altarel, rel.fecha_cambiorel,
					rel.usuario_altarel, rel.usuario_cambiorel, suc.nombre
					INTO cCodret, cSucursal, cSucRelacion, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio, cNombre
					FROM bdisuc:"informix".ss_sucursalesrelacionadas rel, bdinteg:"informix".si_sucursales suc
					WHERE rel.empresa = cEmpresa 
					AND rel.sucursal_matriz = cSucursalMat 
					AND suc.sucursal = rel.sucursal_relacionada
					AND rel.sucursal_matriz <> rel.sucursal_relacionada
					LET cCodret = '000000';
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio WITH RESUME;
				END FOREACH;
				IF cCodret = '000002' THEN
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
				END IF;
			ELSE
				IF cSucursalMat <> cSucursalRel THEN
					--BUSCA SI EXISTE LA SUCURSAL 
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursalRel) THEN
						--BUSCA LA RELACION ENTRE SUCURSALES
						IF  EXISTS (SELECT 1 FROM bdisuc:"informix".ss_sucursalesrelacionadas 
						WHERE sucursal_matriz = cSucursalMat 
						AND sucursal_relacionada = cSucursalRel AND status_relacion  ='A') THEN
							LET cCodret = '000000';
						ELSE
							LET cCodret = '000002';
						END IF;
					ELSE--NO EXISTE LA SUCURSAL RELACIONADA
						LET cCodret = '000004';
					END IF
				ELSE
					LET cCodret = '000000';
				END IF;
				--BUSCA LA CAJA Y LA SUCURSAL QUE LA CREO
				IF EXISTS(SELECT 1 FROM bdisuc:"informix".ss_numcajas WHERE numerocaja = cCaja) THEN
					SELECT NVL(numsuc_crea,numsucursal) INTO cSucRelacion FROM bdisuc:"informix".ss_numcajas WHERE numerocaja = cCaja;
					IF cSucRelacion <>  cSucursalMat THEN 
						LET cCodret = '000003'; -- LA SUCURSAL NO CREO LA CAJA
					ELSE
						LET cCodret = '000000'; -- LA SUCURSAL CREO LA CAJA
					END IF
				END IF;
				RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			END IF
		ELIF iTipoModo = 1 THEN --GRABA
			--VALIDA LOS CAMPOS A INSERTAR
			IF NVL(cSucursalMat,'') = '' OR NVL(cSucursalRel,'') = '' OR NVL(cStatusRel,'') = '' OR NVL(cUsuario,'')  = '' THEN
				LET cCodret = '000001';
				RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			ELSE
				LET dAlta = CURRENT::DATE;
				--VERIFICAR QUE NO SEA RELACION CON LA MISMA SUCURSAL
				IF cSucursalMat  <> cSucursalRel THEN
					--VERIFICAR QUE SEA N
					SELECT tpo_sucursal INTO cTipo FROM bdinteg:"informix".si_sucursales WHERE empresa = cEmpresa AND sucursal = cSucursalRel;
					IF NVL(cTipo, '') = '' THEN
						LET cCodret = '000003';
					ELSE
						IF cTipo = 'S' THEN
							LET cCodret = '000002';
						ELSE
							LET cCodret = '000000';
							--VERIFICAR QUE AMBAS SUCURSALES NO TENGAN UNA RELACION CON OTRA SUCURSAL MATRIZ
							FOREACH
								SELECT sucursal_matriz INTO cSucursal FROM bdisuc:"informix".ss_sucursalesrelacionadas 
								WHERE sucursal_relacionada IN (cSucursalRel,cSucursalMat)
								AND status_relacion = 'A' AND sucursal_matriz <> cSucursalMat
								AND sucursal_matriz <> sucursal_relacionada
								LET cCodret = '000002';
							END FOREACH;
							IF cCodret <> '000002' THEN
								--VERIFICA QUE LA SUCURSAL RELACIONADA NO SEA UNA SUCURSAL MATRIZ
								FOREACH
									SELECT sucursal_matriz INTO cSucursal
									FROM bdisuc:"informix".ss_sucursalesrelacionadas 
									WHERE sucursal_matriz = cSucursalRel
									AND status_relacion = 'A'
									AND sucursal_matriz <> sucursal_relacionada
									LET cCodret = '000002';
								END FOREACH;
							END IF;
						END IF;
					END IF;
				ELSE
					LET cCodret = '000000';
				END IF;
				IF cCodret = '000000' THEN
					LET cCodret = '000001';
					--SI EXISTE ACTUALIZA SI NO INSERTA
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_sucursalesrelacionadas 
					WHERE empresa = cEmpresa AND sucursal_matriz = cSucursalMat AND sucursal_relacionada = cSucursalRel) THEN
						UPDATE bdisuc:"informix".ss_sucursalesrelacionadas SET status_relacion = cStatusRel, fecha_cambiorel = dAlta, 
						usuario_cambiorel = cUsuario 
						WHERE empresa = cEmpresa AND sucursal_matriz = cSucursalMat AND sucursal_relacionada = cSucursalRel;
						LET cCodret = '000000';
						RETURN cCodret, cSucRelacion, cNombre, cEstatus, dCambio, dAlta, cUsrAlta, cUsrCambio;
					ELSE
						INSERT INTO bdisuc:"informix".ss_sucursalesrelacionadas (empresa, sucursal_matriz, sucursal_relacionada, status_relacion, 
						fecha_altarel, fecha_cambiorel, usuario_altarel, usuario_cambiorel) 
						VALUES (cEmpresa, cSucursalMat, cSucursalRel, cStatusRel, dAlta, dCambio, cUsuario, cUsrCambio);
						LET cCodret = '000000';
						RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
					END IF;
				ELSE
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Victor Hugo Nuñez',
'FECHA: 23/Agosto/2012',
'BD: BDISUC',
'DESCRIPCION: Guarda, elimina y consulta las sucursales relacionadas';

CREATE PROCEDURE "informix".reversion_ant(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wtransacc           char(4);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wnaturaleza         char(1);
   DEFINE wtipo               char(1);
   DEFINE wfechoy             date;
   DEFINE wfechahora          datetime hour to minute;
   DEFINE wfolio_oper         char(8);

   LET sql_err 		= 0;
   LET isam_err 	= 0;
   LET cod_ret 		= '000';
   LET contador 	= 0;
   LET wtransacc 	= '0000';
   LET wnaturaleza 	= '0';
   LET wtipo 		= '0';
   LET wfechoy 		= " ";
   LET wfechahora 	= " ";
   LET wfolio_oper 	= '00000000';

  --SET DEBUG FILE TO "reversiondot.out";
  --TRACE ON;

	BEGIN
		ON EXCEPTION
		SET sql_err, isam_err
		IF (sql_err <> 0) THEN
			SET DEBUG FILE TO "reversiondot.err";
			TRACE sql_err || " * " || isam_err;
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	END EXCEPTION;

	SELECT fecha_hoy into wfechoy
	FROM bdinteg:"informix".si_fechas where empresa = pempresa;

    SELECT COUNT(*) INTO contador
	FROM "informix".ss_operaciones m, bdinteg:"informix".si_transacc t
	WHERE m.empresa = pempresa and folio_sucursal = pfolio and
		m.empresa = t.empresa and m.cod_trans = t.numero and
		reversable = "S" and m.reversado <> "S" AND 
		m.fecha_operacion = wfechoy;
		
IF (contador = 0) THEN
		RETURN cod_ret;
	ELSE -- Checa si hay Dotaciones y en Status de Reversarse 
		SELECT folio_oper INTO wfolio_oper 
		FROM   "informix".ss_operaciones
		WHERE  empresa = pempresa AND folio_sucursal = pfolio
		AND    fecha_operacion = wfechoy;
		SELECT COUNT(*) INTO contador 
		FROM   "informix".ss_mae_entradasalida 
		WHERE  folio_oper = wfolio_oper
		AND    status in ('01','06');
		IF contador = 0 THEN 
			LET cod_ret = "888"; 
			RETURN cod_ret;
		ELSE  -- Reversa si es Falso el Maestro y el Movimiento
			-- Se cambia 'S' por '1' para evitar el error -1213 al reintentar de nuevo realizar la devolucion
			UPDATE "informix".ss_operaciones SET reversado = '1'  
			WHERE  empresa = pempresa AND folio_sucursal = pfolio
			AND    fecha_operacion = wfechoy;
			UPDATE "informix".ss_mae_entradasalida SET status = '08',
			fecha_reversion = wfechoy,hora_reversion = wfechahora,
			usuario_reversion = pusuario
			WHERE  folio_oper = wfolio_oper;
		END IF
	end if
   RETURN cod_ret;
END;
END PROCEDURE;