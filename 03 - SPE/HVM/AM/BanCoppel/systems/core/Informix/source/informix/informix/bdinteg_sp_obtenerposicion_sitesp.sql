CREATE PROCEDURE "informix".sp_obtenerposicion_sitesp(pCadena LVARCHAR(5000), pCaracter VARCHAR(30))
	RETURNING INTEGER, INTEGER;

	DEFINE iSqlErr      INTEGER;
	DEFINE iSalida      INTEGER;
	DEFINE iSalida2     INTEGER;
	DEFINE cCadenaAux   LVARCHAR(5000);
	DEFINE cComparaAux  LVARCHAR(5000);  
	DEFINE cCadenaFin   LVARCHAR(5000);  
	DEFINE i            INTEGER;
	define cComparacion LVARCHAR(5000);
	define cCaracter    LVARCHAR(5000);
	DEFINE iTotal       INTEGER;
	DEFINE cBan         CHAR(1);

	LET iSqlErr         = 0;
	LET iSalida         = 0;
	LET iSalida2        = 0;
	LET cCadenaAux      = "";
	LET cComparaAux     = "";  
	LET cCadenaFin      = "";  
	LET i               = 0;
	let cComparacion    = "";
	let cCaracter       = ""; 
	LET iTotal          = 0;
	LET cBan            = 'F';
	
	--SET DEBUG FILE TO '/tmp/sp_obtenerposicion_sitesp.out';
	--TRACE ON;

	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET iSalida = iSqlErr;
				RETURN iSalida,iSalida2;
			END IF;
		END EXCEPTION;

		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
		
		IF  NVL(pCadena,'') = '' THEN 
			LET iSalida = -1;
			LET iSalida2 = -1;
			RETURN iSalida, iSalida2;
		END IF;

		IF  NVL(pCaracter,'') = '' THEN 
			LET iSalida = -1;
			LET iSalida2 = -1;
			RETURN iSalida, iSalida2;
		END IF;

		LET cCadenaAux = pCadena;
		LET cComparaAux = pCaracter;  
		LET cCadenaFin = REPLACE(cCadenaAux,cComparaAux,'º');
		LET cComparacion = LENGTH(cCadenaFin);
		LET iTotal = LENGTH(cComparaAux);

		WHILE i < cComparacion
		   LET i = i + 1;
		   LET cCaracter = SUBSTR(cCadenaFin,i,1);
				IF cCaracter = 'º' THEN 
				   LET iSalida = i;
				   LET iSalida2 = (i + iTotal) - 1;
				   LET cBan = 'T';
					 RETURN iSalida, iSalida2  WITH RESUME;
				END IF;
		END WHILE;

		IF cBan = 'F' THEN
			LET iSalida = -1;
			LET iSalida2 = -1;
			RETURN iSalida, iSalida2  WITH RESUME;
		END IF;
	END
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea copia del procedimiento sp_obtenerposicion para que abarque mas la trama de entrada', 
'AUTOR : Carolina E. Verdugo GastÃ¨lum',
'FECHA : 20/08/2015',                                                  		
'BD : 	bdinteg';

CREATE PROCEDURE "informix".sp_carga_clientes_para_fusion_automatica(iPuntaje_similitud INTEGER, iMax_Transaccion INTEGER)
RETURNING CHAR(5), CHAR(100);

	--DEFINICION DE VARIABLES--
DEFINE iSql_err 			INTEGER;
DEFINE iISam_err 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cMensaje 			CHAR(100);
DEFINE MAX_COMMIT			INTEGER;
DEFINE iEnTransaccion		INTEGER;
DEFINE iContador			INTEGER;
DEFINE iId_Comp				INTEGER;
DEFINE cNumcte				CHAR(20);
DEFINE cCodPostal			CHAR(5);
DEFINE cApell_paterno		CHAR(26);
DEFINE cApell_materno		CHAR(26);

DEFINE smProductos_Activos_1, smProductos_Activos_2, smDestino SMALLINT;
DEFINE cTipo_Cliente_1, cTipo_Cliente_2, cSexo_1, cSexo_2	CHAR(1);
DEFINE cNumcte_1, cNumcte_2, cNumcte_Correcto, cNumcte_Incorrecto	CHAR(20);
DEFINE cRfc_1, cRfc_2		CHAR(13);
DEFINE cRfc_alterno_1, cRfc_alterno_2 CHAR(13);
DEFINE dFecha_1, dFecha_2	DATE;

--SET DEBUG FILE TO "/tmp/josea/64165/sp_carga_clientes_para_fusion_automatica.trace";
--TRACE ON;

	--INICIALIZACION DE VARIABLES--
