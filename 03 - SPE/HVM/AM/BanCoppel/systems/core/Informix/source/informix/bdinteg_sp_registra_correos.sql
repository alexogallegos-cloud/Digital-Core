CREATE PROCEDURE "informix".sp_registra_correos( pEmpresa    CHAR(3),
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
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE cCodRetSp1       CHAR(5);
	DEFINE cCodRetSp2       CHAR(5);
	
	DEFINE correoCli        CHAR(100);
	DEFINE celularCli       CHAR(13);
	DEFINE contCorr         INTEGER;
	--se agrega variable para validar correo en lista NEGRAS
	DEFINE cser_correo CHAR(100);  
    
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
    LET vCorreoNoValido  = 0;
	LET cCodRetSp1        = '00000';
	LET cCodRetSp2        = '00000';
	LET correoCli         ='';
	LET celularCli        ='';
	LET contCorr          =0;
	LET cser_correo =  '%'||SUBSTRING_INDEX(SUBSTRING_INDEX(pCorreoElec,'@',-1),'.',1)||'%';
 
 
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos.err";
        --TRACE ON;
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
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_registra_correos.out";
    --TRACE ON;
    
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
    
	-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
 --se cambia la consulta para evitar busqueda secuencial--
SELECT COUNT(id)
      INTO vCorreoNoValido
      FROM bdinteg:"informix".si_cat_correos_novalidos
     WHERE correo = pCorreoElec;
     

	IF vCorreoNoValido > 0 THEN
        LET vcodret1 = '120';
        RETURN vcodret1;
    END IF;
	
	-- // VALIDA QUE EL CORREO NO SE ENCUENTRE EN LISTAS NEGRAS
	--se cambia el select por un like para hacer la validacion y evitar una busqueda secuencial
 IF EXISTS(SELECT correo FROM bdinteg:si_cat_correos_listnegras WHERE correo like cser_correo) THEN
		LET vcodret1 = '121';
        RETURN vcodret1;
	END IF;
 

    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT tpo_persona, COUNT(*)
      INTO vTpoPersona, vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte
      GROUP BY 1;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '104';
        RETURN vcodret1;
    END IF;
    
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM bdinteg:"informix".si_correos
     WHERE correo_elec = pCorreoElec
       AND status_correo = 'A';
       
    IF vExisteCorreo > 0 THEN
        LET vcodret1 = '999';
        RETURN vcodret1;
    END IF;
    
    -- // ONTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;
	 
	 SELECT correo_elec --Obtiene el correo antiguo que tenia el cliente
		INTO correoCli 
		FROM bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';		
		SELECT COUNT(*) INTO contCorr FROM
		bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';

    -- // INSERTA EN TABLA DE CORREOS
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
    (pEmpresa, pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert);
	
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(pCorreoElec),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION DE NUEVO DE CORREO
	END IF;
   
   END;

    RETURN vcodret1;
END PROCEDURE;