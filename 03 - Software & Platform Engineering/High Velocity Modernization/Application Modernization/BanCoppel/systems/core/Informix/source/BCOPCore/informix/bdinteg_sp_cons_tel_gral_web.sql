CREATE PROCEDURE "informix".sp_cons_tel_gral_web(pEmpresa  CHAR(3),pNumCte   CHAR(20))
RETURNING CHAR(5)   AS vcod_ret,
          CHAR(15)  AS vtelefono,
          CHAR(2)   AS vtipotel,
          CHAR(2)   AS vstatustel,
          CHAR(2)   AS vsecuencia;

    DEFINE vcod_ret  CHAR(5);
    DEFINE vtelefono  CHAR(15);
    DEFINE vtipotel   CHAR(2);
    DEFINE vstatustel CHAR(2);
    DEFINE vsecuencia CHAR(2);
    
    LET vcod_ret = '00000';
    LET vtelefono = '';
    LET vtipotel = '';
    LET vstatustel = '';
    LET vsecuencia	 = '';
    
    foreach
        select telefono, tipo_tel, status_tel, secuencia 
        INTO vtelefono, vtipotel, vstatustel, vsecuencia
        from bdinteg:si_telefonos where empresa= pEmpresa and numcte= pNumCte
        order by tipo_tel, secuencia desc
       

        return vcod_ret, vtelefono, vtipotel, vstatustel, vsecuencia with resume;
    end foreach;
END PROCEDURE;