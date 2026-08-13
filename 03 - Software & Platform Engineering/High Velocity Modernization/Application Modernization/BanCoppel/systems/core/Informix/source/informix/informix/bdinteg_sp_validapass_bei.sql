CREATE PROCEDURE "informix".sp_validapass_bei(pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING CHAR(5),CHAR(50),CHAR(50), CHAR(50),CHAR(50), CHAR(50), CHAR(26), CHAR(13), CHAR(13), DATE, DATE ;
    
    DEFINE cCod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE cUsuario, cPass, cPass1, cPass2, cPass3 CHAR(50);
    DEFINE cNombre CHAR(26);
    DEFINE cTelefono1, cTelefono2 CHAR(13);
    DEFINE dFecha_constitucion, dFecha_actual DATE;
    
    LET cCod_ret       = "000";
    LET cUsuario = "";
    LET cPass = "";
    LET cPass1 = "";
    LET cPass2 = "";
    LET cPass3 = "";
    LET cNombre = "";
    LET cTelefono1 = "";
    LET cTelefono2 = "";
    LET  dFecha_constitucion = '01-01-1900';
    LET  dFecha_actual = CURRENT ;
    
    --Realizó: Manuel Ramos Figueroa
    --Fecha: 05/08/2011
    --Actividad: Obtiene informacion del cliente de BEI
    
    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, cUsuario, cPass, cPass1, cPass2, cPass3, cNombre, cTelefono1, cTelefono2,  dFecha_constitucion, dFecha_actual;
        END IF
    END EXCEPTION;
    
    SET LOCK MODE TO WAIT ;
    SET ISOLATION DIRTY READ ;
    
    IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND num_cliente = pNumCte ) THEN
        SELECT LIMIT 1 usuario, pass, pass1, pass2, pass3 
          INTO cUsuario, cPass, cPass1, cPass2, cPass3 
          FROM bdinteg:"informix".si_bpiusuariospm 
         WHERE empresa = pEmpresa 
           AND num_cliente = pNumCte;
        
        SELECT LIMIT 1 nombre_corto, fecha_constitct 
          INTO cNombre, dFecha_constitucion 
          FROM bdinteg:"informix".si_ctepm
         WHERE empresa = pEmpresa
           AND numcte =  pNumCte;
        /*
        SELECT LIMIT 1 telefono1, telefono2 
          INTO cTelefono1, cTelefono2 
          FROM bdinteg:"informix".si_direcciones_actual 
         WHERE numcte = pNumCte;
        */
        
        SELECT telefono
          INTO cTelefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT telefono
          INTO cTelefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
    ELSE
        LET cCod_ret = '001';
    END IF;
    
    RETURN cCod_ret, NVL(cUsuario,''),NVL(cPass,''), NVL(cPass1,''), NVL(cPass2,''), NVL(cPass3,''), 
           cNombre, NVL(cTelefono1,''), NVL(cTelefono2,''),  dFecha_constitucion, dFecha_actual;
    
    END
    
END PROCEDURE;