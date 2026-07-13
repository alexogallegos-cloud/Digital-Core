CREATE PROCEDURE "informix".sp_trx_mayor_a_tres(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5))
    
    RETURNING CHAR (2) as Hora, CHAR(3) as Diferencia, CHAR(5) as Cantidad;
	
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE vHora CHAR(2);    
    DEFINE vDiferencia CHAR(3);
    DEFINE vCantidad CHAR(5);	   
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/resplogifx/mon_trans_categoria/';    
    LET vHora = '';
    LET vCantidad = '';
    LET vDiferencia = '';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_trx_mayor_a_tres.out";
    --TRACE ON;        
	
	BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        FOREACH
        
            
                SELECT EXTEND(fechahoraoutauth, HOUR TO HOUR) as HORA,
                CASE 
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:00.00000' THEN '00'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:01.00000' THEN '01'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:02.00000' THEN '02'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:03.00000' THEN '03'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:04.00000' THEN '04'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:05.00000' THEN '05'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:06.00000' THEN '06'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:07.00000' THEN '07'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:08.00000' THEN '08'
                    WHEN a.fechahoraoutauth-a.fechahorainauth = '0 00:00:09.00000' THEN '09'
                    WHEN a.fechahoraoutauth-a.fechahorainauth >= '0 00:00:10.00000' THEN '10'
                END diferencia,  COUNT(*) as CANTIDAD
                    INTO vHora, vDiferencia, vCantidad
                 FROM intercard:movimiento a, 
                      intercard:tarjetacuenta b,
                      intercard:tarjeta c, 
                      intercard:productotarjeta d
                WHERE a.fechahorainauth BETWEEN pFechaInicio and pFechaFin                
                  AND a.prodind = "02"
                  AND a.codtran = "00"
                  AND a.formato = "0200"
                  AND a.codigoiso = "00"
                  AND a.movconciliado = "F"
                  AND b.numtarjeta = a.numtarjeta
                  AND c.numtarjeta = a.numtarjeta
                  AND d.codproductotarjeta = c.codproductotarjeta
                  AND a.fechahoraoutauth-a.fechahorainauth >= '0 00:00:03.00000' 
            GROUP BY 1,2
            ORDER BY 1,2          
     
		RETURN vHora, vDiferencia, vCantidad WITH RESUME;
        END FOREACH
		
		
	END
END PROCEDURE;