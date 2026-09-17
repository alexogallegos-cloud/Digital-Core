CREATE PROCEDURE "informix".sp_consultarcattipocarpeta(p_sEmpresa CHAR(3), p_iTipoCarpeta SMALLINT)
	RETURNING	CHAR(6) AS retorno,
				CHAR(3) AS empresa,
				SMALLINT AS tipocarpeta,
				CHAR(80) AS descripcion;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(6);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_iTipoCarpeta					SMALLINT;
	DEFINE v_sDescripcion					CHAR(80);	

	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarCatTipoCarpeta.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET v_sValRetorno = '000001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','';
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		 

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' THEN
			RETURN v_sValRetorno,'','','';
		END IF;

		IF p_iTipoCarpeta = '' THEN
			LET p_iTipoCarpeta = NULL;
		END IF;

		--OBTIENE EL CATALOGO DE TIPOS DE CARPETA
		FOREACH
			SELECT empresa, tipocarpeta, descripcion
			INTO v_sEmpresa, v_iTipoCarpeta, v_sDescripcion
			FROM bdisuc:"informix".ss_cattipocarpeta
			WHERE empresa = p_sEmpresa AND tipocarpeta = NVL(p_iTipoCarpeta, tipocarpeta)

			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno,  v_sEmpresa, v_iTipoCarpeta, v_sDescripcion WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 05/Agosto/2009',
'DESCRIPCION: Obtiene todos los datos del catalogo de tipos de carpeta',
'CASO DE USO: PCU-bdisuc\CU-0020-ConsultarCatTipoCarpeta-SPL';

CREATE PROCEDURE "informix".sp_consultardoctosadmon(p_sEmpresa CHAR(3), p_sSucursal CHAR(4), p_iTipoCarpeta SMALLINT, 
										p_sNumCarpeta CHAR(4), p_sNumCaja CHAR(10), p_dFecha DATE, p_iCantRegistros INTEGER)
	RETURNING	CHAR(6)  AS retorno,
				CHAR(3)  AS empresa,
				CHAR(10) AS numerocaja, 
				CHAR(4)  AS numerocarpeta,
				DATE     AS fechainicio,
				DATE     AS fechafinal,
				CHAR(4)  AS sucursal,
				CHAR(1)  AS estatus,
				DATE     AS fechainsert,
				SMALLINT AS tipocarpeta,
				CHAR(80) AS desCarpeta,
				CHAR(8)  AS numUsuarioRegistro,
				CHAR(45) AS desUsuarioRegistro,
				CHAR(8)  AS numUsuarioAutorizo,
				CHAR(45) AS desUsuarioAutorizo,					
				CHAR(8)  AS numUsuarioSolicita,
				CHAR(45) AS desUsuarioSolicita,
				CHAR(100) AS desComentario;
	
	DEFINE iSqlErr					INTEGER;
	DEFINE v_sValRetorno			CHAR(6);
	DEFINE v_sEmpresa				CHAR(3);
	DEFINE v_sNumCaja				CHAR(10);
	DEFINE v_sNumCarpeta			CHAR(4);
	DEFINE v_iTipoCarpeta			SMALLINT;
	DEFINE v_sDesCarpeta			CHAR(80);
	DEFINE v_dFechaInicio			DATE;
	DEFINE v_dFechaFinal			DATE;
	DEFINE v_sSucursal				CHAR(4);
	DEFINE v_sEstatus				CHAR(1);
	DEFINE v_dFechaInsert			DATE;
	DEFINE v_iNumRegistro			INTEGER;
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita	CHAR(45);
	DEFINE v_sDesComentario			CHAR(100);
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarDoctosAdmon.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	
	LET v_sValRetorno = '000001';	
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--LA EMPRESA Y LA SUCURSAL NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sSucursal,'')='' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','';
		END IF;
		
		IF p_iTipoCarpeta = '' THEN
			LET p_iTipoCarpeta = NULL;
		END IF;
		
		IF p_sNumCarpeta = '' THEN
			LET p_sNumCarpeta = NULL;
		END IF;
		
		IF p_sNumCaja = '' THEN
			LET p_sNumCaja = NULL;
		END IF;
		
		IF p_dFecha = '' THEN
			LET p_dFecha = NULL;
		END IF;
		
		FOREACH
			--OBTIENE TODOS LOS DOCUMENTOS DE LA SUCURSAL ESPECIFICADA
			SELECT doc.empresa, doc.numerocaja, cpta.tipocarpeta, NVL(cpta.descripcion,''), doc.numerocarpeta, doc.fechainicio, 
			doc.fechafinal, doc.sucursal, doc.estatus, doc.usuarioregistra, doc.usuarioautoriza, doc.usuariosolicita,
			doc.comentario, doc.fecha_insert 
			INTO v_sEmpresa, v_sNumCaja, v_iTipoCarpeta, v_sDesCarpeta, v_sNumCarpeta, v_dFechaInicio, 
			v_dFechaFinal, v_sSucursal, v_sEstatus, v_sNumUsuarioRegistro, v_sNumUsuarioAutorizo, v_sNumUsuarioSolicita,
	        v_sDesComentario, v_dFechaInsert
			FROM bdisuc:"informix".ss_documentosadmon doc, bdisuc:"informix".ss_cattipocarpeta cpta
			WHERE doc.empresa = p_sEmpresa
			AND doc.tipocarpeta	= NVL(p_iTipoCarpeta, doc.tipocarpeta)		
			AND (NVL(p_dFecha,doc.fechafinal) BETWEEN doc.fechainicio AND doc.fechafinal)
			AND doc.sucursal = p_sSucursal
			AND doc.numerocaja = NVL(p_sNumCaja, doc.numerocaja)
			AND doc.numerocarpeta = NVL(p_sNumCarpeta, doc.numerocarpeta)
			AND cpta.empresa = doc.empresa			
			AND cpta.tipocarpeta = doc.tipocarpeta

			--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
			IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
				SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = p_sEmpresa
				AND ejecutivo = v_sNumUsuarioRegistro;
			ELSE
				LET v_sDesUsuarioRegistro = '';
			END IF

			--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
			IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
				SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = p_sEmpresa
				AND ejecutivo = v_sNumUsuarioAutorizo;
			ELSE
				LET v_sDesUsuarioAutorizo = '';
			END IF
			
			--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
			IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
				SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = p_sEmpresa
				AND ejecutivo = v_sNumUsuarioSolicita;
			ELSE 
				LET v_sDesUsuarioSolicita = '';
			END IF	
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno, v_sEmpresa, v_sNumCaja, v_sNumCarpeta, v_dFechaInicio, v_dFechaFinal, v_sSucursal, v_sEstatus, 
			v_dFechaInsert, v_iTipoCarpeta, v_sDesCarpeta, v_sNumUsuarioRegistro, v_sDesUsuarioRegistro, v_sNumUsuarioAutorizo, 
			v_sDesUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesUsuarioSolicita, v_sDesComentario WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora',
