CREATE PROCEDURE "informix".sp_valida_domicilio_ife
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20)
)
RETURNING CHAR(5) AS codret , INTEGER AS secuencia;

	DEFINE cCodRet CHAR(5);
	DEFINE iSecuencia INTEGER;
	DEFINE iSql_err INTEGER;
	DEFINE cNumCredito CHAR(20);
	DEFINE iContadorCreditos INTEGER;
	DEFINE iContadorPrestamos INTEGER;
	DEFINE bBandCreditos BOOLEAN;
	DEFINE bBandPrestamos BOOLEAN;
	DEFINE dFechaHoy DATE;
	DEFINE dFechaLimite DATE;
	DEFINE dFecha_AltaId DATE;
	DEFINE vObservacionesId VARCHAR(200);
	DEFINE dFecha_AltaComp DATE;
	DEFINE vObservacionesComp VARCHAR(200);
	DEFINE dtFecUltPag DATE;
	DEFINE dtfechaalta DATE;
	DEFINE v_coddocto CHAR(4);

	LET cCodRet = '00000';
	LET iSecuencia = 0;
	LET iSql_err	 = 0;
	LET cNumCredito ='';
	LET iContadorCreditos = 0;
	LET iContadorPrestamos = 0;
	LET bBandCreditos = 'f' ;
	LET bBandPrestamos = 'f';
	LET dFecha_AltaId = '';
	LET vObservacionesId = '';
	LET dFecha_AltaComp = '';
	LET dtFecUltPag = '';
	LET dtfechaalta = '';
	LET vObservacionesComp = '';
	LET v_coddocto = '';

	BEGIN

		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet , iSecuencia ;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_valida_domicilio_ife.out";
		--TRACE ON;

		--SET DEBUG FILE TO "/respaldosbd/mc/sp_valida_domicilio_ife.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		--IF cCodRet = '00002' OR cCodRet = '00003' THEN
        let cCodRet = '00002';
			SELECT  MAX(secuencia)  INTO iSecuencia
			from "informix".si_direcciones_actual
			WHERE tipo_dir = 1 AND numcte = pNumCte;
		--END IF;

		RETURN cCodRet,iSecuencia;



		--VALIDA PARAMETROS
		IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' THEN

			SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas;





			--RESTA UN AÑO A LA FECHA HOY.
			EXECUTE PROCEDURE bdicred:"informix".monthadd(dFechaHoy,-12)  INTO dFechaLimite;

			--VALIDA SI TIENE COMO COMPROBANTE DE DOMICILIO LA IFE.
			/*IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE  ROWID = (SELECT MAX(ROWID) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE empresa = pEmpresa AND cliente = pNumCte  AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001'))) = '0001'
			AND (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente  WHERE  ROWID =  (SELECT MAX(ROWID) FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE empresa = pEmpresa AND cliente = pNumCte  AND  cod_docto IN  (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002')))  = '0033' THEN

			--OBTIENE LA FECHA DE ALTA EN LA DG_EXPEDIENTE.
			SELECT MAX(fecha_alta),MAX(observaciones)
			INTO dFecha_AltaId,vobservacionesId
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
			WHERE empresa = pEmpresa
			AND cliente = pNumCte
			AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001');

			IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE ROWID = (SELECT MAX(ROWID)
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
				WHERE empresa = pEmpresa AND cliente = pNumCte
				AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '001')
				)
				AND fecha_alta = dFecha_AltaId AND observaciones = vobservacionesId AND empresa = pEmpresa AND cliente = pNumCte) = '0001' THEN

				SELECT MAX(fecha_alta),MAX(observaciones)
				INTO dFecha_AltaComp,vObservacionesComp
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
				WHERE empresa = pEmpresa
				AND cliente = pNumCte
				AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002');


				IF (SELECT cod_docto FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img WHERE ROWID = (SELECT MAX(ROWID)
					FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img
					WHERE empresa = pEmpresa AND cliente = pNumCte
					AND cod_docto IN (SELECT cod_docto FROM  bdidigital@coppelimg_tcp:"informix".dg_tipodocumento WHERE cod_grupo = '002')
					)
					AND fecha_alta = dFecha_AltaComp AND observaciones = vObservacionesComp AND empresa = pEmpresa AND cliente = pNumCte) = '0033' THEN*/

			FOREACH
				SELECT LIMIT 1 a.cod_docto, a.fecha_alta, b.observaciones
				INTO v_coddocto,dFecha_AltaComp,vObservacionesComp
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente a, bdidigital@coppelimg_tcp:"informix".dg_expediente_img b, bdidigital@coppelimg_tcp:"informix".dg_tipodocumento c
				-- WHERE a.empresa = b.empresa
				WHERE a.cliente = b.cliente
				AND a.cod_docto = b.cod_docto
				AND a.secuencia = b.secuencia
				AND a.cliente = pNumCte
				AND a.cod_docto = c.cod_docto
				AND c.cod_grupo = '002'
				ORDER BY fecha_alta DESC, observaciones DESC
			END FOREACH;

			IF v_coddocto = '0033' THEN

					--VERIFICA SI TIENE CREDITOS
						FOREACH

							SELECT num_credito INTO cNumCredito FROM bdicred:"informix".sd_maecred WHERE empresa = pEmpresa AND numcte = pNumCte

							LET iContadorCreditos = iContadorCreditos +1;

							--REVIZA CUAL FUE SU ULTIMA FECHA DE PAGO Y LA FECHA DE ALTA
							SELECT fecha_ultimo_pago ,fecha_alta
							INTO dtFecUltPag,dtfechaalta
							FROM bdicred:"informix".sd_indicador_cred
							WHERE num_credito = cNumCredito;

							--VALIDA LA FECHA ULTIMO PAGO
							IF NVL(dtFecUltPag,DATE(1)) = DATE(1)THEN
							--VALIDA LA FECHA ALTA DEL CREDITO
								IF NVL(dtfechaalta,DATE(1)) > dFechaLimite THEN
									LET bBandCreditos = 't' ;
									EXIT FOREACH;
								ELSE
									LET bBandCreditos = 'f' ;
								END IF;
							ELIF  NVL(dtFecUltPag,DATE(1))> dFechaLimite  THEN
								LET bBandCreditos = 't' ;
								EXIT FOREACH;
							END IF

						END FOREACH;
						--VERIFICA SI TIENE PRESTAMOS
						FOREACH

							SELECT num_credito INTO cNumCredito FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa
							AND numcte = pNumCte

							LET iContadorPrestamos = iContadorPrestamos +1;

							--REVIZA CUAL FUE SU ULTIMA FECHA DE PAGO
							SELECT fecha_ultimo_pago,fecha_alta
							INTO dtFecUltPag,dtfechaalta
							FROM bdicred:"informix".sd_indicador_cred_crd
							WHERE num_credito = cNumCredito;

							IF NVL(dtFecUltPag,DATE(1)) = DATE(1)THEN
								IF NVL(dtfechaalta,DATE(1)) > dFechaLimite THEN
									LET bBandPrestamos = 't' ;
									EXIT FOREACH;
								ELSE
									LET bBandPrestamos = 'f' ;
								END IF;
							ELIF  NVL(dtFecUltPag,DATE(1))> dFechaLimite  THEN
								LET bBandPrestamos = 't';
								EXIT FOREACH;
							END IF;

						END FOREACH;

						--VALIDACION DE CREDITOS Y PRESTAMOS ASI COMO TAMBIEN SE VALIDA LA FECHA DEL ULTIMO PAGO.
						IF iContadorCreditos > 0  AND iContadorPrestamos = 0 THEN
							IF  bBandCreditos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos = 0  AND iContadorPrestamos > 0 THEN
							IF  bBandPrestamos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos > 0  AND iContadorPrestamos > 0 THEN
							IF bBandPrestamos='f' AND bBandCreditos = 'f' THEN
								LET cCodRet = '00002';
							END IF;
						ELIF iContadorCreditos = 0  AND iContadorPrestamos = 0 THEN
							LET cCodRet = '00003';
						END IF;
					--END IF;
				--END IF;
				END IF;
			ELSE
				LET cCodRet = '00001';
			END IF;


	END;
