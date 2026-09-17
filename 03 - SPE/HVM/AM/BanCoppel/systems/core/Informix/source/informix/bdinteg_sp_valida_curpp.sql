CREATE PROCEDURE "informix".sp_valida_curpp(			pcTipo 		CHAR(1),
														pcNumCte	CHAR(10),
														pcCurp		CHAR(18),
														pcSexo		CHAR(1),
														pcApePat	CHAR(50),
														pcApeMat	CHAR(50),
														pcNombres 	CHAR(50),
														pcFecNac 	CHAR(10),
														pcEntidad   INTEGER,
														pcLimit 	INTEGER,
														pcMensajeR	CHAR(100),
														pcStatus	CHAR(2),
														pcTrans		CHAR(6))
														
														  	  
RETURNING 	CHAR(5) AS cCodRet,CHAR(20) AS cNumCte,CHAR(1) AS pcSexo,CHAR(50) AS cNombres,
			CHAR(50) AS cApePat,CHAR(50) AS cApeMat,CHAR(50) AS cCurp,
			CHAR (10) AS cFecNac,CHAR(2) AS cEntFed;
			
	          
--Definicion de Variables
DEFINE cNumCteAux		CHAR(15);
DEFINE iSqlErr 		  	INTEGER;
DEFINE cCodRet 		  	CHAR(5);  
DEFINE cnumcte        	CHAR(15);   
DEFINE capell_paterno 	CHAR(50);    
DEFINE capell_materno 	CHAR(50);    
DEFINE cnombre1       	CHAR(50);    
DEFINE cnombre2       	CHAR(50);    
DEFINE cfecha_nac     	CHAR(10);  
DEFINE cEntFed		  	CHAR(2);  
DEFINE cCurp		  	CHAR(18);
--DEFINE cidsession		CHAR(30);
DEFINE csexo			CHAR(1);
DEFINE cFecNac			CHAR(10);
--DEFINE iEntidad			INTEGER;
--DEFINE fecha_inicio     DATE;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '0';
LET cNumCteAux		= '';
LET cnumcte        	= '';    
LET capell_paterno 	= '';    
LET capell_materno 	= '';    
LET cnombre1       	= '';    
LET cnombre2       	= '';    
LET cfecha_nac     	= '';    
LET cEntFed			= '';
LET cCurp			= '';
--LET cidsession		= '';
LET csexo			= '';
LET cFecNac			= '';
--LET iEntidad		= 0 ;
--LET fecha_inicio    =MDY(12,8,2018);

