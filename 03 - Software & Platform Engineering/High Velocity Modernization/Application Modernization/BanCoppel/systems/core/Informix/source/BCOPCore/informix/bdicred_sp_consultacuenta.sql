CREATE PROCEDURE "informix".sp_consultacuenta(pEmpresa CHAR(3), pNumCuenta CHAR(20))

RETURNING CHAR(6)  AS codigo_error,
          CHAR(80) AS mensaje_error, 
          CHAR(3)  AS empresa, 
          CHAR(20) AS num_cuenta, 
          CHAR(20) AS num_cliente,
          CHAR(50) AS nombre_cliente,          
          CHAR(4)  AS sucursal, 
          CHAR(30) AS bloqueo,
          CHAR(50) AS causa,          
          CHAR(2)  AS status, 
          DATE     AS fecha_apertura;

--31/10/2008
--Abraham Ayala Aguilar
--Busca una cuenta para revisar si la cuenta esta bloqueada o no esta bloqueada.

--05/11/2008
--Rodolfo Tortolero Varela
--Se modifico la consulta para obtener la descripciÃ²n del tipo de bloqueo.

--06/11/2008
--Rodolfo Tortolero Varela
--Se agrego una consulta para checar si el campo id_unidad_prod es nulo
--de ser asi su actualiza con un '0'.

--18/11/2008
--Rodolfo Javier Tortolero Varela
--Se modifico el codigo de la consulta.

--08/01/2009
--Roque Enrique Solis CampaÃ±a
--Se quitÃ³ el update al campo d_unidad_prod y los retornos se hicieron de 6 digitos

-- Fecha: 14/01/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
-- Observaciones/Comentario: Se modifica para realizar la consulta
--en base a la fecha de bloqueo y no a la
--fecha de apertura del credito.

--04/05/2009
-- ModificÃ³: Roque Enrique Solis CampaÃ±a
--Se agrego la causa del bloqueo

--DEFINICION DE VARIABLES--
    DEFINE iSqlErr        INTEGER;
    DEFINE iIsamErr       INTEGER;
    DEFINE cErrorInfo     CHAR(80);
    DEFINE cCodRet        CHAR(6);
    DEFINE vCodRet        CHAR(6);
    DEFINE cMensajeRet    CHAR(80);
    DEFINE vNumCte        CHAR(20);
    DEFINE vSucursal      CHAR(4);
    DEFINE vDescripcion   CHAR(30);
    DEFINE vStatusCredito CHAR(2);
    DEFINE vFechaApertura DATE;
    DEFINE vCodSP         CHAR(6);
    DEFINE cCausa         CHAR(50);
    DEFINE vID            INTEGER;
    DEFINE cCodCausa      CHAR(2);
    DEFINE cNombre        CHAR(50);
    DEFINE cCredBitacora  CHAR(20);
    --Set debug file to '/home/e10000315/bloqueo/sp_consultacuentas.out';
    --trace on;
    
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
               IF iSqlErr != 0 THEN
                  LET cCodRet= iSqlErr;
                  LET cMensajeRet= cErrorInfo;
                 RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                        vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
               END IF;
       END EXCEPTION;
        
    
