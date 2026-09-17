CREATE PROCEDURE "informix".sp_validapass_bpi(pEmpresa char(3), pNumCte char(20))
returning char(5),char(50),char(50), char(50),char(50), char(50), char(26),char(26),char(26),char(26), char(13), char(13), char(13), date, date;
    
    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_usuario, v_pass, v_pass1, v_pass2, v_pass3 char(50);
    define v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno char(26);
    define v_rfc, v_telefono1, v_telefono2 char(13);
    define v_fecha_nac, v_fecha_actual DATE;
    
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret = "000";
    let v_usuario = "";
    let v_pass = "";
    let v_pass1 = "";
    let v_pass2 = "";
    let v_pass3 = "";
    let v_nombre1 = "";
    let v_nombre2 = "";
    let v_apell_paterno = "";
    let v_apell_materno = "";
    let v_rfc = "";
    let v_telefono1 = "";
    let v_telefono2 = "";
    let  v_fecha_nac = '01-01-1900';
    let  v_fecha_actual = CURRENT ;
    
    BEGIN
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_usuario, v_pass, v_pass1, v_pass2, v_pass3, v_nombre1, v_nombre2, 
                   v_apell_paterno, v_apell_materno, v_rfc, v_telefono1, v_telefono2,  v_fecha_nac, v_fecha_actual;
        end if
    end exception;
    
    IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN
        SELECT LIMIT 1 usuario, pass, pass1, pass2, pass3 
          INTO v_usuario, v_pass, v_pass1, v_pass2, v_pass3 
          FROM bdinteg:si_bpiusuarios 
         WHERE empresa = pEmpresa 
           AND numcte = pNumCte;
        
        SELECT LIMIT 1 nombre1, nombre2, apell_paterno, apell_materno,  rfc
          INTO  v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_rfc
          FROM bdinteg:si_cliente
         WHERE empresa = pEmpresa
           AND numcte =  pNumCte;
        
        /*
        SELECT LIMIT 1 telefono1, telefono2 
          INTO v_telefono1, v_telefono2 
          FROM bdinteg:si_direcciones 
         WHERE numcte = pNumCte;
        */
        
        SELECT telefono
          INTO v_telefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT telefono
          INTO v_telefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
        
        SELECT LIMIT 1 fecha_nac 
          INTO v_fecha_nac 
          FROM bdinteg:si_ctepf 
         WHERE numcte = pNumCte;
    ELSE
        LET cod_ret = '001';
    END IF;
    
    return cod_ret, nvl(v_usuario,''),nvl(v_pass,''), nvl(v_pass1,''), nvl(v_pass2,''), nvl(v_pass3,''), 
           v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, nvl(v_rfc,''), nvl(v_telefono1,''), nvl(v_telefono2,''),  v_fecha_nac, v_fecha_actual;
    
    END
    
END PROCEDURE;