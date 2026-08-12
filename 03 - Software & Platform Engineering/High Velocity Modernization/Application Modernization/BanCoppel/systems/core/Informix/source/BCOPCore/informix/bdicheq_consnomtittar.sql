CREATE PROCEDURE "informix".consnomtittar(pEmpresa char(3), pTarjeta char(20))

--DATOS A REGRESAR---
RETURNING

char(5), --Codigo de Retorno
char(20), --Numero Cliente
char(20), --Numero Cuenta
char(26), --Apellido Paterno
char(26), --Apellido Materno
char(26), --Nombre1
char(26), --Nombre2
char(13),  --RFC
CHAR(4);  -- Numero de Producto

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         char(5);
DEFINE Vnumcte          char(20);
DEFINE Vnumcta          char(20);
DEFINE VaPaterno        char(26);
DEFINE vaMaterno        char(26);
DEFINE vNombre1         char(26);
DEFINE VNombre2         char(26);
DEFINE Vrfc             char(13);
DEFINE vCantReg         smallint;
DEFINE vNumProd         CHAR(4);
DEFINE vValProd         CHAR(4);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret 	= "000";
LET Vnumcte		= "";
LET Vnumcta		= "";
LET VaPaterno 	= "";
LET vaMaterno 	= "";
LET vNombre1	= "";
LET VNombre2 	= "";
LET Vrfc 		= "";
LET vCantReg 	= 0;
LET vValProd   	= "";
LET vNumProd    ="";
	
	-- Se agrega para evitar bloqueo 17/01/2012
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

        SELECT
			b.num_cte, a.cuenta, c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, c.rfc,
			b.producto 
        INTO
			Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vNumProd 
        FROM
			bdicheq:sc_tarjeta a, bdicheq:sc_maechq b, bdinteg:si_cliente c
        WHERE
			a.empresa = pEmpresa and a.num_tarjeta = pTarjeta and a.cuenta = b.cuenta and b.num_cte = c.numcte ; 
			
        if Vnumcte <> "" and Vnumcta <> ""  and Vrfc <> "" then
           let vCantReg = vCantReg +1;
                
           SELECT
                   valor 
           INTO
                   vValProd 
           FROM
                   bditarjeta:td_producto_emp
           WHERE
                   codigo = vNumProd; 
            
           IF vValProd IS NULL OR Trim(vValProd) = "" THEN
                LET vValProd = "501";
           END IF

           RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vValProd ;

        end if

        IF vCantReg = 0 THEN
                LET Vcod_Ret      = "252";
                LET Vnumcte       = "";
                LET Vnumcta       = "";
                LET VaPaterno     = "";
                LET vaMaterno     = "";
                LET vNombre1      = "";
                LET VNombre2      = "";
                LET vNombre2      = "";
                LET Vrfc          = "";
                LET vNumProd      ="";

                RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, vNumProd;
        end if

END PROCEDURE;