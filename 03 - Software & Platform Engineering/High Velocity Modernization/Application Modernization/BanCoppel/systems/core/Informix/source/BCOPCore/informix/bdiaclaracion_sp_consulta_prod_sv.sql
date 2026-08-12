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