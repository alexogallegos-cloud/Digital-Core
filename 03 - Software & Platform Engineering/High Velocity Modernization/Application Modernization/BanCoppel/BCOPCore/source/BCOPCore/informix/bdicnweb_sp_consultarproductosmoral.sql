CREATE PROCEDURE "informix".sp_consultarproductosmoral(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(4) AS producto,
		CHAR(40) AS nombre;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cProducto CHAR(4);  
	DEFINE cProductoNombre CHAR(40);     	
	DEFINE iRecuperacion INTEGER;
    
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cProducto = '';
	LET cProductoNombre = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cProducto, cProductoNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarproductosmoral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cProducto,cProductoNombre;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cProducto,cProductoNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH 
			 SELECT DISTINCT(a.producto), b.nombre
			 INTO cProducto,cProductoNombre
             FROM bdicheq:"informix".sc_maechq a INNER JOIN bdicheq:"informix".sc_prodctemoral b ON (a.producto = b.producto)
             WHERE a.num_cte = pNumcte
             AND a.status_cta <> '2'
			
			 LET iRecuperacion = iRecuperacion + 1;
			 RETURN cCodRet,cProducto,cProductoNombre  WITH RESUME;           
		END FOREACH;
				
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00024';
			RETURN cCodRet,cProducto,cProductoNombre;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 20/11/2018',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Mantenimiento Firmas PM ',
'DESCRIPCION: SP que consulta los productos ligados a un Cliente PM.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_busqueda_usuario_movil_ws(pNoEmpleado CHAR(8), pNombre CHAR(60), pStatus CHAR(1), 
													pNo_telefono CHAR(10), pNumRegistro INTEGER,pRecuperacion INTEGER)
                RETURNING CHAR(5)  AS codret,
                                  CHAR(8)  AS cNoEmpleado,
                                  CHAR(60) AS cNombre,
                                  CHAR(8)  AS cCentro_costos,
                                  CHAR(4)  AS cSucursal,
                                  CHAR(10) AS cNo_telefono,
                                  CHAR(1)  AS cStatus,
                                  CHAR(40) AS cNombreSuc,
                                  CHAR(20) AS cImei;
                                                                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE cNoEmpleado        CHAR(8);
        DEFINE cStatus        CHAR(1); 
        DEFINE cNombre        CHAR(60);
        DEFINE cCentro_costos CHAR(8);
        DEFINE cSucursal          CHAR(4);
        DEFINE cNo_telefono   CHAR(10);
        DEFINE cNombreSuc         CHAR(40);
        DEFINE iCont          INTEGER;
        DEFINE cImei          CHAR(20);        
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET cNoEmpleado = 0;
        LET cStatus = '';
        LET cNombre  = '';
        LET cCentro_costos = '';
        LET     cSucursal  = '';
        LET cNo_telefono = '';
        LET cNombreSuc = '';
        LET iCont=0;
		LET cImei = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cNoEmpleado, cNombre, cCentro_costos, cSucursal, cNo_telefono, cStatus, cNombreSuc, cImei;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/informix/LIP/sp_busqueda_usuario_movil_ws.out';
                --TRACE ON;
				
				IF (pNoEmpleado = '' AND pNombre = '' AND  pStatus = '' AND pNo_telefono = '') THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,cNoEmpleado, cNombre, cCentro_costos, cSucursal, cNo_telefono, cStatus, cNombreSuc, cImei;
                END IF;
				
                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                FOREACH
                        SELECT {+INDEX (bdinteg:"informix".si_usuario_movil idx_usa_movil)}
						SKIP pNumRegistro FIRST pRecuperacion ejecutivo, activo, nombre, centro_costos, no_telefono, sucursal, imei
                        INTO cNoEmpleado, cStatus, cNombre, cCentro_costos, cNo_telefono, cSucursal, cImei
                        FROM bdinteg:"informix".si_usuario_movil
						WHERE (pNoEmpleado = '' OR  ejecutivo = pNoEmpleado)
						AND (pNombre = '' OR nombre = pNombre)
						AND (pStatus = '' OR activo = pStatus)
						AND (pNo_telefono = '' OR no_telefono = pNo_telefono)
                
                        SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;
                        
                        LET iCont=iCont+1;
                        RETURN cCodRet,cNoEmpleado, cNombre, cCentro_costos, cSucursal, cNo_telefono, cStatus, cNombreSuc, cImei WITH RESUME;
                END FOREACH;
                
				IF iCont = 0 THEN
						LET cCodRet = '00017';
						RETURN cCodRet,cNoEmpleado, cNombre, cCentro_costos, cSucursal, cNo_telefono, cStatus, cNombreSuc, cImei;
				END IF; 
                
        END;
        
END PROCEDURE;