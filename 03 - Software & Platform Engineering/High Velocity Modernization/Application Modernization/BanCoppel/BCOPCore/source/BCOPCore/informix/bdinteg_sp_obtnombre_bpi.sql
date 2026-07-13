CREATE PROCEDURE "informix".sp_obtnombre_bpi(pEmpresa CHAR(3), pNumCte CHAR(9))
	returning CHAR(5), CHAR(26),CHAR(26), CHAR(26), CHAR(26);

	--Elaboró: Javier A. Chávez T.
	--Actividad: devuelve el nombre del cliente
	--Solicito: Mauricio León
	--Fecha: 17/04/09
	---*********************************************
	--Modifico: José de Jesús Nevarez
	--Actividad: Se modifica para que obtenga el nombre de Clientes de la EmpresaNet.
	--Solicito: Diana Castellanos
	--Fecha: 23/08/2011

	--DEFINE VARIABLES
	DEFINE vNombre1 CHAR (26);
	DEFINE vNombre2 CHAR (26);
	DEFINE vApell_pat CHAR (26);
	DEFINE vApell_mat CHAR (26);
	DEFINE vTpoPersona CHAR (2);
	DEFINE vRazonSocial CHAR (60);
	DEFINE iLongitud  INTEGER;
	DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER; 

	--Inicializa
	LET cod_ret ='000';
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vApell_pat = "";
	LET vApell_mat = "";
	LET vTpoPersona = "";
	LET vRazonSocial= "";
	LET iLongitud = 0;


 BEGIN
	ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNombre1, vNombre2, vApell_pat, vApell_mat;
      END IF ;
	END EXCEPTION ;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF(pNumCte <> '') THEN
	
		SELECT tpo_persona INTO vTpoPersona FROM  bdinteg:"informix".si_cliente WHERE numcte = pNumCte and empresa = pEmpresa;
		
		IF (vTpoPersona IS NOT NULL OR vTpoPersona <> '') THEN
			IF (vTpoPersona == '01') THEN
				SELECT nombre1, nombre2, apell_paterno, apell_materno INTO vNombre1, vNombre2, vApell_pat, vApell_mat
				FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte and empresa = pEmpresa;
			ELSE 
				SELECT razon_social INTO vRazonSocial FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte and empresa = pEmpresa;
			
				LET vRazonSocial = TRIM(vRazonSocial);
				LET iLongitud = LENGTH(vRazonSocial);
			
				IF (iLongitud <= 24) THEN
					LET vNombre1 = vRazonSocial;
					LET vApell_pat = vRazonSocial;
				ELSE 
					LET vNombre1 = SUBSTRING(vRazonSocial FROM 1 FOR 24);
					LET vApell_pat = SUBSTRING(vRazonSocial FROM 25 FOR (iLongitud));
				END IF;
			END IF;
		END IF;

		IF (vNombre1 = '' OR vNombre1 IS NULL) THEN
			LET cod_ret = '002';
		END IF;

	ELSE
		LET cod_ret = '001';
	END IF;

	RETURN cod_ret, vNombre1, vNombre2, vApell_pat, vApell_mat;
 END;
END PROCEDURE;