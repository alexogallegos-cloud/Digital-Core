CREATE PROCEDURE "informix".sp_consfirmantespm(pEmpresa char(3), pNumeroCuenta char(20))
        -- DATOS A REGRESAR --
        RETURNING
        char(5),    -- Codigo de retorno
        char(20),   -- Cliente
        char(26),   -- Apellido paterno^M
        char(26),   -- Apellido materno^M
        char(26),   -- Nombre 1^M
        char(26),   -- Nombre 2^M
        char(60),   -- Razon Social
        char(2),    -- Secuencia^M
        char(2),    -- Parentesco^M
        char(20),   -- Descripcion^M
        char(1),    --reg firma
        char(1),    --tipo nivel
        char(120),   --combinacion
        char(1)      --tipo firma

        -- VARIABLES --^M
        DEFINE vCodRet  char(5);
        DEFINE vNumCte  char(20);
        DEFINE vApePat  char(26);
        DEFINE vApeMat  char(26);
        DEFINE vNombre1 char(26);
        DEFINE vNombre2 char(26);
        DEFINE vSec     char(2);
        DEFINE vParen   char(2);
        DEFINE vDesc    char(20);
        DEFINE vRazon   char(60);
        DEFINE vRegF    char(1);
        DEFINE vTipoF   char(1);
        DEFINE vCombina char(120);
        DEFINE vFirmasReg char(1);



        -- INICIALIZACION DE VARIABLES --
        LET vCodRet  = "000";
        LET vNumCte = "";
        LET vApePat = "";
        LET vApeMat = "";
        LET vNombre1 = "";
        LET vNombre2 = "";
        LET vSec = "";
        LET vParen = "";
        LET vDesc =""; 
        LET vRazon = "";
        LET vRegF = "";
        LET vTipoF = "";
        LET vCombina ="";
        LET  vFirmasReg = "";
                -- CICLO PARA OBTENER A LOS FIRMANTES  --^M
        FOREACH
                SELECT DISTINCT
                        si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2,si_cte.razon_social,
                        sc_fir.secuencia,sc_fir.parentesco,sc_fir.reg_firma,sc_fir.tipo_firma,sc_fir.combinacion
                INTO
                        vNumCte, vApePat, vApeMat, vNombre1, vNombre2,vRazon, vSec, vparen,vRegF,vTipoF,vCombina
                FROM
                        bdicheq:sc_firmantes AS sc_fir,
                        bdinteg:si_cliente AS si_cte
                WHERE
                        sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta  AND
                        sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa 
                order by sc_fir.secuencia  
                
                if vparen <> "" then 
                   select descripcion into vDesc
                   from bdinteg:si_parentesco
                   where parentesco = vparen;   
                end if

                select reg_firmas into vFirmasReg from sc_maenoc
                where cuenta = pNumeroCuenta;


        
                RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2,vRazon, vSec, vparen, vDesc,vRegF,vTipoF,vCombina,vFirmasReg  WITH RESUME;

        END FOREACH;



END PROCEDURE
;