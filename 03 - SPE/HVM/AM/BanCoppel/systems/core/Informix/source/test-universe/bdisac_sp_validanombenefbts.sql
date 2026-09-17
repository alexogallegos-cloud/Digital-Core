CREATE PROCEDURE "informix".sp_validanombenefbts(pPrimerNomBan CHAR(40), pSegNomBan CHAR(40), pApePatBan CHAR(40), pApeMatBan CHAR(40),
                                       pPrimerNomBTS CHAR(40), pSegNomBTS CHAR(40), pApePatBTS CHAR(40), pApeMatBTS CHAR(40))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    --INTEGER; -- Porcentaje
    DECIMAL(6,1); -- Porcentaje

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      	INT;
    DEFINE cCodRet      	CHAR(5);
    DEFINE dPorcentaje1  	DECIMAL(6,1);
	DEFINE dPorcentaje2  	DECIMAL(6,1);
	DEFINE dPorcentaje3  	DECIMAL(6,1);
	DEFINE dPorcentaje4  	DECIMAL(6,1);
	DEFINE dPorcMax      	DECIMAL(6,1);	
	DEFINE i            	INTEGER;
	DEFINE iCoicidencia 	INTEGER;
	DEFINE iCantidad    	INTEGER;
	DEFINE cCarBan      	CHAR(1);
	DEFINE cCarBTS      	CHAR(1);
    DEFINE iSuma        	INTEGER;
	DEFINE dPorciento    	DECIMAL(6,1);
    DEFINE cNomCompBan   	CHAR(160);
    DEFINE cNomCompBTS   	CHAR(160);
	
	DEFINE cPrimerNomBan  	char(40);
	DEFINE cSegNomBan     	char(40);
	DEFINE cApePatBan     	char(40);
	DEFINE cApeMatBan     	char(40);
	DEFINE cPrimerNomBTS  	char(40);
	DEFINE cSegNomBTS     	char(40);
	DEFINE cApePatBTS     	char(40);
	DEFINE cApeMatBTS     	char(40);
	        --INICIALIZACION DE VARIABLES--
    LET sql_err 		= 0;
    LET cCodRet 		= '00000';
    LET dPorcentaje1	= 0;
	LET dPorcentaje2 	= 0;
	LET dPorcentaje3 	= 0;
	LET dPorcMax 		= 0;
    LET i 				= 0;
	LET iCoicidencia 	= 0;
	LET iCantidad 		= 0;
    LET iSuma 			= 0;
	let dPorciento 		= 0;
	LET cNomCompBan 	= '';
	LET cNomCompBTS 	= '';
	
	--Respaldar los nombres completos 
	LET cPrimerNomBan 	=  NVL(pPrimerNomBan,'');
	LET cSegNomBan  	=  NVL(pSegNomBan,'');
	LET cApePatBan 		=  NVL(pApePatBan,'');
	LET cApeMatBan 		=  NVL(pApeMatBan,'');
	LET cPrimerNomBTS 	=  NVL(pPrimerNomBTS,'');
	LET cSegNomBTS 		=  NVL(pSegNomBTS,'');
	LET cApePatBTS 		=  NVL(pApePatBTS,'');
	LET cApeMatBTS 		=  NVL(pApeMatBTS,'');
	
	
    --SET DEBUG FILE TO "/informix/yoselin/sp_ValidaNomBenefBTS.out";
    --TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet, dPorciento;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

      IF NVL(pPrimerNomBan,'') = '' OR NVL(pApePatBan,'') = '' OR NVL(pPrimerNomBTS,'') = '' OR NVL(pApePatBTS,'') = '' THEN
		LET cCodRet =   '00001'; --Faltan parámetros
		RETURN cCodRet, dPorciento;
	END IF;
					
	LET pPrimerNomBan = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pPrimerNomBan,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pSegNomBan = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pSegNomBan,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pApePatBan = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pApePatBan,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pApeMatBan = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pApeMatBan,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pPrimerNomBTS = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pPrimerNomBTS,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pSegNomBTS = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pSegNomBTS,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pApePatBTS = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pApePatBTS,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));
	LET pApeMatBTS = UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE(REPLACE(NVL(pApeMatBTS,''),'á','A'),' ',''),'é','E'),'í','I'),'ó','O'),'ú','U'),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U'));


								 
	--SE VALIDA PRIMER CICLO CARACTER POR CARACTER
	EXECUTE PROCEDURE "informix".sp_ComparaCaracteresBTS (TRIM(pPrimerNomBan), TRIM(pPrimerNomBTS))  --VALIDAR PRIMER NOMBRE CARACTER POR CARACTER
	INTO cCodRet, iCoicidencia;
	
		IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pPrimerNomBTS));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	
		IF NVL(pSegNomBan,'') <> '' AND NVL(pSegNomBTS,'') <> '' THEN  --VALIDAR SEGUNDO NOMBRE CARACTER POR CARACTER
			EXECUTE PROCEDURE "informix".sp_ComparaCaracteresBTS (TRIM(pSegNomBan), TRIM(pSegNomBTS)) 
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;	
		ELSE
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));
		END IF;	
		

    EXECUTE PROCEDURE "informix".sp_ComparaCaracteresBTS (TRIM(pApePatBan), TRIM(pApePatBTS))  --VALIDAR APELLIDO PATERNO CARACTER POR CARACTER
	INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(TRIM(pApePatBTS));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
		
		IF NVL(pApeMatBTS,'') <> '' AND NVL(pApeMatBan,'') <> '' THEN   --VALIDAR APELLIDO MATERNO CARACTER POR CARACTER
			EXECUTE PROCEDURE sp_ComparaCaracteresBTS (TRIM(pApeMatBan), TRIM(pApeMatBTS)) 
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(TRIM(pApeMatBTS));
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;
		ELSE
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pApeMatBTS));
		END IF;
	
	LET dPorcentaje1 = CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));
	--CAST(iPorcMax AS INTEGER);
	LET dPorcMax = dPorcentaje1;
	
	LET iSuma = 0;
	LET iCantidad  =  0;
	
	--SE VALIDA SEGUNDO CICLO DESPLAZAMINETO BTS
	
	EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBTS(TRIM(pPrimerNomBan), TRIM(pPrimerNomBTS))
	INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pPrimerNomBTS));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	
		IF NVL(pSegNomBan,'') <> '' AND NVL(pSegNomBTS,'') <> '' THEN  --VALIDAR SEGUNDO NOMBRE 
			EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBTS (TRIM(pSegNomBan), TRIM(pSegNomBTS)) 
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;	
		ELSE
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));	
		END IF;	
	
	EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBTS (TRIM(pApePatBan), TRIM(pApePatBTS))  --VALIDAR APELLIDO PATERNO 
	INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(pApePatBTS);
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
	
	
		IF NVL(pApeMatBTS,'') <> '' AND NVL(pApeMatBan,'') <> '' THEN  --VALIDAR APELLIDO MATERNO 
			EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBTS (TRIM(pApeMatBan), TRIM(pApeMatBTS))
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(TRIM(pApeMatBTS));
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;
		ELSE
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pApeMatBTS));
		END IF;
	
	LET dPorcentaje2 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));
	 
	LET iSuma = 0;
	LET iCantidad  =  0;
	
		IF dPorcentaje2 > dPorcMax THEN
			LET dPorcMax = dPorcentaje2;
		END IF;
		
	--SE VALIDA tercer CICLO DESPLAZAMINETO BANCOPPEL
	
	EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBanco(TRIM(pPrimerNomBan), TRIM(pPrimerNomBTS))
	INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pPrimerNomBTS));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
		
		IF NVL(pSegNomBTS,'') <> '' AND NVL(pSegNomBan,'') <> '' THEN  --VALIDAR SEGUNDO NOMBRE 
			EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBanco (TRIM(pSegNomBan),TRIM(pSegNomBTS)) 
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;	
		ELSE 
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pSegNomBTS));
		END IF;	
	
	EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBanco (TRIM(pApePatBan), TRIM(pApePatBTS))  --VALIDAR APELLIDO PATERNO 
	INTO cCodRet, iCoicidencia;
		IF cCodRet = '00000' THEN
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad = iCantidad + LENGTH(TRIM(pApePatBTS));
		ELSE
			RETURN cCodRet, dPorciento;	
		END IF;
		
		
		IF NVL(pApeMatBTS,'') <> '' AND NVL(pApeMatBan,'') <> '' THEN  --VALIDAR APELLIDO MATERNO 
			EXECUTE PROCEDURE "informix".sp_ComparaDesfasamientoBanco (pApeMatBan,pApeMatBTS) 
			INTO cCodRet, iCoicidencia;
			IF cCodRet = '00000' THEN
				LET iSuma = iSuma + iCoicidencia;
				LET iCantidad  =  iCantidad + LENGTH(pApeMatBTS);
			ELSE
				RETURN cCodRet, dPorciento;		
			END IF;
		ELSE 
			LET iCoicidencia = 0;
			LET iSuma = iSuma + iCoicidencia;
			LET iCantidad  =  iCantidad + LENGTH(TRIM(pApeMatBTS));
		END IF;
		
		LET dPorcentaje3 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));

		IF dPorcentaje3 > dPorcMax THEN
			LET dPorcMax = dPorcentaje3;
		END IF;
		
		--SE VALIDA CUARTO CICLO CADENA DEL NOMBRE COMPLETA
		
	LET iSuma = 0;
	LET iCantidad  =  0;	
	-- Concatenación del Nombre Completo
	LET cNomCompBTS = TRIM(pPrimerNomBTS);
	LET cNomCompBTS = TRIM(cNomCompBTS)||TRIM(pSegNomBTS);
	LET cNomCompBTS = TRIM(cNomCompBTS)||TRIM(pApePatBTS);
	LET cNomCompBTS = TRIM(cNomCompBTS)||TRIM(pApeMatBTS);
	LET cNomCompBan = TRIM(pPrimerNomBan);
	LET cNomCompBan = TRIM(cNomCompBan)||TRIM(pSegNomBan);
	LET cNomCompBan = TRIM(cNomCompBan)||TRIM(pApePatBan);
	LET cNomCompBan = TRIM(cNomCompBan)||TRIM(pApeMatBan);	
	
	LET cNomCompBTS = TRIM(cNomCompBTS);
	LET cNomCompBan = TRIM(cNomCompBan);
	
	EXECUTE PROCEDURE "informix".sp_ComparaCaracteresBTS (TRIM(cNomCompBan), TRIM(cNomCompBTS))  --VALIDAR NOMBRE COMPLETO CARACTER POR CARACTER
	INTO cCodRet, iCoicidencia;
	IF cCodRet = '00000' THEN
		LET iSuma = iCoicidencia;
		LET iCantidad = LENGTH(TRIM(cNomCompBTS));
	ELSE
        RETURN cCodRet, dPorciento;	
	END IF;
	
	LET dPorcentaje4 =  CAST(iSuma / iCantidad * 100 AS DECIMAL(6,1));

	IF dPorcentaje4 > dPorcMax THEN
		LET dPorcMax = dPorcentaje4;
	END IF;	
	
    --LET iPorciento = CAST(iPorcMax AS INTEGER);
	LET dPorciento		= dPorcMax;
	
	LET cPrimerNomBan 	= TRIM(cPrimerNomBan);
	LET cSegNomBan 		= TRIM(cSegNomBan);
	LET cApePatBan 		= TRIM(cApePatBan);
	LET cPrimerNomBTS 	= TRIM(cPrimerNomBTS);
	LET cSegNomBTS 		= TRIM(cSegNomBTS);
	LET cApePatBTS 		= TRIM(cApePatBTS);
	LET cApeMatBTS 		= TRIM(cApeMatBTS);
	
	--Se realiza la insercion a la bitacora de consultas
	INSERT INTO "informix".sac_bts_bitnombres (s_first_nameban, s_middle_nameban,s_last_nameban,s_mother_m_nameban,s_first_namebts,s_middle_namebts,s_last_namebts,s_mother_m_namebts,coicidencia,fecha_insert) 
	VALUES ( cPrimerNomBan, cSegNomBan,cApePatBan,cApeMatBan,cPrimerNomBTS,cSegNomBTS,cApePatBTS,cApeMatBTS,dPorciento,CURRENT);
	
    RETURN cCodRet, dPorciento;
