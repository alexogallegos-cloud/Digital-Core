CREATE PROCEDURE "informix".consdatadic_web(pEmpresa char(3), prfc char(13))
--DATOS A REGRESAR
RETURNING
CHAR(5),    -- Codigo de retorno
CHAR(20),   -- # Cliente
CHAR(26),   -- Apellido paterno
CHAR(26),   -- Apellido materno
CHAR(26),   -- Nombre 1
CHAR(26),   -- Nombre 2
CHAR(13),   -- RFC
CHAR(10);   -- Fecha de Nacimiento

--DECLARACION DE VARIABLES

DEFINE vCodRet          char(5);
DEFINE vNumCte          char(20);
DEFINE vApell_Paterno   char(26);
DEFINE vApell_Materno   char(26);
DEFINE vNombre1         char(26);
DEFINE vNombre2         char(26);
DEFINE vRfc             char(13);
DEFINE vFechaNacimiento char(10);
DEFINE vCantReg         smallint;

--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET vNumCte = "";
LET vApell_Paterno = "";
LET vApell_Materno = "";
LET vNombre1 = "";
LET vNombre2 = "";
LET vRfc = "";
LET vFechaNacimiento = "";
LET vCantReg = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO wait 3;

-- OBTENER LOS DATOS DEL CLIENTE
        SELECT DISTINCT
                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_pf.fecha_nac
        INTO
                vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento
        FROM
                bdinteg:si_cliente AS si_cte,
                bdinteg:si_ctepf AS si_pf
        WHERE
                si_cte.empresa = pEmpresa AND
                si_cte.rfc = prfc AND
                si_pf.numcte = si_cte.numcte;

        IF vNumCte <> "" AND vApell_Paterno <> "" AND vRfc <> "" THEN
                LET vCantReg = vCantReg + 1;
                RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento;
        END IF;

        IF vCantReg = 0 THEN
                LET vCodRet  = "00253";
                LET vNumCte  = "";
                LET vApell_Paterno  = "";
                LET vApell_Materno  = "";
                LET vNombre1 = "";
                LET vNombre2 = "";
                LET vRfc     = "";
                LET vFechaNacimiento = "";

        RETURN vCodRet, vNumCte, vApell_Paterno, vApell_Materno, vNombre1, vNombre2, vRfc, vFechaNacimiento;
        END IF
END PROCEDURE;