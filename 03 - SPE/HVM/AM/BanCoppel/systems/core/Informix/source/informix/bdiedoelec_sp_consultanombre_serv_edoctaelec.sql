CREATE PROCEDURE "informix".sp_consultanombre_serv_edoctaelec
(
   pEmpresa CHAR(3),
   pNumCte CHAR(9),
   pNumCuenta CHAR(20),
   pNumTarjeta CHAR(20)
)
RETURNING CHAR(6) AS CodRet , CHAR(9) AS NumCliente, CHAR(107) AS NombreCte, CHAR(1) AS Status;

DEFINE	cCodRet			CHAR(6);
DEFINE	iSql_err		INTEGER;
DEFINE	cNombre1		CHAR(26);
DEFINE	cNombre2		CHAR(26);
DEFINE	cApellPat		CHAR(26);
DEFINE	cApellMat		CHAR(26);
DEFINE	cStatusServElec	CHAR(1);
DEFINE	cNombreCompleto	CHAR(107);
DEFINE	cBinTar			CHAR(6);DEFINE	cProTar			CHAR(6);
LET	cCodRet			= '000000';
LET	iSql_err		= 0;
LET	cNombre1		= "";
LET	cNombre2		= "";
LET	cApellPat		= "";
LET	cApellMat		= "";  
LET	cStatusServElec	= "";
LET	cNombreCompleto	= "";
LET	cBinTar			= "";LET	cProTar			= "";
BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/home/sysifx/respaldosbd/JesusRLopez/789/sp_consultanombre_serv_edoctaelec.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND (NVL(pNumTarjeta,'') <> '' OR NVL(pNumCte,'')<> '' OR NVL(pNumCuenta,'')<> '') THEN

		IF NVL(pNumCuenta,'') <> '' THEN
		
			--TDC PAY INICIO
			LET cProTar = SUBSTR(pNumCuenta,1,2); 
			
			IF cProTar ='65' THEN
			
				SELECT LIMIT 1 numcliente 
				INTO pNumCte
				FROM intercard: "informix".TarjetaCuenta Tac, intercard: "informix".Tarjeta Tar
				WHERE Tac.NumTarjeta = Tar.NumTarjeta
				AND Tac.numcuenta = pNumCuenta;
			
			ELSE
			--TDC PAY FIN

				 SELECT LIMIT 1 num_cte		--verifica si es tarjeta de debito
				 INTO pNumCte
				 FROM bdicheq:"informix".sc_maechq
				 WHERE empresa = pEmpresa
				 AND cuenta = pNumCuenta;
			 
			END IF;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN

				SELECT LIMIT 1 numcte	--verifica si es tarjeta de credito
				INTO pNumCte
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND num_credito = pNumCuenta;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN

					SELECT LIMIT 1 numcte	--verifica si es prestamo o reestructura
					INTO pNumCte
					FROM bdicred:"informix".sd_maecredcrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCuenta;

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '000003';
					END IF;
				END IF;
			END IF;
		END IF;

		IF NVL(pNumTarjeta,'') <> '' THEN		
		
			--TDC PAY INICIO
			LET cBinTar = SUBSTR(pNumTarjeta,1,6); 
			
			IF cBinTar ='514014' THEN
			
				SELECT LIMIT 1 numcliente
				INTO pNumCte
				FROM intercard: "informix".Tarjeta 
				WHERE NumTarjeta  = pNumTarjeta
				AND codstatustarjeta ='ACT';

			ELSE
			--TDC PAY INICIO

				SELECT LIMIT 1 numcte
				INTO pNumCte
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND status_tar = "A";
				
			END IF;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				--AAME RQI 27 221 Se contempla la consulta de Tarjetas Inactivas
				SELECT LIMIT 1 numcte
				INTO pNumCte
				FROM bdicred:"informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND status_tar IN ("A","I");

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '000002';
				END IF;
			END IF;
		END IF;

		IF NVL(pNumCte,'') <> '' THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
			ELSE
				SELECT LIMIT 1 status_serv_elec
				INTO cStatusServElec
				FROM bdiedoelec:"informix".edelec_alta_serv
				WHERE numcte = pNumCte
				AND status_serv_elec = 'A';

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cStatusServElec = 'I';
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet = '000001'; --parametros vacios
	END IF;
	
	RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cStatusServElec;
