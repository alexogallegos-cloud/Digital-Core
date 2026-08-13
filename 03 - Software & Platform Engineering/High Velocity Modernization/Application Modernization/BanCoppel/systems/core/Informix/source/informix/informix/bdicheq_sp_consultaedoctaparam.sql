CREATE PROCEDURE "informix".sp_consultaedoctaparam( pProducto CHAR(4))
   RETURNING CHAR(5),
			 CHAR(60),
			 CHAR(60),
			 CHAR(100),
			 CHAR(6),
			 CHAR(2),
			 CHAR(2);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cCodret        CHAR(5);
   DEFINE cNomFis        CHAR(60);
   DEFINE cNomNoFis      CHAR(60);
   DEFINE cDescripcion   CHAR(100);
   DEFINE cFechaGrafica  CHAR(6);
   DEFINE cGrafica       CHAR(2);
   DEFINE cProac         CHAR(2);
   DEFINE sql_err        INTEGER;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cCodret        = "000";
   LET cNomFis        = '';
   LET cNomNoFis      = '';
   LET cDescripcion   = '';
   LET cFechaGrafica  = '';
   LET cGrafica       = '';
   LET cProac         = '';

BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodret = sql_err;
            RETURN cCodret, cNomFis, cNomNoFis, cDescripcion, cProac, cGrafica, cFechaGrafica;
        END IF
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ ;
    SET LOCK MODE TO WAIT 3 ;

    IF (pProducto = '' OR pProducto IS NULL) THEN
        LET cCodret = '001'; --Parametros no validos.
        RETURN cCodret, cNomFis, cNomNoFis, cDescripcion, cProac, cGrafica, cFechaGrafica;
    END IF ;

    SELECT nombre_fis, nombre_nofis, descripcion,  proac,  grafica,   fecha_grafica
	 INTO  cNomFis,    cNomNoFis,    cDescripcion, cProac, cGrafica,  cFechaGrafica 
    FROM bdicheq:sc_param_edocta
    WHERE  Producto = pProducto;

	IF cNomFis = '' OR cNomFis IS NULL THEN
		LET cCodRet = '002';
		LET cNomFis = 'No Existe El Producto';
	END IF;
	
    RETURN cCodret, cNomFis, cNomNoFis, cDescripcion, cFechaGrafica, cGrafica, cProac;

END
END PROCEDURE 
DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'DESCRIPCION: Se Crea un SP para los parametros de los estados de cuenta.',
'EstadosCuentas',
'FECHA : Diciembre del 2010',
'VERSION: 20101206',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_consulta_ctas_sdo_retenido(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCta CHAR(20), pNumTarj CHAR(20), pRegistro INTEGER)

RETURNING 
CHAR(6)  AS Retorno,
CHAR(20) AS NumeroCliente,
CHAR(26) AS Nombre,
CHAR(26) AS Nombre2,
CHAR(26) AS apell_pat,
CHAR(26) AS apell_mat,
CHAR(60) AS Razon_social,
CHAR(20) AS Cuenta,
CHAR(20) AS NumTarjeta,
CHAR(4)  AS ProductoTarj,
CHAR(40) AS NOMBRE_PROD;

DEFINE cCodRet        CHAR(6);
DEFINE cCodRet2       CHAR(5);
DEFINE sql_err        INTEGER;
DEFINE cMensajeRet    CHAR(60);  
DEFINE cCodRet3		 CHAR(6);

DEFINE cNumCte        CHAR(20);
DEFINE cNombre        CHAR(26);
DEFINE cCuenta        CHAR(20);
DEFINE cNumTarjeta    CHAR(20);
DEFINE cProductoTarj  CHAR(4);
DEFINE cApellidosPat  CHAR(26);
DEFINE cApellidosMat  CHAR(26);
DEFINE cNumCredito    CHAR(20);
DEFINE cNomProducto   CHAR(60);
DEFINE cProducto	  CHAR(4);
DEFINE cDescripcion	  CHAR(40);
DEFINE cNombre1		  CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cRazonSocial		CHAR(60);
DEFINE iCont		INTEGER;
DEFINE cEstatus			CHAR(2);
DEFINE 	iID				INTEGER;
DEFINE iCont2			INTEGER;
DEFINE iCont3			INTEGER;
DEFINE iPaginacion		INTEGER;
DEFINE cTipoTarjeta     CHAR(1);
DEFINE cBinTarjeta      CHAR(6);
DEFINE cCreditoDebito   CHAR(1);


LET cCodRet        = '000000';
LET cCodRet2       = '00000';
LET sql_err        = 0;
LET cMensajeRet    = '';
LET cCodRet3	='000000';

