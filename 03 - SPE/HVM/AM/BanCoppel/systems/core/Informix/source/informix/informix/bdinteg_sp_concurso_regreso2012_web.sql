CREATE PROCEDURE "informix".sp_concurso_regreso2012_web(p_canal INT,p_tpoper INT,p_producto INT, p_numcte CHAR(9),p_sucursal CHAR(4),p_foliosuc CHAR(16),p_importe MONEY(16,2),p_fecha DATE)

RETURNING CHAR(5) AS cCod_Ret,CHAR(16) AS cFolio, CHAR(20) AS cFolio_cupon, CHAR(2) AS cTicket;

--Declaracion de variables

DEFINE cError_Info		VARCHAR(80); 
DEFINE iSql_Err			INTEGER;
DEFINE iIsam_Err		INTEGER;
DEFINE cCod_Ret			VARCHAR(5);
DEFINE cFolio 			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE iNumbol			INTEGER;
DEFINE iNumBolFin		INTEGER;
DEFINE cCvesorteo		VARCHAR(6);
DEFINE cParam			CHAR(5);
DEFINE iPart1			INTEGER;
DEFINE iPart2			INTEGER;
DEFINE iPart3			INTEGER;
DEFINE iPart4			INTEGER;
DEFINE cComienza		CHAR(1);
DEFINE cStatus			CHAR(1);

--Asignacion de variables
LET cError_Info		='';
LET iSql_Err		=0;
LET iIsam_Err		=0;
LET cCod_Ret		='00000'; --todo correcto
LET cFolio 			='';
LET cFolio_cupon	='';
LET cTicket			='';
LET iNumbol			=0;
LET iNumBolFin		=0;
LET cCvesorteo		='';
LET cParam			='';
LET iPart1			=0;
LET iPart2			=0;
LET iPart3			=0;
LET iPart4			=0;
LET cComienza		='N';
LET cStatus			='0';

BEGIN

	ON EXCEPTION SET iSql_Err, iIsam_Err, cError_Info
		LET cCod_Ret    = iSql_Err;
		RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET cComienza = "S";
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO "/tmp/sp_concurso_regreso2012.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--Verificar si esta activado el sorteo instantaneo
	SELECT valor INTO cParam
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 117;
	
	IF cParam = '1' THEN
		--Verificar la clave del sorteo de las madres
		SELECT valor INTO cParam
		FROM bdinteg:"informix".si_param
		WHERE cod_param = 136; 
		
		--Verificar la fecha se encuentre dentro del rango del sorteo 04 Agosto al 02 de Septiembre y que sea el sorteo indicado
		SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)}
		cve_sorteo
		INTO cCvesorteo
		FROM bdinteg:"informix".si_sorteo
		WHERE  p_fecha  BETWEEN f_ini AND f_fin
		AND cve_sorteo = cParam;
		
		IF cCvesorteo = '' OR cCvesorteo IS NULL THEN
			--'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
		ELSE
			--Verificar que la persona no es persona fisica y se encuentra dentro del catalogo de personas morales
			IF(SELECT {+INDEX (bdinteg:"informix".si_cltenoparticipa idx_si_cltenoparticipa)} count(numcte)
				FROM bdinteg:"informix".si_cltenoparticipa
				WHERE numcte = p_numcte) > 0 THEN
				--'LA PERSONA ES MORAL NO PARTICIPA'
			ELSE
				--Verificar que cumpla con el perfil establecido
				SELECT {+INDEX (bdinteg:"informix".si_participa idx_si_participa)}
				SUM(CASE WHEN tipo_participa = '1' AND id_elemento = p_producto THEN 1 ELSE 0 END) prod, --tipo de producto
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper THEN 1 ELSE 0 END) trans, --tipo de operacion 
				SUM(CASE WHEN tipo_participa = '3' AND id_elemento = p_canal THEN 1 ELSE 0 END) canal, --tipo de canal
				SUM(CASE WHEN tipo_participa = '4' AND id_elemento = 1 THEN 1 ELSE 0 END) tpo_per, --tipo de persona
				SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper AND p_importe >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
				INTO iPart1,iPart2,iPart3,iPart4,iNumbol
				FROM bdinteg:"informix".si_participa
				WHERE cve_sorteo = cCvesorteo;
				
				--Si se cumple con el perfil comprobar que no sea empleado
				IF iPart1 = 1 AND iPart2 = 1 AND iPart3 = 1 AND iPart4 = 1 AND iNumbol = 1 THEN
					IF(SELECT count(producto) FROM bdicheq:"informix".sc_maechq 
					WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001') > 0 THEN
						--'ES EMPLEADO';
					ELSE
						--Obtener el boleto 
						BEGIN WORK;
							SELECT  {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo_cve)} max_boleto, boleto_ini, boleto_fin INTO cFolio, iNumbol, iNumBolFin
							FROM bdinteg:"informix".si_sorteo 
							WHERE cve_sorteo = cCvesorteo;
							
							--Si aun no se ha registrado ningun boleto se asigna el primer boleto
							IF cFolio = '' OR cFolio IS NULL OR cFolio = '0' THEN
								LET cFolio = iNumbol - 1;
								UPDATE {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)} bdinteg:"informix".si_sorteo
								SET max_boleto = cFolio
								WHERE cve_sorteo = cCvesorteo;
							END IF;
							
							--Si el boleto actual es menor al boleto maximo
							IF cFolio <= iNumBolFin THEN
								UPDATE {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo)} bdinteg:"informix".si_sorteo
								SET max_boleto = max_boleto + 1
								WHERE cve_sorteo = cCvesorteo;
								
								SELECT {+INDEX (bdinteg:"informix".si_sorteo idx_si_sorteo_cve)} max_boleto INTO cFolio 
								FROM bdinteg:"informix".si_sorteo 
								WHERE cve_sorteo = cCvesorteo ;
							ELSE
								LET cTicket = 3;
							END IF;
							
						COMMIT WORK;
						
						IF cComienza = "S" THEN
							BEGIN WORK;
						END IF;
						
						IF cTicket = '' THEN
							--Selecciona y obtiene la informacion del folio
							SELECT {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} folio, folio_cupon, ticket, estatus 
							INTO cFolio, cFolio_cupon, cTicket, cStatus
							FROM bdinteg:"informix".si_premios_regreso2012
							WHERE folio = cFolio;
						END IF;
						
						IF cFolio_cupon IS NULL THEN
							LET cFolio_cupon = '';
						END IF;
						
						IF cTicket = '4' AND p_importe >= 651 AND cStatus = 1 THEN
						
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2'
							WHERE ticket = '4';
						ELIF cTicket = '4' AND p_importe >= 651 AND cStatus = 2 THEN
						
							LET cTicket = '2';
							
						ELIF cTicket = '4' AND (p_importe >= 650 AND p_importe < 651)	THEN
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2', foliosuc = p_foliosuc, f_asignado = p_fecha 
							WHERE ticket = '4' AND Folio = cFolio;
							LET cTicket = '2';
							LET cStatus = 2;
						END IF;
						
						IF cStatus = 1 THEN						
							UPDATE {+INDEX (bdinteg:"informix".si_premios_regreso2012 idx_premios_regreso2012)} bdinteg:"informix".si_premios_regreso2012 
							SET estatus = '2', sucursal = p_sucursal,numcte = p_numcte, foliosuc = p_foliosuc, 
							tipo_operacion = p_tpoper, importe = p_importe, f_asignado = p_fecha WHERE folio = cFolio;						
						END IF
					END IF;
				ELSE 
					--'NO CUMPLE CON PARAMETROS';
				END IF;
			END IF;
		END IF;
	ELSE
		--'NO ACTIVADO EL SORTEO INSTANTANEO';
	END IF;
	
	RETURN cCod_Ret, cFolio,cFolio_cupon,cTicket;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Josue Zepeda',
