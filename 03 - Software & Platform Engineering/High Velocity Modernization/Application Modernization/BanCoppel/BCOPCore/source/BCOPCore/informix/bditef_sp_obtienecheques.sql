CREATE PROCEDURE "informix".sp_obtienecheques( pEmpresa       CHAR(3), 
                                               pBanco         CHAR(3), 
                                               pCuenta        CHAR(20), 
                                               pNumCheque     CHAR(7),
                                               pFechaPresenta DATE )
RETURNING CHAR(6)   AS cCodRet,
          CHAR(3)   AS CveBanco,
          CHAR(40)  AS Descripcion,
          CHAR(20)  AS Cuenta,
          CHAR(7)   AS NumCheque,
          DATE      AS FechaALta,
          DATE      AS FechaPresenta,
          CHAR(8)   AS Usuario,
          CHAR(4)   AS Producto,
          CHAR(20)  AS Cliente,
          CHAR(104) AS NombreCliente,
          CHAR(40)  AS NombreProducto,
          CHAR(20)  AS CuentaDep,
		  CHAR(1)   AS Revisado,
		  CHAR(8)   AS EjecutivoReviso,
	      DECIMAL(16,2) AS Monto,
       	  CHAR(4) AS Sucursal;
		  
    DEFINE cCodRet          CHAR(6);
    DEFINE cCodRet2         CHAR(6);
    DEFINE cCodRet3         CHAR(60);
    DEFINE iSql_Err         INTEGER;
    DEFINE iSam_Err         INTEGER;
    DEFINE iDesc_Err        CHAR(60);
    DEFINE cCveBanco        CHAR(3);  
    DEFINE cDescripcion     CHAR(40);
    DEFINE iCuenta		    INT8;
    DEFINE iNumCheque       INT8;
    DEFINE dFechaAlta		DATE;
    DEFINE dFechaPresenta   DATE;
    DEFINE cUsuarioAlta		CHAR(8);
    DEFINE cProducto        CHAR(4);
    DEFINE cCliente         CHAR(20);
    DEFINE cNombreCte       CHAR(104);
    DEFINE cNomProducto     CHAR(40);
    DEFINE cCuentaDep       CHAR(20);  
    DEFINE dMonto           DECIMAL(18,2);
    DEFINE cRevisado        CHAR(1);  
    DEFINE cEjecutivoReviso CHAR(8);  
    DEFINE dMontoRet		DECIMAL(16,2);
	DEFINE cSucursal		CHAR(4);
		
    LET cCodRet         = '000000';
    LET cCodRet2        = '000000';
    LET cCodRet3        = '';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET iDesc_Err       = '';
    LET cCveBanco       = '';
    LET cDescripcion    = '';
    LET iCuenta         = 0; 
    LET iNumCheque      = 0;
    LET dFechaAlta      = '01-01-2000';
    LET dFechaPresenta  = '01-01-2000';
    LET cUsuarioAlta    = '';
    LET cProducto       = '';
    LET cCliente        = '';
    LET cNombreCte      = '';
    LET cNomProducto    = '';
    LET cCuentaDep      = '';
    LET dMonto          = 0.00;
	LET cRevisado       = '';  
    LET cEjecutivoReviso = '';  
	LET dMontoRet 		= 0.00;
	LET cSucursal		= '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtienecheques.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, iDesc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtienecheques.err";
        TRACE ON;
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            LET cCodRet2 = iSam_Err;
            LET cCodRet3 = iDesc_Err;
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'');	   
        END IF;
    END EXCEPTION;

    -- // Si los parametros vienen vacios '' se convierten a nulos. 
    IF pBanco = '' THEN 
        LET pBanco = NULL;
    END IF;

    IF pCuenta = '' THEN 
        LET pCuenta = NULL;
    END IF;

    IF pNumCheque = '' THEN 
        LET pNumCheque = NULL;
    END IF;

    IF pFechaPresenta = '' THEN 
        LET pFechaPresenta = NULL;
    END IF;

    -- // Valida que al menos traiga valor en un parametro.
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
        LET cCodRet = '000001'; 
        LET cDescripcion = 'Debe mandar al menos un parametro';
        RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
               NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'');
	END IF
    
    IF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH 
            SELECT 
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
			 			 
            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
			SELECT TRIM(nombre)
            INTO cNomProducto
            FROM bdicheq:"informix".sc_producto 
            WHERE producto = cProducto;

            -- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
			  FROM 'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;			 
            
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
        END FOREACH;				   
        
    ELIF pBanco IS NULL AND pCuenta IS NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
        
        FOREACH 
            SELECT  
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.numcheque = pNumCheque
			   			   			   
            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
              INTO cNomProducto
              FROM bdicheq:"informix".sc_producto 
             WHERE producto = cProducto;
			 
			-- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM 'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
        
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
			 
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
        END FOREACH;

    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH 
            SELECT  
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.cvebanco = pBanco

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
              INTO cNomProducto
              FROM bdicheq:"informix".sc_producto 
             WHERE producto = cProducto;

            -- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM 'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
            
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
            
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
			 
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
        END FOREACH;
				        
    ELIF pBanco IS NOT NULL AND pCuenta IS NULL AND pNumCheque IS NULL AND pFechaPresenta IS NULL THEN  
    
        FOREACH 
            SELECT  
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.cvebanco = pBanco

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
              INTO cNomProducto
              FROM bdicheq:"informix".sc_producto 
             WHERE producto = cProducto;

            -- // Consulta revisado y ejecutivo quien reviso --LCJD
            SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
              FROM 'informix'.cce_cheques_revisados 
             WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
            
            IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
            END IF;
            
            IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
            END IF;
                  
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
        END FOREACH;
		
    ELIF pBanco IS NOT NULL AND pCuenta IS NOT NULL AND pNumCheque IS NOT NULL AND pFechaPresenta IS NOT NULL THEN  
    
        FOREACH 
            SELECT  
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE img.fechapresenta = pFechaPresenta
               AND img.cvebanco = pBanco
               AND img.numcuenta = pCuenta
               AND img.numcheque = pNumCheque

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
              INTO cNomProducto
              FROM bdicheq:"informix".sc_producto 
             WHERE producto = cProducto;

			-- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
			  FROM 'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;
			 
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
		END FOREACH;				   
				   
	ELSE
    
        -- // Consulta los cheques que se encuentren en el archivo electronico.
        FOREACH 
            SELECT 
                   DISTINCT img.cvebanco, si.descripcion, img.numcuenta, img.numcheque, img.fecha_alta, img.fechapresenta, img.usuario_alta, det.monto
              INTO cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, cUsuarioAlta, dMonto
              FROM cce_cheques_img img
             INNER JOIN bdinteg:si_bancos si ON ( img.cvebanco = si.banco )
              LEFT OUTER JOIN cce_cheques_det det ON ( det.empresa = img.empresa AND det.numcheque = img.numcheque AND det.numcuenta = img.numcuenta AND det.cvebanco = img.cvebanco AND det.fecha_alta = img.fecha_alta )
             WHERE ((((((img.numcuenta = CASE WHEN (pCuenta != '' )  THEN pCuenta  ELSE img.numcuenta  END )
               AND (img.cvebanco = CASE WHEN (pBanco != '' )  THEN pBanco  ELSE img.cvebanco  END ) )
               AND (img.numcheque = CASE WHEN (pNumCheque != '' )  THEN pNumCheque  ELSE img.numcheque  END ) )
               AND (img.imagen_formato IN ('jpg' ,'tif' )) ) 
               AND (img.empresa = pEmpresa ) )
               AND (img.fechapresenta = CASE WHEN (NVL (pFechaPresenta,'' )!= '' )  THEN pFechaPresenta  ELSE img.fechapresenta  END ) )

            IF dMonto is null THEN
                LET cCuentaDep = iCuenta;
            ELSE
                -- // Obtiene la cuenta de deposito.
                SELECT UNIQUE doc.cuenta, doc.monto, doc.sucursal
                  INTO cCuentaDep, dMontoRet, cSucursal
                  FROM bdicheq:"informix".sc_docret_sbc doc   --MOHA
                 WHERE doc.empresa = pEmpresa
                   AND doc.fecha_alta = dFechaAlta
                   AND doc.num_chq = iNumCheque
                   AND doc.monto_ori = dMonto 
                   AND doc.banco = cCveBanco
                   AND doc.numcuenta::INT8 = iCuenta
                   AND doc.cancelado <> 'S';
            END IF;

            -- // Consulta el producto y el cliente de la cuenta.
            SELECT producto, num_cte
              INTO cProducto, cCliente
              FROM bdicheq:"informix".sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCuentaDep;

            -- // Consulta el nombre del cliente.
            SELECT TRIM(nombre1)||' '|| TRIM( nombre2)||' '|| TRIM(apell_paterno)||' '|| TRIM(apell_materno)|| TRIM(razon_social)
              INTO cNombreCte
              FROM bdinteg:"informix".si_cliente  
             WHERE numcte = cCliente;

            LET cNombreCte = TRIM(cNombreCte);

            -- // Consulta el nombre del producto.
            SELECT TRIM(nombre)
              INTO cNomProducto
              FROM bdicheq:"informix".sc_producto 
             WHERE producto = cProducto;

			-- // Consulta revisado y ejecutivo quien reviso --LCJD
			SELECT revisado, ejecutivo_reviso 
              INTO cRevisado, cEjecutivoReviso
			  FROM 'informix'.cce_cheques_revisados 
			 WHERE numcheque = iNumCheque 
               AND numcuenta = iCuenta 
               AND numcte = cCliente 
               AND fechapresenta = dFechaPresenta;
        
			IF TRIM(NVL(cRevisado,'')) = '' THEN
                LET cRevisado = '0';
			END IF;
        
			IF TRIM(NVL(cEjecutivoReviso,'')) = '' THEN
                LET cEjecutivoReviso = '0';
			END IF;
			 
            RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
                   cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
                   NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'') WITH RESUME;
        END FOREACH;
	   
    END IF;
    
    -- // Se verifica si la consulta regreso informacion.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000002';
        LET cDescripcion = 'No se encuentran registros';
        RETURN cCodRet, cCveBanco, cDescripcion, iCuenta::CHAR(20), iNumCheque::CHAR(7), dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, NVL(cProducto,''), NVL(cCliente,''), NVL(cNombreCte,''),  NVL(cNomProducto,''), cCuentaDep,
               NVL(cRevisado,''), NVL(cEjecutivoReviso,''), dMontoRet, NVL(cSucursal,'');
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'FECHA CREACION: 15 de Julio del 2011',
'DESCRIPCION: Regresa los cheques que se encuentren en el archivo electronico.',
'MODIFICO: Guadalupe Payan',
'FECHA MODIFICACION: 15 de Agosto del 2011',
'DESCRIPCION: Se cambio la longitud de la variable iNumCheque a un char de 7 ya que asi esta en la tabla productiva',
'se cambio la longitud de la variable cDescripcion a char 40,se cambio la longitud de la variable cNombreCte a',
'char 104, se elimino la bandera iCont se sustituyo por el comando DBINFO',
'VERSION: 20110815.1117',
'BD: BDITEF';

