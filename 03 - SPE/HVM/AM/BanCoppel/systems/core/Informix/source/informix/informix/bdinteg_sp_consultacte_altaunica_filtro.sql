CREATE PROCEDURE "informix".sp_consultacte_altaunica_filtro(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cCodRet2  CHAR(5);
DEFINE cPrimerNombre  CHAR(26);
DEFINE cSegundoNombre CHAR(26);
DEFINE cApellidoPaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE dFechaNacimiento DATE;
DEFINE cRfc CHAR(13);
DEFINE cClienteCoppel CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE cNumCte CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cCodret2 = "00000";
LET cPrimerNombre = "";
LET cSegundoNombre ="";
LET cApellidoPaterno ="";
LET cApellidoMaterno ="";
LET dFechaNacimiento ="";
LET cRfc ="";
LET cClienteCoppel ="";
LET iSqlErr = 0;
LET cNumCte ="";
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica_filtro.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,cClienteCoppel,cNumcte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pNumero,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicheq:"informix".sc_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT num_cte
					INTO cNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					UNION
					SELECT num_cte
					FROM bdinvers:"informix".sv_maeinv
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
				END FOREACH;
			ELIF TRIM(NVL(pOpcion,''))='3' THEN
				LET cNumCte=pNumero;
			ELIF TRIM(NVL(pOpcion,''))='4' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicred:"informix".sd_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			END IF
			
			SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
			INTO cApellidoPaterno, cApellidoMaterno, cPrimerNombre, cSegundoNombre, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte=TRIM(NVL(cNumcte,''))
			AND empresa=TRIM(NVL(pEmpresa,''));
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
				LET cPrimerNombre='';
				LET cSegundoNombre='';
				LET cApellidoPaterno='';
				LET cApellidoMaterno='';
				LET dFechaNacimiento='';
				LET cRfc='';
				LET cClienteCoppel='';
			ELSE
				SELECT fecha_nac
				INTO dFechaNacimiento
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte= TRIM(NVL(cNumcte,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados_filtro (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"Descripción: Consulta datos generales del cliente",
"Autor : Leslie Rendón",
"FECHA : 24/10/2014",
"Descripción: Se modifica para agregar consulta por Tarjeta de crédito",
"Modifico : Leslie Rendón",
"FECHA : 16/12/2014",
"BD    : bdinteg",
'Clon de sp sp_consultacte_altaunica, que deja en blanco el cliente coppel si empieza con 9 y es de 11 digitos',
'Autor :Obed Vega',
'FECHA : 01/Julio/2016',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_replica_indicadores_kiosko(dFecha DATE, cSucursal CHAR(4), iCons_movtos INTEGER, iCons_saldos INTEGER, iCons_edocta INTEGER)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE cCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE cEvento 			CHAR(100);
DEFINE bEnTransaccion   BOOLEAN;
DEFINE iNomErr			INTEGER;
DEFINE iIsamErr			INTEGER;


--ASIGNACION DE VARIABLES
LET cCodRet = '000000';
LET cEvento = '';
LET cMensCodRet = 'EL PROCESO DE REPLICA EXITOSO';
LET bEnTransaccion = 'f';

--SET DEBUG FILE TO "/tmp/josea/64170/sp_replica_indicadores_kiosko.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET iNomErr, iIsamErr, cMensCodRet
		IF iNomErr <> 0 THEN
			LET cCodRet=iNomErr;
			IF bEnTransaccion = 't' THEN	
				ROLLBACK;
			END IF;
			
			INSERT INTO informix.si_log_indicadores_sucursal(fecha, proceso, evento, cod_error, mensaje, fecha_insert) 
			VALUES(dFecha, 'REPLICA INDICADORES KIOSKO', cEvento, cCodRet, cMensCodRet, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
			
			LET cEvento = 'RETORNO DE RESULTADOS EXCEPCION';
			RETURN cCodRet, cMensCodRet;
		END IF;
	END EXCEPTION;	
	
	LET cEvento = 'VALIDACION DE BANDERA DE TRANSACCION 1';
	IF bEnTransaccion = 'f' THEN
		BEGIN WORK;
		LET bEnTransaccion = 't';
	END IF;
	
	LET cEvento = 'VALIDACION DE PARAMETROS';
	
	IF NVL(dFecha,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensCodRet = 'FECHA PROCESO INVALIDA';
	ELIF NVL(cSucursal,'') = '' THEN
		LET cCodRet = '000002';
		LET cMensCodRet = 'SUCURSAL INVALIDA';
	ELIF iCons_movtos IS NULL OR iCons_saldos IS NULL OR iCons_edocta IS NULL THEN
		LET cCodRet = '000003';
		LET cMensCodRet = 'CIFRAS RECIBIDAS INVALIDAS';
	ELSE
		LET cEvento = 'VALIDACION DE REGISTRO PREVIO';
		IF EXISTS (SELECT 1 FROM si_indicadores_kiosko WHERE fecha_proceso = dFecha AND sucursal = TRIM(cSucursal)) THEN
			LET cEvento = 'ACTUALIZACION DE REGISTRO';
			
			UPDATE si_indicadores_kiosko SET cons_movimientos = iCons_movtos, cons_saldos = iCons_saldos, cons_edocta = iCons_edocta
			WHERE fecha_proceso = dFecha AND sucursal = TRIM(cSucursal);
		ELSE
			LET cEvento = 'INSERCION DE REGISTRO';
			
			INSERT INTO si_indicadores_kiosko (fecha_proceso, sucursal, cons_movimientos, cons_saldos, cons_edocta)
			VALUES (dFecha, cSucursal, iCons_movtos, iCons_saldos, iCons_edocta);
		END IF;
	END IF;
	
	LET cEvento = 'VALIDACION DE BANDERA DE TRANSACCION 2';
	IF bEnTransaccion = 't' THEN
		COMMIT WORK;
		LET bEnTransaccion = 'f';
	END IF;
	
	LET cEvento = 'RETORNO DE RESULTADOS PRINCIPAL';
	RETURN cCodRet, cMensCodRet;
END;
END PROCEDURE	
DOCUMENT
'FECHA:29/06/2016',
'DESCRIPCION: SP utilizado por el replicador de indicadores de kiosko para insertar la informaciÃ³n extraida del server de postgresql';

CREATE PROCEDURE "informix".sp_actualiza_folio()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE sFolio     CHAR(15);
DEFINE sFolio2     CHAR(15);
DEFINE iConteo	  INT;
DEFINE iFolio2     INT8;
DEFINE cFecha     CHAR(10);
DEFINE iId		     INT8;

LET sFolio        = '';
LET iFolio2        =0;
LET iConteo			=0;
LET iFolio2			=0;
LET cFecha        = '';
LET iId				=0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,iId;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT folio,count(*),fecha_insert INTO sFolio,iConteo,cFecha FROM "informix".si_solicitud_movil
		WHERE status_valua IS NOT NULL
		GROUP BY folio,fecha_insert
		HAVING count(*)>1

		SELECT max(folio),max(folio)::INT8+1 INTO sFolio2,iFolio2 FROM "informix".si_solicitud_movil
		WHERE fecha_insert=cFecha;

		SELECT max(id) INTO iId FROM "informix".si_solicitud_movil WHERE folio=sFolio;

		UPDATE "informix".si_solicitud_movil set folio=iFolio2 WHERE id=iId;


	END FOREACH;


	RETURN cCodRet,iId;
END
END PROCEDURE;