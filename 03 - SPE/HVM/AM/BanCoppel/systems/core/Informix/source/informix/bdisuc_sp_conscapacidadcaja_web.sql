CREATE PROCEDURE "informix".sp_conscapacidadcaja_web(pEmpresa CHAR(3), pNumCja CHAR(10))

RETURNING	CHAR(5) AS CodRet, INTEGER AS HojasRegistradas, INTEGER AS CapacidadCja, 
			INTEGER AS PorcentajeLimiteParaCerrado, DECIMAL(5,2) AS PorcentajeCapacidadActual, CHAR(100) AS Descripcion;
		
DEFINE 	cCodRet		 CHAR(5);
DEFINE	iSqlErr	 	 INTEGER;
DEFINE	iHojas	 	 INTEGER;
DEFINE	iCapacidad	 INTEGER;
DEFINE	iPorLimite	 INTEGER;
DEFINE 	dPorCapAct	 DECIMAL(14,2);
DEFINE  cDescripcion CHAR(100);

LET	cCodRet		 = '00000';
LET iSqlErr		 = 0;
LET iHojas		 = 0;
LET iCapacidad	 = 0;	
LET iPorLimite	 = 0;
LET dPorCapAct	 = 0;
LET cDescripcion = '';

-- SET DEBUG FILE TO '/tmp/sp_conscapacidadcaja.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCja,'') = '' THEN
		LET cCodRet='00001';
		RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
	END IF;
	
	SELECT NVL(paq.capacidad,0), NVL(paq.porcentaje_limite,0), NVL(caj.num_hojas_registradas,0) 
	INTO iCapacidad, iPorLimite, iHojas	
	FROM "informix".ss_cattipopaquetes paq, "informix".ss_numcajas caj
	WHERE paq.empresa = pEmpresa
	AND caj.empresa = paq.empresa
	AND caj.tipopaquete = paq.tipopaquete
	AND caj.numerocaja = pNumCja;
		
	--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
	END IF;
	
	LET dPorCapAct = ((iHojas / iCapacidad)*100);
	LET cDescripcion = iHojas||' de '||iCapacidad||" hojas";
	
	RETURN cCodRet,iHojas,iCapacidad,iPorLimite,dPorCapAct,TRIM(cDescripcion);
END;
END PROCEDURE
DOCUMENT
'AUTOR:	  	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se consulta la capacidad y porcentaje de la caja. Se retorna los datos de la consulta',
'VERSION:     20141017.1630',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultardoctosadmon_web(p_sEmpresa CHAR(3), p_sSucursal CHAR(4), p_iTipoCarpeta SMALLINT,
										p_sNumCarpeta CHAR(4), p_sNumCaja CHAR(10), p_dFecha DATE, p_iCantRegistros INTEGER)
	RETURNING	CHAR(5)  AS retorno,
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
	DEFINE v_sValRetorno			CHAR(5);
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
	--SET DEBUG FILE TO "/informix/JesusBueno/servicios/SpsModificados/sp_consultarDoctosAdmon.out";
	--TRACE ON;
	-----------------------------------------------------------------------------

	LET v_sValRetorno = '00001';

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

			LET v_sValRetorno = '00000';
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

