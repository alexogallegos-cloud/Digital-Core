CREATE PROCEDURE "informix".sp_consultarjetas_debcred_bpi(pEmpresa char(3), pNumCte char(15), pStatus char(3), pIdOper char(4))
RETURNING char(5),char(12),char(20),char(40), char(3), char(1),char(1);   

DEFINE ccodret char(5);
DEFINE isql_err integer;
DEFINE cvcuenta char(12);
DEFINE cvnumtarjeta char(20);
DEFINE cvnombre_prod char(40);
DEFINE cvestatus_tar char(3);
DEFINE cvstatus_tar char(1);
DEFINE iconta integer;
DEFINE iconcre integer;

LET ccodret = "00000";
LET cvcuenta= "";
LET cvnumtarjeta = "";
LET cvnombre_prod = "";
LET cvestatus_tar = "";
LET cvstatus_tar = "";
LET iconta = 0;
LET iconcre = 0;


BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,"",cvstatus_tar;
		END IF;
	END EXCEPTION;
   
   --SET DEBUG FILE TO '/informix/JuanRivera/Traces/sp_consultarjetas_debcred_bpi.out';
   --TRACE ON;
   
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

    IF pIdOper == "6007" OR (pIdOper IS NULL OR pIdOper =='') THEN -- TARJETAS DE DEBITO
	
	    IF pStatus == "INA" THEN --ACTIVACION
            FOREACH
               SELECT tr.cuenta, tr.num_tarjeta, pr.nombre, tj.codstatustarjeta, status_tar
               INTO cvcuenta,cvnumtarjeta, cvnombre_prod, cvestatus_tar,cvstatus_tar
               FROM bdicheq:'informix'.sc_tarjeta tr
               INNER JOIN intercard:'informix'.tarjeta tj ON (codstatustarjeta = pStatus and tr.numcte = tj.numcliente and tr.num_tarjeta = tj.numtarjeta)
               JOIN bdicheq:'informix'.sc_producto pr ON (tr.prodtarjeta = pr.producto)
               WHERE tr.empresa= pEmpresa and tr.numcte = pNumCte and tr.prodtarjeta = '2400' and tr.tipo_tarjeta = 'T'

              LET iconta = iconta + 1;
              IF (iconta < 10) THEN
                RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,"D",cvstatus_tar WITH RESUME;
              END IF;
            END FOREACH	
        ELIF pStatus == "ACT" THEN -- REPORTES
            FOREACH
                SELECT tr.cuenta, tr.num_tarjeta, pr.nombre, tj.codstatustarjeta, status_tar
                INTO cvcuenta,cvnumtarjeta, cvnombre_prod, cvestatus_tar,cvstatus_tar
                FROM bdicheq:'informix'.sc_tarjeta tr
                INNER JOIN intercard:'informix'.tarjeta tj ON (codstatustarjeta = pStatus and tr.numcte = tj.numcliente and tr.num_tarjeta = tj.numtarjeta)
                JOIN bdicheq:'informix'.sc_producto pr ON (tr.prodtarjeta = pr.producto)
                WHERE tr.empresa= pEmpresa and tr.numcte = pNumCte and tr.prodtarjeta IN (1300,1400,1700,1900,2000,2400,2500,2900) and tr.tipo_tarjeta = 'T'

                LET iconta = iconta + 1;
                IF (iconta < 10) THEN
                   RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,"D",cvstatus_tar WITH RESUME;
                END IF;
            END FOREACH
        END IF;
	
        LET iconcre = iconta;
    END IF;   
    IF pIdOper == "6004" OR (pIdOper IS NULL OR pIdOper =='') THEN -- TARJETAS DE CREDITO

        IF pStatus == "INA" THEN --ACTIVACION
            FOREACH
                SELECT tr.num_credito, tr.num_tarjeta, df.nombre_prod, tj.codstatustarjeta, status_tar
                INTO cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,cvstatus_tar			
                FROM bdicred:"informix".sd_tarjeta tr
                INNER JOIN bdicred:sd_maecred cr ON   cr.num_credito = tr.num_credito
                INNER JOIN intercard:"informix".tarjeta tj ON ( tj.codstatustarjeta = 'INA' AND  tr.numcte = tj.numcliente and tr.num_tarjeta = tj.numtarjeta)
                JOIN bdicred:"informix".sd_definicion df ON (df.num_producto = cr.num_producto)
                WHERE tr.empresa= pEmpresa AND tr.numcte = pNumCte --AND tr.tipo_tarjeta = 'T' and tr.prodtarjeta IN (7000,8100)
                    AND  tr.tipo_tarjeta IN ('T','A')
                    AND  cr.num_producto IN (6001,7000,8100,8500,5400)

                LET iconcre = iconcre + 1;
                IF (iconcre < 10) THEN
                    RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,"C",cvstatus_tar WITH RESUME;
                END IF;
            END FOREACH
        ELIF pStatus == "ACT" THEN -- REPORTES
            FOREACH
                SELECT tr.num_credito, tr.num_tarjeta,df.nombre_prod, tj.codstatustarjeta, status_tar
                INTO cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,cvstatus_tar
                FROM bdicred:"informix".sd_tarjeta tr
                INNER JOIN intercard:"informix".tarjeta tj ON (tj.codstatustarjeta = pStatus and tr.numcte = tj.numcliente and tr.num_tarjeta = tj.numtarjeta)
                JOIN bdicred:"informix".sd_definicion df ON (df.num_producto = tr.prodtarjeta)
                WHERE tr.empresa= pEmpresa and tr.numcte = pNumCte and tr.tipo_tarjeta = 'T' and tr.prodtarjeta IN (6001,7000,8100,8500,5400)

                LET iconcre = iconcre + 1;
                IF (iconcre < 10) THEN
                    RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar,"C",cvstatus_tar WITH RESUME;
                END IF;
            END FOREACH
        END IF;
    END IF;

	IF iconcre=0 THEN
		LET ccodret = '00001';
		RETURN ccodret, cvcuenta, cvnumtarjeta, cvnombre_prod, cvestatus_tar, "",cvstatus_tar;
	END IF;
