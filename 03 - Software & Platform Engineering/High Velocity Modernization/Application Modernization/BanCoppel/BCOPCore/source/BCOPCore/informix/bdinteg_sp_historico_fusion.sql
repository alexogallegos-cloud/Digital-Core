CREATE PROCEDURE "informix".sp_historico_fusion(pDia CHAR(2), pMes CHAR(2), pAnio CHAR(4), pDiaHasta CHAR(2), pMesHasta CHAR(2), pAnioHasta CHAR(4), pOpcion CHAR(1), pUsuarioAnalista CHAR(8))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 						AS cCodRet,						
	CHAR(20) 						AS Numero_del_cliente_titular,
	CHAR (110) 						AS Nombre_completo_del_cliente_titular,
	CHAR(10) 						AS Fecha_de_nacimiento_del_cliente_titular,
	CHAR(20) 						AS Numero_del_cliente_traspasado,
	CHAR (110) 						AS Nombre_completo_del_cliente_traspasado,
	CHAR(10) 						AS Fecha_de_nacimiento_del_cliente_traspasado,
	CHAR(20) 						AS Numero_de_cuenta_del_cliente_traspasado,
	CHAR(4) 						AS Producto,
	CHAR(20) 						AS Numero_de_Cliente,
	CHAR(2) 						AS Estatus,
	MONEY(16,2) 					AS Saldo,
	CHAR(40) 						AS Descripcion,
	CHAR(10) 						AS Fecha_de_Alta,
	INTEGER 							AS Numero_de_direcciones_fusionadas,
	DATETIME YEAR TO SECOND 		AS Fecha_de_Fusion,
	DATETIME HOUR TO FRACTION(3) 	AS Hora_de_Fusion,
	CHAR(10) 						AS Status_Cuenta,
	CHAR(45) 						AS Nombre_de_Analista;
	
	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cNumCteTit 		CHAR(20);
	DEFINE cNumCteTrasp 	CHAR(20);
	DEFINE cApePaterTit 	CHAR(26);
	DEFINE cApeMaterTit 	CHAR(26);
	DEFINE cNom1Tit 		CHAR(26);
	DEFINE cNom2Tit 		CHAR(26);
	DEFINE cFechaNacTit 	CHAR(10);
	DEFINE cApePaterTrasp	CHAR(26);
	DEFINE cApeMaterTrasp	CHAR(26);
	DEFINE cNom1Trasp 		CHAR(26);
	DEFINE cNom2Trasp 		CHAR(26);
	DEFINE cFechaNacTrasp 	CHAR(10);
	DEFINE cNomCompTitular 	CHAR (110);
	DEFINE cNomCompTransp 	CHAR (110);
	
	DEFINE cCta 			CHAR(20);
	DEFINE cProducto 		CHAR(4);
	DEFINE cNumCte 			CHAR(20);
	DEFINE cStatus 			CHAR(2);
	DEFINE vSaldo 			MONEY(16,2);
	DEFINE cDescripcion 	CHAR(40);
	DEFINE cFechaAlta 		CHAR(10);
	DEFINE iDirecciones 	CHAR(5);
	--DEFINE dHoraFecha       DATETIME YEAR TO FRACTION(3);