'FECHA: 06/07/2012',
'BD: bdinteg',
'Objetivo: Sorteo Regreso a clases 2012';

CREATE PROCEDURE "informix".sp_consadictecop_web(pEmpresa CHAR(3), pNumCteCop CHAR(20), pTipo CHAR(1))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13); -- RFC

	--Rodolfo Tortolero Varela
	--19/12/2008
	--Consulta la tabla si_cliente para consultar los datos por nÃÂºmero de cliente coppel

	--DEFINICION DE VARIABLES--
	DEFINE vCodRet		CHAR(5);
	DEFINE vNumCliente	CHAR(20);
	DEFINE vApePat		CHAR(26);
	DEFINE vApeMat		CHAR(26);
	DEFINE vNombre1		CHAR(26);
	DEFINE vNombre2		CHAR(26);
	DEFINE vRFC			CHAR(13);
	DEFINE vRFC_alterno CHAR(13);

	--INICIALIZACION DE VARIABLES--
	LET vCodRet		= "00000";
	LET vNumCliente = "";
	LET vApePat		= "";
	LET vApeMat		= "";
	LET vNombre1	= "";
	LET vNombre2	= "";
	LET vRFC		= "";
	LET vRFC_alterno = "";

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	SELECT
		numcte
	INTO
		vNumCliente
	FROM
		bdinteg:si_adiccoppel
	WHERE
		numctecoppel = pNumCteCop
	AND
		secuencia = 1;

    IF vNumCliente IS NOT NULL THEN
		IF pTipo = '1' THEN
			SELECT
				numcte, apell_paterno, apell_materno, nombre1, nombre2, rfc, rfc_alterno
			INTO
				vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno
			FROM
				bdinteg:si_cliente
			WHERE
				numcte = vNumCliente AND
				empresa = pEmpresa AND
				tpo_persona = "01";
			
			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;	

			RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
		END IF;

		IF pTipo = '2' THEN
			FOREACH
				SELECT
					numcte
				INTO
					vNumCliente
				FROM
					bdinteg:si_adiccoppel
				WHERE
					numctecoppel = pNumCteCop
				AND
					secuencia > 1

				SELECT
					a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.rfc_alterno
				INTO
					vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno
				FROM
					bdinteg:si_cliente a, bdinteg:si_adiccoppel b
				WHERE
					a.numcte = vNumCliente AND
					a.empresa = pEmpresa AND
					a.numcte = b.numcte AND
					a.tpo_persona = "01";

				IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
                   LET vRFC = vRFC_alterno;
                END IF;		
					
					RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC WITH RESUME;

			END FOREACH;
		END IF;
	ELSE
		LET vCodRet = '00001';
	END IF;

	IF vCodRet <> '00000' THEN
		RETURN vCodRet, vNumCliente, vApePat, vApeMat, vNombre1, vNombre2, vRFC;
	END IF;
--##############################################################################
--## Procedimiento   : sp_ConsAdiCteCop
--## Base de Datos   : bdinteg
--## Version         : 1.0
--## Creado por      : Rodolfo Tortolero
--## Fecha creacion  : Febrero de 2009
--##Descripcion :  Consulta el Titular y los Adicionales de Clientes Coppel
--##############################################################################
END PROCEDURE;