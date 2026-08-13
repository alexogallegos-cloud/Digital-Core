CREATE PROCEDURE "informix".sp_autoriza_datoscte_coppel_bpi(
    pEmpresa CHAR(3),
    pOpcion CHAR(2),
    pIdCliente CHAR(20),
    pEjecutivo CHAR(8),
    pSucursal CHAR(4),
    pCanal SMALLINT,
    pFecha_insert DATETIME YEAR TO SECOND,
    pBandera_autoriza SMALLINT,
    pFecha_mod_bandera DATETIME YEAR TO SECOND,
    pTipo_responsivo INTEGER )

    RETURNING  CHAR (5);
    DEFINE codret CHAR (5);
    DEFINE iSqlErr INTEGER;
    DEFINE contIntento SMALLINT;
    DEFINE decision SMALLINT;
    DEFINE fh_confirma DATETIME YEAR TO SECOND;
 
    LET codret = '00000';
    LET iSqlErr = 0;
    LET contIntento = 0;
    LET decision = 0;
    LET fh_confirma = '';

    BEGIN 
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET codret = iSqlErr;
                RETURN codret;  
            END IF;
        END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	


    IF(pEmpresa <> '' AND pEmpresa IS NOT NULL AND pIdCliente <>'' AND pIdCliente IS NOT NULL AND pOpcion<>'' AND pOpcion IS NOT NULL) THEN

        --Consulta
            IF (pOpcion='01')THEN
                SELECT flag, fecha_confirma INTO decision, fh_confirma FROM bdinteg:"informix".si_autoriza_datos_contacto WHERE numcte = pIdCliente;
                IF NVL(decision,0) = 1 OR fh_confirma <> '' OR fh_confirma IS NOT NULL THEN
                    LET codret = '00000';                ELSE
                    LET codret = '00002';                END IF;

        --REgistra/Actualiza
            ELIF (pOpcion='02')THEN

                SELECT intentos INTO contIntento FROM bdinteg:"informix".si_autoriza_datos_contacto WHERE numcte=pIdCliente;

                IF NVL(contIntento,0) = 0 THEN
                    IF pBandera_autoriza = 1 THEN--Insert autorizado
                        INSERT INTO bdinteg:"informix".si_autoriza_datos_contacto(empresa,numcte,ejecutivo,sucursal,canal,intentos,tipo_responsivo,fecha_insert,fecha_consulta,fecha_confirma,flag)
                        VALUES (pEmpresa,pIdCliente,pEjecutivo,pSucursal,pCanal,0,pTipo_responsivo,pFecha_insert,pFecha_mod_bandera,pFecha_mod_bandera,pBandera_autoriza);
                    ELSE--Insert No autorizado
                        INSERT INTO bdinteg:"informix".si_autoriza_datos_contacto(empresa,numcte,ejecutivo,sucursal,canal,intentos,tipo_responsivo,fecha_insert,fecha_consulta,fecha_confirma,flag)
                        VALUES (pEmpresa,pIdCliente,pEjecutivo,pSucursal,pCanal,1,pTipo_responsivo,pFecha_insert,pFecha_mod_bandera,'',pBandera_autoriza);
                    END IF;
                ELIF pBandera_autoriza = 1 THEN --Update autorizado
                    LET contIntento = contIntento + 1 ;
                    update bdinteg:"informix".si_autoriza_datos_contacto set canal = pCanal, tipo_responsivo = pTipo_responsivo, intentos = contIntento, fecha_consulta =  pFecha_mod_bandera, fecha_confirma = pFecha_mod_bandera, flag = pBandera_autoriza  WHERE numcte=pIdCliente;                  
                ELSE--Update No autorizado
                    LET contIntento = contIntento + 1 ;
                    update bdinteg:"informix".si_autoriza_datos_contacto set canal = pCanal, tipo_responsivo = pTipo_responsivo, intentos = contIntento, fecha_consulta =  pFecha_mod_bandera, fecha_confirma = '', flag = pBandera_autoriza  WHERE numcte=pIdCliente;                  
                END IF;
            END IF; 

        ELSE
            LET codret = '00003'; -- No existe el cliente
        END IF;


    RETURN codret;

    END;
END PROCEDURE;