DEFINE dHoraFecha       DATE ;
	DEFINE cNumCteTrasp2	CHAR(20);
    DEFINE iBandera         SMALLINT;
    DEFINE iBandera1        SMALLINT;
    DEFINE iBandera2        SMALLINT;
    DEFINE iBandera3        SMALLINT;
	DEFINE Iconsecutivo     INTEGER;
	DEFINE iConteo			INTEGER;	
	DEFINE cTitular 		CHAR(20);
	DEFINE cTraspasar 	    CHAR(20);
	DEFINE iExiste			INTEGER;
	DEFINE dHora  			DATETIME HOUR TO FRACTION(3);
	DEFINE cUnidadp 	    CHAR(20);
	DEFINE cStatusCuenta    CHAR(10);
	DEFINE cExiste          CHAR(1);
	DEFINE cUser_insert     CHAR(10);
	DEFINE cNombreAnalista  CHAR(45);
	DEFINE dValidaFecha		DATE;					--DSB20130911
	DEFINE cValidaNumCte	CHAR(20);				--DSB20130911
	DEFINE iNumRows			INTEGER;				--DSB20130911
	DEFINE cUsuParam		CHAR(8);
	
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 		= 0;
	LET cCodRet 		= '00000';
	LET cNumCteTit 		= '';
	LET cNumCteTrasp 	= '';
	LET cApePaterTit 	= '';
	LET cApeMaterTit 	= '';
	LET cNom1Tit 		= '';
	LET cNom2Tit 		= '';
	LET cFechaNacTit 	= '';
	LET cApePaterTrasp 	= '';
	LET cApeMaterTrasp 	= '';
	LET cNom1Trasp 		= '';
	LET cNom2Trasp 		= '';
	LET cFechaNacTrasp 	= '';
	LET cNomCompTitular = '';
	LET cNomCompTransp 	= '';
		
	LET cCta 			= '';
	LET cProducto 		= '';
	LET cNumCte 		= '';
	LET cStatus 		= '';
	LET vSaldo 			= 0;
	LET cDescripcion 	= '';
	LET cFechaAlta 		= '';
	LET iDirecciones 	= '';
	LET dHoraFecha 		= '';
	LET cNumCteTrasp2 	= '';
    LET iBandera		= 0;
    LET iBandera1		= 0;
    LET iBandera2		= 0;
    LET iBandera3		= 0;
	LET Iconsecutivo	= 0;
	LET iConteo			= 0;
	LET cTitular		= '';
	LET cTraspasar		= '';
	LET iExiste			= 0;
	LET dHora 			= '';
	LET cUnidadp 		= '';
	LET cStatusCuenta 	= '';
	LET cExiste 		= '0';
	LET cUser_insert 	= '';
	LET cNombreAnalista = '';
	LET dValidaFecha 	= '';							
	LET cValidaNumCte	= '';							
	LET iNumRows		= 0;	
	LET cUsuParam		= '';
	
	--SET DEBUG FILE TO '/informix/VH/decli/sp_historico_fusion.out';
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp, cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
			END IF;	
		END EXCEPTION;

		TRUNCATE TABLE bdinteg:"informix".si_fusreporte;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT valor 
		INTO cUsuParam
		FROM bdinteg:"informix".si_param 
		WHERE empresa = '001'
		AND cod_param ='184';
		
		IF pOpcion = 1 THEN																			
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha
			FROM bdinteg:"informix".log_fusionclientes
			WHERE fecha_insert = MDY(pMes,pDia,pAnio) 
			AND user_insert = CASE WHEN pUsuarioAnalista <> ''
			THEN pUsuarioAnalista ELSE user_insert END AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
			LET iNumRows = dbinfo("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																	
				LET cExiste = "1";

				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
					INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert = MDY(pMes,pDia,pAnio)
					AND user_insert = CASE WHEN pUsuarioAnalista <> ''
					THEN pUsuarioAnalista ELSE user_insert END AND user_insert <> cUsuParam AND user_insert <> 'infdesf' --DSB 24112013
					ORDER BY fecha_insert,fecha_hora

					IF iConteo=0 THEN
						LET cTitular= TRIM(cNumCteTit);
						LET cTraspasar= TRIM(cNumCteTrasp);
						LET Iconsecutivo= Iconsecutivo + 1;
						SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
						IF iExiste=0 THEN
							INSERT INTO bdinteg:"informix".si_fusreporte (cliente_tit,cliente_tras ,id_rep,fecha_hora,fecha_insert) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo,dHora,dHoraFecha);
						END IF;
					ELSE
						IF TRIM(cTitular)=TRIM(cNumCteTit) AND TRIM(cTraspasar)=TRIM(cNumCteTrasp) THEN
						
						ELSE
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporte (cliente_tit,cliente_tras ,id_rep,fecha_hora,fecha_insert) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo,dHora,dHoraFecha);
							END IF;
							LET cTitular= cNumCteTit;
							LET cTraspasar= cNumCteTrasp;
						END IF;	
					END IF;
					LET iConteo= iConteo + 1;
				END FOREACH;
			END IF;
		ELSE
			--LET cExiste = "4";
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha	--DSB20130911{
			FROM bdinteg:"informix".log_fusionclientes
			WHERE fecha_insert >= MDY(pMes,pDia,pAnio) AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta) AND user_insert = CASE WHEN pUsuarioAnalista <> ''
			THEN pUsuarioAnalista ELSE user_insert END AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
			LET iNumRows = dbinfo("sqlca.sqlerrd2");
			--LET cExiste = "5";
			IF(iNumRows > 0) THEN									
				LET cExiste = "1";																						--DSB20130911
			
				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
					INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert >= MDY(pMes,pDia,pAnio)
					AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta)
					AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END AND user_insert <> cUsuParam AND user_insert <> 'infdesf'  --DSB 24112013
					ORDER BY fecha_insert,fecha_hora

					IF iConteo=0 THEN
						LET cTitular= trim(cNumCteTit);
						LET cTraspasar= trim(cNumCteTrasp);
						LET Iconsecutivo= Iconsecutivo + 1;
						SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
						IF iExiste=0 THEN
							INSERT INTO bdinteg:"informix".si_fusreporte (cliente_tit,cliente_tras ,id_rep,fecha_hora,fecha_insert) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo,dHora,dHoraFecha);
						END IF;
					ELSE
						IF TRIM(cTitular)=TRIM(cNumCteTit) AND TRIM(cTraspasar)=TRIM(cNumCteTrasp) THEN
						
						ELSE
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte WHERE cliente_tit= cNumCteTit AND cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporte (cliente_tit,cliente_tras ,id_rep,fecha_hora,fecha_insert) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo,dHora,dHoraFecha);
							END IF;
							LET cTitular= cNumCteTit;
							LET cTraspasar= cNumCteTrasp;
						END IF;	
					END IF;
					LET iConteo= iConteo + 1;
				END FOREACH;
			END IF;
		END IF;


		IF cExiste = "1" THEN
			FOREACH
			
				SELECT {+INDEX (bdinteg:"informix".si_fusreporte idx_fusreporte)} cliente_tit, cliente_tras,id_rep,fecha_hora,fecha_insert
				INTO cNumCteTit, cNumCteTrasp, Iconsecutivo,dHora,dHoraFecha
				FROM bdinteg:"informix".si_fusreporte
				ORDER BY fecha_insert,fecha_hora

				/*SELECT {+INDEX (bdinteg:"informix".si_fusreporte idx_fusreporte)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),id_rep
				INTO cNumCteTit, cNumCteTrasp, Iconsecutivo
				FROM bdinteg:"informix".si_fusreporte
				ORDER BY id_rep*/

				--SELECT MIN(fecha_hora) INTO dHoraFecha FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
				
				SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHora GROUP BY user_insert;
				SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;

				IF cNumCteTrasp <> cNumCteTrasp2 THEN
				
					SELECT LIMIT 1 nomctetit.apell_paterno, nomctetit.apell_materno, nomctetit.nombre1, nomctetit.nombre2, fecnactit.fecha_nac
					INTO cApePaterTit, cApeMaterTit, cNom1Tit, cNom2Tit, cFechaNacTit 
					FROM bdinteg:"informix".si_cliente nomctetit,
						 bdinteg:"informix".si_ctepf fecnactit
					WHERE nomctetit.numcte = cNumCteTit
					AND fecnactit.numcte = cNumCteTit;
					   
					SELECT LIMIT 1 nomctetras.apell_paterno, nomctetras.apell_materno, nomctetras.nombre1, 
						   nomctetras.nombre2, fecnactras.fecha_nac
					INTO cApePaterTrasp, cApeMaterTrasp, cNom1Trasp, cNom2Trasp, cFechaNacTrasp
					FROM bdinteg:"informix".si_fuscliente nomctetras,
						 bdinteg:"informix".si_fusctepf fecnactras
					WHERE nomctetras.numcte = cNumCteTrasp
					AND fecnactras.numcte = cNumCteTrasp;

					--trace cNumCteTit;
					--trace cNumCteTrasp;

					--SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
					--LET dHora=dHoraFecha;
					LET cNomCompTitular = TRIM(cNom1Tit)||" "||TRIM(cNom2Tit)||" "||TRIM(cApePaterTit)||" "||TRIM(cApeMaterTit);
					LET cNomCompTransp = TRIM(cNom1Trasp)||" "||TRIM(cNom2Trasp)||" "||TRIM(cApePaterTrasp)||" "||TRIM(cApeMaterTrasp);
					
					LET iDirecciones = '0';
                    LET iBandera1=0;
                    LET iBandera2=0;
                    LET iBandera3=0;
                    LET iBandera=0;
					LET cValidaNumCte = '';																					--DSB20130911{
					SELECT FIRST 1 numcte INTO cValidaNumCte 
					FROM bdinteg:"informix".si_fusdirecciones 
					WHERE numcte = cNumCteTrasp;
					LET iNumRows = dbinfo("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN																					--DSB20130911}
						SELECT NVL(COUNT(numcte),0)
						INTO iDirecciones
						FROM bdinteg:"informix".si_fusdirecciones
						WHERE numcte = cNumCteTrasp;
					END IF;

					FOREACH

						SELECT TRIM(cuenta), TRIM(producto), TRIM(num_cte), TRIM(status_cta), sdo_actual
						INTO cCta, cProducto, cNumCte, cStatus, vSaldo
						FROM bdinteg:"informix".si_fusmaechq
						WHERE num_cte = cNumCteTrasp
						AND status_cta IN (1,3)

						IF cStatus = "3" THEN
							LET cStatusCuenta = "Bloqueada";
						ELSE
							LET cStatusCuenta = "Activa";
						END IF

						SELECT LIMIT 1 TRIM(prod.nombre), fecalta.fecha_alta
						INTO cDescripcion, cFechaAlta
						FROM bdicheq:"informix".sc_producto prod,
							 bdicheq:"informix".sc_maenoc fecalta
						WHERE prod.producto = cProducto
						AND fecalta.cuenta = cCta;

						--SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;

						SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHora GROUP BY user_insert;
						SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;

						LET iBandera=1;
						LET iBandera1=iBandera1 + 1;
						IF iBandera1>1 THEN
							LET iDirecciones='';
						END IF;

						--IF NVL(cCta, '') <> '' THEN																							--DSB20130809
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
								   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						--END IF;

					END FOREACH;
					FOREACH

						SELECT TRIM(num_credito), TRIM(num_producto), TRIM(numcte), TRIM(status_cred), 0, id_unidad_prod
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo, cUnidadp
							FROM bdinteg:"informix".si_fusmaecred
							WHERE numcte = cNumCteTrasp

							IF cUnidadp > 0 OR cUnidadp IS NOT NULL THEN
								LET cStatusCuenta = "Bloqueada";
							ELSE
								LET cStatusCuenta = "Activa";
							END IF

						IF LENGTH(cProducto)=3 THEN
							SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
							INTO cDescripcion, cFechaAlta
							FROM bdicred:"informix".sd_definicion prod,
								 bdinteg:"informix".si_fusmaecred fecalta
							WHERE prod.num_producto = '6'||cProducto
							AND fecalta.num_credito = cCta;
						ELSE
							SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
							INTO cDescripcion, cFechaAlta
							FROM bdicred:"informix".sd_definicion prod,
								 bdinteg:"informix".si_fusmaecred fecalta
							WHERE prod.num_producto = cProducto
							AND fecalta.num_credito = cCta;
						END IF;

						--SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;

						SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHora GROUP BY user_insert;
						SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;

						LET iBandera=1;
						LET iBandera2=iBandera2 + 1;
						IF iBandera2>1 THEN
							LET iDirecciones='';
						END IF;

						--IF NVL(cCta, '') <> '' THEN																							--DSB20130809
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
								   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						--END IF;

					END FOREACH;
					FOREACH
					   SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcte)} TRIM(num_credito), TRIM(num_producto), TRIM(numcte), TRIM(status_cred), 0
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo
							FROM bdinteg:"informix".si_fusmaecredcrd
							WHERE numcte = cNumCteTrasp

						IF LENGTH(cProducto)=3 THEN
							SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcrd)} LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
							INTO cDescripcion, cFechaAlta
							FROM bdicred:"informix".sd_definicion prod,
								 bdinteg:"informix".si_fusmaecredcrd fecalta
							WHERE prod.num_producto = '6'||cProducto
							AND fecalta.num_credito = cCta;
						ELSE
							SELECT {+INDEX (bdinteg:"informix".si_fusmaecredcrd pk_maecdtcrd)} LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
							INTO cDescripcion, cFechaAlta
							FROM bdicred:"informix".sd_definicion prod,
								 bdinteg:"informix".si_fusmaecredcrd fecalta
							WHERE prod.num_producto = cProducto
							AND fecalta.num_credito = cCta;
						END IF; 

						--SELECT MIN(fecha_hora::DATETIME HOUR TO SECOND) INTO dHora FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;

						SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHora GROUP BY user_insert;
						SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;

						LET iBandera=1;
						LET iBandera3=iBandera3 + 1;
						IF iBandera3>1 THEN
							LET iDirecciones='';
						END IF;

						--IF NVL(cCta, '') <> '' THEN																							--DSB20130809
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
								   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						--END IF;

                    END FOREACH;						   
                    IF iBandera=0 THEN
						LET cCta = "";
						LET cProducto = "";
						LET cNumCte = "";
						LET cStatus = "";
						LET vSaldo = "";
						LET cDescripcion = "";
						--LET dHora = "";
						LET cStatusCuenta = "";
						LET iDirecciones = "";
						
						--IF NVL(cCta, '') <> '' THEN																							--DSB20130809
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
							   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						--END IF;
                    END IF;