CREATE PROCEDURE "informix".sp_consultarpaquetecheques_web(p_sEmpresa CHAR(3), p_sSucursal CHAR(4),
				p_sNumeroCaja CHAR(10), p_dFecha DATE, p_iCantRegistros INTEGER, p_cOpcion CHAR(1), p_sScuencia CHAR(5))

	RETURNING 	CHAR(5)  AS retorno,	
				CHAR(3)  AS empresa,	
				CHAR(10) AS numerocaja, 
				CHAR(1)  AS tipocheque,
				DATE     AS fecharegistro, 
				CHAR(4)  AS sucursal, 
				CHAR(1)  AS estatus, 
				DATE     AS fechainsercion,
				CHAR(8)  AS numUsuarioRegistro,
				CHAR(45) AS desUsuarioRegistro,
				CHAR(8)  AS numUsuarioAutorizo,
				CHAR(45) AS desUsuarioAutorizo,
				CHAR(8)  AS numUsuarioSolicita,
				CHAR(45) AS desUsuarioSolicita,
				CHAR(100) AS desComentario,
				INTEGER	 AS iHojasDoc,
				INTEGER  AS iNumHojasReg,
				INTEGER  AS iCapacidad,
				CHAR(5)  AS sSecuencia;
					

	--VARIABLES DE ERROR DEL SP
    DEFINE cVarDataErr			VARCHAR(255);
    DEFINE iSqlErr				INTEGER;
    DEFINE iSamErr				INTEGER;

	--DECLARACION DE VARIABLES DE USO DEL SP
	DEFINE v_sValRetorno			CHAR(5);
	DEFINE v_sNumeroCaja 			CHAR(10);
	DEFINE v_sTipoCheques			CHAR(1);
	DEFINE v_dFechaRegistro			DATE;
	DEFINE v_sSucursal				CHAR(4);
	DEFINE v_sEstatus				CHAR(1);
	DEFINE v_dFechaInsercion		DATE;
	DEFINE v_iNumRegistro			INTEGER;
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita	CHAR(45);
	DEFINE v_sDesComentario			CHAR(100);
	DEFINE iHojasDocumento			INTEGER;
	DEFINE iCantidad 				INTEGER;
	DEFINE iCapacidad				INTEGER;
	DEFINE cSecuencia               CHAR(5);
	
	-----------------------------------------------------------------------	
	--Debug del Procedure
	--SET DEBUG FILE TO "/tmp/vladi/sp_consultarpaquetecheques.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno 		= '00001';
	LET v_sNumeroCaja 		= '';
	LET v_sTipoCheques 		= '';
	LET v_dFechaRegistro 	= '';
	LET v_sSucursal 		= '';
	LET v_sEstatus 			= '';
	LET v_dFechaInsercion 	= '';
	LET v_iNumRegistro = 0;
	LET iHojasDocumento = 0;
	LET iCantidad = 0;
	LET iCapacidad = 0;
	LET cSecuencia = '';
	BEGIN

		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN iSqlErr,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF NVL(p_cOpcion,'') = '' OR p_cOpcion NOT IN ('1','2') THEN 
			RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
		END IF;
		
		IF p_cOpcion = '2' THEN
			IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumeroCaja,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_dFecha,'') = '' THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
			
			UPDATE "informix".ss_paquetescheques 
			SET estatus='E' 
			WHERE empresa = p_sEmpresa 
			AND numerocaja = p_sNumeroCaja 
			AND sucursal = p_sSucursal 	
			AND fecharegistro = p_dFecha
			AND secuencia = p_sScuencia;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET v_sValRetorno = '00002'; 
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;
			
			LET p_dFecha = '';
			--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
			SELECT SUM(cantidad_hojas) 
			INTO iCantidad
			FROM "informix".ss_paquetescheques
			WHERE empresa = p_sEmpresa
			AND numerocaja = p_sNumeroCaja
			AND sucursal = p_sSucursal
			AND estatus <> 'E';

			UPDATE "informix".ss_numcajas
			SET num_hojas_registradas = NVL(iCantidad,0)
			WHERE empresa = p_sEmpresa
			AND numerocaja = p_sNumeroCaja
			AND numsucursal = p_sSucursal
			AND estatus = 'Activa'
			AND tipopaquete = 5;
		
		END IF;
		
		IF p_cOpcion = '1' OR p_cOpcion = '2' THEN
			--LOS PARAMETROS NO DEBEN SER NULOS
			IF NVL(p_sEmpresa, '') = '' OR NVL(p_sSucursal, '') = '' THEN --OR NVL(p_sTipoCheque, '') = '' THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','',0,0,0,'';
			END IF;

			--SI NO SE ESPECIFICAN ESTOS CAMPOS SE REALIZA LA BUSQUEDA CON LOS PARAMETROS REQUERIDOS.
			IF p_sNumeroCaja = '' THEN
				LET p_sNumeroCaja = NULL;
			END IF;

			IF p_dFecha = '' THEN
				LET p_dFecha = NULL;
			END IF;
			
			SELECT NVL(cja.num_hojas_registradas,0), NVL(pte.capacidad,0)
			INTO iCantidad, iCapacidad
			FROM "informix".ss_numcajas cja, "informix".ss_cattipopaquetes pte
			WHERE pte.tipopaquete = cja.tipopaquete 
			AND cja.numerocaja = p_sNumeroCaja 
			ANd cja.numsucursal = p_sSucursal
			AND pte.tipopaquete = '5';
			
			--Consultar la informacion de los paquetes de cheques.
			FOREACH
				SELECT SKIP p_iCantRegistros empresa, numerocaja, tipocheques, fecharegistro, sucursal, estatus, usuarioregistra, 
				usuarioautoriza, usuariosolicita, comentario, fecha_insert, cantidad_hojas, secuencia
				INTO p_sEmpresa, v_sNumeroCaja, v_sTipoCheques, v_dFechaRegistro, v_sSucursal, v_sEstatus, v_sNumUsuarioRegistro,
				v_sNumUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesComentario, v_dFechaInsercion, iHojasDocumento, cSecuencia
				FROM bdisuc:"informix".ss_paquetescheques
				WHERE empresa = p_sEmpresa
				AND sucursal = p_ssucursal
				AND numerocaja = NVL(p_sNumeroCaja, numerocaja)
				AND fecharegistro = NVL(p_dFecha, fecharegistro)
				AND estatus <> 'E'
				ORDER BY fecharegistro

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
				
				LET v_sValRetorno = '00000';
				
				RETURN v_sValRetorno, p_sEmpresa, v_sNumeroCaja, v_sTipoCheques, v_dFechaRegistro, v_sSucursal,
				v_sEstatus, v_dFechaInsercion, v_sNumUsuarioRegistro, v_sDesUsuarioRegistro, v_sNumUsuarioAutorizo,
				v_sDesUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesUsuarioSolicita, v_sDesComentario, iHojasDocumento, iCantidad, iCapacidad, cSecuencia WITH RESUME;

			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Vladimir Felix Galvez',