END;
END PROCEDURE
DOCUMENT
"Folio:1602",
"Autor:95975071 Jairo Valdez",
"Fecha:29/04/2014",
"Modificación: Se crea SP para obtener en base al número de cliente o tarjeta el nombre del cliente y el status del servicio electronico de edo. de cta.",
"Sustento: RQI 12 231 Edo Cta Emisión Consulta Disponibilización y Respaldo OFI.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdiedoelec";

CREATE PROCEDURE "informix".sp_ins_user_paws_bpi (pempresa char(3),pnumcte char(20), pass_first_part char (4), puser_modif varchar(20)) 
    RETURNING CHAR(5) AS CodigoRetorno
 
 --******************************************
  --Se crea spl con el nombre modificado
  --RQI CheckmarxB18  BPI
  --Gabrieal Aguilar  
  --10-03-2025  
--***********************************************
  
    DEFINE iSqlErr              INTEGER;
    DEFINE v_sCodRet            CHAR(5);
	DEFINE v_pass_second_part   CHAR (4);
	DEFINE encry_pass           VARCHAR(20);
	
	DEFINE vnumcte1         		VARCHAR(20);
	DEFINE vnumcte2         		VARCHAR(20);
	DEFINE vcodret1 			CHAR(5);
	
	LET vnumcte1 = '';
	LET vnumcte2 = '';
	LET vcodret1 = '';

   -- SET DEBUG FILE TO  "sp_ins_user_paws_bpi.out"; 
    --TRACE ON;
	
	LET v_sCodRet = '000';
	LET encry_pass = "";

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET v_sCodRet = iSqlErr;
                RETURN v_sCodRet;
            END IF;
        END EXCEPTION;
		
		SELECT FIRST 1 numcte  
		  INTO vnumcte1
		  FROM bdiedoelec:edelec_alta_serv 
		  WHERE numcte = pnumcte;
		  
		SELECT FIRST 1 numcte  
		  INTO vnumcte2
		  FROM bdiedoelec:edelec_constancia 
		  WHERE numcte = pnumcte;
		
		IF ((vnumcte1 IS NULL OR vnumcte1 = '') AND (vnumcte2 IS NULL OR vnumcte2 = '')) THEN
		
			LET v_sCodRet = '001'; --Cliente No se encuentra en el Alta del Servicio
			RETURN v_sCodRet;
					
		END IF 
		
		SELECT password  
		  INTO encry_pass
		  FROM bdinteg:si_ejecut 
		  WHERE ejecutivo = 'informix';

		SET encryption password encry_pass;
	
		SELECT SUBSTR(sp_random(),1,4) 
		  INTO v_pass_second_part
		  FROM bdiedoelec:systables where tabname = "systables";

		/*
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','idplant',pnumcte,null,null,'1',v_pass_second_part,null,null,null,null,null,null,null,null,null,null,null)			
		INTO vcodret1;	
		
		IF vcodret1 <> '00000' THEN
		
			LET v_sCodRet=vcodret1;
			RETURN v_sCodRet; 
		
		END IF
		*/
		
		IF EXISTS (SELECT numcte FROM bdiedoelec:edelec_usr_pass WHERE numcte = pnumcte) THEN
		
			UPDATE bdiedoelec:edelec_usr_pass 
			   SET pass_first_part = encrypt_aes(pass_first_part), 
			       pass_sec_part = encrypt_aes(v_pass_second_part), 
				   fecha_ultima_mod = TODAY, 
				   user_modif = puser_modif
			 WHERE numcte = pnumcte;
			 
		ELSE
		
			INSERT INTO bdiedoelec:edelec_usr_pass (empresa,numcte,pass_first_part,pass_sec_part,fecha_alta,fecha_ultima_mod,user_modif)
				 VALUES (pempresa,pnumcte,encrypt_aes(pass_first_part),encrypt_aes(v_pass_second_part),TODAY,TODAY,puser_modif);
				 
		END IF
			
		RETURN v_sCodRet;    

    END
END PROCEDURE;