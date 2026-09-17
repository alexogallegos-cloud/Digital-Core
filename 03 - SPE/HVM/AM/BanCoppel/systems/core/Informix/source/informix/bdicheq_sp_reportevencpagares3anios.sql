CREATE PROCEDURE "informix".sp_reportevencpagares3anios( pSucursal CHAR(4), pRegistro INTEGER )
RETURNING CHAR(5)     AS RETORNO,			
          CHAR(60)    AS MENSAJE,		    
          CHAR(4)     AS SUCURSAL,	
          CHAR(8)     AS PROMOTOR,		          
          CHAR(9)     AS NUMEROCLIENTE,	
          CHAR(104)   AS NOMBRECLIENTE,
          CHAR(20)    AS CUENTA,
          CHAR(20)    AS CUENTAEJE,
          DATE        AS FECHAAPERTURA,		
          DATE        AS FECHAVENCIMIENTO, 
          CHAR(15)    AS TELEFONO1,
          CHAR(15)    AS TELEFONO2,
          CHAR(15)    AS TELEFONO3,
          CHAR(5)     AS EXTENSION,
          CHAR(50)    AS CORREOELECT;
    
    DEFINE vSqlError 			SMALLINT;
    DEFINE vIsamError 			SMALLINT;
    DEFINE vDescError 			CHAR(50);
    DEFINE cCodRet  			CHAR(5);
    DEFINE cCodRet2  			CHAR(5);
    DEFINE cCodRet3  			CHAR(50);
    DEFINE cMensaje 			CHAR (60);
    DEFINE dFechaHoy  			DATE;
    DEFINE cSucursal 			CHAR(4);
    DEFINE cPromotor 			CHAR(8);
    DEFINE cNumCte				CHAR(9);
    DEFINE cNombreCte           CHAR(104);
    DEFINE cCuenta 				CHAR(20);
    DEFINE cCuentaEje           CHAR(20);
    DEFINE dFecha_apertura 		DATE;
    DEFINE dFecha_vencimiento 	DATE;
    DEFINE cTelefono1           CHAR(15);
    DEFINE cTelefono2           CHAR(15);
    DEFINE cTelefono3           CHAR(15);
    DEFINE cExtension           CHAR(5);
    DEFINE cMail                CHAR(50);
    DEFINE vciclo				SMALLINT;
    
    LET vSqlError		   = 0;
    LET vIsamError		   = 0;
    LET vDescError		   = '';
    LET cCodRet			   = '00000';
    LET cCodRet2		   = '';
    LET cCodRet3		   = '';
    LET cMensaje 		   = 'EL PROCESO SE EJECUTO EXITOSAMENTE';
    LET dFechaHoy 		   = '01-01-1900';
    LET cSucursal		   = "";
    LET cPromotor		   = "";
    LET cNumCte			   = "";
    LET cNombreCte         = "";
    LET cCuenta			   = "";
    LET cCuentaEje         = "";
    LET dFecha_apertura	   = '01-01-1900';
    LET dFecha_vencimiento = '01-01-1900';
    LET cTelefono1         = "";
    LET cTelefono2         = "";
    LET cTelefono3         = "";
    LET cExtension         = "";
    LET cMail              = "";
    LET vciclo			   = 0;
    
    BEGIN
    
    ON EXCEPTION SET vSqlError, vIsamError, vDescError
        SET debug file to "/tmp/sp_reportevencpagares3anios.err";
        trace on;
        IF vSqlError <> 0 THEN
            LET cCodRet = vSqlError;
            LET cCodRet2 = vIsamError;
            LET cCodRet3 = vDescError;
            LET cMensaje = 'Ocurrio un Error Durante La Ejecucion Del Procedimiento';
            RETURN cCodRet, cMensaje, cSucursal, cPromotor, cNumCte, cNombreCte, cCuenta, cCuentaEje, dFecha_apertura, 
                   dFecha_vencimiento, cTelefono1, cTelefono2, cTelefono3, cExtension, cMail WITH RESUME;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/tmp/sp_reportevencpagares3anios.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF NOT EXISTS( SELECT sucursal FROM bdinteg:si_sucursales where sucursal= pSucursal ) THEN
        LET cCodRet = '00001';
        LET cMensaje = 'La Sucursal No Existe';
    ELSE
        -- // Obtener  fecha  de hoy
        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM bdicheq:sc_fechas;
        
        -- // Obtiene los datos de las sucursales, regresa sus valores y los ordena por sucursal
        FOREACH WITH HOLD
            SELECT sucursal, promotor, TRIM(numcte), TRIM(nombre_cte), TRIM(numcta), TRIM(cta_eje), NVL(fecha_apertura,' '), NVL(fecha_vencimiento,' '), 
                   TRIM(NVL(telefono1,' ')), TRIM(NVL(telefono2,' ')), TRIM(NVL(telefono3,' ')), TRIM(NVL(extension,' ')), TRIM(NVL(correo_elect,' '))
              INTO cSucursal, cPromotor, cNumCte, cNombreCte, cCuenta, cCuentaEje, dFecha_apertura, dFecha_vencimiento,
                   cTelefono1, cTelefono2, cTelefono3, cExtension, cMail
              FROM bdicheq:sc_pagares3anios
             WHERE sucursal = pSucursal 
               AND fecha_vencimiento >= dFechaHoy 
             ORDER BY fecha_vencimiento ASC, promotor ASC, numcta ASC
            
            LET vCiclo = vCiclo + 1;
            
            -- // Paginacion
            IF vciclo <= pRegistro THEN
                CONTINUE FOREACH;
            END IF; 
            
            RETURN cCodRet, cMensaje, cSucursal, cPromotor, cNumCte, cNombreCte, cCuenta, cCuentaEje, dFecha_apertura, 
                   dFecha_vencimiento, cTelefono1, cTelefono2, cTelefono3, cExtension, cMail WITH RESUME;
        END FOREACH;
    
        IF vciclo = 0 THEN
            LET cCodRet = '00002';
            LET cMensaje = 'No Se Encontraron Datos';
        END IF;
    END IF;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, cMensaje, cSucursal, cPromotor, cNumCte, cNombreCte, cCuenta, cCuentaEje, dFecha_apertura, 
               dFecha_vencimiento, cTelefono1, cTelefono2, cTelefono3, cExtension, cMail WITH RESUME;
    END IF;
    
    END;
    
END PROCEDURE;