'FECHA:       04-Agosto-2009',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0011-ConsultarPaqueteCheques-SPL',
'DESCRIPCION: Consultar la informacion de la documentacion de los paquetes de cheques. Datos de Entrada Requeridos: Empresa, Sucursal y el tipo de Cheque. Datos de Entrada Opcionales: numero de la caja y la fecha.',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuario que registra, autoriza, solicita y comentario',
'MODIFICO: Victor Hugo NuÃ±ez',  
'FECHA:       30/Agosto/2012',
'BD: bdisuc',
'DESCRIPCION: Se organiza por fecha de registro, se elimina filtro por tipo de cheque',
'MODIFICO: Josue Zepeda',  
'FECHA:       26/Febrero/2013',
'BD: bdisuc',
'DESCRIPCION: Se inhibe parametro de p_sTipoCheque',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'Y EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultarpaquetesoperativos_web(p_sEmpresa CHAR(3),p_sNumCaja CHAR(10), p_sSucursal CHAR(4), 
                                                           p_dFechaRegistro DATE, p_iCantRegistros INTEGER, p_cOpcion CHAR(1),
														   p_sScuencia CHAR(5))
				
	RETURNING	CHAR(5)  	AS retorno, 
				CHAR(10) 	AS numerocaja, 
				DATE     	AS fecharegistro,
				CHAR(1)  	AS estatus,
				CHAR(8)  	AS numUsuarioRegistra,
				CHAR(45) 	AS desUsuarioRegistra,
				CHAR(8)  	AS numUsuarioAutoriza,
				CHAR(45) 	AS desUsuarioAutoriza,
				CHAR(8)  	AS numUsuarioSolicita,
				CHAR(45) 	AS desUsuarioSolicita,
				CHAR(100) 	AS comentario,
				--folio_1668
				INTEGER 	AS iCantHojas,
				INTEGER 	AS iCapacidad,
				INTEGER		AS iCantDocs,
				CHAR(5)     AS sSecuencia;
				
	DEFINE iSqlErr					INTEGER;
	DEFINE v_sValRetorno			CHAR(5);
	DEFINE v_sCajaRegistrada		CHAR(10);
	DEFINE v_dFechaRegistro			DATE;
	DEFINE v_sEstatus				CHAR(1);	
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita 	CHAR(45);
	DEFINE v_sComentario			CHAR(100);
	--folio_1668
	DEFINE iNumReg					INTEGER;
	DEFINE iCapacidad				INTEGER;	
	DEFINE iCantidad 				INTEGER;
	DEFINE iCantDocs				INTEGER;
	DEFINE sSecuencia               CHAR(5);
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consultarpaquetesoperativos.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	
	LET v_sValRetorno 	= '00001';
	--folio_1668
	LET iNumReg 		= 0;
	LET iCapacidad 		= 0;
	LET iCantDocs		= 0;
	LET iCantidad       = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','',0,0,0,'';
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
		IF NVL(p_cOpcion,'') = '' OR p_cOpcion NOT IN ('1','2') THEN 
			RETURN v_sValRetorno,'','','','','','','','','','',0,0,0,'';
		END IF;
		
		-- CONSULTA LOS PAQUETES OPERATIVOS DE UNA SUCURSAL
		IF p_cOpcion = '2' THEN
		
		  IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumCaja,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_dFechaRegistro,'') = '' THEN
				RETURN v_sValRetorno,'','','','','','','','','','',0,0,0,'';
		  END IF;
		
		
			UPDATE "informix".ss_paquetesoperativos 
			SET estatus='E'  
			WHERE empresa = p_sEmpresa 
			AND numerocaja = p_sNumCaja 
			AND sucursal = p_sSucursal 
			AND fecharegistro = p_dFechaRegistro
			AND secuencia = p_sScuencia;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET v_sValRetorno = '00002'; 
					RETURN v_sValRetorno,'','','','','','','','','','',0,0,0,'';
				END IF;
				
			--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
			SELECT SUM(cantidad_hojas) 
			INTO iCantidad
			FROM "informix".ss_paquetesoperativos
			WHERE empresa = p_sEmpresa
			AND numerocaja = p_sNumCaja
			AND sucursal = p_sSucursal
			AND estatus <> 'E';

			UPDATE "informix".ss_numcajas
			SET num_hojas_registradas = NVL(iCantidad,0)
			WHERE empresa = p_sEmpresa
			AND numerocaja = p_sNumCaja
			AND numsucursal = p_sSucursal
			AND estatus = 'Activa'
			AND tipopaquete = 2;
				
		END IF;	
		
		-- ACTUALIZA LOS PAQUETES CHEQUES DE UNA SUCURSAL
		IF p_cOpcion = '1' OR p_cOpcion = '2' THEN
		    
			--LOS PARAMETROS NO DEBEN SER NULOS	
			
			IF NVL(p_sEmpresa, '') = '' OR NVL(p_sSucursal, '') = '' THEN 
				RETURN v_sValRetorno,'','','','','','','','','','',0,0,0,'';
			END IF;
			
			IF p_sNumCaja = '' THEN
				LET p_sNumCaja = NULL;
			END IF;

			IF p_dFechaRegistro = '' THEN
				LET p_dFechaRegistro = NULL;
			END IF;
		
			SELECT NVL(a.capacidad,0), NVL(b.num_hojas_registradas,0) 
			INTO iCapacidad,iNumReg 
			FROM "informix".ss_cattipopaquetes a, "informix".ss_numcajas b
			WHERE a.empresa = p_sEmpresa 
			AND b.numerocaja = p_sNumCaja
			AND a.tipopaquete = b.tipopaquete
			AND b.tipopaquete = '2';
	
			
		--OBTIENE LOS PAQUETES CHEQUES DE UNA SUCURSAL
			FOREACH
				----SELECT {+INDEX("informix".ss_paquetesoperativos crea_idx_ss_paquetesoperativos)} SKIP p_iCantRegistros numerocaja, fecharegistro, estatus, usuarioregistra,
				SELECT SKIP p_iCantRegistros numerocaja, fecharegistro, estatus, usuarioregistra,
				usuarioautoriza, usuariosolicita, comentario,cantidad_hojas, secuencia
				INTO v_sCajaRegistrada, v_dFechaRegistro, v_sEstatus, v_sNumUsuarioRegistro, 
				v_sNumUsuarioAutorizo,	v_sNumUsuarioSolicita, v_sComentario,iCantDocs, sSecuencia
				FROM "informix".ss_paquetesoperativos
				WHERE empresa = p_sEmpresa AND numerocaja = NVL(p_sNumCaja,numerocaja)
				--AND fecharegistro = fecharegistro 
				AND sucursal = p_sSucursal
				--FOLIO_1668
				AND estatus <> 'E'
				ORDER BY fecharegistro

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
							
				LET v_sValRetorno = '00000';
				
				RETURN v_sValRetorno, v_sCajaRegistrada, v_dFechaRegistro, v_sEstatus, v_sNumUsuarioRegistro, v_sDesUsuarioRegistro,v_sNumUsuarioAutorizo, v_sDesUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesUsuarioSolicita,v_sComentario,iNumReg,iCapacidad,iCantDocs,sSecuencia WITH RESUME;
			END FOREACH;
	  END IF;	
			
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora',  
'FECHA:       03/Agosto/2009',
'DESCRIPCION: Obtiene la informacion de los paquetes operativos de la sucursal especificada',
'CASO DE USO: Caso de Uso asociado PCU-bdisuc\CU-0004-ConsultarPaquetesOperativos-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario',
'MODIFICO: Victor Hugo NuÃ±ez',  
'FECHA:       30/Agosto/2012',
'DESCRIPCION: Se organiza por fecha de registro',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'Y EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_reversar_panamericano_web( pFolio_oper char(8))