END
END PROCEDURE
DOCUMENT
'SE ACTUALIZO EL SP PARA LA ELIMINACION DE ESPACIOS EN BLANCO EN LA VALIDACION DE NOMBRES DE BTS Y WU',
'AUTOR : Luis Madrid',
'FECHA : 10/Febrero/2016',
'BD    : bdisac',
'VER   : 20160210-1741',
'Compara el nombre capturado en Bancoppel contra el que envía BTS',
'por medio de los tres ciclos, y obtiene el porcentaje máximo de coincidencia',
'AUTOR : Dulce Ramirez',
'FECHA : 25/Noviembre/2010',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_segundaautenticawu(cNumcte CHAR(20), cRfc CHAR(13), cLicencia CHAR(20), cPais2Id CHAR(4), cEdo2Id CHAR(30))

RETURNING
	CHAR(5)  AS cCodRet;

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 

LET cCodRet = "00000";
	
SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;
	
--SET DEBUG FILE TO "/tmp/Anayeli.out";
--TRACE ON;

BEGIN
	--CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	
    IF cRfc = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		   SET rfc = rfc 
		WHERE numcte = cNumcte;	
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET rfc = cRfc 
		WHERE numcte = cNumcte;
	END IF;
	
	IF cLicencia = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET licencia = licencia 
		WHERE numcte = cNumcte;
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET licencia = cLicencia
		WHERE numcte = cNumcte;
	END IF;
	
	IF cPais2Id = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas
		SET pais2id = pais2id 
		WHERE numcte = cNumcte;			
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET pais2id = cPais2Id
		WHERE numcte = cNumcte;
	END IF;
	
	IF cEdo2Id = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET estado2id = estado2id
		WHERE numcte = cNumcte;
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET estado2id = cEdo2Id
		WHERE numcte = cNumcte;
	END IF;
	
	/*UPDATE bdisac:"informix".sac_cte_remesas 
	SET rfc = (CASE WHEN cRfc = "" THEN rfc ELSE cRfc END),
		licencia = (CASE WHEN cLicencia = "" THEN licencia ELSE cLicencia END),
		pais2id = (CASE WHEN cPais2Id = "" THEN pais2id ELSE cPais2Id END),
		estado2id = (CASE WHEN cEdo2Id = "" THEN estado2id ELSE cEdo2Id END)	
	WHERE numcte = cNumcte;*/
	
	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Folio: 433 REQ. Base de datos para el alta de usuarios de remesas',