--					END IF;
				END IF;	
				LET cNumCteTrasp2 = cNumCteTrasp;
			END FOREACH;
		ELSE
			LET cCodRet = '00001'; -- No existe registro de ctes fusionados para la fecha proporcionada
			
			RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
				   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
		END IF;
	END
	
END PROCEDURE
DOCUMENT
'Consulta el historico de clientes fusionados en la fecha proporcionada',
'Consulta cuentas y direcciones fusionadas',
'Autor :Daniela Ramírez',
'FECHA : 27/Septiembre/2011',
'Modificó: Martha Aguirre',
'Descripción: Se modifica para que los registros se muestren ordenados',
'de acuerdo a la hora de inserción',
'Modificó: Jose Angel Gaxiola Gaxiola',
'Descripción: Se modifica agregando parametros para poder retornar informacion mediante un rango de fechas',
'FECHA : 19/Junio/2013',
'BD: bdinteg',
'Fecha:			09-08-2013	DSB20130809',
'Modifico:		Jesus Horacio Lopez Gonzalez - 95526749',
'Modificacion:	Se modifica para que no muestre en el reporte en blanco los clientes que no tienen cuentas.',
'ASUNTO:		Modificación',
'ELABORÓ: 		José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo directamente de la variable y no de la instucción IF EXIST',
'FECHA: 		04/09/2013	DSB20130911',
'FOLIO: 1568',
'AUTOR : 95584315',
'FECHA : 24-11-2013',
'MODIFICACIÓN: Se modifica SP para que consulte solo las transacciones por el usuario infoaut.',
'SUSTENTO: RQM 61 071 ? Fusión automática de clientes (Página 9)',
'SOLICITA: Jaime Gonzalez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtieneparentesco(pNumCteNvo CHAR(20),pNumCteCoinc CHAR(20))
	RETURNING 	CHAR(5)  AS CodRetorno,
				CHAR(40) AS Nombre1,
				CHAR(40) AS Nombre2,
				CHAR(40) AS ApPaterno,
				CHAR(40) AS ApMaterno,
				CHAR(10) AS FecNac,
				CHAR(1)  AS Situacion,
				SMALLINT AS Causa;   

				
