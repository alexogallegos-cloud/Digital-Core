CREATE PROCEDURE "informix".sp_graba_correos_web( pNumCte     CHAR(20),  -- NO. CLIENTE
                                              pCorreoElec CHAR(100), -- CORREO ELECTRONICO
                                              pTipoCorreo SMALLINT,  -- TIPO CORREO
                                              pCanal      SMALLINT,  -- CANAL
                                              pUserInsert CHAR(8),   -- USUARIO
                                              pSucursal   CHAR(4) )  -- SUCURSAL
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
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
	DEFINE contCorr         INTEGER;
	DEFINE cCodRetSp1       CHAR(5);
	DEFINE correoCli        CHAR(100);
    
    LET vcodret1 = '00000';
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
	LET contCorr      = 0;
	LET cCodRetSp1    = '00000';
	LET correoCli     ='';
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_graba_correos_web.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR
       (pCorreoElec is null OR pCorreoElec = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET vcodret1 = '00110';
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT tpo_persona, COUNT(*)
      INTO vTpoPersona, vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte
      GROUP BY 1;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104';
        RETURN vcodret1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL CORREO PARA EL TIPO INDICADO
    SELECT MAX(secuencia)
      INTO vSecuenciaMax
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo;
       
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo
       AND correo_elec = pCorreoElec
       AND secuencia = vSecuenciaMax;
       
    IF vExisteCorreo > 0 THEN
        LET vcodret1 = '00999';
        RETURN vcodret1;
    END IF;
    
    -- // ONTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = '001';
	 
	SELECT correo_elec --Obtiene el correo antiguo que tenia el cliente
		INTO correoCli 
		FROM bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A'; 
	 
	SELECT COUNT(*) INTO contCorr FROM
		bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A'; 
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO vMaxSec
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte;
             
    IF vMaxSec is null OR vMaxSec = '' THEN
        LET vMaxSec = 0;
    END IF;
    
    LET vMaxSec = vMaxSec + 1;
	
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(correoCli),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION AL CORREO ANTERIOR
	END IF;
    
    UPDATE bdinteg:"informix".si_correos
       SET status_correo = 'C'
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo;
    
    INSERT INTO bdinteg:"informix".si_correos
    (empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert)
    VALUES
    ('001', pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert);
    
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_bitacora_tel
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        INSERT INTO bdinteg:"informix".si_bitacora_tel
        ( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
        VALUES
        ( pNumCte, '0', '0', pCanal, pSucursal, pUserInsert, CURRENT );
    ELSE 
        UPDATE bdinteg:"informix".si_bitacora_tel
           SET ind_telefono = '0',
               ind_correo   = '0',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
	
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(pCorreoElec),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION DE NUEVO DE CORREO
	END IF;
    
    END; 

    RETURN vcodret1;

END PROCEDURE;