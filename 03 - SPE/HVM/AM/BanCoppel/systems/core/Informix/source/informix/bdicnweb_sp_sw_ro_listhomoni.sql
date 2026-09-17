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