CREATE PROCEDURE "informix".cons_img_nula1(pempresa       CHAR(3),
                                          pcvebanco   	 CHAR(3),
                                          pnumcuenta   	 CHAR(20),
                                          pnumcheque   	 CHAR(7),
                                          plado_ft       CHAR(1),
                                          pfechapresenta CHAR(10))
RETURNING CHAR(5);  

    DEFINE v_codret CHAR(5);
    DEFINE sql_err,isam_err INT;   
    --DEFINE v_existe CHAR(1);
	DEFINE iimagen  INT;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  IS NULL OR
       pcvebanco      IS NULL OR
       pnumcuenta     IS NULL OR
       pnumcheque     IS NULL OR
       plado_ft       IS NULL OR
       pfechapresenta IS NULL THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
	
	--SET DEBUG FILE TO "/tmp/Guicho/cons_img_nula1.out";
	--TRACE ON;
    
    BEGIN

		ON EXCEPTION SET sql_err,isam_err
			if sql_err <> 0 OR isam_err <> 0 THEN
				let v_codret = sql_err;
				RETURN v_codret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
		/*
		select length(imagen::lvarchar) 
		INTO iimagen
		from "informix".cce_cheques_img
		 where empresa = pempresa
		   and cvebanco = pcvebanco
		   and numcuenta = pnumcuenta
		   and numcheque = pnumcheque
		   and lado_ft = plado_ft
		   and fechapresenta = pfechapresenta;

        IF iimagen IS NULL OR iimagen = '' THEN
            LET v_codret = 130; 
            RETURN v_codret;                 
        END IF;
		*/

		SELECT COUNT(*)
		INTO iimagen
		FROM "informix".cce_cheques_img
		WHERE empresa = pempresa
		AND cvebanco = pcvebanco
		AND numcuenta = pnumcuenta
		AND numcheque = pnumcheque
		AND fechapresenta = pfechapresenta
		--AND imagen IS NULL OR length(imagen::lvarchar) =0;
		AND (imagen IS NULL OR length(imagen::lvarchar) =0);

		IF iimagen > 0 THEN
			LET v_codret = 130; 
			RETURN v_codret;  
        END IF;	
    
    END;    

    RETURN v_codret;