--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE cNomCte1 		CHAR(40);
DEFINE cNomCte2 		CHAR(40);
DEFINE cApPatCte 		CHAR(40);
DEFINE cApMatCte 		CHAR(40);
DEFINE cFecNacCte 		CHAR(10);
DEFINE cSituacionCte 	CHAR(1);
DEFINE sCausaCte 		SMALLINT;
DEFINE cParentesco 		CHAR(2);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNomCte1 		= '';
LET cNomCte2 		= '';
LET cApPatCte 		= '';
LET cApMatCte 		= '';
LET cFecNacCte 		= '';
LET cSituacionCte 	= '';
LET sCausaCte 		= 0;
LET cParentesco 	= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','','','';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/eduardo/sp_obtieneparentesco.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	
	IF NVL(pNumCteNvo,'') <> '' OR  NVL(pNumCteCoinc,'') <> '' THEN 
	
		SELECT situacion, causa
		INTO cSituacionCte,sCausaCte  
		FROM bdisitesp:"informix".se_ctessitespcte
		WHERE numcte =TRIM(pNumCteCoinc);
		
		SELECT cli.nombre1,cli.nombre2,cli.apell_paterno,cli.apell_materno,cte.fecha_nac
		INTO cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte
		FROM bdinteg:"informix".si_cliente cli,
			 bdinteg:"informix".si_ctepf cte
		WHERE cli.numcte= TRIM(pNumCteCoinc)
		AND cte.numcte = TRIM(pNumCteCoinc);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN --No encontro ningun registro		
			RETURN cCodRet, '','','','','','','';
		ELSE 
			SELECT {+INDEX(bdinteg:"informix".si_refclientes idx_empcte)} parentesco
			INTO cParentesco
			FROM bdinteg:"informix".si_refclientes
			WHERE numcte = TRIM(pNumCteNvo) 
			AND empresa = '001'
			AND numcte_banco = TRIM(pNumCteCoinc);
			
			LET cFecNacCte =  LPAD( TRIM(DAY(cFecNacCte)::CHAR(2)),2,'0') || '/' || LPAD(TRIM(MONTH(cFecNacCte)::CHAR(2)),2,'0') || '/' || YEAR(cFecNacCte);
			
			IF cParentesco = 'P' OR cParentesco = 'J' THEN --
				LET cCodRet = '00001';				RETURN cCodRet, '','','','','','','';
			END IF;
		END IF;
	ELSE 
		LET cCodRet = '00002';	END IF;
	RETURN cCodRet, cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,cSituacionCte,sCausaCte;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los datos del cliente martch y verifica si tiene alguna relacion padre-hijo',
