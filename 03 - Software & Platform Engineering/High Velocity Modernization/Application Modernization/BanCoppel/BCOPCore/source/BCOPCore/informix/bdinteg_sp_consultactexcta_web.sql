CREATE PROCEDURE "informix".sp_consultactexcta_web(pNumcte CHAR(20), pCuenta CHAR(20))
RETURNING VARCHAR(5), CHAR(60), CHAR(40), CHAR(40), CHAR(25);

-- Declaracion de Variables
DEFINE cCliente CHAR(20);
DEFINE cNombre CHAR(60);
DEFINE cApell_pat CHAR(40);
DEFINE cApell_mat CHAR(40);
DEFINE cRfc CHAR(25);
DEFINE codret VARCHAR(5);
DEFINE csql_err INTEGER;
DEFINE cRfc_alterno CHAR(25);

    --Set debug file to '/tmp/sp_consultactexcta.out';
    --trace on;

--Inicializacion de Variables
LET cCliente = "";
LET cNombre = "";
LET cApell_pat = "";
LET cApell_mat = "";
LET cRfc = "";
LET codret = "00000";
LET csql_err = "100";
LET cRfc_alterno = "";

BEGIN
	ON EXCEPTION SET csql_err
		LET codret = csql_err;
		RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;
	END EXCEPTION;	

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF (pNumcte <> "" AND pCuenta <> "") OR (pNumcte <> "" AND pCuenta = "") THEN
		SELECT
			TRIM(nombre1)||' '||TRIM(nombre2) || Trim(razon_social),
			TRIM(apell_paterno),
			TRIM(apell_materno),
			TRIM(rfc),
			TRIM(rfc_alterno)
		INTO cNombre, cApell_pat, cApell_mat, cRfc, cRfc_alterno
		FROM bdinteg:si_cliente
		WHERE numcte = pNumcte	;	
		
	ELIF pNumcte = "" AND pCuenta <> "" THEN
		SELECT num_cte
		INTO cCliente
		FROM bdicheq:sc_maechq
		WHERE empresa = '001'
		AND cuenta = pCuenta;
		
		IF cCliente IS NULL THEN
			LET codret = "00120";
			RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;			
		END IF;
		
		SELECT
			TRIM(nombre1)||' '||TRIM(nombre2) || Trim(razon_social),
			TRIM(apell_paterno),
			TRIM(apell_materno),
			TRIM(rfc),
			TRIM(rfc_alterno)
		INTO cNombre, cApell_pat, cApell_mat, cRfc, cRfc_alterno
		FROM bdinteg:si_cliente
		WHERE numcte = cCliente;
		
	ELIF (pNumcte = "" AND pCuenta = "") OR (pNumcte IS NULL AND pCuenta IS NULL) THEN
		LET codret = "00100";
		RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;		
	END IF;
	
	IF (cNombre IS NULL) OR (cNombre = "") THEN
		LET codret = "00110";
	END IF;
	
	IF cRFC_alterno is not null and cRFC_alterno <> "" THEN
       LET cRFC = cRFC_alterno;
    END IF;	
	
	RETURN codret, cNombre, cApell_pat, cApell_mat, cRfc;
END
END PROCEDURE
DOCUMENT
	'AUTOR: Clemente Angulo Ballardo',
	'DESCRIPCION: Proceso que obtiene informacion personal de cliente Bancoppel: nombre(s), apellido(s) y RFC', 
	'             o en caso de ser persona moral trae su razon social y el RFC.',
	'VERSION: 20090408.1635';

CREATE PROCEDURE "informix".sp_consultarempleado_web (p_sNumEmpleado CHAR(8))
	RETURNING 	CHAR(5) AS codigoRetorno,
				CHAR(3) AS empresa,				
				CHAR(45) AS nombre,
				CHAR(4) AS sucursal,
				CHAR (3) AS puesto,
				CHAR(20) AS nombramiento,
				CHAR (10) AS asistente,
				CHAR (40) AS password;

	DEFINE v_sEmpresa		CHAR(3);
	DEFINE v_sRazon_social	CHAR(50);
	DEFINE v_sNombre		CHAR(45);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sPuesto		CHAR(3);
	DEFINE v_sNombramiento	CHAR(20);
	DEFINE v_sAsistente		CHAR(10);
	DEFINE v_sPassword		CHAR(40);
	DEFINE V_sCodRetorno	CHAR(5);
	
	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/spauconsultarempleado.out";
	--TRACE ON;
	--------------------------------------------------------------------------
	
	LET V_sCodRetorno = '00000';
	
	BEGIN	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT ej.empresa, ej.nombre, ej.sucursal, ej.puesto, ej.nombramiento, ej.asistente, ej.password
			INTO v_sEmpresa, v_sNombre, v_sSucursal, v_sPuesto, v_sNombramiento, v_sAsistente, v_sPassword
			FROM bdinteg:si_ejecut ej 
			WHERE ejecutivo = p_sNumEmpleado  
			ORDER BY nombre									
			
			RETURN V_sCodRetorno, v_sEmpresa, v_sNombre, v_sSucursal, v_sPuesto, v_sNombramiento, v_sAsistente, v_sPassword WITH RESUME;
		END FOREACH
	END
END PROCEDURE;