END PROCEDURE
DOCUMENT
'FECHA: 30/11/2017',
'AUTOR: Jesus Ivan Garcia Guicho.',
'FOLIO: 1856',
'SUSTENTO: INC 24 066 Cheque en blanco.pdf.',
'SOLICITA: Cutberto Gonzalez Perez.',
'DESCRIPCION: Se modifica nombre del SP para ponerlo en pruebas en piloto.',
'BD: bditef';

create procedure "informix".cons_dev_suc_web(pempresa char(3),
		       	psucursal  	char(4),
		       	pfechapre 	date,
		       	pnum_regs 	smallint)
			RETURNING 
			char(5),char(45),char(20),char(11),
			char(16),char(20),char(100),
			char(50);


   DEFINE v_codret          	char(5);
   DEFINE v_banco		char(45);
   DEFINE v_cuenta	    	char(20);
   DEFINE v_numcheque       	char(11);
   DEFINE v_monto	      	char(16);
   DEFINE v_ctadeposito       	char(20);
   DEFINE v_cliente     	char(20);
   DEFINE v_motdevol	   	char(50);
   DEFINE v_contador        	smallint;
   DEFINE v_nombrecte		char(100);
   DEFINE v_rfc  		char(1);
   DEFINE v_curp  		char(1);
   DEFINE sql_err,isam_err  int;   


  --SET debug file to "cons_suc.out";
  --trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "00000";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
	let v_codret = sql_err;
	RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
		v_monto,v_ctadeposito,
		v_cliente || ' ' || v_nombrecte,
		v_motdevol;
      end if;
   end exception;