--INICIALIZACION DE VARIABLES--
        LET vCodRet        = '999999';    --No existe el cliente
        LET vNumCte        = '';
        LET vSucursal      = '';
        LET vDescripcion   = '';
        LET vStatusCredito = '';
        LET vFechaApertura = DATE(1);
        LET vID            = 0;
        LET cCausa         = '';
        LET cCodCausa      = '';
        LET iIsamErr       = 0;
        LET cErrorInfo     = '';
        LET cCodRet        = '';
        LET cmensajeret    = '';
        LET cNombre        = '';
        LET cCredBitacora  = '';

        
        IF pEmpresa IS NULL AND (pNumCuenta IS NULL OR pNumCuenta ='') THEN
        
            LET vCodRet = '000001';    --Faltan valores
            LET cMensajeRet="Faltan valores para ejecutar el proceso";
        ELSE    
        
            EXECUTE PROCEDURE bdicred:sp_validacredito (pEmpresa, pNumCuenta) INTO vCodSP;
            
            IF vCodSP <> '000000' THEN
               LET vCodRet = '000002';    --Faltan valores
               LET cMensajeRet="La cuenta no es valida";
            ELSE
                 LET vCodRet = '000000';    --Cliente encontrado
                SELECT id_unidad_prod, cod_caract_2 
                  INTO vID, cCodCausa
                  FROM "informix".sd_maecred
                 WHERE empresa = pEmpresa 
                   AND num_credito = pNumCuenta;
                   
                IF (vID IS NULL AND cCodCausa IS NOT NULL)  THEN --OR (vID IS NOT NULL AND cCodCausa IS NULL) THEN
                     LET vCodRet= '000003';
                     LET cMensajeRet= 'CrÃ©dito bloqueado manualmente, favor de verificar'; 
                     
                END IF;
                IF vID IS NOT NULL AND (cCodCausa IS NOT NULL OR cCodCausa IS  NULL) THEN
                   LET vCodRet= '000004';
                   LET cMensajeRet= 'El crÃ©dito ya ha sido bloqueado, no sera posible bloquear nuevamente';
                END IF;
                
                SELECT cuenta
                  INTO cCredBitacora
                  FROM "informix".sd_bitacorabloqueocta
                 WHERE cuenta=pNumCuenta
                   AND cve_bloqueo=vID
                   AND nvl(cve_causa,'')=nvl(cCodCausa,'')
                   AND id=(SELECT max(id)
                             FROM "informix".sd_bitacorabloqueocta
                            WHERE cuenta=pNumCuenta
                              AND cve_bloqueo=vID
                              AND nvl(cve_causa,'')=nvl(cCodCausa,''));
                              
                IF cCredBitacora IS NULL AND vID IS NOT NULL THEN  
                    LET vCodRet = '000006';    --La cuenta ya esta desbloqueada.
                    LET cMensajeRet= 'Credito desbloqueado manualmente, favor de verificar';
                END IF;
                
                SELECT cte.numcte, 
                       CASE WHEN NVL(cte.razon_social,'') ='' THEN TRIM(cte.nombre1) || " " || TRIM(cte.nombre2) || " " || TRIM(cte.apell_paterno) || " " || TRIM(cte.apell_materno) ELSE cte.razon_social END,  
                       cte.sucursal, 
                       blo.descripcion,  
                       mae.status_cred, 
                       btc.fecha, 
                       ca.causa_bloq 
                  INTO vNumCte,cNombre, vSucursal, vDescripcion, vStatusCredito, vFechaApertura, cCausa
                  FROM bdicred:sd_maecred mae 
                  LEFT OUTER JOIN bdinteg:si_cliente cte ON (mae.numcte = cte.numcte)
                  LEFT OUTER JOIN bdicred:sd_bloqueoscuenta  blo ON  (mae.id_unidad_prod = blo.clave)
                  LEFT OUTER JOIN bdicred:sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta AND btc.id=(SELECT MAX(b.id) 
                                                                                                                   FROM sd_bitacorabloqueocta b 
                                                                                                                   WHERE b.cuenta=mae.num_credito))
                  LEFT OUTER JOIN bdicred:sd_causa_bloqueo ca ON (ca.cod_causa =mae.cod_caract_2 AND mae.empresa=ca.empresa)
                 WHERE mae.empresa = pEmpresa 
                   AND mae.num_credito = pNumCuenta;                 
                                
            
                IF vNumCte IS NULL THEN
                    let vNumCte = '';
                END IF;

                IF vSucursal IS NULL THEN
                    let vSucursal = '';
                END IF;

                IF vDescripcion IS NULL AND vID IS NOT NULL THEN
                    let vDescripcion = 'Tipo de bloqueo desconocido';
                ELIF vDescripcion IS NULL AND vID IS NULL THEN
                    let vDescripcion = 'No tiene bloqueo';
                END IF
                
                IF cCausa IS NULL AND cCodCausa IS NOT NULL THEN
                   LET cCausa='Motivo de restricciÃ³n desconocido'; --
                ELIF cCausa IS NULL AND cCodCausa IS NULL THEN
                    LET cCausa='No tiene motivo de restricciÃ³n'; 
                END IF;
                
                IF vStatusCredito IS NULL THEN
                    let vStatusCredito = '';
                END IF;

                IF vFechaApertura IS NULL THEN
                    let vFechaApertura = DATE(1);
                END IF;
                
                IF vStatusCredito='CV'    THEN
                    LET vCodRet='000002';
                    LET cMensajeRet = 'CrÃ©dito en cartera vendida';
                    RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
                           vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
                END IF;
                
                
            END IF;        END IF;        
        RETURN vCodRet, cMensajeRet, pEmpresa, pNumCuenta, vNumCte,cNombre, vSucursal, 
               vDescripcion, cCausa , vStatusCredito, vFechaApertura; 
    END;
END PROCEDURE;