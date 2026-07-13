CREATE PROCEDURE "informix".sp_consultmovschq_bei(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pTipoMov CHAR(1), pBanderaUltHora INTEGER, pRegistro INTEGER)
   RETURNING CHAR(5),DATE,CHAR(40),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(40),CHAR(4),CHAR(10) 

-------------------------------------------------------------------------------------------------------
--Folio: 1449,
--Autor: 95414878 - Roberto Castro,
--Fecha: 14/04/2014,
--Modificacion: Se crea sp para la consulta de movimientos de EmpresaNet ,
--Sustento: RQI 03 298 Logintud de referencia en consulta de movimientos EMNET.sdoc,
--Solicita: Alejandro Vazquez,
--BD: BDIBEI;
--Modificacion: Se cambie el parametro de entrada para la paginacion pRegistro de smallint a integer.
--Modifico: Berenice Noriega Guevara - BanCoppel - Internet.
--FechaMod: 13Julio2015
--Modificacion: Se cambia la descripcion de la trasaccion 0274 por la descripcion de la transaccion 0331.
--Modifico: Alejandro Vazquez - BanCoppel - Internet.
--FechaMod: 10Mayo2016
--Modificacion: Se modifica cuando es SPEI para ignorar los registros C
--Modifico: Berenice Noriega Guevara - BanCoppel - Internet.
--FechaMod: 22Mayo2018
--Modificacion: Se agrega a la salida la referencia numerica (SPEI)
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 30 Noviembre 2021
--Modificacion: Se modifica el ORDER de los queries de movimientos a solo fecha y serial
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 16 Marzo 2022
--Modificacion: Ajuste en los queries para detalles de SPEI agregando fecha del movimiento y beneficiario como filtros  para evitar duplicaciones de claves
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 09 Mayo 2022
--Modificacion: Se modifica el ORDER de los queries de movimientos a solo fecha y hora, debido a un descuadre del ID SERIAL
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 08 Diciembre 2022
--Modificacion: A solicitud de usuario, se reversa el cambio del 8 de Diciembre porque no resolvÃÂ­o el problema de ordenamiento de raiz
--Modifico: Armando Barrientos - BanCoppel - Internet.
--FechaMod: 14 Diciembre 2022
--Modificacion: Se implementa fix a la consulta de movimientos para ordenar saldos con num_serial simulado con tipo BIGINT
--Modifico: Marco Tinajero - Luis David Espinoza - Luis Baldivia - BanCoppel - Internet.
--FechaMod: 14 Octubre 2025
--Modificacion: Se actualiza la consulta para excluir resversos
--Modifico: Luis Baldivia - BanCoppel - Internet.
--FechaMod: 11 noviembre 2025
-------------------------------------------------------------------------------------------------------

  DEFINE vCodRet					CHAR(5);
  DEFINE vSqlErr, vIsamErr			INTEGER;
  DEFINE iAux 						BIGINT;
  DEFINE dFechaMov					DATE;
  DEFINE cReferencia				CHAR(40);
  DEFINE cDescripcion				CHAR(50);
  DEFINE mRetiro, 
  mDeposito, 
  mSaldo, 
  mMonto							MONEY(14, 2);
  DEFINE cNaturaleza				CHAR(1);
  DEFINE cFech_param				CHAR(10);
  DEFINE cFech_param_ini			CHAR(10);
  DEFINE vFechaHoy				DATE;
  DEFINE vTrans					CHAR(4);
  DEFINE vHrInicial DATETIME YEAR TO FRACTION(3);
  DEFINE vHrFinal DATETIME YEAR TO FRACTION(3);
  DEFINE cConceptoPago			CHAR(40);
  DEFINE cDescripcionSpei			CHAR(40);
  DEFINE dHoraMov DATETIME YEAR TO FRACTION(3);
  DEFINE cRefNumerica CHAR(10);

  LET vCodRet =		"000";
  LET dFechaMov =		'01/01/1900';
  LET vFechaHoy  =	'01/01/1900';
  LET cReferencia =	"";
  LET cDescripcion =	"";
  LET cNaturaleza =	"";
  LET mSaldo =		0;
  LET mMonto =		0;
  LET pCuenta =		TRIM(pCuenta);
  LET vTrans =		"";
  LET cConceptoPago =	"";
  LET cRefNumerica = "_";

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet, dFechaMov, cReferencia, cDescripcion, cNaturaleza, mMonto, mSaldo, cConceptoPago, vTrans, cRefNumerica;
			END IF;
		END EXCEPTION;

		--Set Debug File To '/home/informix/Berenice/sp_consultmovschq_bpi.out';
		--Trace On;
	
		--Consulta el valor de fechas limite en tabla de parametros
		SELECT valor
		INTO cFech_param
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';
		   
		SELECT valor
		INTO cFech_param_ini
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		--Consulta fecha de sistema
		SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicheq:"informix".sc_fechas;
		
		SELECT TRIM(descripcion)
			INTO cDescripcionSpei 
		FROM bdinteg:"informix".si_transacc 
		WHERE numero='0331';
		
        IF NVL(pBanderaUltHora,0) = 1 THEN
            LET vHrFinal = CURRENT; 
            LET vHrInicial= vHrFinal - INTERVAL(1) HOUR TO HOUR;
        END IF;
        
		-- Obtiene movimientos del dia
		IF pFechaInicial = vFechaHoy AND pFechaFinal = vFechaHoy THEN
			FOREACH
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
					SKIP pRegistro FIRST 10
					(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
						ELSE mm.num_serial 
					END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, 
					CASE WHEN NVL(TRIM(mm.referencia),'') = '' 
									THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
					CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
					mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero
				INTO                                                                            
					iAux, dFechaMov, dHoraMov, cReferencia, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans
				FROM    	 
					bdicheq:"informix".sc_movdia AS mm,
					bdinteg:"informix".si_transacc AS tr 
				WHERE
					mm.empresa = pEmpresa AND
					mm.cuenta = pCuenta AND
					mm.fech_alt = vFechaHoy AND
                   (pBanderaUltHora = 0  OR mm.fech_hor  between vHrInicial and vHrFinal) AND
					mm.cancelad <> "S" AND
					mm.empresa = tr.empresa AND
					mm.transacc = tr.numero AND
					tr.se_emite_edocta = "S" AND 
					tr.sistema= '01' AND
                   (pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 
					ORDER BY
							mm.fech_alt DESC,
							num_serial_nuevo DESC
				
				IF vTrans = '3333' THEN
					LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
				ELIF vTrans = '0231' THEN
					LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
					LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
				ELIF (vTrans = '3320' OR vTrans = '3321') THEN
					LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
					LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
				END IF;	

				LET cConceptoPago =	"";
				LET cRefNumerica =	"_";

				IF vTrans = '0274' OR vTrans = '0276' THEN
					SELECT vchrconceptopago2, intrefnumerica
					INTO cConceptoPago, cRefNumerica
					FROM bdispei:"informix".tblpago 
					WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
					AND cReferencia = vchrclaverastreo
					AND chrestatusenvio<>'C';

					
				END IF;

				IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
            SELECT vchrconceptopago, intrefnumerica
                INTO cConceptoPago, cRefNumerica
            FROM bdispei:"informix".tblpago 
            WHERE cReferencia = vchrclaverastreo
                AND intcvetipopago <> 0
                AND chrestatusenvio<>'C'
                AND dtfechavalor = pFechaInicial
                AND vchrnombrebenef IS NOT NULL 
                AND vchrcuentabenef IS NOT NULL;

				END IF;
				
				RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, NVL(cRefNumerica, '_') WITH RESUME;
			END FOREACH;
			
		--Consulta de movimientos incluyendo la movhis y la movdia
		ELIF pFechaInicial >= cFech_param THEN
			IF pFechaFinal = vFechaHoy THEN
				FOREACH
					SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
						SKIP pRegistro FIRST 10
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero 
					INTO                                                                           					
						iAux, dFechaMov, dHoraMov, cReferencia, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans
					FROM
						bdicheq:"informix".sc_movdia AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt = vFechaHoy AND
						mm.cancelad <> "S" AND
						mm.empresa = tr.empresa AND
						mm.transacc = tr.numero AND
						tr.se_emite_edocta = "S" AND 
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 
					UNION
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)} 
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 			
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero                          			
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 
						ORDER BY
							mm.fech_alt DESC,
							num_serial_nuevo DESC

					IF vTrans = '3333' THEN
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
					ELIF vTrans = '0231' THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
					ELIF (vTrans = '3320' OR vTrans = '3321') THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
					END IF;	
					
					
					LET cConceptoPago =	"";
					LET cRefNumerica =	"_";

					IF vTrans = '0274' OR vTrans = '0276' THEN
						IF  dFechaMov = pFechaFinal THEN
							SELECT vchrconceptopago2 , intrefnumerica
							INTO cConceptoPago , cRefNumerica
							FROM bdispei:"informix".tblpago 
							WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
							AND cReferencia = vchrclaverastreo
							AND chrestatusenvio<>'C';
 
						ELSE	
                SELECT vchrconceptopago2 , intrefnumerica
                    INTO cConceptoPago, cRefNumerica 
                FROM bdispei:"informix".tblhistpago 
                WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
                    AND cReferencia = vchrclaverastreo
                    AND chrestatusenvio<>'C'
                    AND dtfechavalor = dFechaMov
                    AND vchrnombrebenef IS NOT NULL 
                    AND vchrcuentabenef IS NOT NULL;

						END IF;
					END IF;
					
					IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
              SELECT vchrconceptopago, intrefnumerica
                  INTO cConceptoPago , cRefNumerica
              FROM bdispei:"informix".tblhistpago 
              WHERE cReferencia = vchrclaverastreo
                  AND intcvetipopago <> 0
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;
			
					RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, NVL(cRefNumerica, '_') WITH RESUME;
				END FOREACH;
			ELSE 
				FOREACH
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}
						SKIP pRegistro FIRST 10                                       			
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 			
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero
					INTO                                                                           					
						iAux, dFechaMov, dHoraMov, cReferencia, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S" AND 
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'))  
						ORDER BY
							mm.fech_alt DESC,
							num_serial_nuevo DESC	

					IF vTrans = '3333' THEN
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
					ELIF vTrans = '0231' THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
					ELIF (vTrans = '3320' OR vTrans = '3321') THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
					END IF;	
					
					LET cConceptoPago =	"";
					LET cRefNumerica =	"_";

					IF vTrans = '0274' OR vTrans = '0276' THEN
              SELECT vchrconceptopago2 , intrefnumerica
                  INTO cConceptoPago , cRefNumerica
              FROM bdispei:"informix".tblhistpago 
              WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
                  AND cReferencia = vchrclaverastreo
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;
					
					IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
              SELECT vchrconceptopago, intrefnumerica
                  INTO cConceptoPago , cRefNumerica
              FROM bdispei:"informix".tblhistpago 
              WHERE cReferencia = vchrclaverastreo
                  AND intcvetipopago <> 0
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;
		
					RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, NVL(cRefNumerica, '_') WITH RESUME;
				END FOREACH;
			END IF;	
		
		--Consulta de movimientos incluyendo la movhis_old, la mov_his y la movdia		
		ELIF pFechaInicial >= cFech_param_ini THEN
			IF pFechaFinal = vFechaHoy THEN
				FOREACH
					SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia1a)}
						SKIP pRegistro FIRST 10
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero 
					INTO                                                                           					
						iAux, dFechaMov, dHoraMov, cReferencia, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans
					FROM
						bdicheq:"informix".sc_movdia AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt = vFechaHoy AND
						mm.cancelad <> "S" AND
						mm.empresa = tr.empresa AND
						mm.transacc = tr.numero AND
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'))  
					UNION
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}                                       			
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 			
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero                          			
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S"  AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 
					UNION
					SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 
										THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero
					FROM
						bdicheq:"informix".sc_movhis_old AS mm,
						bdinteg:"informix".si_transacc AS tr 
					WHERE
						mm.empresa = pEmpresa AND
						mm.cuenta = pCuenta AND
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND
						mm.fech_alt >= cFech_param_ini AND 
						mm.cancelad <> "S" AND
						mm.transacc = tr.numero AND				
						mm.empresa = tr.empresa AND
						tr.se_emite_edocta = "S"  AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 			 
					ORDER BY
							mm.fech_alt DESC,
							num_serial_nuevo DESC

					IF vTrans = '3333' THEN
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
					ELIF vTrans = '0231' THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
					ELIF (vTrans = '3320' OR vTrans = '3321') THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
					END IF;	
					
					LET cConceptoPago =	"";
					LET cRefNumerica =	"_";

					IF vTrans = '0274' OR vTrans = '0276' THEN
						IF  dFechaMov = pFechaFinal THEN
							SELECT vchrconceptopago2 , intrefnumerica
							INTO cConceptoPago , cRefNumerica
							FROM bdispei:"informix".tblpago 
							WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
							AND cReferencia = vchrclaverastreo
							AND chrestatusenvio<>'C';

						ELSE	
                SELECT vchrconceptopago2 , intrefnumerica
                    INTO cConceptoPago , cRefNumerica
                FROM bdispei:"informix".tblhistpago 
                WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
                    AND cReferencia = vchrclaverastreo
                    AND chrestatusenvio<>'C'
                    AND dtfechavalor = dFechaMov
                    AND vchrnombrebenef IS NOT NULL 
                    AND vchrcuentabenef IS NOT NULL;

						END IF;
					END IF;
					
					IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
              SELECT vchrconceptopago, intrefnumerica
                  INTO cConceptoPago, cRefNumerica 
              FROM bdispei:"informix".tblhistpago 
              WHERE cReferencia = vchrclaverastreo
                  AND intcvetipopago <> 0
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;

					RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, NVL(cRefNumerica, '_') WITH RESUME;
				END FOREACH;
			ELSE
				FOREACH  
					SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew4)}                           				
						SKIP pRegistro FIRST 10                                             			
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = '' 			 
						THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero 
					INTO                                                                           
						iAux, dFechaMov, dHoraMov, cReferencia, cDescripcion, mMonto, cNaturaleza, mSaldo, vTrans
					FROM                                                                        			
						bdicheq:"informix".sc_movhis AS mm,                                            			
						bdinteg:"informix".si_transacc AS tr                                           			
					WHERE                                                                       			
						mm.empresa = pEmpresa AND                                           			
						mm.cuenta = pCuenta AND                                             			
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND               			
						mm.fech_alt >= cFech_param AND                                      			
						mm.cancelad <> "S" AND                                              			
						mm.transacc = tr.numero AND				            			
						mm.empresa = tr.empresa AND                                         			
						tr.se_emite_edocta = "S"  AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R'))                                           			
					UNION                                                                                           
					SELECT {+INDEX(bdicheq:"informix".sc_movhis_old movhis1)}                                                  
						(CASE WHEN char_length(to_char(mm.num_serial)) <= 8 THEN mm.num_serial + 2147483647 
							ELSE mm.num_serial 
						END) AS num_serial_nuevo, mm.fech_alt, mm.fech_hor, CASE WHEN NVL(TRIM(mm.referencia),'') = ''                     
						THEN mm.transacc ELSE TRIM(mm.referencia)  END CASE, 
						CASE WHEN  mm.transacc = '0274' AND mm.transacc_suc = '0331'
                        THEN  cDescripcionSpei ELSE tr.descripcion
                        END CASE,
						mm.monto_tot, tr.naturaleza, mm.sdo_cuenta, tr.numero                                             
					FROM                                                                                            
						bdicheq:"informix".sc_movhis_old AS mm,                                                            
						bdinteg:"informix".si_transacc AS tr                                                               
					WHERE                                                                                           
						mm.empresa = pEmpresa AND                                                               
						mm.cuenta = pCuenta AND                                                                 
						mm.fech_alt BETWEEN pFechaInicial AND pFechaFinal AND                                   
						mm.fech_alt >= cFech_param_ini AND                                                      
						mm.cancelad <> "S" AND                                                                  
						mm.transacc = tr.numero AND				                                
						mm.empresa = tr.empresa AND                                                             
						tr.se_emite_edocta = "S" AND
						tr.sistema= '01' AND
						(pTipoMov ='' OR tr.naturaleza =pTipoMov OR (pTipoMov='A' AND tr.naturaleza ='R')) 
					ORDER BY                                                                                        
							mm.fech_alt DESC,
							num_serial_nuevo DESC                                                                   
											
					IF vTrans = '3333' THEN
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 9 FOR 16));
					ELIF vTrans = '0231' THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 1 FOR 10));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 12));
					ELIF (vTrans = '3320' OR vTrans = '3321') THEN
						LET cDescripcion = TRIM(cDescripcion) || " " || TRIM(SUBSTRING(cReferencia FROM 23 FOR 36));
						LET cReferencia = TRIM(SUBSTRING(cReferencia FROM 1 FOR 2)) || TRIM(SUBSTRING(cReferencia FROM 7 FOR 20)) ;
					END IF;	
					
					LET cConceptoPago =	"";
					LET cRefNumerica =	"_";

					IF vTrans = '0274' OR vTrans = '0276' THEN
              SELECT vchrconceptopago2 , intrefnumerica
                  INTO cConceptoPago, cRefNumerica 
              FROM bdispei:"informix".tblhistpago 
              WHERE pCuenta = SUBSTRING(vchrcuentaord FROM 7 FOR 11) 
                  AND cReferencia = vchrclaverastreo
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;
					
					IF vTrans = '0273' OR vTrans = '0275' OR vTrans = '0277' THEN
              SELECT vchrconceptopago, intrefnumerica
                  INTO cConceptoPago, cRefNumerica 
              FROM bdispei:"informix".tblhistpago 
              WHERE cReferencia = vchrclaverastreo
                  AND intcvetipopago <> 0
                  AND chrestatusenvio<>'C'
                  AND dtfechavalor = dFechaMov
                  AND vchrnombrebenef IS NOT NULL 
                  AND vchrcuentabenef IS NOT NULL;

					END IF;
																					
					RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, NVL(cConceptoPago, ''), vTrans, NVL(cRefNumerica, '_') WITH RESUME;  
				END FOREACH;
			END IF;	
			--Se retorna un codigo de retorno 100 en caso de que el movimiento este fuera de los parametros establecidos             	
		ELSE
			LET vCodRet = '100';
			RETURN vCodRet, dFechaMov, NVL(cReferencia,''), cDescripcion, cNaturaleza, mMonto, mSaldo, cConceptoPago, vTrans, cRefNumerica WITH RESUME;                  
		END IF;
	END;
END PROCEDURE;