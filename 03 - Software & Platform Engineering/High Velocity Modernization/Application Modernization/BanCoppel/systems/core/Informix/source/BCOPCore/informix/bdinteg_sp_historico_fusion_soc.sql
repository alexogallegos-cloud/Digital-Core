CREATE PROCEDURE "informix".sp_historico_fusion_soc(pDia CHAR(2), pMes CHAR(2), pAnio CHAR(4), pDiaHasta CHAR(2), pMesHasta CHAR(2), pAnioHasta CHAR(4), pOpcion CHAR(1), pUsuarioAnalista CHAR(8))

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
	DEFINE dFechaInsertIni  DATE;
	DEFINE dFechaInsertFin  DATE;
	
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
	LET dFechaInsertIni = MDY(pMes,pDia,pAnio);
	LET dFechaInsertFin = MDY(pMesHasta,pDiaHasta,pAnioHasta);
	
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_historico_fusion_soc.out';
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp, cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
			END IF;	
		END EXCEPTION;
		
		BEGIN;
			TRUNCATE TABLE bdinteg:"informix".si_fusreporte;
		COMMIT;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT valor 
		INTO cUsuParam
		FROM bdinteg:"informix".si_param 
		WHERE empresa = '001'
		AND cod_param ='184';
		
		IF pOpcion = 1 THEN			
			IF pUsuarioAnalista <> '' THEN
				SELECT 
				{+AVOID_FULL (bdinteg:"informix".log_fusionclientes)}
				FIRST 1 fecha_insert INTO dValidaFecha
				FROM bdinteg:"informix".log_fusionclientes
				WHERE fecha_insert = dFechaInsertIni 
				AND user_insert = pUsuarioAnalista 
				AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
				LET iNumRows = dbinfo("sqlca.sqlerrd2");
			ELSE
				SELECT 
				{+AVOID_FULL (bdinteg:"informix".log_fusionclientes)}
				FIRST 1 fecha_insert INTO dValidaFecha
				FROM bdinteg:"informix".log_fusionclientes
				WHERE fecha_insert = dFechaInsertIni 
				AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
				LET iNumRows = dbinfo("sqlca.sqlerrd2");
			END IF;
			IF(iNumRows > 0) THEN																	
				LET cExiste = "1";

				IF pUsuarioAnalista <> '' THEN
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
						INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert = dFechaInsertIni
						AND user_insert = pUsuarioAnalista AND user_insert <> cUsuParam AND user_insert <> 'infdesf' --DSB 24112013
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
				ELSE
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
						INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert = dFechaInsertIni
						AND user_insert <> cUsuParam AND user_insert <> 'infdesf' --DSB 24112013
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
			END IF;
		ELSE
			--LET cExiste = "4";
			IF pUsuarioAnalista <> '' THEN
				SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha	--DSB20130911{
				FROM bdinteg:"informix".log_fusionclientes
				WHERE fecha_insert >= dFechaInsertIni AND fecha_insert <= dFechaInsertFin AND user_insert = pUsuarioAnalista AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
				LET iNumRows = dbinfo("sqlca.sqlerrd2");
			ELSE
				SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha	--DSB20130911{
				FROM bdinteg:"informix".log_fusionclientes
				WHERE fecha_insert >= dFechaInsertIni AND fecha_insert <= dFechaInsertFin AND user_insert <> cUsuParam AND user_insert <> 'infdesf'; --DSB 24112013
				LET iNumRows = dbinfo("sqlca.sqlerrd2");
			END IF;

			--LET cExiste = "5";
			IF(iNumRows > 0) THEN									
				LET cExiste = "1";																						--DSB20130911
			
				IF pUsuarioAnalista <> '' THEN
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
						INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert >= dFechaInsertIni
						AND fecha_insert <= dFechaInsertFin
						AND user_insert = pUsuarioAnalista AND user_insert <> cUsuParam AND user_insert <> 'infdesf'  --DSB 24112013
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
				ELSE
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT TRIM(cliente_tit), TRIM(cliente_tras),fecha_hora,fecha_insert
						INTO cNumCteTit, cNumCteTrasp, dHora,dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert >= dFechaInsertIni
						AND fecha_insert <= dFechaInsertFin
						AND user_insert <> cUsuParam AND user_insert <> 'infdesf'  --DSB 24112013
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
					   
					SELECT 
					{+AVOID_FULL (bdinteg:"informix".si_fuscliente), AVOID_FULL (bdinteg:"informix".si_fusctepf)}
					LIMIT 1 nomctetras.apell_paterno, nomctetras.apell_materno, nomctetras.nombre1, 
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
						--AND status_cta IN (1,3)
						AND status_cta != 2

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
					   SELECT {+AVOID_FULL (bdinteg:"informix".si_fusmaecredcrd), AVOID_FULL (bdicred:"informix".sd_maesdoscrd)} 
							TRIM(f.num_credito), TRIM(f.num_producto), TRIM(f.numcte), TRIM(f.status_cred), m.monto_otorgado
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo
							FROM bdinteg:"informix".si_fusmaecredcrd f
							LEFT JOIN bdicred:"informix".sd_maesdoscrd m on m.num_credito=f.num_credito
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
'---------------------',
'AUTOR: L. Montserrat León Amador',
'FECHA: 07/05/2020',
'MODIFICACION: Se realiza clonación de spl para agregar BEGIN/COMMIT en el uso del TRUNCATE.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_traspasocuentas_ide_soc(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_numsolic        CHAR(20);
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_AnioMes	CHAR(6);
DEFINE vc_aniomesI       CHAR(6);
DEFINE vc_aniomesF       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
DEFINE iExiste     INTEGER;
DEFINE vc_statusolic    CHAR(2);
DEFINE vd_FechaSolic    DATE;
DEFINE iNumRows			INTEGER;
DEFINE vc_rfc           CHAR(13);
DEFINE vc_rfc_ori          CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE CparamRango		CHAR(13);
DEFINE sEjercicio		SMALLINT;
DEFINE cUser_insert_ide	CHAR(8);
DEFINE dFecha_insert_ide	DATE;
DEFINE cPendiente		CHAR(1);
DEFINE cAniomes		CHAR(6);
DEFINE cCuenta_ret	CHAR(20);
DEFINE cConsecutivo  CHAR(1);
DEFINE cNumcte		CHAR(20);
DEFINE cRfc			CHAR(13);



DEFINE mImp_acumulado	MONEY;
DEFINE mImp_gravado		MONEY;
DEFINE mImp_arecaudar	MONEY;
DEFINE mImp_recaudado	MONEY;
DEFINE mImp_mesanterior MONEY;
DEFINE mImp_excedente	MONEY;
DEFINE mImp_arecaudarc	MONEY;
DEFINE mImp_recaudadoc	MONEY;
DEFINE mImp_pendiente	MONEY;
DEFINE mImp_anterior	MONEY;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_secuencia = 0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_detalle_mov2 = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_numsolic = "";
LET vc_AnioMes= "";
LET vc_aniomesI="";
LET vc_aniomesF="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;
LET vd_fecha_mov = "";
LET iExiste=0;
LET vc_statusolic = "";
LET vd_FechaSolic = "";
LET iNumRows= 0;
LET vc_rfc="";
LET vc_rfc_ori="";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET CparamRango="";
LET sEjercicio=0;
LET cUser_insert_ide = '';
LET dFecha_insert_ide = '';
LET cPendiente = '';
LET cAniomes	= '';
LET cCuenta_ret = '';
LET cConsecutivo = '';
LET cNumcte = '';
LET cRfc = '';

LET mImp_acumulado	= 0;
LET mImp_gravado	= 0;
LET mImp_arecaudar	= 0;
LET mImp_recaudado	= 0;
LET mImp_mesanterior	= 0;
LET mImp_excedente = 0;
LET mImp_arecaudarc = 0;
LET mImp_recaudadoc = 0;
LET mImp_pendiente = 0;
LET mImp_anterior = 0;



    --BEGIN WORK;
    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            --ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_traspasocuentas_ide_soc.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SELECT  trim(valor) INTO vc_aniomesI FROM si_param where cod_param=151;
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas, pClienteTraspasaCtas));
	--SELECT  trim(valor) INTO vc_aniomesF FROM si_param where cod_param=152;
	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	--LET sEjercicio=SUBSTR(vc_aniomesI,1,4);

    SELECT  {+INDEX(bdinteg:si_cliente idx_si_cliente5)} rfc INTO vc_rfc FROM si_cliente WHERE numcte = pClienteTitular;

	SELECT  {+INDEX(bdilide:sl_movefec i_102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT  {+INDEX(bdilide:sl_movefec i_102)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';   
        
            INSERT INTO bdinteg:si_fusmovefec
            SELECT  {+INDEX(bdilide:sl_movefec i_102)} * FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			
			--DELETE {+INDEX(bdilide:sl_movefec i_102)} FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec i_102)} bdilide:sl_movefec SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes =vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
        END FOREACH;
    END IF;	
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	
    SELECT  FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec_his WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH         
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec_his
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec_his";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';           

            INSERT INTO bdinteg:si_fusmovefec_his
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} * FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			--DELETE {+INDEX(bdilide:si_fusmovefec_his i_102_his)} FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec_his(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec_his i_102_his)} bdilide:sl_movefec_his SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes=vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
        END FOREACH;
    END IF;

	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;
	
	SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)}  FIRST 1 num_cte INTO pCte FROM bdilide:sl_retlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND pendiente IS NOT NULL;
	
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_retlide idx_retcte)} rfc, ref_ret,aniomes
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes
            FROM bdilide:sl_retlide
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL

            LET vc_tabla = "sl_retlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret);
            LET vc_proceso='RETENCION IDE';   
			
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 1 FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} user_insert, fecha_insert, pendiente
				INTO cUser_insert_ide, dFecha_insert_ide, cPendiente
				FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes;
				
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTitular, pClienteTraspasaCtas) AND pendiente IS NOT NULL;
				
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 
					 SUM(imp_acumulado), SUM(imp_gravado), SUM(imp_arecaudar), SUM(imp_recaudado), SUM(imp_mesanterior)
				INTO mImp_acumulado, mImp_gravado, mImp_arecaudar, mImp_recaudado, mImp_mesanterior
				FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes;
				
				UPDATE {+INDEX(bdilide:sl_retlide idx_retcte)}  bdilide:sl_retlide 
				SET imp_acumulado = mImp_acumulado, imp_gravado = mImp_gravado, imp_arecaudar = mImp_arecaudar, imp_recaudado = mImp_recaudado, imp_mesanterior = mImp_mesanterior
				WHERE rfc = vc_rfc AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND pendiente IS NOT NULL;
				
				DELETE FROM bdilide:sl_retlide
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND  pendiente IS NOT NULL;				

			ELSE
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
				
				UPDATE bdilide:sl_retlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		

        END FOREACH;
    END IF;
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));
	
	SELECT  {+INDEX(bdilide:sl_detlide i_d102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq where empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_detlide i_d102)} rfc, ref_ret,aniomes,cuenta_ret,consecutivo
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes,vc_num_cta,vi_num_serial
            FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_detlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vi_num_serial;
            LET vc_proceso='DETALLE IDE';  

			IF EXISTS (SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 1 FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} aniomes,cuenta_ret--,consecutivo
				INTO cAniomes, cCuenta_ret --cConsecutivo
				FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  * FROM bdilide:sl_detlide 
				WHERE aniomes = cAniomes 
					AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular)) AND consecutivo = vi_num_serial;
				
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 
					 SUM(imp_recaudado)
				INTO mImp_recaudado
				FROM bdilide:sl_detlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)}  bdilide:sl_detlide 
				SET  imp_recaudado = mImp_recaudado
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				DELETE FROM bdilide:sl_detlide 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND consecutivo = vi_num_serial;				
			ELSE
        
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} * FROM bdilide:sl_detlide WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)} bdilide:sl_detlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas AND consecutivo = vi_num_serial;
			END IF;
			
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);			
        END FOREACH;
    END IF;

	
	SELECT  
	{+AVOID_FULL (bdilide:"informix".sl_constancias)}
	MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;

	SELECT  
	{+AVOID_FULL (bdilide:"informix".sl_constancias)}
	MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;
	
	SELECT  {+INDEX(bdilide:sl_constancias 112_228)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_constancias WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND tipo_cons is not null;
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   rfc, tipo_cons,aniomes
            INTO   vc_rfc_ori, vc_sucursal,vc_AnioMes
            FROM bdilide:sl_constancias
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null

            LET vc_tabla = "sl_constancias";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_sucursal);
            LET vc_proceso='CONSTANCIAS IDE';
						
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 1 FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} aniomes,num_cte,rfc
				INTO cAniomes,cNumcte,cRfc
				FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias  WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons = vc_sucursal;
				
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 
					 SUM(imp_excedente),SUM(imp_arecaudar),SUM(imp_recaudado),SUM(imp_pendiente),SUM(imp_anterior)
				INTO mImp_excedente, mImp_arecaudarc,mImp_recaudadoc,mImp_pendiente,mImp_anterior
				FROM bdilide:sl_constancias WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				UPDATE {+INDEX(bdilide:sl_constancias  112_228)}  bdilide:sl_constancias 
				SET  imp_excedente = mImp_excedente, imp_arecaudar = mImp_arecaudarc,imp_recaudado = mImp_recaudadoc,imp_pendiente = mImp_pendiente,imp_anterior = mImp_anterior
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				DELETE FROM bdilide:sl_constancias 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons = vc_sucursal;							
			ELSE
			
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;

				UPDATE bdilide:sl_constancias SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		
        END FOREACH;
    END IF;

	SELECT  FIRST 1 num_cte INTO pCte FROM bdicheq:sc_retenisr WHERE empresa='001' 
	AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           --BD-- SELECT   {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)}  cuenta
           SELECT   cuenta
            INTO    vc_num_cta
            FROM bdicheq:sc_retenisr WHERE empresa='001' AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sc_retenisr";
            LET vc_detalle_mov = vi_num_serial||'|'||TRIM(vc_num_cta)||'|'||TRIM(pClienteTraspasaCtas);
            LET vc_proceso='RETEN ISR';   
        
            INSERT INTO bdinteg:si_fusretenisr
            SELECT  {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} * FROM bdicheq:sc_retenisr WHERE empresa='001' AND num_cte =pClienteTraspasaCtas AND cuenta=vc_num_cta; 

			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} bdicheq:sc_retenisr SET num_cte = pClienteTitular WHERE empresa='001' AND num_cte = pClienteTraspasaCtas AND cuenta=vc_num_cta;

        END FOREACH;
    END IF;

   IF vc_CodRet = "00000" THEN
        --COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;