END

END PROCEDURE
DOCUMENT
'OBJETIVO: 	Consulta tarjetas inactivas de dÌ?å?Ì?å©bito platino',
'AUTOR:		JosÌ?å?Ì?å© de JesÌ?å?Ì?å¼s Nevarez',
'FECHA : 	08/02/2017',
'MODIFICACION: Se actualiza para que regrese el status_tar de la bdicheq y bdicred',
'AUTOR:		JosÌ?å?Ì?å© de JesÌ?å?Ì?å¼s Nevarez',
'FECHA : 	20/06/2017',
'BD : 		bdibpi';

CREATE PROCEDURE "informix".sp_actualizadatoscontacto20230822(pNumCliente VARCHAR(9),
										   pCel VARCHAR(15),
										   pCiaCel INT,
										   pEmail VARCHAR(100))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Actualiza datos del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 19/11/2010
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	--variables para registro en nuevas tablas
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8); 
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
    --TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';

        LET v_Empresa    = '001';
        LET v_TipoTel    = 2; 
        LET v_Extension  = ''; 
        LET v_Canal      = 3; 
        LET v_UserInsert = 'transBPI';
        LET v_codret1 = '00000';
        LET v_codret2 = '00000';
        LET v_TipoCorreo    = 1; 
		
		SET LOCK MODE TO WAIT 5;

        --actualización de datos del usuario de portal
		/*UPDATE bpi_usuario SET tel_celular = pCel, cia_cel = pCiaCel, e_mail = pEmail 
        WHERE numcliente = pNumCliente AND st_portal = 'activo';*/
		
	    --inserta registro de teléfono
        IF (pCel <> '') THEN
			IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumCliente 
						and telefono = pCel and carrier = pCiaCel and tipo_tel = v_TipoTel) = 0 THEN
            EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(v_Empresa, pNumCliente, pCel, v_TipoTel, v_Extension, pCiaCel, v_Canal,v_UserInsert)
                             INTO v_codret1;
			END IF;				 
        END IF;
        IF (pEmail <> '') THEN
			IF (SELECT count (correo_elec) from bdinteg:"informix".si_correos where numcte = pNumCliente 
						and correo_elec = pEmail and status_correo = 'A') = 0 THEN
            EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret2;
			END IF;				
        END IF;
         
		RETURN vCod_ret;
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Edgar Alarcon Gonzalez',
'FECHA.........: 12-09-2016',
'MODIFICACIÓN..: Se amplia parametro de correo a 100 caracteres.',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_grabardatosusuario(pNumCliente VARCHAR(9),
									   pNumTel VARCHAR(15),
									   pCiaCel INT,
									   pEmail VARCHAR(100))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra datos del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 16/11/2010
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
--variables para registro en nuevas tablas
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8); 
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
    --TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;

		LET vCod_ret = '00000';
        LET v_Empresa    = '001';
        LET v_TipoTel    = 2; 
        LET v_Extension  = ''; 
        LET v_Canal      = 3; 
        LET v_UserInsert = 'transBPI';
        LET v_codret1 = '00000';
        LET v_codret2 = '00000';
        LET v_TipoCorreo    = 1; 
		
		SET LOCK MODE TO WAIT 5;

		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			/*UPDATE bpi_usuario SET tel_celular = pNumTel, cia_cel = pCiaCel, e_mail = pEmail WHERE numcliente = pNumCliente AND st_portal = 'activo';
                        UPDATE bdinteg:"informix".si_ctepf set email = pEmail where numcte = pNumCliente;*/
            IF (pNumTel <> '') THEN
				IF ((SELECT COUNT (telefono) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCliente AND telefono = pNumTel
						AND tipo_tel = v_TipoTel AND carrier = pCiaCel) = 0) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(v_Empresa, pNumCliente, pNumTel, v_TipoTel,
                                                     v_Extension, pCiaCel, v_Canal,v_UserInsert)
                             INTO v_codret1;
				END IF;
            END IF;
            IF (pEmail <> '') THEN
				IF ((SELECT COUNT (correo_elec) FROM bdinteg:"informix".si_correos WHERE numcte = pNumCliente AND correo_elec = pEmail 
						AND status_correo = 'A') =0) THEN 
                EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret2;
				END IF;			
            END IF;
		ELSE
			LET vCod_ret = '00001'; -- Numero de cliente ya registrado
		END IF;

		RETURN vCod_ret;

	END;

