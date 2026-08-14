CREATE PROCEDURE "informix".sp_historico_desbctasfus(pDia CHAR(2), pMes CHAR(2), pAnio CHAR(4),pDiaHasta CHAR(2), pMesHasta CHAR(2), pAnioHasta CHAR(4), pOpcion CHAR(1), pUsuarioAnalista CHAR(8))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),						-- Codigo de Retorno
	CHAR(20), 						-- Numero del cliente titular
	CHAR (110), 					-- Nombre completo del cliente titular
	CHAR(10), 						-- Fecha de nacimiento del cliente titular
	CHAR(20),						-- Numero del cliente traspasado
	CHAR (110),						-- Nombre completo del cliente traspasado
	CHAR(10), 						-- Fecha de nacimiento del cliente traspasado
	
	CHAR(20),	 					-- Numero de cuenta del cliente traspasado
	CHAR(4),	 					-- Producto
	CHAR(20),	 					-- Numero de Cliente
	CHAR(2),	 					-- Estatus
	MONEY(16,2), 					-- Saldo
	CHAR(40),	 					-- Descripcion
	CHAR(10),    					-- Fecha de Alta
	INTEGER,     					-- Numero de direcciones fusionadas
	DATETIME YEAR TO SECOND, 		--Hora de Fusion
	DATETIME HOUR to FRACTION(3),	--Hora desbloqueo
	CHAR(10),    					-- Status_Cuenta
	CHAR(45);    					--NombreAnalista
	
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
	DEFINE dHoraFecha       DATETIME YEAR TO FRACTION(3);
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
	DEFINE dHora  			DATETIME HOUR to FRACTION(3);
	DEFINE cUnidadp 	    CHAR(20);
	DEFINE cStatusCuenta    CHAR(10);
	DEFINE cExiste          CHAR(1);
	DEFINE cUser_insert     CHAR(10);
	DEFINE cNombreAnalista  CHAR(45);
	DEFINE dValidaFecha		DATE;			--DSB20130911
	DEFINE cValidaNumCte	CHAR(20);		--DSB20130911
	DEFINE iNumRows			INTEGER;		--DSB20130911
	
	--INICIALIZACION DE VARIABLES--
	LET iSql_err 			= 0;
	LET cCodRet 			= '00000';
	LET cNumCteTit 			= '';
	LET cNumCteTrasp 		= '';
	LET cApePaterTit 		= '';
	LET cApeMaterTit 		= '';
	LET cNom1Tit 			= '';
	LET cNom2Tit 			= '';
	LET cFechaNacTit 		= '';
	LET cApePaterTrasp 		= '';
	LET cApeMaterTrasp 		= '';
	LET cNom1Trasp 			= '';
	LET cNom2Trasp 			= '';
	LET cFechaNacTrasp 		= '';
	LET cNomCompTitular 	= '';
	LET cNomCompTransp 		= '';
		
	LET cCta 				= '';
	LET cProducto 			= '';
	LET cNumCte 			= '';
	LET cStatus 			= '';
	LET vSaldo 				= 0;
	LET cDescripcion 		= '';
	LET cFechaAlta 			= '';
	LET iDirecciones 		= '';
	LET dHoraFecha 			= CURRENT;
	LET cNumCteTrasp2 		= '';
    LET iBandera			= 0;
    LET iBandera1			= 0;
    LET iBandera2			= 0;
    LET iBandera3			= 0;
	LET Iconsecutivo		= 0;
	LET iConteo				= 0;
	LET cTitular			= '';
	LET cTraspasar			= '';
	LET iExiste				= 0;
	LET dHora 				= '';
	LET cUnidadp 			= '';
	LET cStatusCuenta 		= '';
	LET cExiste 			= '0';
	LET cUser_insert 		= '';
	LET cNombreAnalista		= '';
	LET	dValidaFecha 		= '';		--DSB20130911
	LET cValidaNumCte 		= '';		--DSB20130911
	LET iNumRows 			= 0;		--DSB20130911
	
	--SET DEBUG FILE TO "/informix/ArmandoM/sp_historico_desbctasfus.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
					    cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista;
			END IF;
		END EXCEPTION;

		--TRUNCATE TABLE bdinteg:"informix".si_fusreporte_desbloqueo;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 1 THEN
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha									--DSB20130911{
			FROM bdinteg:"informix".log_fusionclientes 
			WHERE fecha_insert = MDY(pMes,pDia,pAnio) AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																														--DSB20130911}
				LET cExiste = "1";
				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT(cliente_tit) 
					INTO cNumCteTit
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert = MDY(pMes,pDia,pAnio) AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END
					
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT(cliente_tras),fecha_hora
						INTO cNumCteTrasp, dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert = MDY(pMes,pDia,pAnio)
						AND cliente_tit = cNumCteTit
						AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END
						ORDER BY fecha_hora
						
						 IF iConteo=0 THEN
							LET cTitular= TRIM(cNumCteTit);
							LET cTraspasar= TRIM(cNumCteTrasp);
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte_desbloqueo where cliente_tit= cNumCteTit and cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporte_desbloqueo (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
							END IF;
						 ELSE
								LET Iconsecutivo= Iconsecutivo + 1;
								SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte_desbloqueo where cliente_tit= cNumCteTit and cliente_tras= cNumCteTrasp;
								IF iExiste=0 THEN
									INSERT INTO bdinteg:"informix".si_fusreporte_desbloqueo (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
								END IF;
								LET cTitular= cNumCteTit;
								LET cTraspasar= cNumCteTrasp;
						 END IF;
						 
						 LET iConteo= iConteo + 1;
					END FOREACH;
				END FOREACH;
			END IF;
		ELSE
		
			SELECT FIRST 1 {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} fecha_insert INTO dValidaFecha							--DSB20130911{
			FROM bdinteg:"informix".log_fusionclientes 
			WHERE fecha_insert >= MDY(pMes,pDia,pAnio) AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta) AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END;
			LET iNumRows = DBINFO("sqlca.sqlerrd2");
			IF(iNumRows > 0) THEN																												--DSB20130911}
				LET cExiste = "1";
				FOREACH
					SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT(cliente_tit)
					INTO cNumCteTit
					FROM bdinteg:"informix".log_fusionclientes 
					WHERE fecha_insert >= MDY(pMes,pDia,pAnio) AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta) AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END
					
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".log_fusionclientes idxfeclogfu)} DISTINCT(cliente_tras),fecha_hora
						INTO cNumCteTrasp, dHoraFecha
						FROM bdinteg:"informix".log_fusionclientes 
						WHERE fecha_insert >= MDY(pMes,pDia,pAnio) AND fecha_insert <= MDY(pMesHasta,pDiaHasta,pAnioHasta) AND cliente_tit = cNumCteTit 
						AND user_insert = CASE WHEN pUsuarioAnalista <> '' THEN pUsuarioAnalista ELSE user_insert END
						ORDER BY fecha_hora

						 IF iConteo=0 THEN
							LET cTitular= TRIM(cNumCteTit);
							LET cTraspasar= TRIM(cNumCteTrasp);
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte_desbloqueo where cliente_tit= cNumCteTit and cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporte_desbloqueo (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
							END IF;
						 ELSE
							
							LET Iconsecutivo= Iconsecutivo + 1;
							SELECT NVL(COUNT(*),0) INTO iExiste FROM bdinteg:"informix".si_fusreporte_desbloqueo where cliente_tit= cNumCteTit and cliente_tras= cNumCteTrasp;
							IF iExiste=0 THEN
								INSERT INTO bdinteg:"informix".si_fusreporte_desbloqueo (cliente_tit,cliente_tras ,id_rep) VALUES (cNumCteTit,cNumCteTrasp,Iconsecutivo);
							END IF;
							LET cTitular= cNumCteTit;
							LET cTraspasar= cNumCteTrasp;
							
						 END IF; 
						 
						 LET iConteo= iConteo + 1;
					END FOREACH;
				END FOREACH;
			END IF;
		END IF;
		
		
		IF cExiste = "1" THEN
			FOREACH
			
				SELECT {+INDEX (bdinteg:"informix".si_fusreporte_desbloqueo idx_fusreporte_desbloqueo)} DISTINCT cliente_tit, cliente_tras,id_rep
				INTO cNumCteTit, cNumCteTrasp, Iconsecutivo
				FROM bdinteg:"informix".si_fusreporte_desbloqueo
				ORDER BY id_rep
				 
				SELECT MIN(fecha_hora) INTO dHoraFecha from bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp;
				 
				SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
				SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
				
				IF cNumCteTrasp <> cNumCteTrasp2 THEN
				
					SELECT LIMIT 1 nomctetit.apell_paterno, nomctetit.apell_materno, nomctetit.nombre1, nomctetit.nombre2, fecnactit.fecha_nac
					INTO cApePaterTit, cApeMaterTit, cNom1Tit, cNom2Tit, cFechaNacTit 
					FROM bdinteg:"informix".si_cliente nomctetit, bdinteg:"informix".si_ctepf fecnactit
					WHERE nomctetit.numcte = cNumCteTit AND fecnactit.numcte = cNumCteTit;
					   
					SELECT LIMIT 1 nomctetras.apell_paterno, nomctetras.apell_materno, nomctetras.nombre1, nomctetras.nombre2, fecnactras.fecha_nac
					INTO cApePaterTrasp, cApeMaterTrasp, cNom1Trasp, cNom2Trasp, cFechaNacTrasp
					FROM bdinteg:"informix".si_fuscliente nomctetras, bdinteg:"informix".si_fusctepf fecnactras
					WHERE nomctetras.numcte = cNumCteTrasp AND fecnactras.numcte = cNumCteTrasp;
					
					LET cNomCompTitular = TRIM(cNom1Tit)||" "||TRIM(cNom2Tit)||" "||TRIM(cApePaterTit)||" "||TRIM(cApeMaterTit);
					LET cNomCompTransp = TRIM(cNom1Trasp)||" "||TRIM(cNom2Trasp)||" "||TRIM(cApePaterTrasp)||" "||TRIM(cApeMaterTrasp);
					
					LET iDirecciones = '0';
                    LET iBandera1=0;
                    LET iBandera2=0;
                    LET iBandera3=0;
                    LET iBandera=0;
					
					SELECT FIRST 1 numcte INTO cValidaNumCte																	--DSB20130911{
					FROM bdinteg:"informix".si_fusdirecciones
					WHERE numcte = cNumCteTrasp;
					LET iNumRows = DBINFO("sqlca.sqlerrd2");
					IF(iNumRows > 0) THEN																						--DSB20130911}
						  SELECT NVL(COUNT(numcte),0)
						  INTO iDirecciones
						  FROM bdinteg:"informix".si_fusdirecciones
						  WHERE numcte = cNumCteTrasp;
					END IF;

						FOREACH
							SELECT {+INDEX (bdinteg:"informix".si_fusbitacoradesbloqueo idx_bitdesfus)} TRIM(chq.cuenta), TRIM(chq.producto), TRIM(chq.num_cte), TRIM(chq.status_cta), chq.sdo_actual, desb.hora	--DSB20130808
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo, dHora
							FROM bdicheq:"informix".sc_maechq chq , bdinteg:"informix".si_fusbitacoradesbloqueo desb, bdinteg:"informix".si_fusmaechq fmae
							WHERE chq.num_cte = cNumCteTit AND chq.status_cta = 1 AND chq.cuenta = desb.cuenta AND fmae.num_cte = cNumCteTrasp AND chq.cuenta = fmae.cuenta
							
							LET cStatusCuenta = 'Activa';
							 
							   
							SELECT LIMIT 1 TRIM(prod.nombre), fecalta.fecha_alta
							INTO cDescripcion, cFechaAlta
							FROM bdicheq:"informix".sc_producto prod, bdicheq:"informix".sc_maenoc fecalta
							WHERE prod.producto = cProducto AND fecalta.cuenta = cCta;
							   
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera1=iBandera1 + 1;
                            IF iBandera1>1 THEN
                                LET iDirecciones='';
                            END IF;
							
							IF NVL(cCta, '') <> '' THEN																							--DSB20130808
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							END IF;
							
						END FOREACH;
                        FOREACH
							SELECT TRIM(cred.num_credito), TRIM(cred.num_producto), TRIM(cred.numcte), TRIM(cred.status_cred), 0,'Activa', desb.hora	--DSB20130808
							INTO cCta, cProducto, cNumCte, cStatus, vSaldo,cUnidadp, dHora
							FROM bdicred:"informix".sd_maecred cred, bdinteg:"informix".si_fusbitacoradesbloqueo desb, bdinteg:"informix".si_fusmaecred fcred
							WHERE cred.numcte = cNumCteTit AND cred.num_credito = desb.cuenta AND fcred.numcte = cNumCteTrasp AND cred.num_credito = fcred.num_credito
							AND cred.id_unidad_prod IS NULL AND cred.cod_caract_2 IS NULL
								 LET cStatusCuenta = cUnidadp; 

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
							
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera2=iBandera2 + 1;
                            IF iBandera2>1 THEN
                                LET iDirecciones='';
                            END IF;
								
							IF NVL(cCta, '') <> '' THEN																							--DSB20130808
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							END IF;

                        END FOREACH;
                        FOREACH
                            SELECT TRIM(num_credito), TRIM(num_producto), TRIM(numcte), TRIM(status_cred), 0
                                  INTO cCta, cProducto, cNumCte, cStatus, vSaldo
                                  FROM bdinteg:"informix".si_fusmaecredcrd
                                 WHERE numcte = cNumCteTrasp


                            IF LENGTH(cProducto)=3 THEN
                                SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                  INTO cDescripcion, cFechaAlta
                                  FROM bdicred:"informix".sd_definicion prod,
                                       bdinteg:"informix".si_fusmaecredcrd fecalta
                                 WHERE prod.num_producto = '6'||cProducto
                                   AND fecalta.num_credito = cCta;
                            ELSE
                                SELECT LIMIT 1 TRIM(prod.nombre_prod), fecalta.fecha_apertura
                                  INTO cDescripcion, cFechaAlta
                                  FROM bdicred:"informix".sd_definicion prod,
                                       bdinteg:"informix".si_fusmaecredcrd fecalta
                                 WHERE prod.num_producto = cProducto
                                   AND fecalta.num_credito = cCta;
                            END IF;       

							SELECT hora INTO dHora FROM bdinteg:"informix".si_fusbitacoradesbloqueo WHERE cuenta =cCta;
							
							SELECT user_insert INTO cUser_insert FROM bdinteg:"informix".log_fusionclientes WHERE cliente_tit=cNumCteTit AND cliente_tras=cNumCteTrasp AND fecha_hora = dHoraFecha GROUP BY user_insert;
							SELECT nombre INTO cNombreAnalista FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cUser_insert;
							
                            LET iBandera=1;
                            LET iBandera3=iBandera3 + 1;
                            IF iBandera3>1 THEN
                                LET iDirecciones='';
                            END IF;

							IF NVL(cCta, '') <> '' THEN																							--DSB20130808
								RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
									   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
							END IF;

                    END FOREACH;
                   IF iBandera=0 THEN
						LET cCta = "";
						LET cProducto = "";
						LET cNumCte = "";
						LET cStatus = "";
						LET vSaldo = "";
						LET cDescripcion = "";
						LET dHora = "";
						LET cStatusCuenta = "";
						LET iDirecciones = "";
						
						IF NVL(cCta, '') <> '' THEN																								--DSB20130808
							RETURN cCodRet,cNumCteTit,cNomCompTitular,cFechaNacTit,cNumCteTrasp,cNomCompTransp,cFechaNacTrasp,
							   cCta,cProducto,cNumCte,cStatus,vSaldo,cDescripcion,cFechaAlta,iDirecciones,dHoraFecha,dHora,cStatusCuenta,cNombreAnalista WITH RESUME;
						END IF;
                    END IF;  
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
'Consulta el historico de clientes fusionados en las fechas proporcionadas, Consulta cuentas, direcciones fusionadas, estatus de cuenta y hora desbloqueo',
'Autor :Josue Zepeda',
'FECHA : 23/Mayo/2013',
'BD: bdinteg',
'Fecha:			08-08-2013	DSB20130808',
'Modifico:		Jesus Horacio Lopez Gonzalez - 95526749',
'Modificacion:	Se modifica para que en el reporte se muestren solo las cuentas que han sido desbloqueadas por fusion y para que no muestre en el reporte en blanco los clientes que no tienen cuentas.',
'ASUNTO:		Modificación',
'ELABORÓ: 		José Ernesto Raygoza Villa',
'DESCRIPCIÓN: 	Se genera algunas variables en donde se les asigna la consulta que tienen la instrucción IF EXIST para validarlo directamente de la variable y no de la instucción IF EXIST',
'FECHA: 		04/09/2013 DSB20130911';

CREATE PROCEDURE "informix".generainf_perfis_tmp04( pFechaIni DATE, pFechaFin DATE ) 
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsql_err         INTEGER;
    DEFINE visam_err        INTEGER;
    DEFINE vdesc_err        CHAR(50);
    DEFINE vcontador        INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE nComit           SMALLINT;
    
    DEFINE vctemin          CHAR(20);
    DEFINE vctemax          CHAR(20);
    DEFINE cNumCliente      CHAR(20);
    DEFINE cRfc             CHAR(13);      
    DEFINE cApellido1       CHAR(26);
    DEFINE cApellido2       CHAR(26);
    DEFINE cNombre1         CHAR(26);
    DEFINE cNombre2         CHAR(26);
    DEFINE cNacionalidad    CHAR(3);
    DEFINE dFechaNac        DATE;
    DEFINE dFechaInsert     DATE;
    DEFINE cNombreCalle     CHAR(30);
    DEFINE cNumExtCalle     CHAR(10);
    DEFINE cNumIntCalle     CHAR(10);
    DEFINE cColonia         CHAR(32); 
    DEFINE cCodPostal       CHAR(5);  
    DEFINE cMunicipio       CHAR(27);  
    DEFINE cNomCiudadCte    CHAR(30);       
    DEFINE cNoEstado        CHAR(2);       
    DEFINE cActividad       CHAR(3);
    DEFINE cSubActividad    CHAR(3);
    DEFINE cRiesgo          CHAR(4);
    DEFINE cNumCuenta       CHAR(20);
    DEFINE cNumProducto     CHAR(4);
    DEFINE cSucursal        CHAR(4);      
    DEFINE cStatusCta       CHAR(2);
    DEFINE cNombreSuc       CHAR(40);
    DEFINE cEstadoSuc       CHAR(2);
    DEFINE vstmt            CHAR(200);
    DEFINE cActividadCte    CHAR(3);
    DEFINE cSubActividadCte CHAR(11);
    
    LET vcodret1         = '000';
    LET vcodret2         = '000';
    LET vcodret3         = '';
    LET vsql_err         = 0;
    LET visam_err        = 0;
    LET vdesc_err        = '';
    LET vcontador        = 0;
    LET vcontador2       = 0;
    LET nComit           = 0;
    
    LET vctemin          = '';
    LET vctemax          = '';
    LET cNumCliente      = '';
    LET cRfc             = '';  
    LET cApellido1       = '';
    LET cApellido2       = '';
    LET cNombre1         = '';
    LET cNombre2         = '';
    LET cNacionalidad    = '';
    LET dFechaNac        = '';
    LET dFechaInsert     = '';
    LET cNombreCalle     = '';
    LET cNumExtCalle     = '';
    LET cNumIntCalle     = '';
    LET cColonia         = '';
    LET cCodPostal       = '';
    LET cMunicipio       = '';
    LET cNomCiudadCte    = '';      
    LET cNoEstado        = ''; 
    LET cActividad       = '';
    LET cSubActividad    = '';
    LET cRiesgo          = '';
    LET cNumCuenta       = '';
    LET cNumProducto     = '';
    LET cSucursal        = ''; 
    LET cStatusCta       = '';
    LET cNombreSuc       = '';
    LET cEstadoSuc       = '';
    LET vstmt            = '';
    LET cActividadCte    = '';
    LET cSubActividadCte = '';
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/generainf_perfis_tmp04.out';
    --- TRACE ON;
    
    BEGIN

    ON EXCEPTION SET vsql_err, visam_err, vdesc_err
        SET DEBUG FILE TO '/resplogifx/conciliachq/generainf_perfis_tmp04.err';
        TRACE ON;
        LET vcodret1  = vsql_err;
        LET vcodret2 = visam_err;
        LET vcodret3 = vdesc_err;
        IF nComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN vcodret1, vcodret2, vcontador;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    CREATE TEMP TABLE tmp_cuentas_perfis
      (
        numcte          CHAR(20),
        cuenta          CHAR(20),
        apell_pat       CHAR(26),
        apell_mat       CHAR(26),
        nombre1         CHAR(26),
        nombre2         CHAR(26),
        tpo_persona     CHAR(1),
        nacionalidad    CHAR(3),
        actividad       CHAR(3),
        subactividad    CHAR(3),
        riesgo          CHAR(4),
        producto        CHAR(4),
        calle           CHAR(30),
        no_ext          CHAR(10),
        no_int          CHAR(10),
        colonia         CHAR(32),
        cod_pos         CHAR(5),
        municipio       CHAR(27),
        ciudad          CHAR(30),
        estado          CHAR(2),
        fecha_nac       DATE,
        rfc             CHAR(13),
        activ_emp       CHAR(1),
        fecha_insert    DATE,
        status_cta      CHAR(2),
        sucursal        CHAR(4),
        nombre_suc      CHAR(40),
        estado_suc      CHAR(2)
      ) WITH NO LOG;
      
    -- // TABLA TEMPORAL tbl_bitacoraapertura DE bdiauditor
    SELECT numcte, id_pregunta, id_secuencia, id_act, id_subact
      FROM bdiauditor@pld_ids1170:tbl_bitacoraapertura
     WHERE numcte >= '008529168'
       AND numcte < '010727217'
       AND id_pregunta = 6
       AND id_secuencia > 0
      INTO TEMP tmp_bitacoraapertura WITH NO LOG;
    CREATE INDEX idxtmp_bitaper ON tmp_bitacoraapertura(numcte, id_pregunta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_bitacoraapertura;
    
    -- // CUENTAS DE CHEQUES
    SELECT mae.num_cte AS numcte, mae.cuenta, mae.producto, mae.sucursal, mae.status_cta
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.empresa = noc.empresa
       AND mae.cuenta = noc.cuenta
       AND mae.producto <> '1100'
       AND noc.fecha_alta <= pFechaFin
       AND mae.num_cte >= '008529168'
       AND mae.num_cte <  '010727217'
       AND ( ( mae.status_cta != '2' AND mae.fecha_proceso >= pFechaIni ) OR 
             ( mae.status_cta  = '2' AND mae.fec_cancelac  >= pFechaIni ) OR 
             ( mae.status_cta  = '2' AND mae.fecha_proceso >= pFechaIni ) )
    INTO TEMP tmp_maechq WITH NO LOG;
    CREATE INDEX idxtmp_maechq ON tmp_maechq(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_maechq;
             
    -- // INVERSIONES CRECIENTES
    SELECT mae.num_cte AS numcte, mae.cuenta, mae.producto, mae.sucursal, mae.status_cta
      FROM bdicheq:sc_maechq mae,
           bdicheq:sc_maenoc noc
     WHERE mae.empresa = noc.empresa
       AND mae.cuenta = noc.cuenta
       AND mae.producto = '1100'
       AND mae.fecultdep <= pFechaFin
       AND mae.num_cte >= '008529168'
       AND mae.num_cte <  '010727217'
       AND ( ( mae.status_cta != '2' ) OR
             ( mae.status_cta  = '2' AND mae.fecha_proceso >= pFechaIni ) OR
             ( mae.status_cta  = '2' AND mae.fecha_proceso is null AND mae.fec_ult_mov >= pFechaIni ) )
    INTO TEMP tmp_maeinv WITH NO LOG;
    CREATE INDEX idxtmp_maeinv ON tmp_maeinv(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_maeinv;
             
    -- // PAGARES
    SELECT num_cte AS numcte, cuenta, cod_instrum, sucursal, status_cta
      FROM bdinvers:sv_maeinv
     WHERE fecha_alta <= pFechaFin
       AND fecha_venc >= pFechaIni
       AND num_cte >= '008529168'
       AND num_cte <  '010727217'
    INTO TEMP tmp_pagare WITH NO LOG;
    CREATE INDEX idxtmp_pagare ON tmp_pagare(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_pagare;
       
    -- // TARJETA DE CREDITO
    SELECT mae.numcte, mae.num_credito, mae.num_producto, mae.sucursal, mae.status_cred
      FROM bdicred:sd_maesdoscont dos,
           bdicred:sd_maecred mae
     WHERE dos.num_credito = mae.num_credito
       AND dos.empresa = mae.empresa
       AND dos.fecha BETWEEN pFechaIni AND pFechaFin
       AND mae.fecha_apertura <= pFechaFin
       AND mae.numcte >= '008529168'
       AND mae.numcte <  '010727217'
    INTO TEMP tmp_credito WITH NO LOG;
    CREATE INDEX idxtmp_credito ON tmp_credito(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_credito;
       
    -- // OTROS CREDITOS
    SELECT mae.numcte, mae.num_credito, mae.num_producto, mae.sucursal, mae.status_cred
      FROM bdicred:sd_maesdoscontcrd dos,
           bdicred:sd_maecredcrd mae
     WHERE dos.num_credito = mae.num_credito
       AND dos.empresa = mae.empresa
       AND dos.fecha BETWEEN pFechaIni AND pFechaFin
       AND mae.fecha_apertura <= pFechaFin
       AND mae.numcte >= '008529168'
       AND mae.numcte <  '010727217'
    INTO TEMP tmp_prestamo WITH NO LOG;
    CREATE INDEX idxtmp_prestamo ON tmp_prestamo(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_prestamo;
    
    CREATE TEMP TABLE tmp_ctes( numcte CHAR(20) ) 
    WITH NO LOG;
    
    INSERT INTO tmp_ctes
    SELECT UNIQUE numcte FROM tmp_maechq;
    
    INSERT INTO tmp_ctes
    SELECT UNIQUE numcte FROM tmp_maeinv;
    
    INSERT INTO tmp_ctes
    SELECT UNIQUE numcte FROM tmp_pagare;
    
    INSERT INTO tmp_ctes
    SELECT UNIQUE numcte FROM tmp_credito;
    
    INSERT INTO tmp_ctes
    SELECT UNIQUE numcte FROM tmp_prestamo;
      
    CREATE INDEX idx_cte_tmp ON tmp_ctes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes;
    
    CREATE TEMP TABLE tmp_clientes( numcte CHAR(20) ) 
    WITH NO LOG;
    
    INSERT INTO tmp_clientes
    SELECT UNIQUE numcte FROM tmp_ctes;
    
    CREATE INDEX idx_cliente_tmp ON tmp_clientes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_clientes;
      
    SELECT MIN(numcte), MAX(numcte)
      INTO vctemin, vctemax
      FROM tmp_clientes; 

    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCliente
          FROM tmp_clientes
         WHERE numcte BETWEEN vctemin AND vctemax
            
        BEGIN WORK;
        LET nComit = 1;
        
        -- // DATOS PERSONALES DEL CLIENTE
        SELECT TRIM(cte.rfc) AS rfc,     
               TRIM(cte.apell_paterno) AS apellpaterno,
               TRIM(cte.apell_materno) AS apellmaterno,    
               TRIM(cte.nombre1) AS nombre1,
               TRIM(cte.nombre2) AS nombre2,
               ctepf.nacionalidad, ctepf.fecha_nac, ctepf.fecha_insert,
               cte.actividad_princ, cte.actividad_esp
          INTO cRfc, cApellido1, cApellido2, cNombre1, cNombre2,
               cNacionalidad, dFechaNac, dFechaInsert,
               cActividadCte, cSubActividadCte
          FROM bdinteg:si_cliente cte
          LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
         WHERE cte.numcte = cNumCliente;
         
        -- // DIRECCIÓN PERSONAL DEL CLIENTE 
        SELECT FIRST 1 calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, zona.nombrezona, dir.cod_postal, zona.municipiozona, cd.nombreciudad, edo.estado
          INTO cNombreCalle, cNumExtCalle, cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado
          FROM bdinteg:si_direcciones_actual dir 
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
          LEFT OUTER JOIN bdinteg:si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = cNumCliente
           AND dir.tipo_dir = '1';
           
        IF ( cNombreCalle is null AND cColonia is null AND cMunicipio is null AND cNomCiudadCte is null ) THEN
           
            -- // DIRECCIÓN TRABAJO DEL CLIENTE 
            SELECT FIRST 1 calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, zona.nombrezona, dir.cod_postal, zona.municipiozona, cd.nombreciudad, edo.estado
              INTO cNombreCalle, cNumExtCalle, cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado
              FROM bdinteg:si_direcciones_actual dir 
              LEFT OUTER JOIN bdinteg:si_catcalles calle ON ( calle.numerocalle = dir.numerocalle )
              LEFT OUTER JOIN bdinteg:si_catzonas zona ON ( zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia )
              LEFT OUTER JOIN bdinteg:si_catciudades cd ON ( cd.numerociudad = dir.numerociudad )
              LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
             WHERE dir.numcte = cNumCliente
               AND dir.tipo_dir = '2';
        END IF;
        
        SELECT FIRST 1 id_act, id_subact
          INTO cActividad, cSubActividad
          FROM bdinteg:si_bitacoraapertura
         WHERE numcte = cNumCliente
           AND id_pregunta = 6
           AND id_secuencia = ( SELECT MAX(id_secuencia) FROM bdinteg:si_bitacoraapertura WHERE numcte = cNumCliente AND id_pregunta = 6 );
           
        IF cActividad is null AND cSubActividad is null THEN
            SELECT FIRST 1 id_act, id_subact
              INTO cActividad, cSubActividad
              FROM tmp_bitacoraapertura
             WHERE numcte = cNumCliente
               AND id_pregunta = 6
               AND id_secuencia = ( SELECT MAX(id_secuencia) FROM tmp_bitacoraapertura WHERE numcte = cNumCliente AND id_pregunta = 6 );
               
            IF cActividad is null AND cSubActividad is null THEN
                LET cActividad = cActividadCte;
                LET cSubActividad = cSubActividadCte;
            END IF;
        END IF;
           
        IF cNumCliente IN('000791268','003258205','004986287','002352685','002970192','003680088','005146171','003070142','004224021',
                          '004960008','004970453','006521251','006529614','004496044','006731430','007224164','007316157','007318616',
                          '007336087','007833235','008173185','008581661','008854140','009011413','009089393','009489206','009768896',
                          '009794650','010141322','012440037','012914300','012940427','013313607','014860531','017132825','004399443',
                          '002976751','004092791','004397682','004762510','005716130','006293282','006862956','007316041','008475874',
                          '008694524','008855299','009962331','010353413','011484079','012098379','013156056','013259153','013398135',
                          '014156310','014273866','014564689','016058293','016245536','016276998','016780102') THEN 
            LET cRiesgo = 'ALTO';
        ELSE
            LET cRiesgo = 'BAJO';
        END IF;
         
        -- // CUENTAS DE CHEQUES
        FOREACH
            SELECT cuenta, producto, sucursal, status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM tmp_maechq
             WHERE numcte = cNumCliente
                     
            SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;
            
            INSERT INTO tmp_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // INVERSIONES CRECIENTES
        FOREACH
            SELECT cuenta, producto, sucursal, status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM tmp_maeinv
             WHERE numcte = cNumCliente
                     
            SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;

            INSERT INTO tmp_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // PAGARES
        FOREACH
            SELECT UNIQUE cuenta, cod_instrum, sucursal, status_cta
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM tmp_pagare
             WHERE numcte = cNumCliente
                     
            SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;

            INSERT INTO tmp_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // TARJETA DE CREDITO
        FOREACH
            SELECT UNIQUE num_credito, num_producto, sucursal, status_cred
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM tmp_credito
             WHERE numcte = cNumCliente
                     
            SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;

            INSERT INTO tmp_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        -- // PRESTAMOS
        FOREACH
            SELECT UNIQUE num_credito, num_producto, sucursal, status_cred
              INTO cNumCuenta, cNumProducto, cSucursal, cStatusCta
              FROM tmp_prestamo
             WHERE numcte = cNumCliente
                     
            SELECT FIRST 1 suc.nombre, edo.estado
              INTO cNombreSuc, cEstadoSuc
              FROM bdinteg:si_sucursales suc,
                   bdinteg:si_estados edo
             WHERE suc.sucursal = cSucursal
               AND edo.estado = suc.estado;

            INSERT INTO tmp_cuentas_perfis VALUES
            ( cNumCliente, cNumCuenta, cApellido1, cApellido2, cNombre1, cNombre2, 'F', cNacionalidad, cActividad, cSubActividad, cRiesgo, cNumProducto, cNombreCalle, cNumExtCalle, 
              cNumIntCalle, cColonia, cCodPostal, cMunicipio, cNomCiudadCte, cNoEstado, dFechaNac, cRfc, '', dFechaInsert, cStatusCta, cSucursal, cNombreSuc, cEstadoSuc );
        END FOREACH;
        
        LET vcontador = vcontador + 1;
        LET vcontador2 = vcontador2 + 1;
         
        IF vcontador2 >= 10000 THEN
            LET vcontador2 = 0;
            LET vstmt = '';
            LET vstmt = 'echo "CLIENTES PROCESADOS EN generainf_perfis_tmp04: '||vcontador||'" >> /resplogifx/conciliachq/generainf_perfis_tmp04.log';
            SYSTEM vstmt;
        END IF;
        
        COMMIT WORK;
        LET nComit = 0;
    END FOREACH;
    
    CREATE INDEX idxtmp_cuenta_perfis ON tmp_cuentas_perfis(numcte, cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_cuentas_perfis;
    
    RETURN vcodret1, vcodret2, vcontador;
    
    END;
    
END PROCEDURE;