-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  	pempresa is null or
	 	psucursal is null or
		pnum_regs is null then
	
		   -- datos de entrada incompletos	   
		LET v_codret = '00110'; 
		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			v_cliente || ' ' || v_nombrecte,
			v_motdevol;
	END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
        let v_banco		= " ";
        let v_cuenta   		= " ";
        let v_numcheque     	= " ";        
        let v_monto	    	= 0;
        let v_ctadeposito     	= " ";        
        let v_motdevol     	= " ";
        let v_contador      	= 0;



-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

		-- consulta principal
		
		SELECT 	c.cvebanco || ' ' || b.descripcion,c.numcuenta,
			c.numcheque,c.numcte,c.cta_deposito,c.monto,
			c.motivo || ' ' || dev.descripcion
		INTO	v_banco,v_cuenta,v_numcheque,v_cliente,
			v_ctadeposito,v_monto,v_motdevol
		FROM	cce_cheques_dev c, bdinteg:si_bancos b,
			bdinteg:si_coddevcam dev
		WHERE	c.empresa = pempresa
			and c.fechapresenta = pfechapre
			and c.sucursal = psucursal	
			and c.cvebanco = b.banco
			and c.motivo = dev.codigo

		-- obtener el nombre o razon social del cliente
		
		call consnomcte(pempresa,v_cliente)
              		returning v_codret,v_nombrecte,v_rfc,v_curp;		

		LET v_contador = v_contador +1;
        
        IF v_codret = '000' then
        LET v_codret = '00000';
        END IF;  

        IF v_codret = '800' then
        LET v_codret = '00001';
        END IF;     

		IF v_contador < pnum_regs then
			CONTINUE FOREACH;
		END IF;    


		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			trim(v_cliente) || ' ' || v_nombrecte,
			v_motdevol
			WITH resume;

	END FOREACH		

END;    
END PROCEDURE;