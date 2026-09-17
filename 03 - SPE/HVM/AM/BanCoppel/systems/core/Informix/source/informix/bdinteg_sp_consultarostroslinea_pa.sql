CREATE PROCEDURE "informix".sp_consultarostroslinea_pa(pNumCte CHAR(20))

--DATOS A REGRESAR---
RETURNING             	
	CHAR(5) 	AS CodRet,
	CHAR(3) 	AS empresa,
	SMALLINT 	AS secuencia,
	CHAR(20) 	AS numcte,
	CHAR(4) 	AS sucursal,
	CHAR(20) 	AS fecha_consulta,
	CHAR(15) 	AS ip,
	CHAR(1)		AS sexo,
	SMALLINT	AS tipo_mov,
	CHAR(1)		AS validate_ine;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_consultarostroslinea_pa "
Folio.........: 712.1 - EnvÃ­o de decÃ¡logo de huellas.
Autor.........: 90127902 - Carlos VÃ¡zquez Mitre
Fecha.........: 27/01/2021
Solicita......: Juan Francisco Ponce Damian
BD............: bdinteg
VersiÃ³n.......: 20/08/2021
-------------------

Autor::::::: Gabriel Romero Cuauhitzo
Descripcion.....: Se agrega campo origen_ticket, para ser contemplado para guardar en la tabla si_rostro_linea_hist
RQI.......: 63 720
Version.......: 26/10/2021
--------------------
Autor::::::: Jesus Daniel Guerrero Benitez, Gabriel Romero Cuauhitzo, Jahaziel Eduardo Heredia Hinojosa 
Descripcion.....: Se elimino el FOREACH y se aÃ±adiÃ³ el limit 1 para que devolviera solo un cliente, tambiÃ©n se excluyo a los clientes BEX y se aÃ±adiÃ³ el cÃ³digo retorno 00002 para excluir las imÃ¡genes que se estÃ©n volviendo a mandar.
RQI.......: 63 895
Version.......: 24/01/2023
Solicita......: Juan Francisco Ponce Damian
-------------------
Autor::::::: Gabriel Romero Cuauhitzo 
Descripcion.....: Se hace una mejora en lÃ³gica para cambiar el valor de iTipoMov en los casos siguientes

	 * Caso 1 Alta de cliente: sin registro en la si_rostro_linea y registrado en la si_cte_rostro con secuencia_control = 1 -> insert cliente en la si_rostro_linea con tipo_mov = 1
	 
	 * Caso 2 Cliente ya con captura de rostro: registro en la si_cte_rostro con secuencia_control = 3 y registro en la si_rostro_linea con secuencia = 2 y tipo_mov = 3 -> insert cliente en la si_rostro_linea con tipo_mov = 1
	 
	 * Caso 3 Cliente Mantenimiento tipo_mov = 3 : registro en la si_cte_rostro con secuencia_control = 4 y registro en la si_rostro_linea con secuencia = 3 y tipo_mov = 1 -> insert cliente en la si_rostro_linea con tipo_mov = 3
     
	 lineas modificas de la 114 a 118
RQI.......: 63914
Version.......: 16/03/2023
Solicita......: Juan Francisco Ponce Damian
*/

-- DEFINICION DE VARIABLES.
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE cEmpresa			CHAR(3);
DEFINE shSecuencia		SMALLINT;
DEFINE cNumCte			CHAR(20);
DEFINE cSucursal		CHAR(4);
DEFINE cIp				CHAR(15);
DEFINE cFechaConsulta	DATE;
DEFINE iContador		INTEGER;
DEFINE cSexo			CHAR(1);
DEFINE iTipoMov			SMALLINT;
DEFINE cValidateIne		CHAR(1);
DEFINE cTicket			CHAR(50);

--SET DEBUG FILE TO '/informix/jfponce/gabriel/err/sp_consultarostroslinea_pa.out';
--TRACE ON;

