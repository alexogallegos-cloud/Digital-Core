CREATE PROCEDURE "informix".sp_sw_ro_encabezadooficio(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT)
	RETURNING CHAR(5) AS codret,
			CHAR(10) AS fecha_recepcion,
			CHAR(60) AS oficio,
			CHAR(60) AS num_expediente,
			CHAR(50) AS nombre_ins1n,
			CHAR(255) AS direccion_ins1n,
			CHAR(70 ) AS nombre_facultado,
			CHAR(40) AS puesto_facultado
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE dFechaRecepciON DATE;
	DEFINE cOficio CHAR(60);
	DEFINE cExpediente CHAR(60);
	DEFINE cInstitucion1n CHAR(50);
	DEFINE cDireccionInstitucion1n CHAR(255);
	DEFINE cNombreFacultado CHAR(70);
	DEFINE cPuestoFacultado CHAR(70);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaRecepciON = NULL;
	LET cOficio = '';
	LET cExpediente = '';
	LET cInstitucion1n = '';
	LET cDireccionInstitucion1n = '';
	LET cNombreFacultado = '';
	LET cPuestoFacultado = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaRecepcion, cOficio, cExpediente, 
					cInstitucion1n, cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''
				OR pIdOficio = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaRecepcion, cOficio, cExpediente, 
						cInstitucion1n, cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaRecepcion, cOficio, cExpediente, 
					cInstitucion1n, cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado;
		END IF;
		SET ISOLATION TO DIRTY READ;
		SELECT DISTINCT nvl(a.fecha_recepcion, '')
			, a.oficio AS numero_oficio
			, a.expediente AS numero_expediente
			, nvl(b.desc_i1n_nombrelargo, '')
			, nvl(b.direccion_oficio, '')
			, nvl(d.nombre_facultado, '')
			, nvl(d.puesto_facultado, '')
		INTO dFechaRecepcion, cOficio, cExpediente, cInstitucion1n, 
				cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado
		FROM ((sw_ro_maeoficios a LEFT JOIN sw_ro_insenlace1nivel b ON (a.id_institucion1n = b.id_institucion1n AND b.status = '1'))
				LEFT JOIN sw_ro_oficio_facultados c ON (c.id_oficio = a.id_oficio AND c.id_rolfunciON = 1))
				LEFT JOIN sw_ro_facultados d ON d.id_facultado = c.id_facultado 
		WHERE a.id_oficio = pIdOficio;
		IF dFechaRecepciON is null OR dFechaRecepciON = '' THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dFechaRecepcion, cOficio, cExpediente, 
					cInstitucion1n, cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado;
		ELSE
			RETURN cCodRet, dFechaRecepcion, cOficio, cExpediente, 
					cInstitucion1n, cDireccionInstitucion1n, cNombreFacultado, cPuestoFacultado;
		END IF;
	END
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flore Conde",
"FECHA: 27022013",
"DESCRIPCION: Procedimiento que obtiene los encabezados en un oficio",
"MODIFICA: Juan Salvador Jimenez Galindo",
"FECHA: 26062013",
"DESCRIPCION: Se amplia la salida para el campo domicilio institucion enlace";

CREATE PROCEDURE "informix".sp_sw_ro_listhomoni(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pRegistros INT, 
										pRecuperaciON INT  )
	RETURNING CHAR(5) AS  CodRet,
		     CHAR(164) AS Nombre
	DEFINE cCodRet	   CHAR(5);
	DEFINE iSqlErr 	   INT;
	DEFINE cNombre     CHAR(164); 
	DEFINE cCliente     CHAR(164); 
	DEFINE cCuenta     CHAR(164); 
	DEFINE cTarjeta     CHAR(164); 
	DEFINE iBusq   INTEGER;
	DEFINE iContador   INTEGER;
	LET cCodRet  = '00000';
	LET iSqlErr	 = 0;
	LET cNombre   = ''; 
	LET cCliente   = ''; 
	LET cCuenta   = ''; 
	LET cTarjeta   = ''; 
	LET iBusq = 0;
	LET iContador = 0; 
	
	BEGIN
			--EXEPCIONES
		ON EXCEPTION SET  iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet= iSqlErr;
				RETURN  cCodRet,  cNombre;
			END IF;				
		END EXCEPTION;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN  cCodRet, cNombre;
			END IF;
			-- VALIDACIONES DE ENTRADA
			IF  pUsuario = ''
					OR pIdFunciON = ''
					OR pRegistros = ''
					OR pRecuperaciON = ''
					OR pIdOficio = ''
				THEN
					LET cCodRet = '00003';
					RETURN  cCodRet, cNombre;
			END IF;			
			SET ISOLATION TO DIRTY READ;
			FOREACH
					SELECT skip pRegistros FIRST pRecuperaciON 
							TRIM(TRIM(TRIM(TRIM(TRIM(TRIM(bp.nombre1)|| ' ' ||
							TRIM(bp.nombre2))|| ' ' || TRIM(bp.apell_paterno)) || ' ' || 
							TRIM(bp.apell_materno)) || ' ' || TRIM( bp.razon_social))) 
						AS nombre, TRIM(bp.numcte) AS cliente, TRIM(bp.cuenta) AS cuenta, TRIM(bp.num_tarjeta) AS tarjeta
					INTO cNombre, cCliente, cCuenta, cTarjeta
					FROM sw_ro_resulper rp, sw_ro_buscaper bp
					WHERE rp.id_oficio = pIdOficio
						AND rp.status_busqueda = 2
						AND rp.ind_omitir = 0 
						AND rp.status = 1
						AND bp.id_oficio = rp.id_oficio
						AND bp.id_busqueda = rp.id_busqueda
						AND bp.id_tipobusqueda != 3
					group BY 1, 2, 3, 4         
					LET iContador= iContador + 1;
					IF cNombre != '' THEN
						RETURN  cCodRet, cNombre WITH resume;
					ELIF cCliente != '' THEN
						RETURN  cCodRet, cCliente WITH resume;
					ELIF cCuenta != '' THEN
						RETURN  cCodRet, cCuenta WITH resume;
					ELIF cTarjeta != '' THEN
						RETURN  cCodRet, cTarjeta WITH resume;
					END IF;
			END FOREACH; 
			IF iContador = 0 THEN
				LET cCodRet='01001';
				RETURN cCodRet, cNombre;			
			END IF;
		END
END PROCEDURE;