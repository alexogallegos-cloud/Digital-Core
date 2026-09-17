CREATE PROCEDURE "informix".sp_consulta_usuario_movil_ws(pEjecutivo CHAR(8), pImei CHAR(20))
            RETURNING CHAR(5) AS codret,
                              CHAR(20) AS cPassword,         
                              CHAR(20) AS cImei,         
                              CHAR(1) AS cActivo,       
                              CHAR(60) AS cNombre,       
                              CHAR(8) AS cCentro_costos,
                              CHAR(10) AS cNo_telefono,  
                              CHAR(20) AS cGenerico1,    
                              CHAR(30) AS cGenerico2,    
                              CHAR(40) AS cGenerico3,    
                              CHAR(4)  AS cSucursal,         
                              CHAR(40) AS cNombreSuc;        

            
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iCodRetSp INTEGER;
    DEFINE iNoRegistros INTEGER;
    DEFINE cPassword          CHAR(20);
    DEFINE cImei          CHAR(20);
    DEFINE cActivo        CHAR(1); 
    DEFINE cNombre        CHAR(60);
    DEFINE cCentro_costos CHAR(8); 
    DEFINE cNo_telefono   CHAR(10);
    DEFINE cGenerico1     CHAR(20);
    DEFINE cGenerico2     CHAR(30);
    DEFINE cGenerico3     CHAR(40);
    DEFINE cSucursal          CHAR(4);
    DEFINE cNombreSuc         CHAR(30);
    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET iCodRetSp = 0;
    LET iNoRegistros = 0;
    LET cPassword = '';
    LET cImei  = '';
    LET cActivo = '';
    LET cNombre  = '';
    LET cCentro_costos = '';
    LET cNo_telefono = '';
    LET cGenerico1 = '';
    LET cGenerico2 = '';
    LET cGenerico3 = '';
    LET cSucursal  = '';
    LET cNombreSuc = '';
    
    
    BEGIN
        ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
        END EXCEPTION;
        
        --SET DEBUG FILE TO '/informix/LIP/sp_consulta_usuario_movil_ws.out';
        --TRACE ON;

		IF pEjecutivo = '' THEN
                LET cCodRet = '00003';
                RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
        END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        IF(pImei = '') THEN                                                                          
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo;
							
			IF iNoRegistros > 1 THEN
				LET cCodRet = '00478';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
			ELIF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
			ELIF iNoRegistros = 1 THEN
				SELECT password, imei, activo, nombre, centro_costos, no_telefono, generico1, generico2, generico3, sucursal
				INTO cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal 
				FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo;
				
				SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal; 
				
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
			END IF;
		ELSE
			SELECT password, imei, activo, nombre, centro_costos, no_telefono, generico1, generico2, generico3, sucursal
			INTO cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal 
			FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo AND imei = pImei;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
			END IF;	
			
			
			SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal; 
			
			RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc; 
		END IF;
	
	END;
    
END PROCEDURE;