CREATE PROCEDURE "informix".sp_consulta_sesion(pc_numero_cliente varchar(20), pc_canal varchar(50), pc_id_sesion char(500), pc_usuario varchar(20))
    RETURNING CHAR(5),CHAR(3);
	
	DEFINE resultado CHAR(3);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE vCount 	INTEGER;
    DEFINE vCountinactivas INTEGER;
    DEFINE vCountBex INTEGER;
	
	LET resultado = '000';
	LET vcodret   = '00000';
	LET vCount	  = 0;
    LET vCountinactivas = 0;
    LET vCountBex = 0;
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_sesion.out";
    --TRACE ON; 
BEGIN	
	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

   
	
	SELECT COUNT(numcliente) 
	INTO vCount 
	FROM "informix".bpi_doblesesion 
	WHERE numcliente = pc_numero_cliente;


	IF vCount > 0 THEN
--GM3 P.Del Razo: 15/11/2018 INI:Modificacion Validacion Doble Sesion para evitar error -284
		SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
        INTO vCountinactivas
        FROM "informix".bpi_doblesesion 
        WHERE numcliente = pc_numero_cliente;
       

		LET vCountinactivas = NVL(vCountinactivas,0);
				
		IF ( vCountinactivas > 0 ) THEN
			LET resultado = '003';
            SELECT COUNT(numcliente) INTO vCountBex  FROM "informix".bpi_doblesesion where canal = 'NBEX'  AND  numcliente = pc_numero_cliente;
            IF ( vCountBex > 0 ) THEN
                LET resultado = '005';
            END IF;
		ELSE
			SELECT COUNT(numcliente)  
			INTO vCount 
			FROM "informix".bpi_doblesesion
			WHERE numcliente = pc_numero_cliente;
--GM3 P.Del Razo: 15/11/2018 FIN: Modificacion Validacion Doble Sesion para evitar error -284		
			IF vCount > 0 THEN
				DELETE FROM "informix".bpi_doblesesion 
				WHERE numcliente = pc_numero_cliente;
						
				INSERT INTO "informix".bpi_doblesesion (numcliente, 
					usuario, fecha, canal, id_sesion, status)
				VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal, pc_id_sesion, '0');
				
				LET resultado = '000';		
			ELSE
				LET resultado = '004';
			END IF;
		END IF;
		
	ELSE  
--GM3 GABRIELA MENDOZA: 15/11/2018 INI: INSERT		
		INSERT INTO "informix".bpi_doblesesion (numcliente, usuario, fecha, canal, id_sesion, status)
		VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal, pc_id_sesion, '0');
--GM3 GABRIELA MENDOZA: 15/11/2018 FIN: INSERT	
	END IF;
END;	
	RETURN	vcodret, resultado;	
END PROCEDURE

DOCUMENT
'MODIFICADO POR: GM3-PATRICIA DEL RAZO HERNANDEZ',
'MODIFICADO POR: GM3-GABRIELA MENDEZ',
'VoBo POR: GM2-JUAN OLIVARES',
'FECHA DE MODIFICACION: 15 DE NOVIEMBRE DE 2018',
'OBJETIVO: CAMBIO: VALIDACION DOBLE SESION',
'          EVITAR ERROR -284',
'BD: BDIBPI';

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