--DATOS A REGRESAR---												 
RETURNING CHAR(5) AS cCod_ret;
	  
--DECLARACIONES.
DEFINE iSqlErr         	 INTEGER;
DEFINE cCod_ret          CHAR(5);

---INICIALIZACIONES
LET iSqlErr           = 0;
LET cCod_ret          = "00001";


BEGIN
    ON EXCEPTION SET iSqlErr	
		IF 	iSqlErr <> 0 THEN
			RETURN iSqlErr;
		END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO  "/respaldosbd/OmarGamez/342/sp_reversar_panamericano_web.out";
	--TRACE ON;

	IF NVL(pFolio_oper,'') <> '' THEN
		UPDATE bdisuc: "informix".ss_operaciones SET reversado = '1' WHERE folio_oper = pFolio_oper;
		
		UPDATE bdisuc: "informix".ss_mae_entradasalida SET status = '08'  WHERE folio_oper = pFolio_oper;
		
		LET cCod_ret = '00000';
	ELSE
		LET cCod_ret = '00002';
	END IF;
		RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'Autor: 97839523 - Jose Luis Garcia',
'Folio: 342-Monitor de efectivo BanCoppel',
'Fecha: 29-12-2017',
'ModificaciÃ³n: Se crearÃ¡ un procedimiento almacenado para realizar el reverso para laÂ transacciÃ³n "0066 SOLICITUD DE SERVICIO DE RECOLECCION"Â en caso de fallar',
'Solicita: ABRAHAM NERVAEZ', 
'Base de datos: bdisuc';

