CREATE PROCEDURE "informix".sp_valida_datos_contacto_bpi(pEmpresa CHAR(3),pIdUsuario CHAR(11))
RETURNING CHAR (5);
	-- Creador: Solser
	-- Objetivo: Validar datos de contacto de  usuario BPI
	-- Fecha: 03/01/2022
	
	DEFINE sql_err int;
	DEFINE vCodRet CHAR (5);
    DEFINE vNumCliente CHAR (9);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet ;
		  END IF ;
		END EXCEPTION ;
		
		LET vCodRet = '00000';
        LET vNumCliente = '';
       
		
		SET LOCK MODE TO WAIT 3;
        
        IF(LENGTH(TRIM(NVL(pEmpresa,''))) = 0  OR  LENGTH(TRIM(NVL(pIdUsuario,''))) = 0)THEN
            LET vCodRet="00003";
            RETURN vCodRet;
        END IF;

      

        SELECT numcliente INTO vNumCliente FROM bdibpi:bpi_usuario where id_usuario= pIdUsuario and st_portal = 'activo';     
        IF (vNumCliente <> '' OR vNumCliente IS NOT NULL) THEN
           
             	IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = vNumCliente 	AND status_tel ='A' AND tipo_tel=2) = 0 THEN 
                    LET vCodRet="00001";
                ELIF (SELECT count(correo_elec) FROM bdinteg:"informix".si_correos WHERE numcte = vNumCliente AND status_correo = 'A') = 0 THEN 
                    LET vCodRet="00002";
                END IF
        ELSE
             LET vCodRet="00004";
        END IF;
                 
     
         
		RETURN vCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Solser',
'FECHA.........: 03-01-2022',
'CREACION..: Validación deatos de contacto bpi',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDInteg';

CREATE PROCEDURE "informix".sp_valida_cel_repetido_bpi(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_valida_cel_repetido.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='V'	
	AND (DATE(CURRENT) - DATE(SUBSTR(fecha_hora,0,10)) < 90);
		
	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;