END PROCEDURE
DOCUMENT
'AUTOR.........: Edgar Alarcon Gonzalez',
'FECHA.........: 12-09-2016',
'MODIFICACIÓN..: Se amplia parametro de correo a 100 caracteres.',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_grabardatosusuario_bpi(pNumCliente VARCHAR(9),pNumTel VARCHAR(15),pCiaCel INT,pEmail VARCHAR(100),pAlterEmail VARCHAR(100))


RETURNING CHAR (5);
		
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
--variables para registro en nuevas tablas
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8); 
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
    --TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;

		LET vCod_ret = '00000';
        LET v_Empresa    = '001';
        LET v_TipoTel    = 2; 
        LET v_Extension  = ''; 
        LET v_Canal      = 3; 
        LET v_UserInsert = 'transBPI';
        LET v_codret1 = '00000';
        LET v_codret2 = '00000';
        LET v_TipoCorreo    = 1; 
		
		SET LOCK MODE TO WAIT 5;

		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		
		IF NVL(vNumCliente, '') <> '' THEN
			/*UPDATE bpi_usuario SET tel_celular = pNumTel, cia_cel = pCiaCel, e_mail = pEmail WHERE numcliente = pNumCliente AND st_portal = 'activo';
                        UPDATE bdinteg:"informix".si_ctepf set email = pEmail where numcte = pNumCliente;*/
            IF (pNumTel <> '') THEN
				IF ((SELECT COUNT (telefono) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCliente AND telefono = pNumTel
						AND tipo_tel = v_TipoTel AND carrier = pCiaCel) = 0) THEN
						EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(v_Empresa, pNumCliente, pNumTel, v_TipoTel, v_Extension, pCiaCel, v_Canal,v_UserInsert)
                         INTO v_codret1;
				END IF;
            END IF;
			/*
            IF (pEmail <> '') THEN
				
                EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos_bpi(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert,pAlterEmail)
                            INTO v_codret2;
			
            END IF;
			*/
		ELSE
			LET vCod_ret = '00001'; -- Numero de cliente ya registrado
		END IF;

		RETURN vCod_ret;

	END;