END PROCEDURE
DOCUMENT
"Folio:1586",
"Autor:95142134 Mario Gallardo",
"Fecha:27/02/2014",
"Modificación: Se crea SP para vailidar que el domicilio de el cliente sea el mismo que el de la IFE",
"Sustento: RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Jaime Garciadiego, Juan Miguel Rivas ",
"BD: bdinteg",
"Folio:1430",
"Autor:Ivan Garcia",
"Fecha:27/05/2014",
"Modificación: Se modifica SP para obtener correctamente si la credencial de elector fue digitalizada como identificacion y como comprobante de domicilio",
"Sustento:RQM 09 337 Mantenimiento de Datos y OS para Domicilio diferente al IFE_0001_v1.0.pdf",
"Solicita: Angeles Perez,Rodolfo Gomez",
"BD: bdinteg",
'Modifica: Mario Gamaliel Olivo Urias',
'Solicita: Rodolfo Gomez',
'Modificacion: Se modifica la validacion de la ultima fecha de pago.',
'BD: bdinteg',
'FOLIO:1663',
'BD:bdinteg',
'MODIFICACION:Se modifica procedimiento para validar que el cliente haya presentado su credencial de elector(IFE) como identificación y',
'comprobante de domicilio. Si la validación es correcta consulta si cuenta con algun crédito o prestamo para tomar su fecha de ultimo pago.',
'Cuando el valor de la fecha de ultimo pago sea igual a null,se consultara con la fecha de alta y en caso de ser menor a la fecha limite,', 'mandara un código de retorno que otro componente interpretara.',
'AUTOR:Isarai Bojorquez',
'FECHA:20140911.1200';

CREATE PROCEDURE "informix".sp_obtiene_cterfc( pRfc CHAR(13))

RETURNING CHAR(5) AS codret , 
	      CHAR(9) as numcte;

DEFINE vCodret CHAR (5);
DEFINE vNumcte CHAR (20);
DEFINE vSql_err INTEGER;  

LET vCodret  = '00000';
LET vNumcte  = '';
LET vSql_err = 0;

 BEGIN

     ON EXCEPTION SET vSql_err
        IF vSql_err <> 0 THEN
           LET vCodret = vSql_err;
           RETURN vCodret, vNumcte ;
        END IF;
     END EXCEPTION;
     
     --SET DEBUG FILE TO "/tmp/sp_obtiene_cterfc.out";
     --TRACE ON;

     SET LOCK MODE TO WAIT 3;
     SET ISOLATION TO DIRTY READ;

     IF pRfc is null or pRfc ="" THEN 
        LET vCodret = '00002' ; -- Falta parametro de entrada
        RETURN vCodret, vNumcte ;

     END IF;

     SELECT LIMIT 1 numcte 
     INTO vNumcte
     FROM si_cliente 
     WHERE rfc = pRfc; 
 
     LET vNumcte = NVL(vNumcte,'');

     RETURN vCodret, vNumcte ;
 END;
END PROCEDURE;