-- INICIALIZACION DE VARIABLE.
LET cCodRet				= '00001';
LET iSqlErr				= 0;
LET cEmpresa			= '';
LET shSecuencia			= 0;
LET cNumCte				= '';
LET cSucursal			= '';
LET cIp					= '';
LET iContador			= 0;
LET cSexo				= '';
LET iTipoMov			= 1;
LET cValidateIne		= 'F';
LET cFechaConsulta 		= CURRENT::DATE;
LET cTicket				= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,shSecuencia, cNumCte, cSucursal,cIp, cFechaConsulta, cSexo, iTipoMov, cValidateIne;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	SELECT LIMIT 1 empresa,secuencia_control, numcte, sucursal,ip 
	INTO cEmpresa, shSecuencia, cNumCte, cSucursal, cIp 
	FROM bdirostros@coppelimg_tcp:"informix".si_cte_rostro
	--FROM  "informix".si_cte_rostro
	--FROM  bdirostros:si_cte_rostro 
	WHERE numcte = pNumCte AND ip != '' AND secuencia = 1 AND usuario != 'BEX' AND estado = 'A';
	
	
	IF cNumCte <> '' THEN 

		IF(shSecuencia <> 1) THEN
			
			IF EXISTS(SELECT numcte FROM "informix".si_rostro_linea WHERE numcte = pNumCte AND tipo_mov='1') THEN
			  
                LET iTipoMov = 3;
				
            END IF;
			
		END IF;
			
		SELECT LIMIT 1 sexo INTO cSexo FROM "informix".si_ctepf WHERE numcte = pNumCte;
			
		IF EXISTS(SELECT numcte FROM "informix".si_bitacora_huella_ine WHERE numcte = pNumCte) THEN
				LET cValidateIne = 'T';
		END IF;
			
			--
		IF EXISTS(SELECT numcte FROM "informix".si_rostro_linea WHERE secuencia >= shSecuencia AND (status_consulta = '2' OR status_consulta = '3') AND numcte = pNumCte) THEN
			 LET cCodRet = '00002';
		ELSE
				-- 
				IF(NVL(cSexo,'') = '' )THEN
						LET cCodRet = '00003';
				ELSE	
						LET cCodRet = '00000';
						
					IF EXISTS (SELECT numcte FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte) THEN
						INSERT INTO "informix".si_rostro_linea_hist(secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine, origen_ticket, origen_result, fecha_result, 
																	status_result, desc_result, match_result, num_match_result, codret_result, code_service, fecha_env, fecha_resp) 
						SELECT secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine, origen_ticket, origen_result, fecha_result, status_result, desc_result, 
								match_result, num_match_result, codret_result, code_service, fecha_env, fecha_resp
						FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
						
						SELECT ticket INTO cTicket FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
						
						IF (NVL(cTicket, '') <> '') THEN
							INSERT INTO "informix".si_rostro_linea_result_hist(id_hist, ticket, numcte_match, empresa_match, 
																			   sitesp_match, porc_match,Fecha_insert,
																				   origen_result,num_match_result) 
							SELECT id, ticket, numcte_match, empresa_match, sitesp_match, porc_match,Fecha_insert,
								   origen_result,num_match_result
							FROM "informix".si_rostro_linea_result WHERE ticket = cTicket;
							
							DELETE FROM "informix".si_rostro_linea_result WHERE ticket = cTicket;
						END IF;	
						
						DELETE FROM "informix".si_rostro_linea WHERE secuencia = shSecuencia AND numcte = pNumCte;
					END IF;
					
					
					INSERT INTO "informix".si_rostro_linea (secuencia, numcte, sucursal, fecha_consulta, sexo, ip, tipo_mov, ticket, status_consulta, ine)
					VALUES(shSecuencia, pNumCte, cSucursal, cFechaConsulta, cSexo, cIp, iTipoMov, '', '0', cValidateIne);
					
				END IF;
		END IF;
		RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	ELSE
		RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	END IF;
	
	--IF (iContador <= 0) THEN
	--RETURN cCodRet, cEmpresa, shSecuencia, cNumCte, cSucursal, cFechaConsulta, cIp, cSexo, iTipoMov, cValidateIne WITH RESUME;
	--END IF;
	
END;
END PROCEDURE;