'FECHA :      03/Agosto/2009',
'DESCRIPCION: Obtiene los datos de los documentos administrativos de la sucursal especificada',
'CASO DE USO: Caso de uso asociado PCU-bdisuc\CU-0006-ConsultarDoctosAdmon-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario';

CREATE PROCEDURE "informix".sp_validarcaja(p_sEmpresa CHAR(3), p_sCaja CHAR(10), p_sSucursal CHAR(4), p_iTipoPaquete  SMALLINT)
	RETURNING 	CHAR(6) AS retorno,
				CHAR(3) AS empresa,
				CHAR(10) AS numerocaja,
				CHAR(4) AS numsucursal,
				SMALLINT AS tipopaquete,
				DATE AS fecha_insert,
				CHAR(7) AS status;
				
	
	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(6);
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sNumerocaja		CHAR(10);
	DEFINE v_sNumSucursal		CHAR(4);
	DEFINE v_iTipoPaquete 		SMALLINT;
	DEFINE v_dFechaInsercion	DATE;	
	
	DEFINE v_sSucursal			CHAR(4);
	DEFINE v_iMes				SMALLINT;
	DEFINE v_iAnio				SMALLINT;
	DEFINE v_iConsecutivo		SMALLINT;
	
	DEFINE v_sCajaNueva			CHAR(6);	
	DEFINE v_iMesMayor			SMALLINT;
	DEFINE v_iAnioMayor			SMALLINT;
	DEFINE v_iConsecutivoMayor	SMALLINT;
	DEFINE v_cStatus		    CHAR(7);
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_validarCaja.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET isqlerr 	         = 0;
	LET v_sValRetorno        = '000001';	
	LET  v_sEmpresa			 = '';
	LET  v_sNumerocaja		 = '';
	LET  v_sNumSucursal		 = '';
	LET  v_iTipoPaquete 	 = '';	
	LET  v_dFechaInsercion	 = '';
	LET  v_sSucursal		 = '';
	LET  v_iMes				 = '';
	LET  v_iAnio			 = '';
	LET  v_iConsecutivo		 = '';
	LET  v_sCajaNueva		 = '';
	LET  v_iMesMayor		 = '';
	LET  v_iAnioMayor		 = ''; 
	LET  v_iConsecutivoMayor = '';		
	LET v_cStatus            = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','';
			END IF;
		END EXCEPTION;
		
		
		 SET ISOLATION TO DIRTY READ;
         SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sCaja,'')='' OR p_iTipoPaquete  IS NULL OR NVL(p_sSucursal,'')='' THEN
			RETURN v_sValRetorno,'','','','','','';
		END IF;
		
		SELECT empresa, numerocaja, numsucursal, tipopaquete, fecha_insert,estatus
		INTO v_sEmpresa, v_sNumerocaja, v_sNumSucursal, v_iTipoPaquete, v_dFechaInsercion,v_cStatus
		FROM bdisuc:"informix".ss_numcajas 
		WHERE empresa = p_sEmpresa AND numerocaja = p_sCaja 
		AND numsucursal = p_sSucursal;
		
		--SI LA CAJA EXISTE
		IF v_sNumerocaja IS NOT NULL THEN
			IF v_iTipoPaquete  = p_iTipoPaquete  THEN
				LET v_sValRetorno = '000000'; --EXISTE Y ES EL MISMO TIPO
			ELSE
				LET v_sValRetorno = '000002'; --EXISTE PERO NO ES EL MISMO TIPO
			END IF;
		ELSE
		--SI NO EXISTE
			--para el numero de caja 0316020902
			LET v_sSucursal = SUBSTR(p_sCaja,1,4);		--0316
			LET v_iMes = SUBSTR(p_sCaja,5,2);			--02
			LET v_iAnio = SUBSTR(p_sCaja,7,2);			--09
			LET v_iConsecutivo = SUBSTR(p_sCaja,9,2);	--02
			
			--SE OBTIENE EL NUMERO DE CAJA CON EL AÑO, MES Y CONSECUTIVO MAS ALTO, EN EL FORMATO SIGUIENTE
			--AAMMCC (AÑO-MES-CONSECUTIVO)
			SELECT NVL(MAX((SUBSTR(numerocaja,7,2) || SUBSTR(numerocaja,5,2) || SUBSTR(numerocaja,9,2))::INT),'000000')
			INTO v_sCajaNueva
			FROM bdisuc:"informix".ss_numcajas 
			WHERE numsucursal = v_sSucursal;
			
			LET v_sCajaNueva = LPAD(TRIM(v_sCajaNueva),6,'0');
			LET v_iMesMayor = SUBSTR(v_sCajaNueva,3,2);
			LET v_iAnioMayor = SUBSTR(v_sCajaNueva,1,2);
			LET v_iConsecutivoMayor = SUBSTR(v_sCajaNueva,5,2);
			
			--NO SE PUEDE INGRESAR UNA CAJA CON UN AÑO ANTERIOR, YA QUE LA FECHA ES ASCENDENTE 
			IF v_iAnio < v_iAnioMayor THEN
				LET v_sValRetorno = '000004';			
			ELIF v_iAnio = v_iAnioMayor THEN
				--SI ES EL MISMO AÑO PERO EL MES ES ANTERIOR, TAMBIEN SE MARCA UN ERROR
				IF v_iMes < v_iMesMayor THEN
					LET v_sValRetorno = '000004';			
				--SI ES EL MISMO AÑO Y MES 
				ELIF v_iMes = v_iMesMayor THEN
					--SI  EL CONSECUTIVO NO CORRESPONDE AL SIGUIENTE NUMERO DEL CONSECUTIVO MAYOR, 
					--SE MARCA UN ERROR Y SE REGRESA EL NUMERO DE CAJA CON EL CONSECUTIVO SIGUIENTE AL CONSECUTIVO MAYOR			
					IF v_iConsecutivo <> v_iConsecutivoMayor + 1 THEN
						LET v_sValRetorno = '000005'; --NUMERO CONSECUTIVO INCORRECTO
						LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || LPAD(v_iConsecutivoMayor + 1,2,'0');
					ELSE
						LET v_sValRetorno = '000003'; --NUMERO DE CAJA CORRECTA
					END IF;
					
				--SI ES EL MISMO AÑO Y EL MES ES MAYOR, SE INICIALIZA EL NUMERO CONSECUTIVO EN 01
				ELSE
					IF v_iConsecutivo <> 1 THEN
						LET v_sValRetorno = '000005'; --NUMERO CONSECUTIVO INCORRECTO
						LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || '01';
					ELSE
						LET v_sValRetorno = '000003'; --NUMERO DE CAJA CORRECTA
					END IF;
				END IF;
			ELSE
				--SI EL AÑO ES MAYOR SE INICIALIZA EL NUMERO CONSECUTIVO EN 01
				IF v_iConsecutivo <> 1 THEN
					LET v_sValRetorno = '000005'; --NUMERO CONSECUTIVO INCORRECTO
					LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || '01';
				ELSE
					LET v_sValRetorno = '000003'; --NUMERO DE CAJA CORRECTA
				END IF;
			END IF;
		END IF;
		
		RETURN v_sValRetorno, v_sEmpresa, v_sNumerocaja, v_sNumSucursal, v_iTipoPaquete, v_dFechaInsercion,v_cStatus;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 01/Agosto/2009',
'DESCRIPCION: Indica si la caja especificada existe en la tabla numcajas',
'CASO DE USO: PCU-bdisuc\CU-0001-ValidarCaja-SPL',
'MODIFICO: Josue Zepeda',
'FECHA: 18-Abril-2012',
'DESCRIPCION: Se agrego variable v_cStatus para que regrese valor',
'BD: bdisuc';

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