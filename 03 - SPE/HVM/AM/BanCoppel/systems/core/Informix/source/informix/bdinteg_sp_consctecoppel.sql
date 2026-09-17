CREATE PROCEDURE "informix".sp_consctecoppel(p_sEmpresa CHAR(3), p_sNumCte CHAR(20))

RETURNING CHAR(5), CHAR(20), CHAR(26), CHAR(26), CHAR(26), CHAR(26), DATE, CHAR(13), CHAR(20), CHAR(20);

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE v_sNumCte CHAR(20);
DEFINE v_sNombre1 CHAR(26);
DEFINE v_sNombre2 CHAR(26);
DEFINE v_sApellidoP CHAR(26);
DEFINE v_sApellidoM CHAR(26);
DEFINE v_dFechaNac DATE;
DEFINE v_sRfc CHAR(13);
DEFINE v_sNumCteCoppel CHAR(20);
DEFINE v_sNumTarCoppel CHAR(20);
DEFINE v_sRfc_alterno CHAR(13);
DEFINE v_Numcteref CHAR(20);
DEFINE v_secuencia SMALLINT;

--****************************************************************************************************
-- DESCRIPCION: Consulta Clientes Coppel.
-- AUTOR : Marcos Cuevas
-- FECHA : 09/02/2009
-- SISTEMA : Caja Unica
--****************************************************************************************************

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET v_sNumCte = '';
LET v_sNombre1 = '';
LET v_sNombre2 = '';
LET v_sApellidoP = '';
LET v_sApellidoM = '';
LET v_dFechaNac = DATE(1);
LET v_sRfc = '';
LET v_sNumCteCoppel = '';
LET v_sNumTarCoppel = '';
LET v_sRfc_alterno = '';
LET v_Numcteref ='';
LET v_secuencia = 0;

--set debug file to "/tmp/sp_ConsCteCoppel.out";
--Trace on;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
	
		ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF viSqlErr <> 0 THEN
				RETURN viSqlErr,'','','','','','','', '', '';
			END IF;
		END EXCEPTION;
		
		--Valida que el cliente exista, si existe consulta los datos requeridos sino manda el codigo de retorno 1
		IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = p_sNumCte) THEN
		
			SELECT a.numcte, a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno, a.rfc, b.fecha_nac, a.rfc_alterno,a.numcte_ref
			INTO v_sNumCte, v_sNombre1, v_sNombre2, v_sApellidoP, v_sApellidoM, v_sRfc, v_dFechaNac, v_sRFC_alterno, v_Numcteref
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
			WHERE a.empresa = p_sEmpresa AND a.numcte = p_sNumCte AND a.numcte = b.numcte;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET vsCodRet = '00001';									
			ELSE
				--AAME 16042020 RQI 27 221 Se obtiene la referencia registrada al cte bco para obtener el cte coppel correcto y evitar error -284			
				SELECT MAX(secuencia) INTO v_secuencia
				FROM bdinteg:si_adiccoppel 
				WHERE empresa = p_sEmpresa 
				AND numcte = p_sNumCte 
				AND numctecoppel = v_Numcteref;
				
				SELECT numctecoppel, numtarcoppel
				INTO v_sNumCteCoppel, v_sNumTarCoppel
				FROM bdinteg:"informix".si_adiccoppel
				WHERE empresa = p_sEmpresa
				AND numctecoppel = v_Numcteref
				AND secuencia = v_secuencia;  				
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET vsCodRet = '00001';						
				ELSE				
					IF v_sRFC_alterno is not null and v_sRFC_alterno <> "" THEN
					   LET v_sRFC = v_sRFC_alterno;
					END IF;
				END IF;			
			END IF;
		ELSE 
			LET vsCodRet = '00001';
		END IF;
		
		RETURN vsCodRet,v_sNumCte,v_sNombre1,v_sNombre2,v_sApellidoP,v_sApellidoM,v_dFechaNac,v_sRfc,v_sNumCteCoppel,v_sNumTarCoppel;
	
	END
END PROCEDURE;