CREATE PROCEDURE "informix".consfirmantes_web(pEmpresa char(3), pNumeroCuenta char(20))

	-- DATOS A REGRESAR --
	RETURNING
	char(5),    -- Codigo de retorno
	char(20),   -- Cliente
	char(26),   -- Apellido paterno
	char(26),   -- Apellido materno
	char(26),   -- Nombre 1
	char(26),   -- Nombre 2
	char(2),   -- Secuencia
	char(2),   -- Parentesco
	char(20),    -- Descripcion
    char(1),     -- Tipo de Firma
	char(1),      -- Registro de firma
	char(120)   -- combinación
	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vSec	char(2);
    DEFINE vParen   char(2);
	DEFINE vDesc    char(20);
    DEFINE vTipo_firma char(1);
	DEFINE vReg_firma char(1);
	DEFINE vCombinacion char(120);



	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "00000";
	LET vNumCte = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vSec = "";
	LET vParen = "";
	LET vDesc ="";	
    LET vTipo_firma = "";
	LET vReg_firma = "";
	LET vCombinacion = "";

		-- CICLO PARA OBTENER A LOS FIRMANTES  --

        SET ISOLATION DIRTY READ;
        SET LOCK MODE TO WAIT 3;

	FOREACH

		SELECT DISTINCT
			si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2,
                        sc_fir.secuencia,sc_fir.parentesco, sc_fir.tipo_firma, sc_fir.reg_firma, sc_fir.combinacion
		INTO
			vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vSec, vparen, vTipo_firma, vReg_firma, vCombinacion
		FROM
			bdicheq:sc_firmantes AS sc_fir,
			bdinteg:si_cliente AS si_cte
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta  AND
			sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa 
                ORDER BY sc_fir.secuencia

		
		if vparen <> "" then 
                   select descripcion into vDesc
                   from bdinteg:si_parentesco
                   where parentesco = vparen;   
		end if
	
		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vSec, vparen, vDesc , vTipo_firma, vReg_firma, vCombinacion WITH RESUME;

	END FOREACH;

        /* let vCodRet = '00001'; */
        /* RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vSec, vparen, vDesc , vTipo_firma WITH RESUME; */


END PROCEDURE;