CREATE PROCEDURE "informix".sp_actmarhuella(
        pEmpresa                CHAR(3),
        pNumCta                 CHAR(20),
        pNumCte                 CHAR(20),
        pNumTarjeta           CHAR(20),
        pTipoOperacion      CHAR(1),
        pNumOperador       CHAR(8))

---DATOS A REGRESAR
RETURNING
        CHAR(5),    --Codigo de Retorno
        CHAR(20),   --Numero de Cuenta
        CHAR(20),   --Numero de Cliente
        CHAR(26),   --Appellido Paterno
        CHAR(26),   --Apellido Materno
        CHAR(26),   --Nombre1
        CHAR(26),   --Nombre2
        CHAR(4),    --Sucursal
        DATE,          --Fecha de Alta del Cliente
        CHAR(20),  --Numero de Tarjeta
        CHAR(4),    --Codigo del Producto de la Cuenta
        CHAR(40),   --Descripcion del producto
        MONEY(14, 2),      --Importe del deposito
        DATE;          --Fecha del Deposito

--DECLARACION DE VARIABLES
DEFINE      vCodRet          CHAR(5);
DEFINE      vNumCta         CHAR(20);
DEFINE      vNumCte         CHAR(20);
DEFINE      vApellPat         CHAR(26);
DEFINE      vApellMat         CHAR(26);
DEFINE      vNombre1       CHAR(26);
DEFINE      vNombre2       CHAR(26);
DEFINE      vSucursal        CHAR(4);
DEFINE      vFechaCte       DATE;
DEFINE      vNumTarjeta         CHAR(20);
DEFINE      vCodProducto       CHAR(4);
DEFINE      vDescProducto     CHAR(40);
DEFINE      vImporteDep          MONEY(14,2);
DEFINE      vFechaDeposito    DATE;
DEFINE      vSqlErr                     SMALLINT;
DEFINE      vCantidadReg        SMALLINT;

--INICIALIZACION DE VARIABLES

LET     vCodRet = "00000";
LET     vNumCta = "";
LET     vNumCte = "";
LET     vApellPat = "";
LET     vApellMat = "";
LET     vNombre1 = "";
LET     vNombre2 = "";
LET     vSucursal = "";
LET     vFechaCte = "";
LET     vNumTarjeta = "";
LET     vCodProducto = "";
LET     vDescProducto = "";
LET     vImporteDep = 0;
LET     vFechaDeposito = "";
LET     vSqlErr = 0;
LET     vCantidadReg = 0;