'AUTOR : Eduardo Lopez',
'FECHA : 11-09-2013',
'VERSION: 20130911.1240',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_intr_obtenerregiones(piRegNum INTEGER, piRegistroInicial INTEGER)
	RETURNING CHAR(6) AS CodRetorno,
				CHAR(3) AS NumRegion,
				CHAR(40) AS NomRegion;
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);	
DEFINE cNumRegion CHAR(3);
DEFINE cRegion CHAR(40);
---------------------------	

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cNumRegion = '';
LET cRegion  = '';

	
--SET DEBUG FILE TO "/home/informix/sp_intr_obtenerregiones.out";
--TRACE ON;
	
SET LOCK MODE TO WAIT 3;
	
-- INICIO DEL PROCEDIMIENTO
BEGIN
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,	cNumRegion, cRegion;
		END IF;
	END EXCEPTION;	  
	
	IF piRegNum IS NULL OR piRegistroInicial IS NULL THEN
		LET cCodRet = '000001'; --Parametros incorrectos
		RETURN cCodRet, cNumRegion, cRegion;
	END IF;
	
-- Se realiza la consulta por Regiones		
	IF piRegNum = 0 THEN
	
		-- Se realiza la búsqueda en la tabla, todas las Regiones
		FOREACH		
			SELECT SKIP piRegistroInicial codigo_plaza, descripcion
			INTO cNumRegion, cRegion		  
			FROM bdinteg:si_plazas_cajagen				   
			ORDER BY descripcion	
			 
			RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END FOREACH;	 
						
		-- Se valida que se haya obtenido información
		IF NVL(cNumRegion,'') = '' AND NVL(cRegion,'') = '' THEN			
			LET cCodRet = '999999';  -- No se encontró información
			--RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END IF;		

	ELSE
		SELECT codigo_plaza, descripcion
		INTO cNumRegion, cRegion		  
		FROM bdinteg:si_plazas_cajagen
		WHERE codigo_plaza = piRegNum;		
		
		-- Se valida que se haya obtenido información
		IF NVL(cNumRegion,'') = '' AND NVL(cRegion,'') = '' THEN
			LET cCodRet = '999999';  -- No se encontró información
			--RETURN cCodRet, cNumRegion, cRegion WITH RESUME;
		END IF;
	END IF;
	
	IF cCodRet <> '000000' OR piRegNum <> 0 THEN
		RETURN cCodRet, cNumRegion, cRegion;
	END IF;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para extraer los nombres de las regiones',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 01/11/2013',
'VERSION: 1.0',
'BD: BDINTEG',
'SISTEMA : INTRANET';

CREATE PROCEDURE "informix".sp_intr_obtenersucursal(numsucursal INT, pRegistroInicial INT)

--DATOS A REGRESAR---
RETURNING
CHAR(6),      -- Código de Retorno
CHAR(4),      -- Clave de la Sucursal
CHAR(40);     -- Nombre de la Sucursal
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);	
---------------------------	
DEFINE cClave  CHAR(4);
DEFINE cNombre CHAR(40);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cClave  = '';
LET cNombre = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_intr_obtenersucursal.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cClave, cNombre;
			END IF;
		END EXCEPTION;	  
		
