CREATE PROCEDURE "informix".sp_homologa_email(pempresa CHAR(3))

    RETURNING CHAR(5), CHAR (80), INTEGER;

--Definicion de Variables
    DEFINE vcodret          CHAR (5);
    DEFINE sql_err          INTEGER;
    DEFINE vMensaje         CHAR (80);

    DEFINE vNumcliente      CHAR (20);
    DEFINE vE_mail          CHAR (80);
    DEFINE vNumcte          CHAR (20);
    DEFINE vEmail           CHAR (80);

    DEFINE vContador        INTEGER;

-- Inicializa variables
    LET vcodret         = '00000';
    LET sql_err         = 0;

    LET vNumcliente     = '';
    LET vE_mail         = '';
    LET vNumcte         = '';
    LET vEmail          = '';
    LET vContador       = 0;



BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET vcodret = sql_err;
            LET vcodret = '00045';
            LET vMensaje = 'ERROR EN LA EJECUCION';
 
            RETURN vcodret, vMensaje, vContador;        -- Termina proceso del SP
        END IF;
    END EXCEPTION;

    --SET DEBUG file TO "/ids10_uc9/raul/capitulox/pba/homologa_email.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH

    SELECT numcliente,e_mail
      INTO vNumcliente,vE_mail
      FROM bdibpi:bpi_usuario
     WHERE id_usuario IS NOT NULL
       AND st_portal = 'activo'
       AND (e_mail <> '' OR e_mail IS NOT NULL)
    
      IF vNumcliente is null THEN  
        CONTINUE FOREACH;
      END IF;

    SELECT numcte,email
      INTO vNumcte,vEmail
      FROM bdinteg:si_ctepf
     WHERE numcte = vNumcliente;

      
      --IF NVL(vEmail,'') THEN
      --  UPDATE bdinteg:si_ctepf SET email = vE_mail WHERE numcte = vNumcliente;
      --END IF;
      IF vNumcliente = vNumcte AND vE_mail <> '' THEN
         UPDATE bdinteg:si_ctepf SET email = vE_mail WHERE numcte = vNumcliente;
         LET vContador = vContador + 1;
      END IF;
     
     END FOREACH;
END     
    LET vMensaje        = 'Actualización Exitosa';
    RETURN vcodret, vMensaje, vContador;

END PROCEDURE;