BEGIN
        ON EXCEPTION SET vSqlErr 
            IF vSqlErr <> 0 THEN
                    LET vCodRet = vSqlErr;
                    RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                    vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
            END IF
        END EXCEPTION
        
        IF pTipoOperacion = "" THEN
                LET vCodRet = "99999";
                RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                 vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
        END IF
       -- SET DEBUG FILE  TO "/pisa/pisabanco/pisa_ftes/cheques/ActMarHuella.out";
        --TRACE ON;
        
        IF pTipoOperacion = "1" THEN  --- Consulta datos por medio del número de cuenta
                IF pNumCta = "" OR pEmpresa = "" THEN
                    LET vCodRet = "110";
                    RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                    vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                    
                ELSE
                     IF EXISTS(SELECT cheq.cuenta, cheq.num_cte FROM bdicheq:sc_maechq AS cheq INNER JOIN bdicheq:sc_tarjeta  AS tar ON tar.cuenta  = cheq.cuenta AND tar.numcte = cheq.num_cte INNER JOIN bdinteg:si_cliente AS cte ON cte.numcte = cheq.num_cte WHERE cheq.empresa = pEmpresa AND cheq.cuenta = pNumCta) THEN

                            SELECT maechq.cuenta, maechq.num_cte, maechq.producto, maechq.sdo_actual, maechq.fecultdep, prod.nombre,  
                                            tarje.num_tarjeta, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.sucursal, cte.fecha_alta

                             INTO       vNumCta, vNumCte, vCodProducto, vImporteDep, vFechaDeposito, vDescProducto, vNumTarjeta, vApellPat,
                                            vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte
                             FROM    bdicheq:sc_maechq AS maechq INNER JOIN bdicheq:sc_producto AS prod ON maechq.producto = prod.producto
                                            INNER JOIN bdicheq:sc_tarjeta AS tarje ON maechq.cuenta = tarje.cuenta AND maechq.num_cte = tarje.numcte AND 
                                            tarje.tipo_tarjeta = "T" AND tarje.status_tar = "A"
                                            INNER JOIN bdinteg:si_cliente AS cte ON cte.empresa = pEmpresa AND maechq.num_cte = cte.numcte
                             WHERE  maechq.empresa = pEmpresa AND maechq.cuenta = pNumCta;

                             RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                             vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 

                    ELSE

                                LET vCodRet = "100";
                                RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                 vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                    END IF;

                END IF;
            
 


       ELIF pTipoOperacion = "2" THEN  --Consulta por numero de cliente
                    IF pNumCte = "" OR pEmpresa = "" THEN
                                LET vCodRet = "110";
                                RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                    ELSE
                                IF EXISTS (SELECT num_cte FROM bdicheq:sc_maechq WHERE num_cte = pNumCte) THEN
                                    FOREACH

                                                SELECT cuenta INTO vNumCta FROM bdicheq:sc_maechq WHERE num_cte = pNumCte
                                                LET vCantidadReg = vCantidadReg + 1;
                                                 RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                                 vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito WITH RESUME; 

                                    END FOREACH;

                                ELSE

                                    LET vCodRet = "141";
                                    RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                     vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                                END IF;
                    END IF;

       ELIF pTipoOperacion = "3" THEN  --Consulta por medio del numero de tarjeta

                      IF pEmpresa = "" OR  pNumTarjeta = "" THEN
                                   LET vCodRet = "110";
                                    RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                     vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                      ELSE
                                    IF EXISTS (SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE num_tarjeta = pNumTarjeta) THEN

                                                SELECT tarje.num_tarjeta, tarje.cuenta, tarje.numcte, maechq.producto, maechq.sdo_actual,
                                                                maechq.fecultdep, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, 
                                                                cte.sucursal, cte.fecha_alta, prod.nombre

                                                INTO        vNumTarjeta, vNumCta, vNumCte, vCodProducto, vImporteDep, vFechaDeposito,
                                                                 vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte, vDescProducto
                                                FROM       bdicheq:sc_tarjeta  AS tarje INNER JOIN  bdicheq:sc_maechq AS maechq ON tarje.empresa = maechq.empresa AND tarje.cuenta = maechq.cuenta AND
                                                                  tarje.numcte = maechq.num_cte INNER JOIN bdinteg:si_cliente AS cte ON  tarje.empresa = cte.empresa AND
                                                                  tarje.numcte = cte.numcte INNER JOIN bdicheq:sc_producto AS prod ON tarje.prodtarjeta = prod.producto
                                                WHERE    tarje.empresa = pEmpresa AND tarje.num_tarjeta = pNumTarjeta AND tarje.tipo_tarjeta = "T" AND tarje.status_tar = "A";

                                              RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                             vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito; 
                                                                                                                                                                                   
                                    ELSE
                                                LET vCodRet = "252";
                                                 RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                                 vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito;                                                
                                    END IF;
                      END IF;

       ELIF  pTipoOperacion = "4" THEN --Actualiza el flag de huella confirmada

                       IF pEmpresa = "" OR pNumCta = "" OR pNumCte = ""  OR pNumOperador = "" THEN
                                        LET vCodRet = "110";
                                         RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                          vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito;                                                                                           
                       ELSE

                                        IF EXISTS (SELECT cuenta, num_cte FROM bdicheq:sc_maechq WHERE empresa  = pEmpresa AND cuenta = pNumCta AND
                                                            num_cte = pNumCte AND status_cta = "1" AND marca_ret = "0") THEN
                                                            
                                                            UPDATE bdicheq:sc_maechq SET marca_ret = "1" WHERE empresa = pEmpresa AND cuenta = pNumCta AND
                                                            num_cte = pNumCte AND status_cta = "1";
                                                             RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                                              vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito;            
                                        ELSE
                                                             IF EXISTS (SELECT cuenta, num_cte FROM bdicheq:sc_maechq WHERE empresa  = pEmpresa AND cuenta = pNumCta AND
                                                                                num_cte = pNumCte AND status_cta <> "1") THEN
                                                                                
                                                                        LET vCodRet = "243";
                                                                        RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                                                         vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito;            

                                                             ELIF EXISTS (SELECT cuenta, num_cte FROM bdicheq:sc_maechq WHERE empresa  = pEmpresa AND cuenta = pNumCta AND
                                                            		  num_cte = pNumCte AND status_cta = "1" AND marca_ret = "1") THEN

                                                                                   
                                                                        LET vCodRet = "244";
                                                                         RETURN vCodRet, vNumCta, vNumCte, vApellPat, vApellMat, vNombre1, vNombre2, vSucursal, vFechaCte,
                                                                                         vNumTarjeta, vCodProducto, vDescProducto, vImporteDep, vFechaDeposito;            
                                                            END IF;
                                        END IF;
                       END IF;
                
       END IF;
END;
--ELABORO:  Aymme Osuna
--FECHA:        28/09/2007
--PROYECTO: Actualizacion de la bandera de huella confirmada(Nuevo)
END PROCEDURE;