-- Se realiza la consulta por Sucursales		
		IF numsucursal = 0 THEN
		
			-- Se realiza la búsqueda en la tabla de todas las sucursales de tipo "S" (Activas)	
			FOREACH		
				                SELECT SKIP pRegistroInicial {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
                INTO cClave, cNombre		  
				FROM bdinteg:si_sucursales				   
				WHERE tpo_sucursal = 'S'
				ORDER BY sucursal
				 
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información			
            IF nvl(cClave,'') = '' AND nvl(cNombre,'') = '' THEN			
				LET cCodRet = '999999';  -- No se encontró información			
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END IF;
-- Se realiza la consulta por Tiendas Matriz
		ELSE		
			-- Se realiza la búsqueda en la tabla de las tiendas matriz
			FOREACH		
				                SELECT SKIP pRegistroInicial FIRST 1 {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
                INTO cClave, cNombre		  
                FROM bdinteg:si_sucursales
                --WHERE tpo_sucursal = 'S' and sucursal = numsucursal AND tienda_matriz != 0
                WHERE tpo_sucursal = 'S' and sucursal = numsucursal
                ORDER BY sucursal
				
                RETURN cCodRet, cClave, cNombre WITH RESUME;				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF nvl(cClave,'') = '' AND nvl(cNombre,'') = '' THEN			
				LET cCodRet = '999999';  -- No se encontró información			
				RETURN cCodRet, cClave, cNombre	WITH RESUME;				  
			END IF;			
		
		END IF;
					
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea SP para extraer los nombres de las sucursales',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 01/11/2013',
'VERSION: 1.0',
'BD: BDINTEG',
'SISTEMA : INTRANET';

CREATE PROCEDURE  "informix".sp_cnsif_consdirec(cID_USUARIO CHAR(8),cID_FUNCION CHAR(10),cNUMCTE CHAR(20),cTBUSQUEDA CHAR(1),cTDOMICILIO CHAR(1),pNumRegistro INTEGER,pRecuperacion INTEGER)
       returning 	CHAR(5)  AS Cod_Retorno,
					CHAR(20) AS Numero_Cliente,
					CHAR(1)  AS Tipo_Direccion,
					INTEGER  AS Secuencia,
					CHAR(40) AS Calle,
					CHAR(10) AS Numero_Exterior_Calle,
					CHAR(10) AS Numero_Interior_Calle,
					CHAR(6)  AS Departamento,
					CHAR(60) AS Colonia,
					CHAR(60) AS Municipio,
					CHAR(60) AS Ciudad,
					CHAR(30) AS Estado,
					CHAR(20) AS Pais,
					CHAR(5)  AS Codigo_Postal,
					CHAR(13) AS Telefono_1,
					CHAR(13) AS Telefono_2,
					CHAR(13) AS Telefono_3,
					CHAR (5) AS Extension,
					CHAR(1)  AS Punto_Cardinal,
					CHAR(30) AS Manzana,
					CHAR(30) AS Otros,
					CHAR(30) AS Andador,
					CHAR(30) AS Etapa,
					CHAR(30) AS Lote,
					CHAR(30) AS Entrada,
					CHAR(30) AS Edificio,
					CHAR(40) AS Complemento,
					CHAR(80) AS Entre_Calles,
                    CHAR(15) AS Tipo_Dom,
					DATE	 AS fecha_insert;

					
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;



DEFINE cNumcliente CHAR (20);
DEFINE vtipo_dir CHAR(1);
DEFINE vsecuencia INT;
DEFINE vcalle CHAR(40);
DEFINE vnumeroextcalle  CHAR(10);
DEFINE vnumerointcalle  CHAR(10);
DEFINE vdepartamento  CHAR(6);
DEFINE vcolonia CHAR(60);
DEFINE vmunicipio CHAR(60);
DEFINE vciudad CHAR(60);
DEFINE vestado CHAR(30);
DEFINE vpais CHAR(20);
DEFINE vcod_postal CHAR(5);
DEFINE vtelefono1 CHAR(13);
DEFINE vtelefono2  CHAR(13);
DEFINE vtelefono3  CHAR(13);
DEFINE vextension CHAR(5);
DEFINE vpuntocardinal  CHAR(1);
DEFINE vunidadhabitac  CHAR(1);
DEFINE vmanzana CHAR(30);
DEFINE votros  CHAR(30);
DEFINE vandador CHAR(30);
DEFINE vetapa CHAR(30);
DEFINE vlote  CHAR(30);
DEFINE ventrada  CHAR(30);
DEFINE vedificio  CHAR(30);
DEFINE ventre_calles CHAR(80);
DEFINE vobservaciones CHAR(40);
DEFINE iMaxdomicilio INTEGER;
DEFINE iexiste INTEGER;
DEFINE iCont INTEGER;
DEFINE dfecha_insert DATE;

--VARIABLES AUXILIARES
DEFINE vCvePais   CHAR(3);
DEFINE vCveEstado CHAR(2);
DEFINE vCveCiudad CHAR(3);
DEFINE vnumcalle  INTEGER;
DEFINE vnumerocolonia   INT;
DEFINE vnumerociudad    SMALLINT ;
DEFINE vcvemunicipio  CHAR(5);
DEFINE vCdCoppel        SMALLINT;
DEFINE vcvemanzana   SMALLINT;
DEFINE vcveotros     SMALLINT;
DEFINE vcveandador   SMALLINT;
DEFINE vcveetapa     SMALLINT;
DEFINE vcveedificio  SMALLINT;
DEFINE vcveentrada   SMALLINT;
DEFINE vcvelote      SMALLINT;

--VARIABLE PARA LOS TELEFONOS
DEFINE	vcodrett         CHAR(5);
DEFINE	vTelefono        CHAR(13);
DEFINE	vTipoTel         SMALLINT;
DEFINE	vSecuenciaTel    SMALLINT;
DEFINE	vStatus_Tel      CHAR(1);
DEFINE	vExtensionTel    CHAR(5);
DEFINE	vNombreCarrier   CHAR(20);
DEFINE	StatusValidacion SMALLINT;
DEFINE vCarrier         SMALLINT;
DEFINE cTipo_Dom        CHAR(15);

let vciclo = 0;
let vcodret = "00000";
let  vsqlerr = 0;

LET cNumcliente= "";
LET vtipo_dir = "";
LET vsecuencia = 0 ;
LET vcalle = "";
LET vnumeroextcalle  = "";
LET vnumerointcalle  = "";
LET vdepartamento  = "";
LET vcolonia = "";
LET vmunicipio = "";
LET vciudad = "";
LET vestado = "";
LET vpais = "";
LET vcod_postal  = "";
LET vtelefono1  = "";
LET vtelefono2   = "";
LET vtelefono3   = "";
LET vextension  = "";
LET vpuntocardinal   = "";
LET vunidadhabitac   = "";
LET vmanzana  = "";
LET votros   = "";
LET vandador  = "";
LET vetapa  = "";
LET vlote   = "";
LET ventrada   = "";
LET vedificio   = "";
LET ventre_calles = "";
LET vobservaciones = "";
LET iMaxdomicilio = 0;
LET iexiste = 0;
LET iCont=0;

--VARIABLES AUXILIARES
LET vCvePais   = "";
LET vCveEstado = "";
LET vCveCiudad = "";
LET vnumcalle  = 0;
LET vnumerocolonia = 0;
LET vnumerociudad = 0;
LET vcvemunicipio = "";
LET vCdCoppel = 0;
LET vcvemanzana = 0;
LET vcveotros = 0;
LET vcveandador = 0;
LET vcveetapa  = 0;
LET vcveedificio = 0;
LET vcveentrada = 0;
LET vcvelote    =0;

--variables para los telefonos
LET	vcodrett         = "";
LET	vTelefono        = "";
LET	vTipoTel         = 0;
LET	vSecuenciaTel    = 0;
LET	vStatus_Tel      = "";
LET	vExtensionTel    = "";
LET	vNombreCarrier   = "";
LET	StatusValidacion = 0;
LET	vCarrier = 0;
LET cTipo_Dom="";
LET dfecha_insert=TODAY;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         return vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,
		vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal,vmanzana,
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;

      END IF;
   END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consdirec_2.out";
	--TRACE ON;
		
	IF cTBUSQUEDA <> '1' AND cTBUSQUEDA <> '0' THEN 
		LET vcodret = "00052";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
		vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
		votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF; 	
	
	IF 	cID_USUARIO = ''OR
		cID_FUNCION =''	OR 
		cNUMCTE = 	'' 	OR 
		cTBUSQUEDA = ''	OR
		cTDOMICILIO = '' 	THEN
		LET vcodret = "00054";
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF;		

    IF pNumRegistro<0 THEN
        LET vcodret='00098';
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
    ELSE
        IF pRecuperacion<=0 THEN
            LET vcodret='00098';
            RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
                vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
                votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
        END IF;
    END IF;    	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIO,cID_FUNCION, cNUMCTE,'11','2')
	INTO
	vcodret;
	IF (vcodret != '00000')  THEN
		RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			   vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			   votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
	END IF;
	-- TERMINA VALIDACION		

    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_direcciones WHERE numcte = cNUMCTE; 

    IF iexiste = 0 THEN 
        LET vcodret = "00056";
        RETURN vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
        vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
        votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
    END IF;	

	IF cTBUSQUEDA = '1' THEN
 
		SELECT 	DI.numcte, DI.tipo_dir, DI.secuencia, DI.numeroextcalle, DI.numerointcalle,DI.departamento,
				DI.cod_postal, DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				DI.estado,DI.pais,DI.municipio
		INTO    cNumcliente, vtipo_dir, vsecuencia, vnumeroextcalle, vnumerointcalle, vdepartamento,
				vcod_postal,vnumcalle,vnumerociudad,vnumerocolonia,
				vCveEstado,vCvePais,vcvemunicipio
		FROM si_direcciones_actual DI 		
		WHERE DI.numcte = cNUMCTE 		
		AND tipo_dir = cTDOMICILIO;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,1,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono1 = vTelefono;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,2,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono2 = vTelefono;
		LET vextension = vExtensionTel;
		
		EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,3,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET vtelefono3 = vTelefono;
		
		SELECT nombre
		INTO vpais
		FROM si_paises
		WHERE pais = vCvePais;

		SELECT TRIM(nombre)
		INTO vestado
		FROM bdinteg:si_estados
		WHERE estado = vCveEstado;

		SELECT TRIM(nombreciudad), numerociudadcoppel
		INTO vciudad,vCdCoppel
		FROM bdinteg:si_catciudades
		WHERE numerociudad = vnumerociudad;		
		
		SELECT TRIM(nombrezona)
		INTO vcolonia
		FROM bdinteg:si_catzonas
		WHERE numerociudad = vnumerociudad
		AND numerocolonia = vnumerocolonia;
		
		SELECT TRIM(nombrecalle)
		INTO vcalle
		FROM bdinteg:si_catcalles
		WHERE numerocalle = vnumcalle;
		
		IF TRIM(vcvemunicipio) ='00000' THEN
			LET vcvemunicipio  = "";
			SELECT TRIM(municipiozona)
			  INTO vmunicipio
			  FROM bdinteg:si_catzonas
			 WHERE numerociudad = vnumerociudad
			   and numerocolonia  = vnumerocolonia;
		ELSE
			LET vmunicipio = vciudad;
		END IF;
		
		
	RETURN  	vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
				vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
				votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
				
    ELIF cTBUSQUEDA = '0' THEN 
	
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion 
				 DI.numcte,DI.tipo_dir,DI.secuencia,DI.numeroextcalle,DI.numerointcalle,DI.departamento,
				 DI.cod_postal, DI.puntocardinal,DI.manzana, DI.otros,DI.andador,DI.etapa,DI.lote,DI.entrada,
				 DI.edificio,DI.entre_calles,DI.observaciones,DI.numerocalle,DI.numerociudad,DI.numerocolonia,
				 DI.estado,DI.pais,DI.municipio,DECODE(DI.tipo_dir,"1","CASA","2","OFICINA","3","CORRESPONDENCIA"),fecha_insert
			INTO  cNumcliente,vtipo_dir,vsecuencia,vnumeroextcalle,vnumerointcalle,vdepartamento,
				  vcod_postal,vpuntocardinal, vcvemanzana,vcveotros,vcveandador,vcveetapa,vcvelote,vcveentrada,
				  vcveedificio,ventre_calles,vobservaciones,vnumcalle,vnumerociudad,vnumerocolonia,
				  vCveEstado,vCvePais,vcvemunicipio,cTipo_Dom,dfecha_insert
			FROM si_direcciones DI
			WHERE numcte = cNUMCTE
            ORDER BY 3 DESC
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,1,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono1 = vTelefono;
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,2,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono2 = vTelefono;
			LET vextension = vExtensionTel;
			
			EXECUTE PROCEDURE "informix".sp_consulta_telefonos('001',cNUMCTE,3,'0')
			INTO
			vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
			
			LET vtelefono3 = vTelefono;
			
			SELECT nombre
			INTO vpais
			FROM si_paises
			WHERE pais = vCvePais;
		
			SELECT TRIM(nombre)
			INTO vestado
			FROM bdinteg:si_estados
			WHERE estado = vCveEstado;

			SELECT TRIM(nombreciudad), numerociudadcoppel
			INTO vciudad,vCdCoppel
			FROM bdinteg:si_catciudades
			WHERE numerociudad = vnumerociudad;
			
			SELECT TRIM(nombrezona)
			INTO vcolonia
			FROM bdinteg:si_catzonas
			WHERE numerociudad = vnumerociudad
			AND numerocolonia = vnumerocolonia;
			
			SELECT TRIM(nombrecalle)
			INTO vcalle
			FROM bdinteg:si_catcalles
			WHERE numerocalle = vnumcalle;
			
			IF TRIM(vcvemunicipio) ='00000' THEN
				LET vcvemunicipio  = "";

				SELECT TRIM(municipiozona)
				  INTO vmunicipio
				  FROM bdinteg:si_catzonas
				 WHERE numerociudad = vnumerociudad
				   and numerocolonia  = vnumerocolonia;
			ELSE
				LET vmunicipio = vciudad;
			END IF;
			
			 IF vcvemanzana > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vmanzana
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 1
				   AND complementoclave = vcvemanzana;
			END IF;
			
			IF vcveotros > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO votros
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 2
				   AND complementoclave = vcveotros;
			END IF;

			IF vcveandador > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vandador
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 3
				   AND complementoclave = vcveandador;
			END IF;

			IF vcveetapa > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vetapa
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 4
				   AND complementoclave = vcveetapa;
			END IF;

			IF vcveedificio > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vedificio
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 5
				   AND complementoclave = vcveedificio;
			END IF;

			IF vcveentrada > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO ventrada
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 6
				   AND complementoclave = vcveentrada;
			END IF;

			IF vcvelote > 0 THEN
				SELECT TRIM(nombredomicilio)
				  INTO vlote
				  FROM bdinteg:si_catdomicilios
				 WHERE numerociudad = vCdCoppel
				   AND numerocolonia = vnumerocolonia
				   AND clavedomicilio = 7
				   AND complementoclave = vcvelote;
			END IF;

            LET iCont=iCont + 1;	
			
			RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
					vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
					votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert with resume;
					
		END FOREACH	; 
		
        IF iCont = 0 THEN
            LET vcodret = 1001; 
            RETURN  vcodret,cNumcliente,vtipo_dir,vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,
			vciudad,vestado,vpais,vcod_postal,vtelefono1,vtelefono2,vtelefono3,vextension,vpuntocardinal, vmanzana, 
			votros,vandador,vetapa,vlote,ventrada,vedificio,vobservaciones,ventre_calles,cTipo_Dom,dfecha_insert;
        END IF 	
		
	END IF 
	
	
END
END PROCEDURE
DOCUMENT
"Autor : ARTURO CERVANTES PEÑA",
"FECHA : 01/MARZO/2012",
"FUNCIONAMIENTO:Dependiento del tipo de busqueda y del numero de usuario hara una busqueda de domicilio del cliente, la busqueda tipo 1",
"devolvera una sola direccion que sera la actual del cliente, se considerara la actual como la direccion con mayor secuencia dentro de la base",
"el tipo de busqueda 0 regresara todas las direcciones que el cliente tiene registradas dentro de la base de datos",
"Ver.  : 1.0",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cons_ref_cop(p_empresa char(3), p_sucursal char(4), p_usuario char(8), p_numcte char(20), p_referencia char(20),p_apellpat char(20),
											p_apellmat char(20),p_nom1 char(20),p_nom2 char(20), p_rfc char(13))
            RETURNING 
            char(5),char(1);

   DEFINE v_codret          char(5);
   DEFINE v_referencia		char(20);
   DEFINE v_apellpat		char(20);
   DEFINE v_apellmat		char(20);
   DEFINE v_nom1			char(20);
   DEFINE v_nom2			char(20);
   DEFINE v_rfc				char(13);
   DEFINE v_result			char(1);
   DEFINE sql_err,isam_err  int;
   DEFINE v_cuantos			int;
 
 -- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        let v_codret            = "000";
        let v_referencia        = " ";        
        let v_apellpat          = " ";
		let v_apellmat          = " ";
        let v_nom1         		= " ";
        let v_nom2          	= " ";
		let v_rfc				= " ";
		let v_result			= " ";

--set debug file to "/tmp/sp_cons_ref_cop.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
		 let v_result = '1';
         RETURN v_codret,v_result;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  p_empresa is null or
        p_referencia is null or 
		p_apellpat is null or
		p_nom1 is null or		
		p_rfc is null
		then
       -- datos de entrada incompletos     
       let v_codret = 110; 
	   let v_result = '1';
       RETURN v_codret,v_result;
    END IF;

-- ****************************************************************************
-- Consultar datos
-- ****************************************************************************

	SELECT COUNT(numcte) INTO v_cuantos FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia;

	IF v_cuantos <= 1 THEN

		IF EXISTS (SELECT numcte_ref FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia) THEN
			SELECT numcte_ref, rfc, nombre1, nombre2, apell_paterno, apell_materno
			INTO v_referencia, v_rfc, v_nom1, v_nom2, v_apellpat, v_apellmat
			FROM bdinteg:si_cliente
			WHERE numcte_ref = p_referencia;
			IF 	TRIM(p_referencia) = TRIM(v_referencia)
				AND TRIM(p_rfc) = TRIM(v_rfc)
				AND TRIM(p_nom1) = TRIM(v_nom1)
				AND TRIM(p_nom2) = TRIM(v_nom2)
				AND TRIM(p_apellpat) = TRIM(v_apellpat)
				AND	TRIM(p_apellmat) = TRIM(v_apellmat)
			THEN
				LET v_codret = '000';
                        LET v_result = '0';
			ELSE
				LET v_codret = '000';
				LET v_result = '1';
				INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
					VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
			END IF;
		ELSE
				LET v_codret = '000';
				LET v_result = '0';	
		END IF;
	
	ELSE
		LET v_codret = '000';
		LET v_result = '1';
		INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
			VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
	END IF;		
	
	RETURN v_codret,v_result;

END;    
END PROCEDURE;