LET cNumCte        = '';
LET cNombre        = '';
LET cCuenta        = '';
LET cNumTarjeta    = '';
LET cProductoTarj  = '';
LET cApellidosPat  = '';
LET cApellidosMat  = '';
LET cNumCredito    = '';
LET cNomProducto   = '';
LET cProducto	   = '';
LET cDescripcion   = '';
LET cNombre1	   = '';
LET cNombre2	   = '';
LET cApellPat	   = '';
LET cApellMat		= '';
LET cRazonSocial	= '';
LET iCont 			= 0;
LET cEstatus		= '';
LET 	iID			=0;
LET iCont2			= 0;
LET iCont3			=0;
LET iPaginacion     =0;
LET cTipoTarjeta  = '';
LET cBinTarjeta  = '';
LET cCreditoDebito = '';

--SET DEBUG FILE TO "/tmp/sp_consulta_ctas_sdo_retenido.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;

BEGIN

    ON EXCEPTION SET sql_err --, isam_err, error_info
        LET cCodRet = sql_err;
      --LET cMensajeRet = error_info;
	   RETURN cCodRet, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, 

cProductoTarj, cDescripcion;	
    END EXCEPTION;		
    
	--Validacion de parametros
    IF NVL(pEmpresa,'') = '' THEN
        LET pEmpresa = NULL;
    END IF;
    
    IF NVL(pNumCte,'') = '' THEN
        LET pNumCte = NULL;
    END IF;
    
    IF NVL(pNumTarj,'') = '' THEN
        LET pNumTarj = NULL;
    END IF;
    
    IF NVL(pNumCta,'') = '' THEN
        LET pNumCta = NULL;
    END IF;

    IF (pEmpresa IS NULL) OR (pNumCte IS NULL) AND (pNumTarj IS NULL) AND (pNumCta IS NULL)  THEN
        LET cCodRet = '000002'; --"Faltan parametros para su ejecucion"
        RETURN cCodRet, cNumCte,  cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, cProductoTarj, cDescripcion;	
    END IF
    
    IF NOT EXISTS (SELECT Empresa FROM bdinteg:si_empresas WHERE Empresa = pEmpresa) THEN
        LET cCodRet = '000003'; --"No Existe la Empresa"
        RETURN cCodRet, cNumCte,  cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, cProductoTarj, cDescripcion;	
    END IF

    IF (pNumTarj IS NOT NULL) OR (pNumTarj <> '') THEN
       LET cBinTarjeta = SUBSTR (pNumTarj, 0, 6);
	   
	   SELECT TRIM(creditodebito) INTO cCreditoDebito FROM intercard:bines WHERE bin = cBinTarjeta;
      
        IF cCreditoDebito = 'C' THEN
        
            SELECT tipo_tarjeta INTO cTipoTarjeta FROM bdicred:sd_tarjeta
            WHERE  empresa = pEmpresa
            and num_tarjeta = pNumTarj;

            IF cTipoTarjeta <> 'T' THEN
            LET cCodRet= '000186';
            LET cMensajeRet= 'La tarjeta no es titular de la cuenta';
            RETURN cCodRet, cNumCte,  cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, cProductoTarj, cDescripcion;	
            END IF;

        ELSE

            SELECT tipo_tarjeta INTO cTipoTarjeta FROM bdicheq:sc_tarjeta
            WHERE  empresa = pEmpresa
            and num_tarjeta = pNumTarj;

            IF cTipoTarjeta <> 'T' THEN
            LET cCodRet= '000186';
            LET cMensajeRet= 'La tarjeta no es titular de la cuenta';
            RETURN cCodRet, cNumCte,  cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, cProductoTarj, cDescripcion;	
            END IF;

        END IF;
    
     END IF;        
 		--Consulta creditos
        FOREACH
		
            EXECUTE PROCEDURE bdicred:sp_consulta_datos_general(pEmpresa,pNumCte, pNumCta, pNumTarj, cApellidosPat, cApellidosMat, cProductoTarj)
            INTO cCodRet3, cMensajeRet, cNumCredito, cNumCte, cNomProducto, cNumTarjeta, cNombre     
			
			IF cCodRet3 = '000000' THEN
			
				IF cNumTarjeta = '' OR cNumTarjeta IS NULL THEN
					CONTINUE FOREACH;					
	            END IF;  
			
				--Obtiene numero de producto en creditos
				SELECT num_producto , status_cred, id_unidad_prod
				INTO cProducto,cEstatus, iID
				FROM BDICRED:sd_maecred 
				WHERE num_credito = cNumCredito;				
				
				--En caso de no obtener el producto buscara el producto en prestamos
				IF cProducto IS NULL OR cProducto = '' THEN 			
				
					SELECT num_producto , status_cred
					INTO cProducto, cEstatus
					FROM BDICRED:sd_maecredcrd 
					WHERE num_credito = cNumCredito;				
					
				END IF;		
				--Valida que el producto este en el listado de productos retenidos
				IF NOT EXISTS( SELECT sdo.Num_Producto FROM bdicred:sd_productos_sdoret sdo WHERE Num_Producto =  cProducto) THEN
					CONTINUE FOREACH;
				END IF;	
				
				IF cEstatus IN ('CV', 'FF', 'FC') OR iID IN (2,3,4) THEN
					CONTINUE FOREACH;
				END IF;	
				
				SELECT nombre_prod
				INTO cDescripcion
				FROM bdicred:sd_definicion
				WHERE num_producto = cProducto;					
				
				--Consulta el nombre del cliente solo la primer vuelta.
				IF iCont = 0 THEN
				
					SELECT nombre1, nombre2, apell_paterno, apell_materno, razon_social               
					INTO cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial
					FROM BDINTEG:si_cliente
					WHERE empresa = pEmpresa
					AND numcte = cNumCte; 		
					
					LET iCont = 1;
				END IF;

				LET iCont2 = 1;
				
				LET iPaginacion = iPaginacion +1;
				--Paginacion para sucursal
				IF iPaginacion <= pRegistro THEN
		            CONTINUE FOREACH;
		        END IF;
				
				
				RETURN cCodRet, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial,
				cNumCredito, cNumTarjeta, cProducto, cDescripcion WITH RESUME;			
			
			END IF;
			
        END FOREACH;		
		
		--Consulta cuentas de captacion
        FOREACH
            EXECUTE PROCEDURE bdicheq:sp_consulta_ctas_cap_activas(pEmpresa, pNumCte, pNumTarj, pNumCta)
            INTO cCodRet2, cNumCte, cCuenta, cNumTarjeta, cProductoTarj
			
			IF cCodRet2 = '00000' THEN    
				
				IF cNumTarjeta = '' OR cNumTarjeta IS NULL THEN
					CONTINUE FOREACH;					
	            END IF;   
				
                IF cCuenta = '' OR cCuenta IS NULL THEN
					CONTINUE FOREACH;					
	            END IF;
 
				--Obtiene la descripcion del producto
				SELECT nombre
				INTO cDescripcion
				FROM bdicheq:sc_producto
				WHERE producto = cProductoTarj;
				
				IF iCont = 0 THEN
					--Obtiene el nombre del cliente
					SELECT nombre1, nombre2, apell_paterno, apell_materno, razon_social               
					INTO cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial
					FROM BDINTEG:si_cliente
					WHERE empresa = pEmpresa
					AND numcte = cNumCte; 		
					
					LET iCont = 1;
				END IF;     
				
				LET iCont3 = 1;
				
				LET iPaginacion = iPaginacion +1;
				--Paginacion para sucursal
				IF iPaginacion <= pRegistro THEN
					CONTINUE FOREACH;
		        END IF;				
				
				RETURN cCodRet, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, 