END PROCEDURE
DOCUMENT
'AUTOR.........: Edgar Alarcon Gonzalez',
'FECHA.........: 12-09-2016',
'MODIFICACIÓN..: Se amplia parametro de correo a 100 caracteres.',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_consultafrases_bpi(pIdFrase INT)
RETURNING CHAR (5), INT, CHAR(100);

	DEFINE iSql_err INT;
	DEFINE cCod_ret CHAR (5);
	DEFINE iIdFrase INT;
	DEFINE vDesc_frase VARCHAR(100);
	DEFINE iMaxID INT;
	DEFINE iIdAleatorio INT;
	

	LET cCod_ret = '00000';
	LET iIdFrase = 0;
	LET vDesc_frase = '';
	LET iMaxID = 0;
	LET iIdAleatorio = 0;


	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iIdFrase, vDesc_frase;
		  END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/gaby/spl_consulta-frase/sp_consultafrases_bpi.out';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;


				SELECT  COUNT(*) INTO iMaxID FROM bdibpi:"informix".bpi_cat_frases;

                IF NVL(pIdFrase, '') <> '' AND pIdFrase <= iMaxID THEN
                    SELECT FIRST 1 id_frase, desc_frase INTO iIdFrase, vDesc_frase FROM bdibpi:"informix".bpi_cat_frases WHERE id_frase = pIdFrase;
                ELSE
                    EXECUTE PROCEDURE bdibpi:"informix".sp_random(1, iMaxID) INTO iIdAleatorio;
                    SELECT FIRST 1 id_frase, desc_frase INTO iIdFrase, vDesc_frase FROM bdibpi:"informix".bpi_cat_frases WHERE id_frase = iIdAleatorio;
                END IF;

				IF NVL(iIdFrase, 0) = 0 THEN
				LET iIdFrase='0';
				LET  vDesc_frase='VALENZUELA';
				END IF;
				
		RETURN cCod_ret, iIdFrase, vDesc_frase;
	END;

END PROCEDURE
DOCUMENT
'CREî: 95419888 ELMER LîPEZ VALENZUELA',
'FECHA: 05/01/2016',
'BD: bdibpi',
'Objetivo: OBTIENE UNA FRASE FALSA ALEATORIA',
'2016-05-05',
'Se modifica flujo dummy',
'Bibiana Gaxiola Verdugo',
'Se modifica para quitar la tabla temporal',
'Gabriela Aguilar, 09-08-2016';

CREATE PROCEDURE "informix".sp_locale_geo_cons(pFolio CHAR(30), pRef CHAR(30),  pLat CHAR(12), pLong CHAR(12), pTransacc CHAR (4), pTipo CHAR (1)  ) RETURNING CHAR(5) AS cod_ret;
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de geolocalizacion
-- AUTOR : AVF
-- FECHA : 21/08/2023
-- BD: bdibpi
--****************************************************************************************************
-- FECHA : 01/11/2023
-- Actualizacio
--****************************************************************************************************
-- Definicion de variables
	DEFINE distance INTEGER;
	DEFINE idEnt INTEGER;
	DEFINE delta_lat FLOAT;
	DEFINE delta_lng FLOAT;
	DEFINE lat0 CHAR(12);
	DEFINE lon0 CHAR(12);
	DEFINE alfa_lat CHAR(12);
	DEFINE beta_lat CHAR(12);
	DEFINE gamma_lat CHAR(12);
	DEFINE alfa_lon CHAR(12);

	DEFINE	geodata	CHAR(60);
	DEFINE	pFolio_suc	CHAR(30);
	DEFINE	xFolio	CHAR(30);
	DEFINE xCveGeo CHAR(1);
	DEFINE vTransacc CHAR(4);	
	DEFINE vSuc CHAR(4);
	DEFINE vNumserial CHAR(10); 


-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE cod_res	CHAR(5);
	LET cod_ret  = '00000';
	LET geodata  = '000,000,00,00000,XX';
	
   -- set debug file to "/ifxsif01/aw/out/sp_locale_geo_cons.out";
   -- Trace on;

BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
	END EXCEPTION;

	
	IF pFolio IS NULL OR pFolio ='' OR pTipo='' THEN
		LET cod_ret  = '00009';
		RETURN cod_ret;
	END IF;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--Opcion A
	LET alfa_lat = SUBSTR(pLat,1,5);
	LET alfa_lon = SUBSTR(pLong,1,5);
	--Opcion B
	LET beta_lat = SUBSTR(pLat,1,7);
	--Opcion C
	LET gamma_lat = SUBSTR(pLat,1,9);
	
	LET cod_ret  = '00002';

	LET pFolio_suc = '';
	LET xCveGeo = '0';

		IF pTipo='2' AND pTransacc='0274' THEN
			--SELECT FIRST 1 folio_suc INTO pFolio FROM bdicheq:sc_movdia as mov WHERE mov.empresa = '001' AND mov.sucursal = '5008' AND mov.referencia = pRef;

			FOREACH WITH HOLD
				SELECT chrfolioprom 
				INTO xFolio
				FROM bdispei:tblpago 
				WHERE vchrclaverastreo=pFolio
				
				IF xFolio<>'' THEN
					LET pFolio_suc=xFolio;
				END IF;	
			CONTINUE FOREACH;	
			END FOREACH;		
			
			IF (pFolio_suc = '') THEN
				FOREACH WITH HOLD
					SELECT chrfolioprom 
					INTO xFolio
					FROM bdispei:tblhistpago 
					WHERE vchrclaverastreo=pFolio
					
					IF xFolio<>'' THEN
						LET pFolio_suc=xFolio;
					END IF;	
				CONTINUE FOREACH;	
				END FOREACH;		
			END IF;
		ELSE
			LET pFolio_suc = pFolio;
		END IF;
		
		
	--Inicia busqueda de geolocalización
	EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, alfa_lat,alfa_lon, '1') INTO cod_res,geodata; 
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, beta_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, gamma_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, alfa_lat, '', '2') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		--Inicia iteracion USA
		EXECUTE PROCEDURE sp_locale_data_geo( pLat, pLong, '','', '3') INTO cod_res,geodata; 
	END IF;
	
	IF geodata = '' THEN
		LET geodata  = '000,000,00,00000,XX';	
	END IF;
	
	
	
	IF pTipo='1' THEN
		UPDATE bdibpi:bpi_geolocalizacion SET  referencia_23 = geodata WHERE folio = pFolio;			
		IF pFolio_suc<>'' THEN
			LET xCveGeo = '1';
			UPDATE bdicheq:sc_movhis SET referencia_23 = geodata WHERE empresa='001' AND folio_suc = pFolio_suc; 
			
			FOREACH WITH HOLD
				SELECT  folio_suc,  num_serial, transacc, sucursal
				INTO  xFolio, vNumserial, vTransacc, vSuc
				FROM  bdicheq:sc_movhis as mov  			
				WHERE  empresa='001' AND folio_suc=pFolio_suc
				
				
				IF (xFolio <> '' AND vTransacc = pTransacc) THEN 								
					UPDATE bdibpi:bpi_geolocalizacion SET cve_geo=xCveGeo, version_a =  vNumserial WHERE folio = pFolio_suc;
				ELSE 
					UPDATE bdibpi:bpi_geolocalizacion SET cve_geo=xCveGeo, version_b =  vNumserial  WHERE folio = pFolio_suc;
				END IF;	
			
			CONTINUE FOREACH;	
			END FOREACH;
		END IF;
	END IF;
	
	IF pTipo='2' THEN
		UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, referencia_23 = geodata WHERE referencia = pFolio;			
		IF pFolio_suc<>'' THEN
			LET xCveGeo = '1';
			UPDATE bdicheq:sc_movhis SET referencia_23 = geodata WHERE empresa='001' AND folio_suc = pFolio_suc; 
			
			FOREACH WITH HOLD
				SELECT  folio_suc,  num_serial, transacc, sucursal
				INTO  xFolio, vNumserial, vTransacc, vSuc
				FROM  bdicheq:sc_movhis as mov  			
				WHERE  empresa='001' AND folio_suc=pFolio_suc
				
				
				IF (xFolio <> '' AND vTransacc = pTransacc) THEN 								
					UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, version_a =  vNumserial WHERE referencia = pFolio;
				ELSE 
					UPDATE bdibei:bei_bitacora_geolocalizacion SET cve_geo=xCveGeo, version_b =  vNumserial  WHERE referencia = pFolio;
				END IF;	
			
			CONTINUE FOREACH;	
			END FOREACH;
		END IF;
	
	END IF;

	LET cod_ret  = '00000';

RETURN cod_ret;
END;
END PROCEDURE;