--SET DEBUG FILE TO '/informix/jfponce/DanielGuerrero/sp_valida_curpp.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','','';
		END IF;
	END EXCEPTION;
	
	IF 	pcTipo = '0' THEN-- Obtener los clientes o empleados a consultar en coppel
		FOREACH WITH HOLD
		
			SELECT first pcLimit {INDEX ("informix".si_ctepf idx_validacurp)}
			D.numcte,P.sexo,D.apell_paterno,D.apell_materno,D.nombre1,D.nombre2,P.fecha_nac,P.lugar_nac,P.curp 
			INTO cnumcte,csexo,capell_paterno,capell_materno,cnombre1,cnombre2,cfecha_nac,cEntFed,ccurp
			FROM "informix".si_ctepf P
			LEFT JOIN "informix".si_cliente D
			ON D.numcte=P.numcte
			--LEFT JOIN "informix".si_estados E
			--ON P.lugar_nac=E.estado 
			WHERE
			P.lugar_nac IN (SELECT estado FROM "informix".si_estados WHERE pais='001' and estado=estado) AND --D.fecha_insert >= MDY(12,08,2015) AND ESTO SE COMENTA PARA PRUEBAS
			P.curp=P.curp AND  P.validacurp IS NULL  		
			AND D.fecha_insert >= MDY(01,01,2024) --D.fecha_insert = TODAY-1  -- ESTO SE PONE PARA PRUEBAS
			 -- AND ESTO SE COMENTA PARA PRUEBAS
			
			
			--LET cFecNac = YEAR(cfecha_nac)||'/'||LPAD(MONTH(cfecha_nac),2,'0')||'/'||LPAD(DAY(cfecha_nac),2,'0');
			LET cFecNac = LPAD(DAY(cfecha_nac),2,'0')||'/'||LPAD(MONTH(cfecha_nac),2,'0')||'/'||YEAR(cfecha_nac);
			
			RETURN cCodret,trim(cnumcte),csexo,trim(trim(cnombre1)||' '||trim(cnombre2)),capell_paterno,capell_materno,NVL(ccurp,''),cFecNac,cEntFed WITH RESUME;
			
		END FOREACH;
		
	ELIF pcTipo = '1' THEN  -- Actualizar validacurp=1 consulta exitosa renapo y se actualiza curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00001'; --El cliente is null cuando validacurp=1
		ELSE
			UPDATE "informix".si_ctepf
			SET validaCurp= '1',curp=pcCurp
			WHERE numcte=pcNumCte;

			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';
		
	ELIF pcTipo = '2' THEN  -- Actualizar solo validacurp=2 La curp no existe en la base de datos Renapo.
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00002'; --El cliente is null cuando validacurp=2
		ELSE	
			UPDATE "informix".si_ctepf
			SET validaCurp= '2'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet, '','','','','','','','';
		
	ELIF pcTipo = '3' THEN  --Actualizar solo validacurp=3 El cliente cuenta con mas de un curp
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00003'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='3'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;

		END IF;
		RETURN cCodRet,'','','','','','','','';

	ELIF pcTipo = '4' THEN  -- Actualizar registros exitosos
		IF (pcNumCte IS NULL OR pcNumCte = '' )THEN
			LET cCodRet = '00004'; --Valor de parametros nulos o no valido
		ELSE
			UPDATE "informix".si_ctepf 
			SET validacurp ='4', lugar_nac = pcEntidad
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,pcNumCte,'','','','','','','';	
		
	ELIF pcTipo = '5' THEN  --Actualizar solo validacurp=5 Ocurrio un error no controlado
		IF (pcNumCte IS NULL OR pcNumCte = '') THEN
			LET cCodRet = '00005'; --El cliente is null cuando validacurp=3
		ELSE

			UPDATE "informix".si_ctepf 
			SET validacurp ='5'
			WHERE numcte=pcNumCte;
			
			SELECT numcte INTO cNumCteAux FROM si_bitacora_renapob WHERE numcte = pcNumCte;

			IF cNumCteAux = '' THEN
				--INSERSION EN BITACORA RENAPO
				INSERT INTO "informix".si_bitacora_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			ELSE
				--INSERSION EN TABLA HISTORICA
				INSERT INTO "informix".si_historica_renapob(numcte,fecha_insert,mensaje_resp,status,transacc)
				VALUES (pcNumCte,CURRENT,pcMensajeR,pcStatus,pcTrans);
			END IF;
			
		END IF;
		RETURN cCodRet,'','','','','','','','';
		
		
	ELSE
		LET cCodRet = '00069';	--El valor de pTipo no coincide con ninguno del sps
	RETURN cCodRet, '','','','','','','','';
	
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Angel Daniel Hernandez Gallardo',
'FECHA: 26/09/2024',
'SUSTENTO: RQI 63 1121',
'MODIFICACION: Se modifica procedimiento almacenado para insertar informacion en la tabla historica si_historica_renapob';

CREATE PROCEDURE "informix".sp_tarcop( pNumCte     CHAR(20),  -- NO. CLIENTE
                                              PNumTarcoppel CHAR(20),
											  POption INTEGER )-- TARJETA COPPEL 
RETURNING   CHAR(5) AS cod_error,
            CHAR(20) AS num_tarjeta,
            CHAR (100) AS NOMBRE,
            DECIMAL(12,2) AS monto_solicitado;  -- CODIGO DE RETORNO
    
    DEFINE vcodret1 CHAR(5);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE vTarjCop CHAR(20);
    DEFINE cNombre CHAR(100);
    DEFINE mSolicitado DECIMAL(12,2);
 
    
    LET vcodret1 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	LET vTarjCop = '';
    LET cNombre = '';
    LET mSolicitado = '';
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR
       (PNumTarcoppel is null OR PNumTarcoppel = '') THEN
        LET vcodret1 = '00001';
        RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
    END IF;

    SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre
    INTO cNombre
    FROM bdinteg:"informix".si_cliente 
    WHERE numcte = pNumCte;

    SELECT monto_solicitado
    INTO mSolicitado
    FROM bdisolic:"informix".ss_solicitudes
    WHERE numcte = pNumCte
    AND num_producto ='6500';

    IF ( POption = 1) THEN
        DELETE FROM bdinteg:"informix".si_conscoppel WHERE numcte = pNumCte;
		INSERT INTO bdinteg:"informix".si_conscoppel
		(empresa, numcte, numtarcoppel, fechahora)
		VALUES
		('001', pNumCte, PNumTarcoppel, CURRENT);
		
		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;
		
		IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	ELSE 

		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;

        IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	END IF;
    
    END; 

    RETURN vcodret1, vTarjCop, cNombre, mSolicitado;

END PROCEDURE;