CREATE PROCEDURE "informix".sp_soldocta_ws_web(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
		pfolio_suc CHAR(16),
  		ptransaccion CHAR(4),
		pdivisa CHAR(2),
		pmonto_dot money(14,2),
		pfecha date,
		pdeno1 CHAR(18),
		pdeno2 CHAR(18),
		pdeno3 CHAR(18),
		pdeno4 CHAR(18),
		pdeno5 CHAR(18),
		pdeno6 CHAR(18),
		pdeno7 CHAR(18),
		pdeno8 CHAR(18),
		pdeno9 CHAR(18),
		pdeno10 CHAR(18),
		pdeno11 CHAR(18),
		pdeno12 CHAR(18),
		pdeno13 CHAR(18),
		pdeno14 CHAR(18),
		pdeno15 CHAR(18),
		pcant1 FLOAT(8),
		pcant2 FLOAT(8),
		pcant3 FLOAT(8),
		pcant4 FLOAT(8),
		pcant5 FLOAT(8),
		pcant6 FLOAT(8),
		pcant7 FLOAT(8),
		pcant8 FLOAT(8),
		pcant9 FLOAT(8),	
		pcant10 FLOAT(8),
		pcant11 FLOAT(8),
		pcant12 FLOAT(8),
		pcant13 FLOAT(8),
		pcant14 FLOAT(8),
		pcant15 FLOAT(8),
		pFlagActivaServicio CHAR(1))
		
		RETURNING CHAR(5) AS Retorno,CHAR(8) AS folio_oper,CHAR(25)AS id_servicio,CHAR(521) AS trama;
		
		
DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vnum INTEGER;
DEFINE vFecha_formato,vFechaInsert CHAR(25);
DEFINE vidsolicitud,vidsolicitud1 CHAR(25);
DEFINE cId_servicio				VARCHAR(28);
DEFINE cMisc1					VARCHAR(40);
DEFINE cMisc2					VARCHAR(40);
DEFINE cMisc3					VARCHAR(40);
DEFINE cMisc4					VARCHAR(40);
DEFINE cMisc5					VARCHAR(40);
DEFINE cId_banco				VARCHAR(5);
DEFINE cTrama					CHAR(521);
DEFINE cConsecutivo				INTEGER;
DEFINE cAuxCons					CHAR(3);
DEFINE cMontoAnt 				CHAR(20);
DEFINE cHoraAParam				CHAR(5);	
DEFINE cproveedor				CHAR(4);
DEFINE cpanamericano 			CHAR(4);


LET vcodret = "00000";
LET vhora = SUBSTR(CURRENT,12,5);
LET vnum = 0;
LET vfolio = "";
LET vsqlerr = 0;
LET visamerr = 0;
LET vFecha_formato = "";
LET vFechaInsert = "";
LET vidsolicitud = "";
LET vidsolicitud1 = "";
LET cId_servicio = '0                            ';	
LET cMisc1 = psucursal;	
LET cMisc2 = '0                                       ';			
LET cMisc3 = '0                                       ';					
LET cMisc4 = '0                                       ';					
LET cMisc5 = '0                                       ';
LET cId_banco	= '67   ';	
LET cTrama = '';
LET cConsecutivo = 1;
LET cAuxCons = '001';
LET cMontoAnt = '';
LET cHoraAParam = '';
LET cproveedor = '';
LET cpanamericano = '';

BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret,vfolio,vidsolicitud,cTrama;
	   END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;

	--SET DEBUG FILE TO "/tmp/sp_soldocta_ws.out";
	--TRACE ON;

	--- Verifica recepcion correcta de datos
	IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
	   pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
	   OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
	   OR pmonto_dot = 0 THEN
	   LET vcodret = "00110";
	ELSE
		
		SELECT p.cod_proveedor
		INTO cproveedor
		FROM  "informix".ss_proveedores p, bdinteg: "informix".si_sucursales s
		WHERE p.plaza = s.plaza_cajagen
		AND s.empresa = pempresa
		AND s.sucursal = psucursal;
				
		SELECT sucursal
		INTO cpanamericano
		FROM  "informix".ss_sucursales_panamericano
		WHERE centro_costos = cproveedor;	
			
		SELECT valor INTO cHoraAParam
		FROM  "informix".ss_param_cajagen
		WHERE codigo = '0044';
					 
		IF TO_CHAR(current, "%H:%M:%S") <= cHoraAParam THEN
		
			SELECT  limit 1 ent.monto
			INTO cMontoAnt
			FROM  "informix".ss_mae_entradasalida ent,  "informix".ss_operaciones op
			WHERE ent.cod_proveedor = cproveedor
			AND ent.sucursal = psucursal
			AND ent.fecha_solicitud = DATE(CURRENT)
			AND ent.id_solicitud <> ''
			AND LEFT(TRIM(ent.id_solicitud),3) = 'DOT'
			AND ent.folio_oper = op.folio_oper
			AND ent.monto = pmonto_dot
			AND op.reversado <> '1';
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN --<-- si la ultima sentencia trae registros entonces ya existe el monto en la dotacion del dia.
			   
			   LET cproveedor = TRIM(NVL(cproveedor,''));
			   
			   IF  (cproveedor != '') THEN

					SELECT valor INTO vnum
					FROM    "informix".ss_param_cajagen
					WHERE  codigo = '0005';

					UPDATE  "informix".ss_param_cajagen
					SET    valor = valor + 1
					WHERE  codigo = '0005';
									
					SELECT  RIGHT(TRIM(MAX(ent.id_solicitud)),3) 
					INTO cAuxCons
					FROM  "informix".ss_mae_entradasalida ent , "informix".ss_operaciones op
					WHERE ent.cod_proveedor = cproveedor
					AND ent.sucursal = psucursal
					AND ent.fecha_solicitud = DATE(CURRENT)
					AND ent.id_solicitud <> ''
					AND LEFT(TRIM(ent.id_solicitud),3) = 'DOT'
					AND ent.folio_oper = op.folio_oper
					AND op.reversado <> '1';
								
					IF  NVL(cAuxCons,'') <> '' THEN
					
						LET cConsecutivo = cAuxCons + 1;	
						
					END IF;

					LET vfolio = LPAD(vnum,8,"0");
					LET vFecha_formato = LPAD(DAY(pfecha),2,0) ||'/'|| LPAD(MONTH(pfecha),2,0) ||'/'|| YEAR(pfecha);		   
					
					IF pFlagActivaServicio = '0' THEN
					
					   LET vidsolicitud1 = '';
					   LET vidsolicitud = '';
					   
					Else		
						
						LET vidsolicitud1 = "DOT" ||"|"|| psucursal ||"|" || TRIM(REPLACE(vFecha_formato,"/",""))  ||"|"|| LPAD(cConsecutivo,3,'0');
						LET vidsolicitud = "DOT" ||"|"|| psucursal::int ||"|" ||TRIM(REPLACE(vFecha_formato,"/","")) ||"|"|| LPAD(cConsecutivo,3,'0') ;
										
					END IF;
					
					LET vFechaInsert = current;
					
				   INSERT INTO  "informix".ss_operaciones
					  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,id_solicitud,folio_oper,reversado,usuario,divisa,monto,
					   denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
					   denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
					   denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
					   cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
					   cantidad_13,cantidad_14,cantidad_15)
				   VALUES
					  (pempresa,ptransaccion,pfecha,lpad(psucursal,4, "0"),pfolio_suc,vidsolicitud1,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
					   pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
				   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
				   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

				   INSERT INTO  "informix".ss_mae_entradasalida
					   (empresa,cod_proveedor,id_solicitud,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
						status,monto)
				   VALUES (pempresa,cproveedor,vidsolicitud1,vfolio,lpad(psucursal,4, "0"),pfolio_suc,pfecha,vhora,pcajeroprincipal,'01',pmonto_dot);
					
					LET cTrama = RPAD('0', 8 , " ") || RPAD('0', 8 , " ") || RPAD(pcant4::INT, 8 , " ") || RPAD(pcant1::INT,8, " ") || RPAD('0'::INT,8, " ") || 
								RPAD(pcant6::INT,8, " ") || RPAD(pcant3::INT,8, " ")  || RPAD('0'::INT,8, " ")  || RPAD(pcant5::INT,8, " ")  || RPAD(pcant2::INT,8, " ") || 
								RPAD('MXN',3, " ") || RPAD( TO_CHAR(current + 1 UNITS DAY, "%d/%m/%Y %H:%M:%S"),19, " ") || RPAD( TO_CHAR(current, "%d/%m/%Y %H:%M:%S"),19, " ") ||
								RPAD(cId_banco,5, " ")|| RPAD(psucursal::INT,8, " ") ||RPAD(cId_servicio,28, " ") || RPAD(vidsolicitud ,25, " ") || RPAD(cMisc1::INT,40, " ") || 
								RPAD(cMisc2,40, " ") || RPAD(cMisc3,40, " ") || RPAD(cMisc4,40, " ") || RPAD(cMisc5,40, " ") || RPAD('0',8, " ") || RPAD('0',8, " ") || 
								RPAD(pcant15::INT,8, " ") || RPAD(pcant14::INT,8, " ")|| RPAD('0'::INT,8, " ") || RPAD(pcant13::INT,8, " ") || RPAD(pcant12::INT,8, " ") || 
								RPAD(pcant9::INT,8, " ") || RPAD(pcant8::INT,8, " ") || RPAD(pcant11::INT ,8, " ") || RPAD('0'::INT,8, " ") || RPAD(pcant10::INT,8, " ") || 
								RPAD('0'::INT,8, " ") || RPAD(pmonto_dot::decimal(14,2),15, " ") || RPAD(cpanamericano,3, " ")|| RPAD('S',1, " ")|| RPAD('S',1, " ");
					
					
			   ELSE

					LET vcodret = "00105";
			   
			   END IF;
			ELSE
				LET vcodret = '01050';
			END IF;
		ELSE
			LET vcodret = '01051';
		END IF;
	END IF;

	RETURN vcodret,vfolio,replace(vidsolicitud1, "|",""),cTrama;
END;
END PROCEDURE
DOCUMENT
'FOLIO: 380.1 - Adendum RQI 14 322 Monitor de efectivo BanCoppel',
'AUTOR: Irma Ureta',
'FECHA: 02/03/2018',
'MODIFICACION: Se clona sp_soldocta con nombre sp_soldocta_ws para guardar el id de solicitud de dotacion',
'SOLICITA: Abraham Nervaez',
'DB: bdisuc',
'FOLIO: 421.1 - Adendum - Monitor de efectivo BanCoppel',
'AUTOR: Veronica Rodriguez',
'FECHA: 17/07/2018',
'MODIFICACION: Se agrega un nuevo parametro de entrada, si el parametro viene en 0 no debera de insertar valor en el campo id_solicitud, si viene en 1 si debera de insertar valor en el campo id_solicitud.',
'SOLICITA: Alejandro Sanchez',
'DB: bdisuc'
;

CREATE PROCEDURE "informix".sp_valida_numcaja_web(pEmpresa CHAR(3),
											  pSucursal CHAR(4),
											  pNumeroCaja CHAR(10))
--DATOS A REGRESAR---
	RETURNING
	CHAR(5)      AS cCodRet

---DECLARACIONES
DEFINE iSqlErr         	 INTEGER;
DEFINE cCodRet         	 CHAR(5);
DEFINE cSucursal         CHAR(4);
DEFINE cNumCaja          CHAR(10);
DEFINE cNumCaja2         CHAR(10);

---INICIALIZACIONES
LET iSqlErr           = 0;
LET cCodRet           = "00000";
LET cSucursal         = "";
LET cNumCaja          = "";
LET cNumCaja2         = "";

BEGIN
    ON EXCEPTION SET iSqlErr
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END IF;
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/tmp/jairo/sp_valida_numcaja.out";
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pNumeroCaja,"") = "" THEN
		LET cCodRet = "01308";
		RETURN cCodRet;
	ELSE

		SELECT sucursal
		INTO cSucursal
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "01309";
			RETURN cCodRet;
		END IF;

		SELECT numerocaja
		INTO cNumCaja
		FROM bdisuc:"informix".ss_numcajas
		WHERE empresa = pEmpresa
		AND numsucursal = pSucursal
		AND numerocaja = pNumeroCaja
		AND tipopaquete = '3'
		AND UPPER(estatus) = UPPER("Activa");

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "00000";
			RETURN cCodRet;
		END IF;

		SELECT LIMIT 1 numerocaja
		INTO cNumCaja2
		FROM bdisuc:"informix".ss_documentosadmon
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND numerocaja = pNumeroCaja;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "01310";
			RETURN cCodRet;
		ELSE
			LET cCodRet = "00000";
			RETURN cCodRet;
		END IF;
	END IF;
END;
END PROCEDURE
;