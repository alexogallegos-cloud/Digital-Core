CREATE PROCEDURE "informix".sp_busca_producto_cred_cuenta(p_sNumeroCuenta CHAR(20), p_skip INT, p_sNumeroEmpresa CHAR(3))
	RETURNING CHAR(6) AS numeroProducto, CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;
	
	-- Definicion de variables 
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto         CHAR(60);
	DEFINE resultado_numeroCuenta           CHAR(30);
	DEFINE resultado_numeroTarjeta          CHAR(30);
	DEFINE iSqlErr                          INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
    -- Inicializacion de variables
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';
	
    --SET DEBUG FILE TO "/home/e10000263/sp_busca_producto_cred_cuenta.out";
	--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
            END IF;
        END EXCEPTION;
		
        FOREACH
			SELECT SKIP p_skip bdicred:sd_definicion.num_producto,nombre_prod, num_credito, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicred:sd_maecred 
				LEFT JOIN bdicred:sd_definicion 
					ON (bdicred:sd_definicion.empresa = p_sNumeroEmpresa 
					AND bdicred:sd_definicion.num_producto = bdicred:sd_maecred.num_producto) 
				LEFT JOIN intercard:tarjetacuenta ON (bdicred:sd_maecred.num_credito = intercard:tarjetacuenta.numcuenta)
				LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				WHERE num_credito = p_sNumeroCuenta
				AND bdicred:sd_maecred.status_cred IN ('AA' ,'BA', 'BT','E1','E2','E3') 		--IFRS 
				ORDER BY num_credito asC
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta WITH RESUME;
        END FOREACH;
		
        -- Agregado TDC COPPEL MASTER CARD		
		FOREACH
			SELECT SKIP p_skip intercard:binproducto.codprodcta as numeroProducto, intercard:binproducto.desccodprodcta AS nombreProducto, intercard:tarjetacuenta.numcuenta AS cuentaProducto, intercard:tarjetacuenta.numtarjeta, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
            FROM intercard:tarjeta      
				LEFT JOIN intercard:tarjetacuenta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
				LEFT JOIN intercard:binproducto ON (intercard:binproducto.codproductotarjeta = intercard:tarjeta.codproductotarjeta)
			WHERE intercard:tarjeta.codstatustarjeta IN ('ACT','BLO','BLT','CAN','DAN','EXT','FAL','INA','ROB')
			AND intercard:tarjetacuenta.numcuenta = p_sNumeroCuenta
			AND intercard:tarjeta.codproductotarjeta = '007'
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;    
		END FOREACH;
		
		-- Agregado TDC Smart Vista		
		FOREACH
		
			select num_producto, num_cuenta_clabe,num_tdc
				into resultado_numeroProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			from bdinteg:si_credito_sv
			where num_cuenta_clabe = p_sNumeroCuenta
			
			
			SELECT descripcion
			INTO  resultado_nombreProducto
			FROM "informix".acl_tipo_producto 
			WHERE producto = resultado_numeroProducto and activo = '1';
		
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, '';    
		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'MODIFICA: Jorge Alberto Lara Mendoza',
'Se agrega la busqueda de productos correspondientes a Credito Coppel Masterd Card.',
'FECHA: 01/Septiembre/2022',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_prod_sv(pProducto CHAR(6))
         RETURNING 	CHAR(5) AS codRet,  
					CHAR(6) AS tipoProducto;
					--CHAR(60) AS nombreProducto, 
					--CHAR(30) AS numeroCuenta, 
					--CHAR(30) AS numeroTarjeta,
					--INTEGER AS tipoProducto;
						
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    
	DEFINE cNumeroProducto CHAR(6);
    DEFINE cNombreProducto CHAR(60);
    DEFINE cNumeroCuenta CHAR(30);      
    DEFINE cNumeroTarjeta CHAR(30);   
	DEFINE cStatusTarjeta CHAR(3);	

	DEFINE cNumeroCuentaInversion CHAR(30);	
	DEFINE cTelefonoTransfer CHAR(30); 
	DEFINE cClienteTransfer CHAR(30);	
	DEFINE iRecuperacion INTEGER;
    DEFINE cEmpresa CHAR(3);  
	DEFINE iTipoProducto INTEGER;
    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    
	LET cNumeroProducto = '';
    LET cNombreProducto = '';
	LET cNumeroCuenta='';
	LET cNumeroTarjeta='';
	
	LET cNumeroCuentaInversion='';
	LET cTelefonoTransfer='';
	LET cClienteTransfer='';
	LET iRecuperacion = 0;
	LET cEmpresa='001';
	LET iTipoProducto = 0;
	LET cStatusTarjeta = '';
   	
	 BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTipoProducto;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/home/e10000263/sp_busca_producto.out';
		--TRACE ON;
		
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
		
			SELECT descripcion,  pky_tipo_producto
			INTO  cNombreProducto,iTipoProducto 
			FROM "informix".acl_tipo_producto 
			--INNER JOIN "informix".acl_tipo_producto b ON a.numero_producto = pProducto 
			WHERE producto = pProducto and activo = '1';
			
			--LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, iTipoProducto;		
		
    END;
	
END PROCEDURE;