LET iSql_err 				= 0;
LET iISam_err				= 0;
LET iContador				= 0;
LET cCodRet 				= '00000';
LET cMensaje				= 'EJECUCION CORRECTA';
LET MAX_COMMIT				= iMax_Transaccion;
LET iEnTransaccion			= 0;
LET smDestino				= 0;
LET smProductos_Activos_1	= 0;
LET smProductos_Activos_1	= 0;
LET cTipo_Cliente_1			= '';
LET cTipo_Cliente_2			= '';
LET cNumcte_1				= '';
LET cNumcte_2				= '';

BEGIN
	ON EXCEPTION SET iSql_err, iISam_err, cMensaje
		IF iEnTransaccion = 1 THEN
			ROLLBACK WORK;
		END IF;
		LET cCodRet = iSql_err;
		RETURN  cCodRet, cMensaje;		
	END EXCEPTION;

    ON EXCEPTION IN (-535)	
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	--BEGIN WORK;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
	--FOREACH Cursor_CTES WITH HOLD FOR	
	FOREACH WITH HOLD
		SELECT {+INDEX (bdinteg:"informix".si_bitctedup  idx_si_bitctedup_04)} id_comp, numcte_uno, tipo_cliente_uno, (ctas_cap_uno + creditos_uno + inversiones_uno + solicitudes_act_uno),
																				numcte_dos, tipo_cliente_dos, (ctas_cap_dos + creditos_dos + inversiones_dos + solicitudes_act_dos)
		INTO iId_Comp, cNumcte_1, cTipo_Cliente_1, smProductos_Activos_1, cNumcte_2, cTipo_Cliente_2, smProductos_Activos_2		
		FROM si_bitctedup
		WHERE procesado = 't'
		AND resultadofin = iPuntaje_similitud
		AND cargado = '0'
		
		IF iEnTransaccion = 0 THEN
			BEGIN WORK;
			LET iEnTransaccion = 1;
		END IF;
		
		LET iContador = iContador + 1;
		IF EXISTS (SELECT 1 FROM si_cliente WHERE numcte = cNumcte_1) THEN
			IF EXISTS (SELECT 1 FROM si_cliente WHERE numcte = cNumcte_2) THEN
				SELECT NVL (tipo_cliente, '0')
				INTO cTipo_Cliente_1
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = cNumcte_1;

				SELECT NVL (sexo,'')
				INTO cSexo_1
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = cNumcte_1;
				
				SELECT NVL (tipo_cliente, '0')
				INTO cTipo_Cliente_2
				FROM bdinteg:"informix".si_cliente 
				WHERE numcte = cNumcte_2;

				SELECT NVL (sexo,'')
				INTO cSexo_2
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = cNumcte_2;
				
				IF cSexo_1 <> cSexo_2 THEN
					LET smDestino = 2;
					LET cNumcte_Correcto = cNumcte_1;
					LET cNumcte_Incorrecto = cNumcte_2;		
				ELIF cTipo_Cliente_1 = '1' AND cTipo_Cliente_2 = '1' THEN
					LET smDestino = 2;
					LET cNumcte_Correcto = cNumcte_1;
					LET cNumcte_Incorrecto = cNumcte_2;
				ELIF cTipo_Cliente_1 = '1' AND cTipo_Cliente_2 = '2' THEN
					LET smDestino = 1;
					LET cNumcte_Correcto = cNumcte_1;
					LET cNumcte_Incorrecto = cNumcte_2;
				ELIF cTipo_Cliente_1 = '2' AND cTipo_Cliente_2 = '1' THEN
					LET smDestino = 1;
					LET cNumcte_Correcto = cNumcte_2;
					LET cNumcte_Incorrecto = cNumcte_1;
				ELIF cTipo_Cliente_1 = '2' AND cTipo_Cliente_2 = '2' THEN
					IF (smProductos_Activos_1 = 0 AND smProductos_Activos_2 = 0) OR (smProductos_Activos_1 > 0 AND smProductos_Activos_2 > 0) THEN
						SELECT fecha_insert 
						INTO dFecha_1 
						FROM si_cliente WHERE numcte = cNumcte_1;
						
						SELECT fecha_insert 
						INTO dFecha_2 
						FROM si_cliente WHERE numcte = cNumcte_2;
						
						IF dFecha_1 > dFecha_2 THEN
							LET smDestino = 1;
							LET cNumcte_Correcto = cNumcte_1;
							LET cNumcte_Incorrecto = cNumcte_2;
						ELIF dFecha_1 < dFecha_2 THEN
							LET smDestino = 1;
							LET cNumcte_Correcto = cNumcte_2;
							LET cNumcte_Incorrecto = cNumcte_1;
						ELIF dFecha_1 = dFecha_2 THEN
							IF cNumcte_1::INTEGER > cNumcte_2::INTEGER THEN
								LET smDestino = 1;
								LET cNumcte_Correcto = cNumcte_1;
								LET cNumcte_Incorrecto = cNumcte_2;
							ELSE
								LET smDestino = 1;
								LET cNumcte_Correcto = cNumcte_2;
								LET cNumcte_Incorrecto = cNumcte_1;					
							END IF;
						END IF;				
						--Validar fecha de alta
					ELIF smProductos_Activos_1 > 0 AND smProductos_Activos_2 = 0 THEN
						LET smDestino = 1;
						LET cNumcte_Correcto = cNumcte_1;
						LET cNumcte_Incorrecto = cNumcte_2;
					ELIF smProductos_Activos_1 = 0 AND smProductos_Activos_2 > 0 THEN
						LET smDestino = 1;
						LET cNumcte_Correcto = cNumcte_2;
						LET cNumcte_Incorrecto = cNumcte_1;
					END IF;
				END IF;
				
				IF smDestino = 1 THEN --INSERTAR en tabla de fusion automatica
					IF NOT EXISTS (SELECT 1 FROM bdinteg:si_fusionaut WHERE cliente_tit = cNumcte_1 AND cliente_tras = cNumcte_2) THEN
						IF NOT EXISTS (SELECT 1 FROM bdinteg:si_fusionaut WHERE cliente_tit = cNumcte_2 AND cliente_tras = cNumcte_1) THEN						
							INSERT INTO informix.si_fusionaut(cliente_tit, cliente_tras, canal, fecha_insert, estatus, cod_retorno, proceso, fecha_fusion, fecha_proceso) 
							VALUES(cNumcte_Correcto, cNumcte_Incorrecto, '1', CURRENT::DATE, 0, '', '', '', '');
							
							UPDATE bdinteg:si_bitctedup SET cargado = '1'
							WHERE id_comp = iId_Comp;
						ELSE
							UPDATE bdinteg:si_bitctedup SET cargado = '4'
							WHERE id_comp = iId_Comp;
						END IF;
					ELSE --Cargado previamente
						UPDATE bdinteg:si_bitctedup SET cargado = '4'
						WHERE id_comp = iId_Comp;
					END IF;
					LET smDestino = 0;
				ELIF smDestino = 2 THEN --INSERTAR en tabla de fusion SOC
					IF NOT EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_tr_clientesduplicados WHERE numcte_1 = cNumcte_1 AND numcte_2 = cNumcte_2) THEN
						IF NOT EXISTS (SELECT 1 FROM bdicnweb:"informix".sw_tr_clientesduplicados WHERE numcte_1 = cNumcte_2 AND numcte_2 = cNumcte_1) THEN
							SELECT rfc, rfc_alterno 
							INTO cRfc_1, cRfc_alterno_1 
							FROM bdinteg:si_cliente WHERE numcte = cNumcte_Correcto;
							
							SELECT rfc, rfc_alterno 
							INTO cRfc_2, cRfc_alterno_2 
							FROM bdinteg:si_cliente WHERE numcte = cNumcte_Incorrecto;
							
							INSERT INTO bdicnweb:"informix".sw_tr_clientesduplicados(numcte_1, numcte_2, rfc_1, rfc_2, cte_correcto, flag_fusion, causa_no_fus, estatus_asig, user_asig, fecha_dict, canal, user_insert, fecha_insert)															
							VALUES (cNumcte_Correcto, cNumcte_Incorrecto, DECODE(NVL(cRfc_alterno_1,''),'',cRfc_1,cRfc_alterno_1), DECODE(NVL(cRfc_alterno_2,''),'',cRfc_2,cRfc_alterno_2), '', '0', '', '', '', '', '4', 'infoaut', CURRENT);
							
							UPDATE bdinteg:si_bitctedup SET cargado = '1'
							WHERE id_comp = iId_Comp;
						ELSE --Cargado previamente
							UPDATE bdinteg:si_bitctedup SET cargado = '4'
							WHERE id_comp = iId_Comp;
						END IF;
					ELSE --Cargado previamente
						UPDATE bdinteg:si_bitctedup SET cargado = '4'
						WHERE id_comp = iId_Comp;
					END IF;
					LET smDestino = 0;
				END IF;
			ELSE --Cliente no existe		 
				UPDATE bdinteg:si_bitctedup SET cargado = '3'
				WHERE id_comp = iId_Comp;					
			END IF;
		ELSE --Cliente no existe
			UPDATE bdinteg:si_bitctedup SET cargado = '3'
			WHERE id_comp = iId_Comp;		
		END IF;
		IF iContador >= MAX_COMMIT THEN
			IF iEnTransaccion = 1 THEN
				COMMIT WORK;
				LET iEnTransaccion = 0;
				LET iContador = 0;
			END IF;
		END IF;					
	END FOREACH;	

	IF iContador > 0 THEN
		IF iEnTransaccion = 1 THEN
			COMMIT WORK;
			LET iEnTransaccion = 0;
			LET iContador = 0;
		END IF;
	END IF;	
	
	RETURN cCodRet, cMensaje;
END
END PROCEDURE;