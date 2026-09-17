CREATE PROCEDURE "informix".sp_calcularrfc(pApellidoPaterno CHAR(26), pApellidoMaterno CHAR(26), pNombre CHAR(55), pFechaNacimiento DATE)
        RETURNING CHAR(5) AS codret,
                        CHAR(13) AS rfc;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cRfc CHAR(13);
        DEFINE cCaracter CHAR(1);
        DEFINE i SMALLINT;
        DEFINE bBoolValue BOOLEAN;
        DEFINE lPalabra LVARCHAR;
        DEFINE bSalirBucle BOOLEAN;
        -- Variables de RFC
        DEFINE cPrimerLetraApellidoPaterno CHAR(1);
        DEFINE cVocalApellidoPaterno CHAR(1);
        DEFINE cPrimerLetraApellidoMaterno CHAR(1);
        DEFINE cPrimerLetraNombre CHAR(1);
        DEFINE cFechaNacimientos CHAR(6);
        DEFINE cHomoclave CHAR(2);
        DEFINE cDigitoVerificador CHAR(2);
		DEFINE cApellidoMaterno CHAR(26);

    DEFINE iCont INTEGER;
    DEFINE lPalabra2 LVARCHAR;
    LET iCont=0;
    LET lPalabra2 = '';

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cRfc = '';
        LET cCaracter = '';
        LET bBoolValue = 'f';
        LET lPalabra = '';
        LET bSalirBucle = 'f';
        LET cPrimerLetraApellidoPaterno = '';
        LET cVocalApellidoPaterno = '';
        LET cPrimerLetraApellidoMaterno = 'X';
        LET cPrimerLetraNombre = '';
        LET cFechaNacimientos = '';
        LET cHomoclave = '';
        LET cDigitoVerificador = '';
		LET cApellidoMaterno = pApellidoMaterno;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cRfc;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_calcularrfc.out';
                --TRACE ON;

                IF pNombre = '' OR pFechaNacimiento IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                IF pApellidoPaterno = '' AND pApellidoMaterno = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cRfc;
                END IF;

                LET pApellidoPaterno = UPPER(pApellidoPaterno);
                LET pApellidoMaterno = UPPER(pApellidoMaterno);
                LET pNombre = UPPER(pNombre);

                FOR i = 0 TO LENGTH(TRIM(pApellidoPaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoPaterno), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00221'; -- CARACTER RARO EN EL APELLIDO PATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pApellidoMaterno))
                        LET cCaracter = SUBSTR(TRIM(pApellidoMaterno), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00222'; -- CARACTER RARO EN EL APELLIDO MATERNO
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                FOR i = 0 TO LENGTH(TRIM(pNombre))
                        LET cCaracter = SUBSTR(TRIM(pNombre), i, 1);
                        EXECUTE FUNCTION  bdinteg:"informix".sp_sololetrasnumeros(cCaracter) INTO bBoolValue;

                        IF NOT bBoolValue THEN
                                LET cCodRet = '00223'; -- CARACTER RARO EN EL NOMBRE
                                RETURN cCodRet, cRfc;
                        END IF;
                END FOR;

                -- SI SOLO TIENE UN APELLIDO TOMARLO COMO PATERNO
                IF TRIM(pApellidoPaterno) = '' AND TRIM(pApellidoMaterno) <> '' THEN
                        LET pApellidoPaterno = pApellidoMaterno;
                        LET pApellidoMaterno = '';
                END IF;

                -- Se Obtiene la primera letra y la primer vocal del apellido
                IF TRIM(pApellidoPaterno) <> '' THEN
						--CONTADOR DE APELLIDO
						FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra2
							Let iCont=iCont+1;
							--RETURN iCont, 'CONTADOR';
						END FOREACH;


                        FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoPaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION "informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00224'; -- APELLIDO PATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO PATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
								IF iCont>1 THEN
									EXECUTE FUNCTION  bdinteg:"informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;
								ELSE
									LET bBoolValue='t';
								END IF;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoPaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                -- SE BUSCA LA PRIMERA VOCAL DEL APELLIDO
                                                IF LENGTH(TRIM(lPalabra)) > 1 THEN
                                                        FOR i = 2 TO LENGTH(TRIM(lPalabra))
                                                                LET cCaracter = SUBSTR(TRIM(lPalabra), i, 1);
                                                                EXECUTE FUNCTION  bdinteg:"informix".sp_esvocal(cCaracter) INTO bBoolValue;
                                                                IF bBoolValue THEN
                                                                        LET cVocalApellidoPaterno = cCaracter;
                                                                        LET bSalirBucle = 't';
                                                                        EXIT FOR;
                                                                --ELSE
                                                                --      LET cVocalApellidoPaterno = 'X';
                                                                END IF;
                                                        END FOR;
                                                        LET bSalirBucle = 't';
                                                ELSE
                                                        LET bSalirBucle = 't';
                                                END IF;

                                                IF bSalirBucle THEN
                                                        EXIT FOREACH;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;
                LET bSalirBucle = 'f';

                -- Se Obtiene la primera letra apellido materno
                IF TRIM(pApellidoMaterno) <> '' THEN
                        FOREACH EXECUTE FUNCTION  bdinteg:"informix".sp_split_cadena(pApellidoMaterno, ' ') INTO lPalabra

                                -- Verificar que el apellido no este abreviado
                                EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN -- EL APELLIDO ESTA ABREVIADO
                                        LET cCodRet = '00225'; -- APELLIDO MATERNO ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE -- EL APELLIDO MATERNO NO ESTA ABREVIADO
                                        -- SE VALIDA QUE SEA UN APELLIDO VALIDO
                                        EXECUTE FUNCTION  bdinteg:"informix".sp_esapellido_valido(lPalabra) INTO bBoolValue;

                                        IF bBoolValue THEN
                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                EXIT FOREACH;
                                        END IF;

                                END IF;

                        END FOREACH;
                END IF;

				--TRACE '-----------------------------------------------------';
				--TRACE '>>>>>'||cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;

                -- Se obtiene la primer letra del nombre
                IF TRIM(pNombre) <> '' THEN

                        FOREACH EXECUTE FUNCTION bdinteg:"informix".sp_split_cadena(pNombre, ' ') INTO lPalabra

                                -- Revisar que el nombre no este abreviado
                                EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_apellido_abreviado(lPalabra) INTO bBoolValue;
                                IF bBoolValue THEN
                                        LET cCodRet = '00226'; -- NOMBRE ABREVIADO
                                        RETURN cCodRet, cRfc;
                                ELSE
                                        EXECUTE FUNCTION  bdinteg:"informix".sp_esnombre_valido(TRIM(lPalabra)) INTO bBoolValue;

                                        IF bBoolValue THEN
												--TRACE '*********************************';
                                                IF cVocalApellidoPaterno = '' THEN
                                                        LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
                                                        LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                ELSE
                                                        IF TRIM(pApellidoMaterno) = '' THEN
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                                EXIT FOREACH;
                                        ELSE
                                                IF TRIM(lPalabra) = 'MARIA' OR TRIM(lPalabra) = 'JOSE' OR TRIM(lPalabra) = 'MA' OR TRIM(lPalabra) = 'M' OR TRIM(lPalabra) = 'J' THEN
                                                        IF cVocalApellidoPaterno = '' THEN
                                                                LET cVocalApellidoPaterno = cPrimerLetraApellidoMaterno;
																LET pApellidoMaterno = '';
                                                                LET cPrimerLetraApellidoMaterno = SUBSTR(TRIM(lPalabra), 1, 1);
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 2, 1);
                                                        ELSE
                                                                LET cPrimerLetraNombre = SUBSTR(TRIM(lPalabra), 1, 1);
                                                        END IF;
                                                END IF;
                                        END IF;

                                END IF;

                        END FOREACH;

                END IF;

				LET pApellidoMaterno = cApellidoMaterno;

                LET cRfc = cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre;
                -- Busqueda de palabra Altisonante
                EXECUTE FUNCTION  bdinteg:"informix".sp_espalabra_altisonante(TRIM(cRfc)) INTO bBoolValue;
                IF bBoolValue THEN
                        LET cPrimerLetraNombre = 'X';
                END IF;

                LET cFechaNacimientos = TO_CHAR(pFechaNacimiento, '%y%m%d');
                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos;

                -- ObtenciÃ³n de la homoclave
                LET lPalabra = UPPER(TRIM(pApellidoPaterno))||' '||UPPER(TRIM(pApellidoMaterno))||' '||UPPER(TRIM(pNombre));
                EXECUTE FUNCTION  bdinteg:"informix".sp_obtenerhomoclave(lPalabra) INTO cHomoclave;

                -- ObtenciÃ³n del digito verificador
                LET cRfc = TRIM(cRfc)||cHomoclave;
                EXECUTE FUNCTION  bdinteg:"informix".sp_obtienedigitoverificador_rfc(TRIM(cRfc)) INTO cDigitoVerificador;

                LET cRfc =      cPrimerLetraApellidoPaterno||cVocalApellidoPaterno||cPrimerLetraApellidoMaterno||cPrimerLetraNombre||cFechaNacimientos||cHomoclave||cDigitoVerificador;
                RETURN cCodRet, cRfc;
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Oscar Flores Conde',
'FECHA: 05/12/2013',
'DESCRIPCION: Funcion que genera el RFC de un cliente';

CREATE PROCEDURE "informix".sp_pay_depuracion_pba()
RETURNING VARCHAR(10), VARCHAR(255);


	DEFINE vcod_ret         		VARCHAR(10); 
	DEFINE sql_err          		INTEGER;
	DEFINE isam_err         		INTEGER;
	DEFINE error_info       		CHAR(40);
	
	DEFINE vdia_cte					INTEGER;
	DEFINE vdif_cte					INTEGER;
	DEFINE vfec_depuracion_cte		DATE;
	DEFINE vfecha_hoy				DATE;
	
	DEFINE vdia_dir					INTEGER;
	DEFINE vdif_dir					INTEGER;
	DEFINE vfec_depuracion_dir		DATE;

	DEFINE vdia_cta					INTEGER;
	DEFINE vdif_cta					INTEGER;
	DEFINE vfec_depuracion_cta		DATE;

	DEFINE vdia_tar					INTEGER;
	DEFINE vdif_tar					INTEGER;
	DEFINE vfec_depuracion_tar 		DATE;
	
	
	--Manejo del error
       ON EXCEPTION
		SET sql_err, isam_err, error_info
		
           IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            RETURN vcod_ret, isam_err||' ' ||error_info;
			
           END IF;
       END EXCEPTION;
	   
	set debug file to "/tmp/costo/costo/20220324/bdichq/sp_pay_depuracion";
	TRACE ON;	   
	 
	LET vcod_ret = '000';          
	LET sql_err = 0;          
	LET isam_err = 0;        
	LET error_info = '';
	
	
	LET vfecha_hoy = '';
	LET vdia_cte = 0;				
	LET vdif_cte = 0;				
	LET vfec_depuracion_cte = '';	
				
	
	LET vdia_dir = 0;				
	LET vdif_dir = 0;				
	LET vfec_depuracion_dir = '';	
	
	LET vdia_cta = 0;				
	LET vdif_cta = 0;				
	LET vfec_depuracion_cta = '';
	
	LET vdia_tar = 0;
	LET vdif_tar = 0;
	LET vfec_depuracion_tar = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	   
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cte, vdia_cte
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 1;
		
	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_dir, vdia_dir
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 2;

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_cta, vdia_cta
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 3;	

	SELECT fecha_depuracion, dia
		INTO vfec_depuracion_tar, vdia_tar
		FROM bdinteg:si_pyt_depuracion
		WHERE id_tabla = 4;	

	LET vfecha_hoy = TODAY;
	
	LET vdif_cte = vfecha_hoy - vfec_depuracion_cte;
	LET vdif_dir = vfecha_hoy - vfec_depuracion_dir;
	LET vdif_cta = vfecha_hoy - vfec_depuracion_cta;
	LET vdif_tar = vfecha_hoy - vfec_depuracion_tar;
	
	-- Depuracion de Cliente
	IF( vdif_cte = vdia_cte ) THEN
	
		TRUNCATE bdinteg:info_clientes_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 1;
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion 
		   SET ind_dep = '0'
		 WHERE id_tabla = 1;
	END IF			

	-- Depuracion de Direccion
	IF(vdif_dir = vdia_dir ) THEN
	
		TRUNCATE bdinteg:info_direccion_pyt;
	
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		  WHERE id_tabla = 2;
				
	ELSE 
			UPDATE bdinteg:si_pyt_depuracion 
			  SET ind_dep = '0'
			WHERE id_tabla = 2;
	END IF	
	
	--Depuracion de Cuenta
	IF(vdif_cta = vdia_cta) THEN

		TRUNCATE bdinteg:info_cuenta_pyt;
		
		UPDATE bdinteg:si_pyt_depuracion 
		   SET (fecha_depuracion, ind_dep) = (TODAY, '1')
		 WHERE id_tabla = 3;
				
	ELSE 
		UPDATE bdinteg:si_pyt_depuracion SET ind_dep = '0'
				WHERE id_tabla = 3;
				
	END IF

	-- Depuracion de Tarjeta
	IF( vdif_tar = vdia_tar ) THEN
		-- Pendiente
	END IF			
	
	RETURN vcod_ret, 'PROCESO EXITOSO';
END PROCEDURE;