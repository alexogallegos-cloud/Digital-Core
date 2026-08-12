CREATE PROCEDURE "informix".sp_consulta_usuario_movil_cc(pCentroCostos CHAR(8))
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
                
                --SET DEBUG FILE TO '/informix/LIP/sp_consulta_usuario_movil_cc.out';
                --TRACE ON;
        
                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                FOREACH
						SELECT {+INDEX (bdinteg:"informix".si_usuario_movil idx_usa_movil)}
						ejecutivo, activo, nombre, centro_costos, no_telefono, sucursal, imei
                        INTO cNoEmpleado, cStatus, cNombre, cCentro_costos, cNo_telefono, cSucursal, cImei
                        FROM bdinteg:"informix".si_usuario_movil 
                        WHERE centro_costos = pCentroCostos
                
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