CREATE PROCEDURE "informix".sp_obthuellasactes2(pNumCteCorr CHAR(20), pNumCteInc CHAR(20))
	RETURNING
	CHAR(6) 	AS 	cCodRet,
	CHAR(942)	AS	cTrama,
	CHAR(942)	AS	cTrama2,
	CHAR(942)	AS	cTramaInc,
	CHAR(942)	AS	cTramaInc2;


	--DECLARACIONES
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    
	DEFINE cTrama	    	CHAR(942);
	DEFINE cTrama2	    	CHAR(942);
	DEFINE cTramaInc    	CHAR(942);
	DEFINE cTramaInc2    	CHAR(942);
	DEFINE cTipoCte	    	CHAR(1);
	DEFINE cTipoCte2    	CHAR(1);
	DEFINE cSecTitular    	CHAR(2);
	DEFINE cSecInco	    	CHAR(2);
	DEFINE cTicket1	    	CHAR(20);
	DEFINE cTicket2	    	CHAR(20);
	DEFINE cTicket3	    	CHAR(20);
	DEFINE iNumCte	    	INTEGER;
	DEFINE ibandera	    	INTEGER;

    --INICIALIZACIONES
	LET cCodRet				= '000000';
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	
	LET cTrama				= '';
	LET cTrama2				= '';
	LET cTramaInc			= '';
	LET cTramaInc2			= '';
	LET cTipoCte			= '';
	LET cTipoCte2			= '';
	LET cSecTitular    		= '';
	LET cSecInco	    	= '';
	LET cTicket1	    	= '';
	LET cTicket2	    	= '';
	LET cTicket3	    	= '';
	LET iNumCte	    		= 0;
	LET ibandera	    	= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
		END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_obthuellasactes2.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF NVL(pNumCteCorr,'') = '' OR NVL(pNumCteInc,'') = '' THEN
		LET cCodRet = '000001';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	END IF
	
	--VALIDA QUE SEAN TITULARES AMBOS CLIENTES.
	SELECT tipo_cliente
	INTO cTipoCte
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteCorr;
	
	IF NVL(cTipoCte,'') = '' THEN -- CLIENTE CORRECTO NO EXISTE
		LET cCodRet = '000002';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	END IF;
		
	SELECT tipo_cliente
	INTO cTipoCte2
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = pNumCteInc;
	
	IF NVL(cTipoCte2,'') = '' THEN --CLIENTE INCORRECTO NO EXISTE
		LET cCodRet = '000003';
		RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
	ELSE
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TITULAR
		SELECT dmapa, imapa, secuencia
		INTO cTrama, cTrama2, cSecTitular
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteCorr
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteCorr);		
		
		--OBTIENE EL TEMPLATE DE LA HUELLA DEL CLIENTE TRASPASAR
		SELECT dmapa, imapa, secuencia
		INTO cTramaInc, cTramaInc2, cSecInco
		FROM bdinteg:"informix".si_cte_huella   
		WHERE numcte = pNumCteInc
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdinteg:"informix".si_cte_huella
						WHERE numcte = pNumCteInc);
		
		--VALIDA QUE LA SECUENCIA EXISTA EN LA CONSULTA A LA TABLA "si_cte_huella" SINO, REGRESA UN CODIGO DE RETORNO
		IF cSecTitular <> '' THEN
			SELECT ticket
			INTO cTicket1
			FROM bdinteg:"informix".si_huella_linea
			WHERE numcte = pNumCteCorr
			AND secuencia = cSecTitular;
			
			IF NVL(cTicket1,'') = '' THEN
				SELECT ticket
				INTO cTicket2
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE numcte = pNumCteCorr
				AND secuencia = cSecTitular
				AND fecha_consulta = (SELECT MAX (fecha_consulta)
									  FROM bdinteg:"informix".si_huella_linea_hist
									  WHERE numcte = pNumCteCorr
									  AND secuencia = cSecTitular);
									  
				IF cTicket2 = '' THEN
					LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
					RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
				END IF;
			END IF;
		END IF;
		
		
		--SE CONSULTA EL NUMERO DE CLIENTE PARA VER SI SE REALIZO LA COMPARACIÃÂ DE HUELLA EXITOSA EN SUCURSAL SINO SE MANDA CODIGO DE EXITO
		IF cTicket1 <> '' THEN
			LET cTicket3 = cTicket1;
		ELIF cTicket2 <> '' THEN
			LET cTicket3 = cTicket2;
		ELSE
			LET cCodRet = "000000";  --NO SE A REALIZADO LA COMPARACION DE HUELLA DEL CLIENTE SOLICITADO
			RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));
		END IF;	
		
		
			SELECT LIMIT 1 cliente
			INTO iNumCte
			FROM bdinteg:"informix".si_huella_linea_resultado
			WHERE estado_proceso = '2'
			AND cliente = pNumCteInc
			AND ticket = cTicket3
			AND empresa  = '5'
			AND num_mensaje = '602';
			--AND secuencia = cSecInco; -- ESTA LINEA SE ACTIVARA CUANDO LO DE SUCURSAL YA ESTE
										-- FUNCIONANDO,ES DECIR, CUANDO EL VALOR DE LA SECUENCIA SE ESTE
										-- GUARDANDO EN LAS TABLAS.

			IF NOT iNumCte > 0 THEN
                SELECT LIMIT 1 cliente
                INTO iNumCte
                FROM bdinteg:"informix".si_huella_linea_resultado_hist
                WHERE estado_proceso = '2'
                AND cliente = pNumCteInc
                AND ticket = cTicket3
                AND empresa  = '5'
                AND num_mensaje = '602';
            END IF;    
		
			IF iNumCte > 0 THEN
				LET cCodRet = '000006';  --Los clientes consultados ya tuvieron la comparaciÃ³Â®Â Â¤e huellas
			END IF;
	END IF;
	
	RETURN TRIM(cCodRet), TRIM(NVL(cTrama,'')), TRIM(NVL(cTrama2,'')), TRIM(NVL(cTramaInc,'')), TRIM(NVL(cTramaInc2,''));		
END
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/08/2022',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusion Manual de Clientes',
'DESCRIPCION: Se crea procedimiento el cual consulta la tabla si_cte_huella para traer la informacion de la huella derecha e izquierda del cliente por su maxima secuencia',
'BD: bdinteg';

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