CREATE PROCEDURE "informix".sp_registra_correos_pros( pEmpresa    CHAR(3),
                                                      pNumCte     CHAR(20), 
                                                      pCorreoElec CHAR(100),
                                                      pTipoCorreo SMALLINT,
                                                      pCanal      SMALLINT,
                                                      pUserInsert CHAR(8) )
RETURNING CHAR(5) AS vcodret1;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vTpoPersona      CHAR(2);
    DEFINE vfecha_insert    DATE;
    DEFINE vSecuenciaMax    SMALLINT;
    DEFINE vExisteCorreo    SMALLINT;
    DEFINE vMaxSec          SMALLINT;
    
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vTpoPersona   = '';
    LET vfecha_insert = '';
    LET vSecuenciaMax = 0;
    LET vExisteCorreo = 0;
    LET vMaxSec       = 0;
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos_pros.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-239)
        LET vcodret1 = '999';
        RETURN vcodret1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos_pros.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pCorreoElec is null OR pCorreoElec = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET vcodret1 = '110';
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT tpo_persona, COUNT(*)
      INTO vTpoPersona, vExisteCte
      FROM pr_cliente
     WHERE numcte_pros = pNumCte
      GROUP BY 1;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '104';
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL CORREO PARA EL TIPO INDICADO
    SELECT MAX(secuencia)
      INTO vSecuenciaMax
      FROM pr_correos
     WHERE numcte_pros = pNumCte
       AND tipo_correo = pTipoCorreo;
       
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM pr_correos
     WHERE numcte_pros = pNumCte
       AND tipo_correo = pTipoCorreo
       AND correo_elec = pCorreoElec
       AND secuencia = vSecuenciaMax;
       
    IF vExisteCorreo > 0 THEN
        LET vcodret1 = '999';
        RETURN vcodret1;
    END IF;
    
    -- // ONTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO vMaxSec
      FROM pr_correos
     WHERE numcte_pros = pNumCte;
             
    IF vMaxSec is null OR vMaxSec = '' THEN
        LET vMaxSec = 0;
    END IF;
    
    LET vMaxSec = vMaxSec + 1;
    
    UPDATE pr_correos
       SET status_correo = 'C'
     WHERE numcte_pros = pNumCte
       AND tipo_correo = pTipoCorreo;
    
    INSERT INTO pr_correos
    (empresa, numcte_pros, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert)
    VALUES
    (pEmpresa, pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert);
    
    END;

    RETURN vcodret1;

END PROCEDURE;