'Autor: 98243217 Marco Rivera ',
'Fecha: 21/08/2018',
'Descripcion: Actualiza datos de segunda autenticacion.',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

create procedure "informix".sp_verificaconvenio(cValorconv char(10))

    RETURNING char(5), char (120);

    --DEFINICION DE VARIABLES
    define cCodret          char (5);
    define cValordesc       char (120);
    define sestatus         char(1);
    define sestatusov       char(1);
    define sestatusvg       char(1);
    define remdesc          char(15);
    define remdescov        char(15);
    define remdescvg        char(5);


    --INICIALIZACION DE VARIABLES
    let cCodret         = "00000";
    let cValordesc      = "";
    let sestatus        = "";
    let sestatusov      = "";
    let sestatusvg      = "";
    let remdesc         = "";
    let remdescov       = "";
    let remdescvg       = "";


    begin
        -- BTS (30802,30803,30804)
        if cValorconv in ('30802','30803') then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '004';
            
            if sestatus = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el servicio de BTS no esta operando, intentelo más tarde";
            end if;
        end if;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
		
		if cValorconv = '20067' then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '009';
            
            if sestatus = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el servicio de APPRIZA PAY no esta operando, intentelo más tarde";
            end if;
        end if;

/*		
        -- WU, OV y VG (30401,30402,30403,30405)
        if cValorconv in ('30401','30402','30403','30405') then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '006';  --WU

            select statusconvenio
            into sestatusov
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '007';  --OV
            
            select statusconvenio
            into sestatusvg
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '008';  --VG

            if sestatus = 'I' then
                let remdesc = 'Western Union';
            end if;
            if sestatusov = 'I' then
                let remdescov = 'Orlandi Valuta';
            end if;
            if sestatusvg = 'I' then
                let remdescvg = 'Vigo';
            end if;
            
            if sestatus = 'I' or sestatusov = 'I' or sestatusvg = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el o los servicios " || trim(remdesc) || " " || trim(remdescov) || " " || trim(remdescvg) || " no esta(n) operando, intentelo más tarde.";
            end if;
           
        end if;
*/		
		
        return cCodret, cValordesc;
    end;

end procedure;