END;
END PROCEDURE
DOCUMENT
'----------------------------------------------',
'AUTOR: L. Montserrat León Amador',
'FECHA: 07/05/2020',
'MODIFICACION: Se realiza clonación de spl para eliminar BEGIN/COMMIT (error de transacción desde SOC).';

CREATE PROCEDURE "informix".sp_valida_perfil_usuario(pEmpresa CHAR(3), pUsuario CHAR(10))
	RETURNING CHAR(6)  AS codigo_retorno,
			CHAR(80) AS mensaje_retorno,
			SMALLINT AS tipo_perfil;
		
	---DECLARACIONES
	DEFINE cCodRet 		CHAR(6); 
	DEFINE cMensajeRet 	CHAR(80);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iIsamErr 	INTEGER;
	DEFINE cErrorInfo 	CHAR(80);
	DEFINE cPerfil 		CHAR(11);
	DEFINE iMuestra 	INTEGER;
	
	---INICIALIZACIONES
	
	LET iSqlErr 		= 0;
	LET iIsamErr 		= 0;
	LET cErrorInfo 		= "";
	LET cCodRet 		= "000000";
	LET cMensajeRet 	= "Se realizÃ³ la consulta correctamente";
	LET cPerfil 		= "";
	Let iMuestra 		= 0 ;
	
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;	 
				RETURN cCodRet, cMensajeRet, 0;
			END IF;
		END EXCEPTION;
	
		-- SET DEBUG FILE TO "/informix/jesus/sp_valida_perfil_usuario.out";
		-- TRACE ON;
	
		IF NVL(pEmpresa,"") = "" OR NVL(pUsuario,"")="" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "Falta un parÃ¡metro de fecha requerido para realizar  la consulta";
			RETURN cCodRet, cMensajeRet, 0;
		END IF;
	
	
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH WITH HOLD
			SELECT perfil
			INTO cPerfil
			FROM si_perfil_ejecut
			WHERE cod_emp = pEmpresa
			AND ejecutivo= pUsuario 
			AND perfil IN ("602","707","109","2001") 
			ORDER BY perfil desc
			IF cPerfil =   "2001" THEN
				Let iMuestra = 0 ;
				EXIT FOREACH;
			ELIF cPerfil <>  "2001" THEN
				Let iMuestra = 1 ;
			ELSE
				Let iMuestra = 0 ;
			END IF;
		END FOREACH
		
		--si es uno se levantara el nuevo reporte
		--si es 0 se levantara el  reporte anterior
		RETURN cCodRet, cMensajeRet, iMuestra;	
			
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para validar que reporte se levantara en el aplicativo GENEREPORCRED',
'AUTOR: JesÃºs Manuel Aguilar Heredia',
'FECHA: ENERO 2014',
'VERSION: 20140214.1735',
'BD: bdinteg',
'DESCRIPCION: Se realiza ajuste al procedimiento para extender el tamaÃ±o de la vaiable cPerfil',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 19/01/2020',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_adm_cons_ejecutivo(e_ejecut CHAR(8),e_mac CHAR(12),e_suc CHAR(4))  
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE s_status 		CHAR(1);

	DEFINE s_ejecutivo 		CHAR(8);
	
	DEFINE s_esZona 		INTEGER;
	

    LET cod_ret  = "00000";

    LET s_ejecutivo= "";
	
	LET s_esZona = 0;
  

