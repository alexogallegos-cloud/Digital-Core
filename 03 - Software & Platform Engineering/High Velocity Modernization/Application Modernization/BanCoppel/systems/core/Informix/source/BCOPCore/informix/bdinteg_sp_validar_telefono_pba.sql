create procedure "informix".sp_validar_telefono_pba(pTelefono char(20) )
 returning char(5);
 
 define v_codret char(5);
 --define v_cadena char(10);
 define i smallint;
 define v_long_word smallint;
 define v_caracter char(1);
 --define v_result char(1);
 
 let v_codret = '00000';
 --let v_cadena = '';
 let i = 0;
 let v_long_word = 0;
 let v_caracter = '';
 --let v_result = 'S';
 
 let v_long_word = length(pTelefono);
 
  BEGIN

    FOR i IN (0 TO v_long_word)
          let v_caracter = substr(pTelefono, i, 1);     
          IF ( v_caracter <> '0' and v_caracter <> '1' and v_caracter <> '2' and v_caracter <> '3' and v_caracter <> '4' and v_caracter <> '5' and
               v_caracter <> '6' and v_caracter <> '7' and v_caracter <> '8' and v_caracter <> '9')   THEN

               --let v_result = 'N';
               let v_codret = "00700";
               RETURN v_codret;
          END IF;
    END FOR;
   
    --let v_codret = "Telefono correcto!";
    RETURN v_codret;
    
  END;
end procedure;