cNumTarjeta, cProductoTarj, cDescripcion WITH RESUME;			
				
			END IF;		
            
        END FOREACH;
    
		--Valida que no regrese cuentas de captacion ni creditos.
		IF  iCont2 = 0  AND iCont3 =0  THEN
			LET cCodRet = '000001';
	        RETURN cCodRet, cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, cRazonSocial, cCuenta, cNumTarjeta, 

cProductoTarj, cDescripcion;		
		END IF
    
END
END PROCEDURE
DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: EL SP MUESTRA UN REPORTE DE LOS CREDITOS Y DEBITOS QUE TIENE EL CLIENTE EN LA BASE DE DATOS.',
'FECHA : MARZO DE 2011',
'VERSION: 20110418.1346';

CREATE PROCEDURE "informix".consctestjt(pEmpresa char(3), pNumeroCuenta char(26), pNumeroCliente char(20))
	-- DATOS A REGRESAR --
	RETURNING
	char(5),     -- Codigo de retorno
	char(20),    -- # Cliente
	char(26),    -- Apellido paterno
	char(26),    -- Apellido materno
	char(26),    -- Nombre 1
	char(26),    -- Nombre 2
	char(13),    -- RFC
	char(16),    -- # Tarjeta
	char(5),     -- Fecha vencimiento
	money(14,2), -- Limite de retiro maximo por mes
	char(1),     -- Status tarjeta
	char(8);     -- Tipo de cliente

	-- VARIABLES --
	DEFINE vCodRet  char(5);
	DEFINE vTipCte  char(1);
	DEFINE vNumCte	char(20);
	DEFINE vApePat  char(26);
	DEFINE vApeMat  char(26);
	DEFINE vNombre1 char(26);
	DEFINE vNombre2 char(26);
	DEFINE vRFC     char(13);
	DEFINE vNumTarj char(16);
	DEFINE vFecVenc char(5);
	DEFINE vLimTar  money(14,2);
	DEFINE vTipoCte char(8);
	DEFINE vStatTjt char(1);
	DEFINE vCantReg smallint;
	DEFINE vRFC_alterno char(13);

	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  = "000";
	LET vCantReg = 0;
	LET vRFC_alterno = "";

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3 ;

	-- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
	LET	vTipCte = "";

	SELECT
		'T' AS tipo_cliente, sc_mcq.num_cte
	INTO
		vTipCte, vNumCte
	FROM
		bdicheq:sc_maechq AS sc_mcq
	WHERE
		sc_mcq.empresa = pEmpresa AND
		sc_mcq.cuenta  = pNumeroCuenta AND
		sc_mcq.num_cte = pNumeroCliente;



	IF vTipCte = 'T' THEN
		-- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
		FOREACH
			SELECT DISTINCT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Titular' AS tipo_cliente
			FROM
				bdicheq:sc_maechq AS sc_mcq,
				bdinteg:si_cliente AS si_cte
			WHERE
				sc_mcq.empresa = pEmpresa AND sc_mcq.cuenta =  pNumeroCuenta AND
				sc_mcq.num_cte = si_cte.numcte AND  si_cte.empresa = pEmpresa

			UNION ALL

			SELECT DISTINCT
				si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
			INTO
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
			FROM
				bdicheq:sc_firmantes AS sc_fir,
				bdinteg:si_cliente AS si_cte
			WHERE
				sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte != vNumCte AND
				sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa

			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;			
			
			-- OBTENER LA TARJETA DEL TITULAR O FIRMANTE --
			SELECT
				sc_tjt.num_tarjeta, SUBSTRING(TO_CHAR(sc_tjt.expiracion, "%y-%m-%d") FROM 1 FOR 5), sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				vNumTarj, vFecVenc, vLimTar, vStatTjt
			FROM
				bdicheq:sc_tarjeta AS sc_tjt
			WHERE
				sc_tjt.empresa = pEmpresa AND
				sc_tjt.cuenta = pNumeroCuenta AND
				sc_tjt.numcte = vNumCte AND
				sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar  = 0;
				LET vStatTjt = "";
			END IF

			LET vCantReg = vCantReg + 1;

			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte WITH RESUME;
		END FOREACH;
	ELSE
		-- OBTENER LAS TARJETAS DEL FIRMANTE
		SELECT DISTINCT
			si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'Firmante' AS tipo_cliente
		INTO
			vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte
		FROM
			bdicheq:sc_firmantes AS sc_fir,
			bdinteg:si_cliente AS si_cte
		WHERE
			sc_fir.empresa =  pEmpresa AND sc_fir.cuenta =  pNumeroCuenta AND sc_fir.numcte = pNumeroCliente AND
			sc_fir.numcte = si_cte.numcte AND si_cte.empresa = pEmpresa;

        IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
           LET vRFC = vRFC_alterno;
        END IF;		
			
		-- OBTENER LA TARJETA DEL FIRMANTE --
		SELECT DISTINCT
			sc_tjt.num_tarjeta, SUBSTRING(TO_CHAR(sc_tjt.expiracion, "%y-%m-%d") FROM 1 FOR 5), sc_tjt.limite_aut, sc_tjt.status_tar
		INTO
			vNumTarj, vFecVenc, vLimTar, vStatTjt
		FROM
			bdicheq:sc_tarjeta AS sc_tjt
		WHERE
			sc_tjt.empresa = pEmpresa AND
			sc_tjt.cuenta = pNumeroCuenta AND
			sc_tjt.numcte = vNumCte AND
			sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


		IF vNumTarj IS NULL THEN
			LET vNumTarj = "Sin tarjeta";
			LET vLimTar  = 0;
			LET vStatTjt = "";
		END IF

		LET vCantReg = vCantReg + 1;

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF

	IF vCantReg = 0 THEN
		LET vCodRet  = "141";
		LET vNumCte  = "";
		LET vApePat  = "";
		LET vApeMat  = "";
		LET vNombre1 = "";
		LET vNombre2 = "";
		LET vRFC     = "";
		LET vNumTarj = "";
		LET vLimTar  = 0;
		LET vStatTjt = "";
		LET vTipoCte = "";
		LET vFecVenc = "";

		RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, vFecVenc, vLimTar, vStatTjt, vTipoCte;
	END IF
END PROCEDURE
;