BEGIN
ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;

         	RETURN  cod_ret;
      END IF ;
   END EXCEPTION ;

SET LOCK MODE TO WAIT 4;
	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
     	RETURN  cod_ret;
    END IF;

	IF NVL(e_ejecut,'') =='' THEN 
	 	  LET cod_ret = '02002'; -- No contiene Dato de Ejecutivo
    	RETURN  cod_ret;
    END IF;

	IF NVL(e_suc,'') =='' THEN 
	 	  LET cod_ret = '02003'; -- No contiene Dato de Sucursal
     	RETURN  cod_ret;
    END IF;
	
	
	SELECT COUNT(ejecutivo)
		    INTO  s_esZona
    FROM si_ejecut   
	WHERE ejecutivo = e_ejecut
	AND puesto = '005' 
	AND password <> 'BAJA';

	IF s_esZona = 1 THEN
       LET s_status = 'A';
	ELSE
		SELECT status INTO s_status
        FROM si_macejecutivo        
        WHERE ejecutivo = e_ejecut AND MAC = e_suc;
	END IF;
	
	IF NVL(s_status,'') =='' THEN 
	 	  LET cod_ret = '02004'; -- Usuario no Autorizado en esta Sucursal
       	RETURN  cod_ret;
    END IF;
    
    IF NVL(s_status,'') <>'A' THEN 
	 	  LET cod_ret = '02005'; -- Usuario no Activo
     	RETURN  cod_ret;
    END IF;

	IF s_esZona = 1 THEN
      SELECT ejecutivo   
			INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut;
	ELSE
		SELECT ejecutivo   
		INTO  s_ejecutivo
		FROM si_ejecut   
		WHERE ejecutivo = e_ejecut AND sucursal = e_suc;
	END IF;
    

    IF NVL(s_ejecutivo,'') =='' THEN 
	 	  LET cod_ret = '02006'; -- No se encontro registro de el Ejecutivo
       	RETURN  cod_ret;
    ELSE

    END IF;

     	RETURN  cod_ret;
END
END PROCEDURE

;