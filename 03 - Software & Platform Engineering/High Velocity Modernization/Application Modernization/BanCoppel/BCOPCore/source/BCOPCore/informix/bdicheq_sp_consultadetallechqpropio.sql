CREATE PROCEDURE "informix".sp_consultadetallechqpropio(pConcepto CHAR(1), pEstatus CHAR(2), pParticular CHAR(20), pFechaInicial CHAR(10), pFechaFinal CHAR(10))
RETURNING CHAR(6)       AS cod_retorno,
		  DATE          AS fecha_alta,
		  CHAR(20)      AS cuenta,
		  CHAR(20)       AS estatus_cuenta,
		  VARCHAR(110)  AS nom_cte,
		  CHAR(45)      AS suc_apert,
		  CHAR(40)      AS plaza_suc_aper,
		  INTEGER       AS chequera,
		  VARCHAR(50)   AS estatus_chequera,
		  INTEGER       AS cheque,
		  VARCHAR(50)   AS estatus_cheque,
		  MONEY(15,2)   AS monto_cheque,
		  INTEGER       AS no_cheq_gir,
		  MONEY(15,2)   AS monto_cheq_gir,
		  INTEGER       AS no_cheq_devuelt,
		  MONEY(15,2)   AS monto_cheq_dev,
		  INTEGER       AS num_cheq_pag,
		  MONEY (15,2)  AS monto_cheq_pag,
	      INTEGER       AS cheq_dev_suc,
		  INTEGER       AS cheq_dev_cam,
		  CHAR(2)       AS causa_devol;

	--DECLARACIONES
	DEFINE cCodRet            CHAR(6);
	DEFINE iSqlErr            INTEGER;
	DEFINE dFechaActual       DATE;
	DEFINE dtFechaMinima      DATE;
	DEFINE pCliente           CHAR(20);
	DEFINE pCuenta            CHAR(20);
	DEFINE pChequera          INTEGER;
	DEFINE pCheque            INTEGER;
	DEFINE dtFechaInicial     DATE;
	DEFINE dtFechaFinal       DATE;
	DEFINE dtFechaAlta        DATE;
	DEFINE cCuenta            CHAR(20);
	DEFINE cEstatusCta        CHAR(20);
	DEFINE vNombreCte         VARCHAR(110);
	DEFINE cSucursalApertura  CHAR(45);
	DEFINE cPlazaSucApertura  CHAR(40);
	DEFINE iChequera          INTEGER;
	DEFINE vEstatusChequera   VARCHAR(50);
	DEFINE iCheque            INTEGER;
	DEFINE vEstatusCheque     VARCHAR(50);
	DEFINE mMonCheque         MONEY (15,2);
	DEFINE iNumCheqGir        INTEGER;
	DEFINE mMonCheqGir        MONEY (15,2);
	DEFINE iMaximaSecuencia   INTEGER;
	DEFINE iInicial           INTEGER;
	DEFINE iFinal             INTEGER;
	DEFINE iNoCheqDev         INTEGER;
	DEFINE mMonCheqDev        MONEY(15,2);
	DEFINE mMonCheqDevCam     MONEY(15,2);
	DEFINE mMonCheqDevSuc     MONEY(15,2);
	DEFINE iNoCheqPag         INTEGER;
	DEFINE mMonCheqPag        MONEY(15,2);
	DEFINE iNoCheqDevSuc      INTEGER;
	DEFINE iNoCheqDevCam      INTEGER;
	DEFINE cSQL              CHAR(5000);
	DEFINE sFlag             SMALLINT;
	DEFINE iWhile            INTEGER;
	--------ADECUACION
	DEFINE cMotDevol         CHAR(2);
	DEFINE cEstatusCheque    CHAR(1);

	--INICIALIZACIONES
	LET cCodRet            = '000000';
	LET iSqlErr            = 0;
	LET dFechaActual       = DATE(1);
	LET dtFechaMinima      = DATE(1);
	LET pCliente           = '';
	LET pCuenta            = '';
	LET pChequera          = 0;
	LET pCheque            = 0;
	LET dtFechaInicial     = DATE(1);
	LET dtFechaFinal       = DATE(1);
	LET dtFechaAlta        = DATE(1);
	LET cCuenta            = '';
	LET cEstatusCta        = '';
	LET vNombreCte         = '';
	LET cSucursalApertura  = '';
	LET cPlazaSucApertura  = '';
	LET iChequera          = 0;
	LET vEstatusChequera   = '';
	LET iCheque            = 0;
	LET vEstatusCheque     = '';
	LET mMonCheque         = 0.00;
	LET iNumCheqGir        = 0;
	LET mMonCheqGir        = 0.00;
	LET iMaximaSecuencia   = 0;
	LET iInicial           = 0;
	LET iFinal             = 0;
	LET iNoCheqDev         = 0;
	LET mMonCheqDevSuc     = 0.00;
	LET mMonCheqDevCam     = 0.00;
	LET mMonCheqDev        = 0.00;
	LET iNoCheqPag         = 0;
	LET mMonCheqPag        = 0.00;
	LET iNoCheqDevSuc      = 0;
	LET iNoCheqDevCam      = 0;
	LET cSQL               = '';
	LET sFlag              = 0;
	LET iWhile             = 0;
	--------ADECUACION
	LET cMotDevol         = '';
	LET cEstatusCheque    = '';

	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_consultadetallechqpropio.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		--************************************************************************************
		--*****************************CONTROL DE ERRORES POR PARAMETROS**********************
		--************************************************************************************
		IF NVL(pConcepto,'') = '' OR NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
			LET cCodRet = '000001'; --PARAMETROS OBLIGATORIOS VACIOS O NULOS
		ELIF NVL(pConcepto,'') NOT IN ('1','2','3','4')  THEN
			LET cCodRet = '000002'; --TIPO DE BUSQUEDA INVALIDA
		END IF;
		--SI CAYO EN ALGUNO DE LOS FLUJOS ANTERIORES SE SALE CON EL CODIGO ASIGNADO PREVIAMENTE
		IF cCodRet <> '000000' THEN
			RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
		END IF;

		--SET EXPLAIN FILE TO '/dbexportb/carlos/adecuacion/explain.out';

		SELECT fecha_hoy
		INTO dFechaActual
		FROM "informix".sc_fechas
		WHERE empresa = '001';

		LET dtFechaMinima = dFechaActual - 60 UNITS DAY;

		LET dtFechaInicial =  TO_DATE(pFechaInicial,"%Y-%m-%d");
		LET dtFechaFinal = TO_DATE(pFechaFinal,"%Y-%m-%d");

		IF dtFechaInicial > dtFechaFinal THEN
			LET cCodRet = '435'; --FECHA INICIAL NO DEBE SER MAYOR A LA FECHA FINAL
		ELIF  dtFechaInicial > dFechaActual THEN
			LET cCodRet = '436'; --FECHA INICIAL NO DEBE SER MAYOR A LA FECHA ACTUAL
		ELIF dtFechaFinal > dFechaActual THEN
			LET cCodRet = '437'; --FECHA FINAL NO DEBE SER MAYOR A LA FECHA ACTUAL
		ELIF dtFechaInicial < dtFechaMinima THEN
			LET cCodRet = '040'; --SOLO SE PERMITIRA LA CONSULTA EN UN RANGO DE 60 DIAS
		END IF;

		--SI CAYO EN ALGUNO DE LOS FLUJOS ANTERIORES SE SALE CON EL CODIGO ASIGNADO PREVIAMENTE
		IF cCodRet <> '000000' THEN
			RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
		END IF;

		--************************************************************************************
		--*****************************       BLOQUE DE CONSULTAS       **********************
		--************************************************************************************

		IF pConcepto = '1' THEN --CLIENTE
			LET pCliente = TRIM(pParticular);
			LET pCuenta = '';
			LET pChequera = 0;
			LET pCheque = 0;
		ELIF pConcepto = '2' THEN --CUENTA
			LET pCuenta = TRIM(pParticular);
			LET pCliente = '';
			LET pChequera = 0;
			LET pCheque = 0;
		ELIF pConcepto = '3' THEN --CHEQUERA
			LET pChequera = TRIM(pParticular)::INTEGER;
			LET pCliente = '';
			LET pCuenta = '';
			LET pCheque = 0;
		ELIF pConcepto = '4' THEN --CHEQUE
			LET pCheque = TRIM(pParticular);
			LET pCliente = '';
			LET pCuenta = '';
			LET pChequera = 0;
		ELSE
			LET cCodRet = '000004'; --TIPO DE BUSQUEDA INVALIDO
			RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
		END IF;


		IF pConcepto IN ('2') THEN
			LET cSql = ' SELECT noc.fecha_alta, noc.cuenta, chq.status_cta, (CASE WHEN ti.es_fisica = ''S'' THEN'||
			'(TRIM(NVL(cli.nombre1,""))||" "||TRIM(NVL(cli.nombre2,""))||" "||TRIM(NVL(cli.apell_paterno,""))||" "||'||
			'TRIM(NVL(cli.apell_materno,""))) WHEN  ti.es_fisica = ''N'' THEN  (TRIM(NVL(cli.razon_social,""))) END) AS'||
			'nombre,(suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		ELIF pConcepto IN ('3') THEN
			LET cSql = ' SELECT sqmae.fecha_act, noc.cuenta, chq.status_cta, (CASE WHEN ti.es_fisica = ''S'' THEN'||
			'(TRIM(NVL(cli.nombre1,""))||" "||TRIM(NVL(cli.nombre2,""))||" "||TRIM(NVL(cli.apell_paterno,""))||" "||'||
			'TRIM(NVL(cli.apell_materno,""))) WHEN  ti.es_fisica = ''N'' THEN  (TRIM(NVL(cli.razon_social,""))) END) AS'||
			'nombre,(suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		ELSE
			LET cSql = ' SELECT scon.fecha_alta, noc.cuenta, chq.status_cta, (CASE WHEN ti.es_fisica = ''S'' THEN'||
			'(TRIM(NVL(cli.nombre1,""))||" "||TRIM(NVL(cli.nombre2,""))||" "||TRIM(NVL(cli.apell_paterno,""))||" "||'||
			'TRIM(NVL(cli.apell_materno,""))) WHEN  ti.es_fisica = ''N'' THEN  (TRIM(NVL(cli.razon_social,""))) END) AS'||
			'nombre,(suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		END IF;

		IF pConcepto = '3' THEN
				LET cSql = TRIM(cSql) || ' , ( sqmae.consec) AS chequera, (sq.descripcion) AS estatus_chequera ' ;
		ELIF pConcepto IN ('1','4') THEN
				LET cSql = TRIM(cSql) || ' ,(COUNT(scon.estado))AS no_chqes_girados, (SUM(scon.importe)) AS monto_cheques_girados ' ;

		END IF;

		IF pConcepto IN ('2') THEN
			LET cSql = TRIM(cSql) || ' FROM "informix".sc_maechq chq INNER JOIN  "informix".sc_maenoc noc ON (noc.cuenta = chq.cuenta AND noc.fecha_alta BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'") INNER JOIN bdinteg: "informix".si_cliente cli ON(cli.numcte = chq.num_cte) INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = chq.sucursal) INNER JOIN bdinteg:"informix".si_tipper ti ON (cli.tpo_persona = ti.tpo_persona) ';
		ELSE
			LET cSql = TRIM(cSql) || ' FROM "informix".sc_maechq chq INNER JOIN  "informix".sc_maenoc noc ON (noc.cuenta = chq.cuenta AND noc.fecha_alta = noc.fecha_alta)   INNER JOIN bdinteg: "informix".si_cliente cli ON(cli.numcte = chq.num_cte) INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = chq.sucursal) INNER JOIN bdinteg:"informix".si_tipper ti ON (cli.tpo_persona = ti.tpo_persona) ';
		END IF;

		IF pConcepto = '3' THEN
			LET cSql = TRIM(cSql) || ' INNER JOIN bdicntchq:"informix".sq_maechqra sqmae ON (sqmae.empresa = "001" AND sqmae.cuenta = chq.cuenta AND sqmae.consec = (SELECT {+INDEX(bdicntchq:"informix".sq_maechqra idxmaechqraemp)} MAX(sma.consec) FROM bdicntchq:"informix".sq_maechqra sma  WHERE sma.empresa = "001" AND sma.status= sma.status AND sma.cuenta = sqmae.cuenta AND sma.consec =  ';
			IF NVL(pChequera,0) <> 0 THEN
				LET cSql = TRIM(cSql) || ' '||pChequera||'  ';
			ELSE
					LET cSql = TRIM(cSql) || ' sma.consec ';
			END IF;

			IF NVL(pEstatus,'') <> '' THEN
					LET cSql = TRIM(cSql) || ' AND sma.status = SUBSTR("'||pEstatus||'",2,1) ' ;
			ELSE
					LET cSql = TRIM(cSql) || ' AND sma.status = sma.status ' ;
			END IF;

			LET cSql = TRIM(cSql) || ' )) '; --PARA CERRAR EL SUBQUERY Y EL INNER JOIN

		ELIF pConcepto IN ('1','4') THEN
			LET cSql = TRIM(cSql) || ' INNER JOIN "informix".sc_contch scon ON (scon.empresa = "001" AND scon.cuenta = chq.cuenta AND scon.estado NOT IN("E","A","C","S") AND (scon.cuenta = noc.cuenta) ';

			IF NVL(pCheque,0) <> 0 AND pConcepto = '4' THEN
					LET cSql = TRIM(cSql) || ' AND scon.numero = '||pCheque||' ';
			END IF;
			IF pConcepto IN ('1')  OR  NVL(pCheque,0) = 0 AND pConcepto = '4' THEN
				LET cSql = TRIM(cSql) || ' AND scon.consec = (SELECT {+INDEX(bdicntchq:"informix".sq_maechqra idxmaechqraemp)} MAX(sma.consec) FROM bdicntchq:"informix".sq_maechqra sma  WHERE sma.status= sma.status AND sma.cuenta = scon.cuenta AND sma.consec = sma.consec)) ';
			ELSE 
				LET cSql = TRIM(cSql) || ' ) ';
			END IF
			 
		END IF;


		LET cSql = TRIM(cSql) || ' ,"informix".sc_producto prod, bdinteg:"informix".si_plazas plaz  ';

		IF pConcepto IN ('1','3','4') THEN
			LET cSql = TRIM(cSql) || ' ,bdicntchq:"informix".sq_status_chequera sq ';
		END IF;


		IF NVL(pCliente,'') <> '' AND pConcepto = '1' THEN
			LET cSql = TRIM(cSql) || ' 	WHERE chq.num_cte =  "'||pCliente||'" ';
		ELSE
			LET cSql = TRIM(cSql) || ' 	WHERE chq.num_cte =  chq.num_cte  ';
		END IF;

		IF NVL(pCuenta,'') <> '' AND pConcepto = '2' THEN
			LET cSql = TRIM(cSql) || ' 	AND chq.cuenta = "'||pCuenta||'"  ';
		ELIF pConcepto IN ('3','4') THEN
			LET cSql = TRIM(cSql) || ' 	AND chq.cuenta = chq.cuenta  ';
		END IF;

		IF NVL(pEstatus,'') <> '' AND pConcepto IN ('2') THEN
			LET cSql = TRIM(cSql) || ' 	AND chq.status_cta = "'||pEstatus||'"   ';
		ELIF pConcepto IN ('1','3','4') THEN
			LET cSql = TRIM(cSql) || ' 	AND chq.status_cta = chq.status_cta  ';
		END IF;


		LET cSql = TRIM(cSql) || ' AND prod.empresa = "001" AND prod.producto = chq.producto  AND prod.val_chequeras = "S"  AND plaz.plaza = suc.plaza ';


		IF pConcepto = '3' THEN
			LET cSql = TRIM(cSql) || ' AND sq.clave = "1" AND sq.clave||sq.status = ' ;
			IF NVL(pEstatus,'') <> '' THEN
					LET cSql = TRIM(cSql) || ' "'||pEstatus||'"  AND sqmae.fecha_act BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'" ' ;
			ELSE
					LET cSql = TRIM(cSql) || ' sq.clave||sq.status AND sqmae.fecha_act BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'" ' ;
			END IF;

			--RELACION DEL CATALOGO CON EL DATO EN TABLA
			LET cSql = TRIM(cSql) || ' AND "1"||sqmae.status = sq.clave||sq.status ' ;

		ELIF pConcepto IN ('1','4') THEN
			LET cSql = TRIM(cSql) || ' AND sq.clave = "2" AND sq.status = sq.status AND sq.clave||sq.status = ' ;
			IF NVL(pEstatus,'')<> '' THEN
				LET cSql = TRIM(cSql) || ' "'||pEstatus||'" ' ;
			ELSE
				LET cSql = TRIM(cSql) || ' sq.clave||sq.status AND scon.fecha_alta BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'" ' ;
			END IF;

			--CAMBIO HECHO PARA LA ADECUACION DE CHEQUES
			--RELACION DEL CATALOGO CON DATO EN TABLA
			IF NVL(pEstatus,'') <> '' THEN
					LET cSql = TRIM(cSql) || ' AND sq.clave||scon.estado = "'||pEstatus||'"  AND scon.estado IN ("M","P","N","U") AND scon.fecha_alta BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'"';

			ELSE
					LET cSql = TRIM(cSql) || ' AND sq.clave||scon.estado = sq.clave||scon.estado  AND scon.estado IN ("M","P","N","U")' ;
			END IF;

		END IF;


		IF pConcepto IN ('1','2','4') THEN
			LET cSql = TRIM(cSql) || ' GROUP BY 1,2,3,4,5,6 ';
		ELIF pConcepto = '3' THEN
			LET cSql = TRIM(cSql) || ' GROUP BY 1,2,3,4,5,6,7,8 ';
		END IF;


		LET cSql = TRIM(cSql) || ' ORDER BY 2	  ';


		LET cSql = TRIM(cSql) ;

	PREPARE xsql FROM TRIM(cSql);
		DECLARE xcur CURSOR FOR xsql;
		OPEN xcur;
				LET cCuenta = '';
				IF pConcepto IN ('2') THEN
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
				ELIF pConcepto = '3'  THEN
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
				ELIF pConcepto IN ('1','4') THEN
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
				END IF;


				---SI NO ENCUENTRA REGISTROS CON LOS PARAMETROS INDICADOS SE SALE DEL FOREACH Y CAE AQUI
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '598'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
					RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
				END IF;

			WHILE  SQLCODE= 0 --Si encuentra registros el cursor
				LET iWhile = 1;
				IF cEstatusCta = '1' THEN
					LET cEstatusCta = 'Activa';
				ELIF cEstatusCta = '2' THEN
					LET cEstatusCta = 'Cancelada';
				ELIF cEstatusCta = '3' THEN
					LET cEstatusCta = 'Bloqueada';
				ELIF cEstatusCta = '4' THEN
					LET cEstatusCta = 'Inactiva';
				ELIF cEstatusCta = '5' THEN
					LET cEstatusCta = 'Informada';
				ELIF cEstatusCta = '6' THEN
					LET cEstatusCta = 'Concentrada';
				ELIF cEstatusCta = '7' THEN
					LET cEstatusCta = 'Traspasada';
				ELIF cEstatusCta = '8' THEN
					LET cEstatusCta = 'Desconcentrada';
				END IF;

				LET sFlag = 0;

				IF pConcepto IN ('1','2','4')THEN
				
					IF pConcepto IN ('1','2') THEN
						--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA
						SELECT MAX(sma.consec)
						INTO iMaximaSecuencia
						FROM bdicntchq:"informix".sq_maechqra sma
						WHERE sma.status= sma.status
						AND sma.cuenta = TRIM(cCuenta)
						AND sma.consec = sma.consec;
						
					END IF
					
					IF pConcepto = '4' AND NVL(pCheque,0) = 0 THEN
						--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA
						SELECT MAX(sma.consec)
						INTO iMaximaSecuencia
						FROM bdicntchq:"informix".sq_maechqra sma
						WHERE sma.status= sma.status
						AND sma.cuenta = TRIM(cCuenta)
						AND sma.consec = sma.consec;
					END IF
					
					
					IF pConcepto = '4' AND NVL(pCheque,0) <> 0 THEN
						--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA
						SELECT scon.consec
						INTO iMaximaSecuencia
						FROM "informix".sc_contch scon
						WHERE scon.cuenta = TRIM(cCuenta)
						AND scon.numero = NVL(pCheque,0)
						AND scon.consec = scon.consec;
						
						
						
					END IF
					
					IF iMaximaSecuencia IS NULL THEN

						---SI NO ENCUENTRA REGISTROS CON LOS PARAMETROS INDICADOS SE SALE DEL FOREACH Y CAE AQUI
						IF SQLCODE <> 0 THEN
							LET cCodRet = '598'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
							RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
						END IF;

						--CONTINUE WHILE;
						IF pConcepto IN ('2') THEN
							LET iWhile = 0;
							LET cCuenta = '';
							LET sFlag = 1;
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
							CONTINUE WHILE;
						ELIF pConcepto = '3' THEN
							LET iWhile = 0;
							LET cCuenta = '';
							LET sFlag = 1;
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
							CONTINUE WHILE;
						ELIF pConcepto IN ('1','4') THEN
							LET iWhile = 0;
							LET cCuenta = '';
							LET sFlag = 1;
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
							CONTINUE WHILE;
						END IF;

					END IF;

						--CHEQUERA
						SELECT (sqmae.consec) AS chequera, (sq.descripcion) AS estatus_chequera
						INTO iChequera, vEstatusChequera
						FROM  bdicntchq:"informix".sq_maechqra sqmae , bdicntchq:"informix".sq_status_chequera sq
						WHERE  sqmae.cuenta = TRIM(cCuenta)
						AND sqmae.consec = sqmae.consec
						AND sqmae.status = sq.status
						AND sqmae.consec = iMaximaSecuencia --MAXIMA SECUENCIA DE LA CUENTA
						AND sq.clave = '1';

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						---SI NO ENCUENTRA REGISTROS CON LOS PARAMETROS INDICADOS SE SALE DEL FOREACH Y CAE AQUI
						IF SQLCODE <> 0 THEN
							LET cCodRet = '598'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
							RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
						END IF;

						--CONTINUE WHILE;
						IF pConcepto IN ('2') THEN
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
							CONTINUE WHILE;
						ELIF pConcepto = '3' THEN
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
							CONTINUE WHILE;
						ELIF pConcepto IN ('1','4') THEN
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
							CONTINUE WHILE;
						END IF;

					END IF;
				END IF;


				IF NVL(pCheque,0) = 0 THEN
					IF pConcepto IN ('1','2','3') THEN
						LET pEstatus = '';
					END IF;

					FOREACH
								--OBTENEMOS LOS DISTINTOS CHEQUES DE LA CUENTA ASI COMO EL IMPORTE QUE MANEJAN
								SELECT DISTINCT(scon.numero) AS cheque, sta.descripcion , scon.importe, scon.estado
								INTO iCheque, vEstatusCheque, mMonCheque, cEstatusCheque
								FROM "informix".sc_contch scon
								INNER JOIN bdicntchq:"informix".sq_status_chequera sta ON (sta.clave = '2' AND sta.status = scon.estado AND sta.clave||sta.status = DECODE(NVL(pEstatus,''), '', sta.clave||sta.status, pEstatus) )
								WHERE scon.cuenta = TRIM(cCuenta)
								AND scon.estado NOT IN('E','A','C','S')
								AND scon.numero = scon.numero
								AND scon.consec = iChequera
								AND scon.fecha_alta = CASE WHEN pConcepto IN ('1','4') THEN dtFechaAlta ELSE scon.fecha_alta END
								GROUP BY 1,2,3,4

								--SI LA BUSQUEDA ES POR CHEQUE SE OMITIRAN LOS ESTATUS QUE NO SEAN LOS PERMITIDOS
								IF pConcepto IN ('1','4') AND cEstatusCheque NOT IN ('M','P','N','U') THEN
									CONTINUE FOREACH;
								END IF;

								LET iWhile = 1;

								IF pConcepto IN ('1','4') THEN
									-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
									SELECT (COUNT(scon.estado))AS no_chqes_girados,
									(SUM(scon.importe)) AS monto_cheques_girados
									INTO iNumCheqGir, mMonCheqGir
									FROM "informix".sc_contch scon
									WHERE scon.cuenta = TRIM(cCuenta)
									AND scon.estado NOT IN('E','A','C','S')
									AND scon.numero = scon.numero
									AND scon.consec = iChequera --MAXIMA SECUENCIA DE LA CUENTAz
									AND scon.fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal;
								ELSE
									-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
									SELECT (COUNT(scon.estado))AS no_chqes_girados,
									(SUM(scon.importe)) AS monto_cheques_girados
									INTO iNumCheqGir, mMonCheqGir
									FROM "informix".sc_contch scon
									WHERE scon.cuenta = TRIM(cCuenta)
									AND scon.estado NOT IN('E','A','C','S')
									AND scon.numero = scon.numero
									AND scon.consec = iChequera --MAXIMA SECUENCIA DE LA CUENTA
									AND scon.fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);
								END IF;

								--SE OBTIENE: NUM DE CHEQUES DEVUELTOS
								--SE OBTIENE EL VALOR INICIAL Y FINAL DE LA CUENTA CON EL MAXIMO CONSECUTIVO
								SELECT inicial, final
								INTO iInicial, iFinal
								FROM bdicntchq:"informix".sq_maechqra
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera;

								--SE OBTIENE: NUMERO DE CHEQUES PAGADOS, MONTO DE CHEQUES PAGADOS
								SELECT (COUNT(estado)) AS no_cheques_pagados, SUM (importe) AS monto_cheques_pagados
								INTO iNoCheqPag, mMonCheqPag
								FROM "informix".sc_contch
								WHERE consec = iChequera
								AND cuenta = TRIM(cCuenta)
								AND estado IN ('P','M')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								--SE OBTIENE: CHEQUES DEVUELTOS EN SUC
								SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
								INTO iNoCheqDevSuc, mMonCheqDevSuc
								FROM "informix".sc_contch
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera
								AND estado IN ('U')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								--SE OBTIENE: CHEQUES DEVUELTOS EN CAMARA
								SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
								INTO iNoCheqDevCam, mMonCheqDevCam
								FROM "informix".sc_contch
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera
								AND estado IN ('N')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								LET iNoCheqDev = iNoCheqDevCam + iNoCheqDevSuc;
								LET mMonCheqDev = mMonCheqDevCam + mMonCheqDevSuc;

								---------------------**
								--SE OBTIENE LA CAUSA DE DEVOLUCION
								SELECT mot_devol
								INTO cMotDevol
								FROM bditef:"informix".cce_propios_det
								WHERE c_cheque = iCheque
								AND c_cuenta  = TRIM(cCuenta);

								---------------------**
								RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') WITH RESUME;

							END FOREACH;

						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
								LET sFlag = 1;

								IF pConcepto IN ('2') THEN
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
								ELIF pConcepto = '3' THEN
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
								ELIF pConcepto IN ('1','4') THEN
									LET iWhile = 0;
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
								END IF;

						END IF;


				ELIF NVL(pCheque,0) <> 0 THEN
						FOREACH
								--OBTENEMOS LOS DISTINTOS CHEQUES DE LA CUENTA ASI COMO EL IMPORTE QUE MANEJAN
								SELECT DISTINCT(scon.numero) AS cheque, sta.descripcion , scon.importe, scon.estado
								INTO iCheque, vEstatusCheque, mMonCheque, cEstatusCheque
								FROM "informix".sc_contch scon
								INNER JOIN bdicntchq:"informix".sq_status_chequera sta ON (sta.clave = '2' AND sta.status = scon.estado AND sta.clave||sta.status = DECODE(NVL(pEstatus,''), '',sta.clave||sta.status,pEstatus))
								WHERE scon.cuenta = TRIM(cCuenta)
								AND scon.estado NOT IN('E','A','C','S')
								AND scon.numero = pCheque
								AND scon.consec = iChequera
								AND scon.fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END)
								GROUP BY 1,2,3,4

								--SI LA BUSQUEDA ES POR CHEQUE SE OMITIRAN LOS ESTATUS QUE NO SEAN LOS PERMITIDOS
								IF pConcepto IN ('1','4') AND cEstatusCheque NOT IN ('M','P','N','U') THEN
									CONTINUE FOREACH;
								END IF;

								LET iWhile = 1;

								IF pConcepto IN ('1','4') THEN
									-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
									SELECT (COUNT(scon.estado))AS no_chqes_girados,
									(SUM(scon.importe)) AS monto_cheques_girados
									INTO iNumCheqGir, mMonCheqGir
									FROM "informix".sc_contch scon
									WHERE scon.cuenta = TRIM(cCuenta)
									AND scon.estado NOT IN('E','A','C','S')
									AND scon.numero = scon.numero
									AND scon.consec = iChequera --MAXIMA SECUENCIA DE LA CUENTA
									AND scon.fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal;
								ELSE
									-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
									SELECT (COUNT(scon.estado))AS no_chqes_girados,
									(SUM(scon.importe)) AS monto_cheques_girados
									INTO iNumCheqGir, mMonCheqGir
									FROM "informix".sc_contch scon
									WHERE scon.cuenta = TRIM(cCuenta)
									AND scon.estado NOT IN('E','A','C','S')
									AND scon.numero = scon.numero
									AND scon.consec = iChequera --MAXIMA SECUENCIA DE LA CUENTA
									AND scon.fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);
								END IF;

								--SE OBTIENE: NUM DE CHEQUES DEVUELTOS
								--SE OBTIENE EL VALOR INICIAL Y FINAL DE LA CUENTA CON EL MAXIMO CONSECUTIVO
								SELECT inicial, final
								INTO iInicial, iFinal
								FROM bdicntchq:"informix".sq_maechqra
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera;

								--SE OBTIENE: NUMERO DE CHEQUES PAGADOS, MONTO DE CHEQUES PAGADOS
								SELECT (COUNT(estado)) AS no_cheques_pagados, SUM (importe) AS monto_cheques_pagados
								INTO iNoCheqPag, mMonCheqPag
								FROM "informix".sc_contch
								WHERE consec = iChequera
								AND cuenta = TRIM(cCuenta)
								AND estado IN ('P','M')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								--SE OBTIENE: CHEQUES DEVUELTOS EN SUC
								SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
								INTO iNoCheqDevSuc, mMonCheqDevSuc
								FROM "informix".sc_contch
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera
								AND estado IN ('U')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								--SE OBTIENE: CHEQUES DEVUELTOS EN CAMARA
								SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
								INTO iNoCheqDevCam, mMonCheqDevCam
								FROM "informix".sc_contch
								WHERE cuenta = TRIM(cCuenta)
								AND consec = iChequera
								AND estado IN ('N')
								AND fecha_alta BETWEEN (CASE WHEN pConcepto IN ('1','4') THEN dtFechaInicial ELSE DATE((SELECT MIN(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END) AND (CASE WHEN pConcepto IN ('1','4') THEN dtFechaFinal ELSE DATE((SELECT MAX(fecha_alta) FROM "informix".sc_contch WHERE cuenta = TRIM(cCuenta))) END);

								LET iNoCheqDev = iNoCheqDevCam + iNoCheqDevSuc;
								LET mMonCheqDev = mMonCheqDevCam + mMonCheqDevSuc;

								---------------------**
								--SE OBTIENE LA CAUSA DE DEVOLUCION
								SELECT mot_devol
								INTO cMotDevol
								FROM bditef:"informix".cce_propios_det
								WHERE c_cheque = iCheque
								AND c_cuenta  = TRIM(cCuenta);

								---------------------**
								RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') WITH RESUME;

							END FOREACH;

					IF DBINFO("sqlca.sqlerrd2") = 0 AND iCheque = 0 THEN
						LET sFlag = 1;

								IF pConcepto IN ('2') THEN
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
								ELIF pConcepto = '3' THEN
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
								ELIF pConcepto IN ('1','4') THEN
									FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
								END IF;

					END IF;

				END IF;

				IF pConcepto IN ('2') AND sFlag = 0 THEN
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura;
				ELIF pConcepto = '3' AND sFlag = 0 THEN
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera, vEstatusChequera;
				ELIF pConcepto IN ('1','4') AND sFlag = 0 THEN
					LET iWhile = 0;
					FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iNumCheqGir, mMonCheqGir;
				END IF;
			END WHILE;

			IF (iWhile = 0 AND NVL(cCuenta,'') = '') AND (sFlag = 1 AND DBINFO("sqlca.sqlerrd2") = 0 ) OR ( NVL(iCheque,0) = 0 AND DBINFO("sqlca.sqlerrd2") = 0) OR ( NVL(iCheque,0) = 0 AND sFlag = 1) THEN

				LET dtFechaAlta        = DATE(1);
				LET cCuenta            = '';
				LET cEstatusCta        = '';
				LET vNombreCte         = '';
				LET cSucursalApertura  = '';
				LET cPlazaSucApertura  = '';
				LET iChequera          = 0;
				LET vEstatusChequera   = '';
				LET iCheque            = 0;
				LET vEstatusCheque     = '';
				LET mMonCheque         = 0.00;
				LET iNumCheqGir        = 0;
				LET mMonCheqGir        = 0.00;
				LET iMaximaSecuencia   = 0;
				LET iInicial           = 0;
				LET iFinal             = 0;
				LET iNoCheqDev         = 0;
				LET mMonCheqDev        = 0.00;
				LET iNoCheqPag         = 0;
				LET mMonCheqPag        = 0.00;
				LET iNoCheqDevSuc      = 0;
				LET iNoCheqDevCam      = 0;

				LET cCodRet = '598'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
				RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(iCheque,0), NVL(vEstatusCheque,''), NVL(mMonCheque,0.00), NVL(iNumCheqGir,0), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0), NVL(cMotDevol,'') ;
			END IF;
		CLOSE xcur;
		FREE xcur;
		FREE xsql;

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE HACE CONSULTA POR CLIENTE, CUENTA, ESTATUS, CHEQUERA O CHEQUE Y REGRESA LA FECHA DE APERTURA; DATOS DEL CLIENTE Y LA RELACION DE NUMERO DE CHEQUES Y MONTO DE DISTINTA NATURALEZA (GIRADOS, DEVUELTOS,PAGADOS, ETC)',
'AUTOR: CARLOS OCHOA',
'FECHA DE CREACION: 23 de SEPTIEMBRE DE 2013',
'VERSION: 20130923.1630',
'BD: bdicheq',
'MODIFICO: CARLOS OCHOA',
'FECHA: 17 de DICIEMBRE 2013',
'DESCRIPCION: SE AGREGA NUEVA COLUMNA (CAUSA DE DEVOLUCION), Y EN CASO DE BUSQUEDA POR CHEQUE SE TRABAJA SOLO CON LOS ESTATUS (Pagado por CÃ¡mara /Pagado en Sucursal /Presentado por CÃ¡mara /Presentado en Sucursal) SEGUN EL CORREO ENVIADO POR SERGIO FERNANDEZ EL DIA VIERNES 22 de NOVIEMBRE de 2013.',
'VERSION: 20131217.1200',
'DESCRIPCION: PROCEDIMIENTO PARA CONSULTAR CHEQUES Y CHEQUERAS CON UNA CUENTA CON MAS DE 60 DIAS APARTIR DEL DIA DE HOY',
'AUTOR: VAZQUEZ HERRERA HUGO',
'FECHA DE CREACION: 11/02/2014',
'VERSION: 20140221.1042',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consultaglobalchqpropios(pConcepto CHAR(1), pEstatus CHAR(2), pFechaInicial CHAR(10), pFechaFinal CHAR(10))
RETURNING CHAR(6)       AS cod_retorno,
		  DATE          AS fecha_alta,
		  CHAR(20)      AS cuenta,
		  CHAR(20)       AS estatus_cuenta,
		  VARCHAR(110)  AS nom_cte,
		  CHAR(45)      AS suc_apert,
		  CHAR(40)      AS plaza_suc_aper,
		  INTEGER       AS chequera,
		  VARCHAR(50)   AS estatus_cheq,
		  DECIMAL(18,2) AS no_cheq_gir,
		  MONEY(15,2)   AS monto_cheq_gir,
		  INTEGER       AS no_cheq_devuelt,
		  MONEY(15,2)   AS monto_cheq_dev,
		  INTEGER       AS num_cheq_pag,
		  MONEY (15,2)  AS monto_cheq_pag,
		  INTEGER       AS cheq_dev_suc,
		  INTEGER       AS cheq_dev_cam;
		  		  
	--DECLARACIONES DE VARIABLES Y SU TIPO DE DATO
	DEFINE cCodRet            CHAR(6);
	DEFINE iSqlErr            INTEGER;
	DEFINE dFechaActual       DATE;
	DEFINE dtFechaMinima      DATE;
	DEFINE dtFechaInicial     DATE;
	DEFINE dtFechaFinal       DATE;
	DEFINE dtFechaAlta        DATE;
	DEFINE cCuenta            CHAR(20);
	DEFINE cEstatusCta        CHAR(20);
	DEFINE vNombreCte         VARCHAR(110);
	DEFINE cSucursalApertura  CHAR(45);
	DEFINE cPlazaSucApertura  CHAR(40);
	DEFINE iChequera          INTEGER;
	DEFINE vEstatusChequera   VARCHAR(50);
	DEFINE dNumCheqGir        DECIMAL(18,2);
	DEFINE mMonCheqGir        MONEY (15,2);
	DEFINE iMaximaSecuencia   INTEGER;
	DEFINE iInicial           INTEGER;
	DEFINE iFinal             INTEGER;
	DEFINE iNoCheqDev         INTEGER;
	DEFINE mMonCheqDev        MONEY(15,2);
	DEFINE mMonCheqDevCam     MONEY(15,2);
	DEFINE mMonCheqDevSuc     MONEY(15,2);
	DEFINE iNoCheqPag         INTEGER;
	DEFINE mMonCheqPag        MONEY(15,2);
	DEFINE iNoCheqDevSuc     INTEGER;
	DEFINE iNoCheqDevCam     INTEGER;
	DEFINE cClave            CHAR(1);
	DEFINE cSQL              CHAR(5000);
	DEFINE cBand             CHAR(1);
	
	--INICIALIZACIONES DEVALORES DEFAULT DE VARIABLES
	LET cCodRet            = '000000';
	LET iSqlErr            = 0;
	LET dFechaActual       = DATE(1);
	LET dtFechaMinima      = DATE(1);
	LET dtFechaInicial     = DATE(1);
	LET dtFechaFinal       = DATE(1);
	LET dtFechaAlta        = DATE(1);
	LET cCuenta            = '';
	LET cEstatusCta        = '';
	LET vNombreCte         = '';
	LET cSucursalApertura  = '';
	LET cPlazaSucApertura  = '';
	LET iChequera          = 0;
	LET vEstatusChequera   = '';
	LET dNumCheqGir        = 0.00;
	LET mMonCheqGir        = 0.00;
	LET iMaximaSecuencia   = 0;
	LET iInicial           = 0;
	LET iFinal             = 0;
	LET iNoCheqDev         = 0;
	LET mMonCheqDev        = 0.00;
	LET mMonCheqDevSuc     = 0.00;
	LET mMonCheqDevCam     = 0.00;
	LET iNoCheqPag         = 0;
	LET mMonCheqPag        = 0.00;
	LET iNoCheqDevSuc      = 0;
	LET iNoCheqDevCam      = 0;
	LET cClave             = '';
	LET cSQL               = '';
	LET cBand              = '0';
	
	--SET DEBUG FILE TO '/respaldosbd/josue/sp_consultaglobalchqpropios.out';
	--TRACE ON;	
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,'') , NVL(dNumCheqGir,0.00), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0) ;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		--************************************************************************************
		--*****************************CONTROL DE ERRORES POR PARAMETROS**********************
		--************************************************************************************
		
		--pConcepto = 2 (CONSULTA POR NUMERO DE CUENTA)
		--pConcepto = 3 (CONSULTA POR NUMERO DE CHEQUERA)
		--pConcepto = 4 (CONSULTA POR NUMERO DE CHEQUE)
		
		IF NVL(pConcepto,'') = '' OR NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
			LET cCodRet = '000001'; --PARAMETROS OBLIGATORIOS VACIOS O NULOS
		ELIF NVL(pConcepto,'') NOT IN ('2','3','4') THEN
			LET cCodRet = '000002'; --TIPO DE BUSQUEDA NO VALIDO
		END IF;

		--SI CAYO EN ALGUNO DE LOS FLUJOS ANTERIORES SE SALE CON EL CODIGO ASIGNADO PREVIAMENTE
		IF cCodRet <> '000000' THEN
			RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,'') , NVL(dNumCheqGir,0.00), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0) ;	
		END IF;
		
		-- SE TOMA LA FECHA ACTUAL PARA VALIDAR EL RANGO DE DIAS PERMITIDOS
		SELECT fecha_hoy 
		INTO dFechaActual
		FROM "informix".sc_fechas
		WHERE empresa = '001';
		
		LET dtFechaMinima = dFechaActual - 60 UNITS DAY;

		LET dtFechaInicial =  TO_DATE(pFechaInicial,"%Y-%m-%d");
		LET dtFechaFinal = TO_DATE(pFechaFinal,"%Y-%m-%d");
		
		IF dtFechaInicial > dtFechaFinal THEN
			LET cCodRet = '435'; --FECHA INICIAL NO DEBE SER MAYOR A LA FECHA FINAL
		ELIF  dtFechaInicial > dFechaActual THEN
			LET cCodRet = '436'; --FECHA INICIAL NO DEBE SER MAYOR A LA FECHA ACTUAL
		ELIF dtFechaFinal > dFechaActual THEN
			LET cCodRet = '437'; --FECHA FINAL NO DEBE SER MAYOR A LA FECHA ACTUAL
		ELIF dtFechaInicial < dtFechaMinima THEN
			LET cCodRet = '040'; --SOLO SE PERMITIRA LA CONSULTA EN UN RANGO DE 60 DIAS
		END IF;
		
		--SI CAYO EN ALGUNO DE LOS FLUJOS ANTERIORES SE SALE CON EL CODIGO ASIGNADO PREVIAMENTE
		IF cCodRet <> '000000' THEN
			RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,'') , NVL(dNumCheqGir,0.00), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0) ;	
		END IF;
		
		--************************************************************************************
		--*****************************       BLOQUE DE CONSULTAS       **********************
		--************************************************************************************
		
		IF pConcepto = '2' THEN
			LET cSql = ' SELECT noc.fecha_alta, noc.cuenta, chq.status_cta,DECODE(tip.es_fisica, "S", TRIM(NVL(cli.nombre1,""))||"  "||TRIM(NVL(cli.nombre2,"")) ||"  "||TRIM(NVL(cli.apell_paterno,""))||"  "||TRIM(NVL(cli.apell_materno,"")), "N", TRIM(NVL(cli.razon_social, ""))) AS nombre, (suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		ELIF(pConcepto = '3') THEN
			LET cSql = ' SELECT sqmae.fecha_act, noc.cuenta, chq.status_cta,DECODE(tip.es_fisica, "S", TRIM(NVL(cli.nombre1,""))||"  "||TRIM(NVL(cli.nombre2,"")) ||"  "||TRIM(NVL(cli.apell_paterno,""))||"  "||TRIM(NVL(cli.apell_materno,"")), "N", TRIM(NVL(cli.razon_social, ""))) AS nombre, (suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		ELIF(pConcepto = '4') THEN
			LET cSql = ' SELECT sc.fecha_alta, noc.cuenta, chq.status_cta,DECODE(tip.es_fisica, "S", TRIM(NVL(cli.nombre1,""))||"  "||TRIM(NVL(cli.nombre2,"")) ||"  "||TRIM(NVL(cli.apell_paterno,""))||"  "||TRIM(NVL(cli.apell_materno,"")), "N", TRIM(NVL(cli.razon_social, ""))) AS nombre, (suc.sucursal||" "||suc.nombre) AS sucursal_apertura, (plaz.nombre) AS plaza_suc_de_apertura ';
		END IF;
		
		IF pConcepto IN ('3','4') THEN --POR CHEQUERA o CHEQUE
	
			    LET cClave = '1';
			
			LET cSql = TRIM(cSql) || ' ,( sqmae.consec) AS chequera, (sq.descripcion) AS estatus_chequera '; 
			
		END IF;
		
		IF pConcepto IN ('3','4') THEN --POR CHEQUERA o CHEQUE
			LET cSql = TRIM(cSql) || ' FROM "informix".sc_maechq chq  INNER JOIN bdinteg:"informix".si_cliente cli ON (cli.numcte = chq.num_cte) INNER JOIN bdinteg:"informix".si_tipper tip ON (cli.tpo_persona = tip.tpo_persona ) INNER JOIN "informix".sc_maenoc noc ON (noc.cuenta = chq.cuenta) INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = chq.sucursal) ';
		ELSE
			LET cSql = TRIM(cSql) || ' FROM "informix".sc_maechq chq  INNER JOIN bdinteg:"informix".si_cliente cli ON (cli.numcte = chq.num_cte ) INNER JOIN bdinteg:"informix".si_tipper tip ON (cli.tpo_persona = tip.tpo_persona ) INNER JOIN  "informix".sc_maenoc noc ON (noc.cuenta = chq.cuenta AND noc.fecha_alta BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'") INNER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = chq.sucursal) ';
		END IF
				
		IF pConcepto IN ('3','4') THEN --POR CHEQUERA o CHEQUE
			LET cSql = TRIM(cSql) || ' INNER JOIN bdicntchq:"informix".sq_maechqra sqmae ON (sqmae.empresa = "001" AND sqmae.cuenta = chq.cuenta AND sqmae.consec = (SELECT {+INDEX(bdicntchq:"informix".sq_maechqra idxmaechqraemp)} MAX(sma.consec) FROM bdicntchq:"informix".sq_maechqra sma  WHERE sma.empresa="001" AND sma.cuenta = sqmae.cuenta AND sma.consec = sma.consec ';
			
			
			IF pConcepto = '3' AND NVL(pEstatus,'') <> '' THEN
					LET cSql = TRIM(cSql) || ' AND sma.status = SUBSTR("'||pEstatus||'",2,1) ' ;
			ELIF NVL(pEstatus,'') = '' THEN
					LET cSql = TRIM(cSql) || ' AND sma.status = sma.status ' ;
			END IF;
			
			LET cSql = TRIM(cSql) || ' )) ';
		END IF;
		
		IF pConcepto = '3' THEN -- CHEQUERA
			LET cSql = TRIM(cSql) || 'INNER JOIN "informix".sc_contch sc on (sc.cuenta = noc.cuenta )';
		END IF
		
		IF pConcepto = '4' THEN -- CHEQUE
			LET cSql = TRIM(cSql) || 'INNER JOIN "informix".sc_contch sc ON (sc.cuenta = noc.cuenta AND sc.consec = sqmae.consec AND sc.estado NOT IN ("A","C","E","S") )'; 
		END IF
		
		
		LET cSql = TRIM(cSql) || ' INNER JOIN "informix".sc_producto prod ON (prod.producto = prod.producto  AND prod.empresa = "001" AND prod.val_chequeras = "S" AND prod.producto = chq.producto) , bdinteg:"informix".si_plazas plaz ';
		
		IF pConcepto IN ('3','4') THEN
			LET cSql = TRIM(cSql) || '  , bdicntchq:"informix".sq_status_chequera sq ';	
		END IF;		
		
		LET cSql = TRIM(cSql) || ' WHERE chq.num_cte =  chq.num_cte AND chq.cuenta = chq.cuenta ';		
	
		IF NVL(pEstatus,'') = '' THEN
			LET cSql = TRIM(cSql) || ' AND chq.status_cta = chq.status_cta '; 
		ELIF NVL(pEstatus,'') <> '' THEN
			IF pConcepto = '2' THEN
				LET cSql = TRIM(cSql) || ' AND chq.status_cta = "'||pEstatus||'" '; 
			END IF;
		END IF;
		
		LET cSql = TRIM(cSql) || ' AND plaz.plaza = suc.plaza ';		
		
		IF pConcepto ='3' THEN 
			LET cSql = TRIM(cSql) || ' AND sq.clave = "'||cClave||'" AND sq.clave||sq.status = ';
			
			IF NVL(pEstatus,'')='' THEN
				LET cSql = TRIM(cSql) || ' sq.clave||sq.status ';
			ELIF NVL(pEstatus,'')<>''  THEN
				LET cSql = TRIM(cSql) || ' "'||pEstatus||'" ';
			
			END IF;			
			
			LET cSql = TRIM(cSql) || ' AND sqmae.fecha_act BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'" ';
			 LET cSql = TRIM(cSql) || ' AND sq.clave||sq.status = "'||cClave||'"||sqmae.status ';
		END IF;
		
		IF pConcepto = '4' THEN 
			LET cSql = TRIM(cSql) || ' AND sc.estado = ';
			IF NVL(pEstatus,'')='' THEN
				LET cSql = TRIM(cSql) || ' sc.estado';
			ELIF NVL(pEstatus,'')<>''  THEN
				LET pEstatus =  SUBSTR (pEstatus,2,1 );
				LET cSql = TRIM(cSql) || ' "'||TRIM(pEstatus)||'" ';
				LET cSql = TRIM(cSql) || 'AND sc.cuenta = sqmae.cuenta AND sqmae.status = sqmae.status AND sq.clave = '||cClave||'AND sq.status = sqmae.status';
			END IF;
			
			LET cSql = TRIM(cSql) || ' AND sc.fecha_alta BETWEEN "'||dtFechaInicial||'" AND "'||dtFechaFinal||'" ';
			LET cSql = TRIM(cSql) || ' AND sq.clave||sq.status = "'||cClave||'"||sqmae.status ';
		END IF
		
		IF pConcepto = '2' THEN
			LET cSql = TRIM(cSql) || ' GROUP BY 1,2,3,4,5,6 ';
		ELSE
			LET cSql = TRIM(cSql) || ' GROUP BY 1,2,3,4,5,6,7,8 ';
		END IF;		
		
		LET cSql = TRIM(cSql) || ' ORDER BY 2 '; 
	
		LET cSql = TRIM(cSql) ;
	
	PREPARE xsql FROM TRIM(cSql); 
		DECLARE xcur CURSOR FOR xsql; 
		OPEN xcur;		
			IF pConcepto = '2' THEN
				FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura; 
			ELSE
				FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera,vEstatusChequera; 
			
			END IF;
			
			--SI NO ENCUENTRA REGISTROS CON LOS PARAMETROS INDICADOS SE SALE DEL FOREACH Y CAE AQUI
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '598'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
				RETURN TRIM(cCodRet), NVL(dtFechaAlta,DATE(1)), NVL(cCuenta,''), NVL(cEstatusCta,''), NVL(vNombreCte,''), NVL(cSucursalApertura,'') , NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,'') , NVL(dNumCheqGir,0.00), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0) ;
			END IF;
			
			WHILE  SQLCODE= 0 --Si encuentra registros el cursor
			
				IF cEstatusCta = '1' THEN
					LET cEstatusCta = 'Activa';
				ELIF cEstatusCta = '2' THEN
					LET cEstatusCta = 'Cancelada';
				ELIF cEstatusCta = '3' THEN
					LET cEstatusCta = 'Bloqueada';
				ELIF cEstatusCta = '4' THEN
					LET cEstatusCta = 'Inactiva';
				ELIF cEstatusCta = '5' THEN
					LET cEstatusCta = 'Informada';
				ELIF cEstatusCta = '6' THEN
					LET cEstatusCta = 'Concentrada';
				ELIF cEstatusCta = '7' THEN
					LET cEstatusCta = 'Traspasada';
				ELIF cEstatusCta = '8' THEN
					LET cEstatusCta = 'Desconcentrada';
				END IF;

				IF pConcepto = '2' THEN
					--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA	
					SELECT MAX(sma.consec) 
					INTO iMaximaSecuencia
					FROM bdicntchq:"informix".sq_maechqra sma 
					WHERE sma.status= sma.status 
					AND sma.cuenta = TRIM(cCuenta)
					AND sma.consec = sma.consec;
					
					IF DBINFO('sqlca.sqlerrd2') = 0  THEN
						FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura; 
						
						CONTINUE WHILE;
					END IF;
					
					--CHEQUERA
					SELECT (sqmae.consec) AS chequera, (sq.descripcion) AS estatus_chequera
					INTO iChequera, vEstatusChequera
					FROM  bdicntchq:"informix".sq_maechqra sqmae , bdicntchq:"informix".sq_status_chequera sq
					WHERE sqmae.empresa = '001'
					AND sqmae.cuenta = TRIM(cCuenta)
					AND sqmae.consec = sqmae.consec
					AND sqmae.status = sq.status
					AND sqmae.consec = iMaximaSecuencia --MAXIMA SECUENCIA DE LA CUENTA
					AND sq.clave = '1';
					
					IF DBINFO('sqlca.sqlerrd2') = 0  THEN
						FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura; 
						
						CONTINUE WHILE;
					END IF;
				
					-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
					SELECT (COUNT(scon.estado))AS no_chqes_girados,
					(SUM(scon.importe)) AS monto_cheques_girados
					INTO dNumCheqGir, mMonCheqGir
					FROM "informix".sc_contch scon 
					WHERE scon.cuenta = TRIM(cCuenta)
					AND scon.estado NOT IN('E','A','C','S') 
					AND scon.numero = scon.numero
					AND scon.consec = iMaximaSecuencia; --MAXIMA SECUENCIA DE LA CUENTA
				ELSE 
								
					--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA	
					SELECT MAX(sma.consec) 
					INTO iMaximaSecuencia
					FROM bdicntchq:"informix".sq_maechqra sma 
					WHERE sma.status= sma.status 
					AND sma.cuenta = TRIM(cCuenta)
					AND sma.consec = iChequera;
					
					IF DBINFO('sqlca.sqlerrd2') = 0  THEN
						FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera,vEstatusChequera; 
						
						CONTINUE WHILE;
					END IF;
				END IF;
					
					IF pConcepto = '4' THEN
					
						--SE OBTIENE LA MAXIMA SECUENCIA DE LA CUENTA	
						SELECT MAX(consec) 
						INTO iMaximaSecuencia
						FROM bdicntchq:"informix".sq_maechqra 
						WHERE cuenta = TRIM(cCuenta);
										
						-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
						SELECT (COUNT(scon.estado))AS no_chqes_girados,
						(SUM(scon.importe)) AS monto_cheques_girados
						INTO dNumCheqGir, mMonCheqGir
						FROM "informix".sc_contch scon 
						WHERE scon.cuenta = TRIM(cCuenta)
						AND scon.estado NOT IN('E','A','C','S') 
						AND scon.numero = scon.numero
						AND scon.consec = iMaximaSecuencia
						AND scon.fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal; --MAXIMA SECUENCIA DE LA CUENTA

						IF DBINFO('sqlca.sqlerrd2') = 0  THEN
							FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera,vEstatusChequera; 
							
							CONTINUE WHILE;
						END IF

						--SE OBTIENE: NUMERO DE CHEQUES PAGADOS, MONTO DE CHEQUES PAGADOS
						SELECT (COUNT(estado)) AS no_cheques_pagados, SUM (importe) AS monto_cheques_pagados
						INTO iNoCheqPag, mMonCheqPag
						FROM "informix".sc_contch
						WHERE consec = iChequera
						AND cuenta = TRIM(cCuenta) 
						AND estado IN ('P','M')
						AND numero = numero
						AND fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal;

						--SE OBTIENE: CHEQUES DEVUELTOS EN SUC
						SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
						INTO iNoCheqDevSuc, mMonCheqDevSuc
						FROM "informix".sc_contch
						WHERE cuenta = TRIM(cCuenta) 
						AND consec = iChequera
						AND estado IN ('U')
						AND numero = numero
						AND fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal;

						--SE OBTIENE: CHEQUES DEVUELTOS EN CAMARA				
						SELECT (COUNT(cuenta)) AS cheques_devueltos_camara, (NVL(SUM(importe),0.00))
						INTO iNoCheqDevCam, mMonCheqDevCam
						FROM "informix".sc_contch
						WHERE cuenta = TRIM(cCuenta) 
						AND consec = iChequera
						AND estado IN ('N')
						AND numero = numero
						AND fecha_alta BETWEEN dtFechaInicial AND dtFechaFinal;
					ELSE 
										
						-- NUMERO DE CHEQUES GIRADOS, MONTO DE CHEQUES GIRADOS
						SELECT (COUNT(scon.estado))AS no_chqes_girados,
						(SUM(scon.importe)) AS monto_cheques_girados
						INTO dNumCheqGir, mMonCheqGir
						FROM "informix".sc_contch scon 
						WHERE scon.cuenta = TRIM(cCuenta)
						AND scon.estado NOT IN('E','A','C','S') 
						AND scon.numero = scon.numero
						AND scon.consec = iMaximaSecuencia; --MAXIMA SECUENCIA DE LA CUENTA
					
						--SE OBTIENE: NUMERO DE CHEQUES PAGADOS, MONTO DE CHEQUES PAGADOS
						SELECT (COUNT(estado)) AS no_cheques_pagados, SUM (importe) AS monto_cheques_pagados
						INTO iNoCheqPag, mMonCheqPag
						FROM "informix".sc_contch
						WHERE consec = iChequera
						AND cuenta = TRIM(cCuenta) 
						AND estado IN ('P','M');

						--SE OBTIENE: CHEQUES DEVUELTOS EN SUC
						SELECT (COUNT(cuenta)) AS cheques_devueltos_ensuc, (NVL(SUM(importe),0.00))
						INTO iNoCheqDevSuc, mMonCheqDevSuc
						FROM "informix".sc_contch
						WHERE cuenta = TRIM(cCuenta) 
						AND consec = iChequera
						AND estado IN ('U');

						--SE OBTIENE: CHEQUES DEVUELTOS EN CAMARA				
						SELECT (COUNT(cuenta)) AS cheques_devueltos_camara, (NVL(SUM(importe),0.00))
						INTO iNoCheqDevCam, mMonCheqDevCam
						FROM "informix".sc_contch
						WHERE cuenta = TRIM(cCuenta) 
						AND consec = iChequera
						AND estado IN ('N');
					END IF;

				LET iNoCheqDev = iNoCheqDevCam + iNoCheqDevSuc;
				LET mMonCheqDev = mMonCheqDevCam + mMonCheqDevSuc;


				RETURN cCodRet,dtFechaAlta, TRIM(cCuenta), NVL(cEstatusCta,''), TRIM(vNombreCte), NVL(cSucursalApertura,''), NVL(cPlazaSucApertura,''), NVL(iChequera,0), NVL(vEstatusChequera,''), NVL(dNumCheqGir,0.00), NVL(mMonCheqGir,0.00), NVL(iNoCheqDev,0), NVL(mMonCheqDev,0.00), NVL(iNoCheqPag,0), NVL(mMonCheqPag,0.00), NVL(iNoCheqDevSuc,0), NVL(iNoCheqDevCam,0)  WITH RESUME;
			
			    IF NVL(iChequera, 0) <> 0 THEN
				    LET cBand = '1'; 
					IF pConcepto = '2' THEN
						FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura; 
					ELSE
						FETCH  xcur INTO dtFechaAlta, cCuenta, cEstatusCta, vNombreCte, cSucursalApertura, cPlazaSucApertura, iChequera,vEstatusChequera; 

					END IF;
			    END IF;
				
			END WHILE;
	       
			IF NVL(iChequera, 0) = 0 AND cBand = '0' THEN
			    LET cCodRet = '598';
			    RETURN cCodRet,DATE(1), '', '', '', '', '', 0, '', 0.00, 0.00, 0, 0.00, 0, 0.00, 0, 0;
			END IF;
	        
		CLOSE xcur;
		FREE xcur;
		FREE xsql;
	
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE HACE CONSULTA POR CUENTA, CHEQUERA O CHEQUE, CON OPCION DE DETALLAR POR ESTATUS DE LOS MISMOS Y REGRESA LA FECHA DE APERTURA; DATOS DEL CLIENTE Y LA RELACION DE NUMERO DE CHEQUES Y MONTO DE DISTINTA NATURALEZA (GIRADOS, DEVUELTOS,PAGADOS, ETC)',
'AUTOR: CARLOS OCHOA',   
'FECHA DE CREACION: 25 de SEPTIEMBRE DE 2013',
'VERSION: 201309251830',
'BD: bdicheq',
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1404',
'Autor: 94912599 ',
'Fecha: 11/02/2014',
'Descripción: Se realiza validacion de la fecha para condicionar los registros a esta o retornar su valor deacuerdo',
'al concepto ya sea 2,3 0 4 (cuenta,chequera o cheque) para validarlas por campos separados de tablas diferentes,',
'concepto 2 (cuenta) de el campo fecha_alta de la tabla sc_maenoc,concepto 3(chequera) de el campo fecha_act',
'de la tabla sq_maechqra  y concepto 4(cheque) de el campo fecha_alta de la tabla sc_contch, también se validó',
'para que se regrese el nombre de la si_cliente concatenando los campos nombre1,nombre2,apell_paterno y apell_materno',
'si el campo tp_persona es igual a "S" o en su caso de el campo razon_social si el campo tp_persona es igual a "N",',
'se validó que los cheq_dev_cam se consultaran solo con el estado = "N" y los cheq_dev_suc se consultaran solo con el',
' campo estado = "S", en la consulta de cheques y monto girados se omitiran los estados igual a "S"',
'Sustento: RQM 06 268 Adecuacion Reporte Cheques Mantenimiento.odt',
'Solicita: Sergio Fernandez Cordero',
'BD:BDICHEQ',
'--------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctes_sit_especial( cNumCte  CHAR(20), 
                                              pMotivo   CHAR(2), 
                                              pPromotor CHAR(8), 
                                              pSucursal CHAR(4) )
RETURNING CHAR(5)  AS cCodRet,
		  CHAR(5)  AS cCodRet2,
          CHAR(80) AS cMensajeRet;
          
    
    DEFINE cCodRet          CHAR(5);
	DEFINE cCodRet2         CHAR(5);
    DEFINE cMensajeRet      CHAR(80);
    DEFINE iSqlErr          INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE Vfchmodifica     DATETIME HOUR TO SECOND;
	DEFINE vponderacion 	SMALLINT;
	DEFINE vponderacion2 	SMALLINT;
	DEFINE Vidmovto			INTEGER; 
	DEFINE Vtipomovto		CHAR(1);
	DEFINE Vnumcte			CHAR(20);
	DEFINE Vempresa			CHAR(3);
	DEFINE Vsituacion		CHAR(1);
	DEFINE Vcausa			SMALLINT;
	DEFINE Vcvesitesporigen CHAR(12);
	DEFINE Vsucursal 		CHAR(4);
	DEFINE Vempleadoefectuo CHAR(8);
	DEFINE Vusralta			CHAR(8);
	DEFINE Vfchalta			DATE;
	DEFINE Vusrmodifica		CHAR(8);
	DEFINE iIsamErr         INTEGER;
	DEFINE vnombre			CHAR(45);
	
    
    LET cCodRet          = '';
	LET cCodRet2         = '';
    LET cMensajeRet      = '';
    LET iSqlErr          = 0;
    LET cErrorInfo       = '';
    LET Vfchmodifica     = CURRENT HOUR TO FRACTION(3);
	LET vponderacion 	 = 0;
	LET vponderacion2 	 = 0;
	LET Vidmovto		 = 0;
	LET Vtipomovto		 = '';
	LET Vnumcte			 = '';
	LET Vempresa		 = '';
	LET Vsituacion		 = '';
	LET Vcausa			 = 0;
	LET Vcvesitesporigen = '';
	LET Vsucursal		 = '';
	LET Vempleadoefectuo = '';
	LET Vusralta		 = '';
	LET Vfchalta		 = DATE(1);
	LET Vusrmodifica	 = '';
	LET iIsamErr         = 0;
	LET vnombre 		 = '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr,iIsamErr, cErrorInfo
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctes_sit_especial.err";
        --- TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cMensajeRet = cErrorInfo;
            RETURN cCodRet,cCodRet2, cMensajeRet;
        END IF;
    END EXCEPTION;

     --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctes_sit_especial.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 5;
    
    -- // SE VALIDAN LOS PARAMETROS DE ENTRADA
    IF ( cNumCte   is null OR cNumCte  = '' )  OR
       ( pMotivo   is null OR pMotivo   = '' ) OR
       ( pPromotor is null OR pPromotor = '' ) OR
       ( pSucursal is null OR pSucursal = '' ) THEN
        LET cCodRet = '00050';
		LET cCodRet2= '00050';
        LET cMensajeRet = '';
        RETURN cCodRet,cCodRet2, cMensajeRet;
    END IF;
    
	
    
	IF pMotivo = '04' THEN --// MOTIVO POR FALLECIMIENTO

	-- // OBTIENE LOS DATOS DE LA TABLA se_ctessitespcte
		SELECT idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen,
		sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica  
		INTO 
		Vidmovto, Vtipomovto, Vnumcte, Vempresa, Vsituacion, Vcausa, Vcvesitesporigen,
		Vsucursal, Vempleadoefectuo, Vusralta, Vfchalta, Vusrmodifica, Vfchmodifica  
		FROM bdisitesp:se_ctessitespcte
		WHERE numcte = cNumCte;

		--IF Vnumcte != '' OR Vnumcte is not null THEN
		IF NVL(Vnumcte,'') <> '' THEN
		
			INSERT INTO bdisitesp:se_ctessitespcte_his 
			(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen,
				sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
			VALUES
			(Vtipomovto, Vnumcte, Vempresa, Vsituacion, Vcausa, Vcvesitesporigen,
			Vsucursal, Vempleadoefectuo, Vusralta, Vfchalta, pPromotor, current hour to fraction(3));  -- ok
			
			/*INSERT INTO bdinteg:si_bitacora_dictamenes
			VALUES	(Vnumcte, 'F',  '42','0','0','0','0', pSucursal, pPromotor, '2',  Vfchmodifica);
			
			(Vtipomovto, Vnumcte, Vempresa, Vsituacion, Vcausa, Vcvesitesporigen,
			Vsucursal, Vempleadoefectuo, Vusralta, Vfchalta, Vusrmodifica, Vfchmodifica);*/

			UPDATE bdisitesp:se_ctessitespcte 
			SET situacion = 'F', causa= '42', usrmodifica = pPromotor, fchmodifica = current hour to fraction(3)
			WHERE idmovto = Vidmovto;
			
			INSERT INTO bdinteg:si_bitacora_dictamenes  (numcte, situacion, causa, numcte_coinc, situacion_coinc,
			causa_coinc, tipo, sucursal, numemp, origen, fecha_insert )
			VALUES
			(cNumCte, 'F', '42', '0','0','0','0',  pSucursal, pPromotor, '2', current hour to fraction(3) );
			
		ELSE
		
		SELECT nombre  
		INTO vnombre
		FROM BDINTEG:SI_EJECUT WHERE EJECUTIVO = pPromotor;
		
		INSERT INTO bdisitesp:se_ctessitespcte ( empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto,
		empleadoefectuo, nombreefectuo,	fechamovto, usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
		VALUES ('001', cNumCte, 'F', '42', '2' , pSucursal, 'M', pPromotor, vnombre, current hour to fraction(3),pPromotor , current hour to fraction(3) ,'','','');

		INSERT INTO bdinteg:si_bitacora_dictamenes  (numcte, situacion, causa, numcte_coinc, situacion_coinc,
			causa_coinc, tipo, sucursal, numemp, origen, fecha_insert )
			VALUES
			(cNumCte, 'F', '42', '0','0','0','0',  pSucursal, pPromotor, '2', current hour to fraction(3) );
		
		END IF
		
		--RETURN cCodRet, cMensajeRet;
   
   ELSE  -- // MOTIVO 08 ES POR FRAUDE CONSUMADO
   
   -- // 7 valor de ponderacion para situacion P y causa 108
   
		SELECT idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen,
		sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica --, ponderacion 
		INTO 
		Vidmovto, Vtipomovto, Vnumcte, Vempresa, Vsituacion, Vcausa, Vcvesitesporigen,
		Vsucursal, Vempleadoefectuo, Vusralta, Vfchalta, Vusrmodifica, Vfchmodifica
		FROM bdisitesp:se_ctessitespcte
		WHERE numcte = cNumCte;

		--IF Vnumcte != '' OR Vnumcte is not null THEN
		IF NVL(Vnumcte,'') <> '' THEN
		
		
			SELECT  ponderacion
			INTO vponderacion
			FROM bdisitesp:se_catsitesp
			WHERE situacion = Vsituacion
			AND  causa = Vcausa;
			
			
			SELECT  ponderacion
			INTO vponderacion2
			FROM bdisitesp:se_catsitesp
			WHERE situacion = 'P'
			AND  causa = '108';
			
			IF vponderacion > vponderacion2 OR  vponderacion = '0' THEN
			
				INSERT INTO bdisitesp:se_ctessitespcte_his 
				(tipomovto, numcte, empresa, situacion, causa, cvesitesporigen,
				sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
				
				VALUES
				(Vtipomovto, Vnumcte, Vempresa, Vsituacion, Vcausa, Vcvesitesporigen,
				Vsucursal, Vempleadoefectuo, Vusralta, Vfchalta, pPromotor, current hour to fraction(3));
				
				UPDATE bdisitesp:se_ctessitespcte 
				SET situacion = 'P', causa= '108', usrmodifica = pPromotor, fchmodifica = current hour to fraction(3)
				WHERE idmovto = Vidmovto;
			
				INSERT INTO bdinteg:si_bitacora_dictamenes  (numcte, situacion, causa, numcte_coinc, situacion_coinc,
				causa_coinc, tipo, sucursal, numemp, origen, fecha_insert )
				VALUES
				(cNumCte, 'P', '108', '0','0','0','0',  pSucursal, pPromotor, '2', current hour to fraction(3) );
				
		
			END IF

		ELSE	
				
			SELECT nombre  
			INTO vnombre
			FROM BDINTEG:SI_EJECUT WHERE EJECUTIVO = pPromotor;
			
			INSERT INTO bdisitesp:se_ctessitespcte ( empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto,
			empleadoefectuo, nombreefectuo,	fechamovto, usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
			VALUES ('001', cNumCte, 'P', '108', '2', pSucursal,'M' , pPromotor, vnombre, current hour to fraction(3), pPromotor, current hour to fraction(3) ,'','','');
			
			INSERT INTO bdinteg:si_bitacora_dictamenes  (numcte, situacion, causa, numcte_coinc, situacion_coinc,
			causa_coinc, tipo, sucursal, numemp, origen, fecha_insert )
			VALUES
			(cNumCte, 'P', '108', '0','0','0','0',  pSucursal, pPromotor, '2', current hour to fraction(3) );
		
			
			--RETURN cCodRet, cMensajeRet;
		
		END IF
   
   END IF
   
   
    
    RETURN cCodRet, cCodRet2, cMensajeRet;
    
    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se genera el proceso para identificar y grabar situaciones especiales de clientes que cancelan cuentas de captación en SIF',
'AUTOR: Sergio Fernandez Cordero',
'FECHA: 15/Agosto/2013',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_rptctasinact( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE vcontador3           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    
    DEFINE vfecha_hoy           date;
    DEFINE vfecha_ant           DATE;
    DEFINE vpri_dia_mes         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_ejecucion     DATE;
    DEFINE vfechconmovhis       char(10);
    DEFINE vfechconmovhisold    char(10);
    
    DEFINE vcuenta              CHAR(20);
    DEFINE vnumcte              CHAR(20);
    DEFINE vproducto            CHAR(4);
    DEFINE vsucursal            CHAR(4);
    DEFINE vsaldo               DECIMAL(18,2);
    DEFINE vnombre              CHAR(104);
    DEFINE vtel_casa            CHAR(13);
    DEFINE vtel_cel             CHAR(13);
    DEFINE vtel_ofi             CHAR(13);
    DEFINE vcorreo              CHAR(60);
    
    DEFINE vsql                 CHAR(500);
    DEFINE vaniomes             CHAR(6);

    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
       
    LET vfecha_hoy        = ''; 
    LET vfecha_ant        = ''; 
    LET vpri_dia_mes      = '';
    LET vfecha_ini        = '';
    LET vfecha_fin        = '';
    LET vfecha_ejecucion  = '';
    LET vfechconmovhis    = '';
    LET vfechconmovhisold = '';
    
    LET vcuenta   = '';
    LET vnumcte   = '';
    LET vproducto = '';
    LET vsucursal = '';
    LET vsaldo    = 0.00;
    LET vnombre   = '';
    LET vtel_casa = '';
    LET vtel_cel  = '';
    LET vtel_ofi  = '';
    LET vcorreo   = '';
    
    LET vsql = '';
    LET vaniomes = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptctasinact.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, fecha_ant, pri_dia_mes
      INTO vfecha_hoy, vfecha_ant, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ini = vpri_dia_mes - 1 UNITS MONTH;
    LET vfecha_fin = vpri_dia_mes - 1 UNITS DAY;
    
    -- // VERIFICA QUE NO SE HAYA EJECUTADO EL PROCESO PARA ESTE PERIODO
    SELECT fecha
      INTO vfecha_ejecucion
      FROM sc_contproc_cobrocominact
     WHERE proceso = 'rptctasinactivas'
       AND empresa = pempresa;
       
    IF vfecha_ejecucion >= vpri_dia_mes THEN
        LET vcodret1 = '958';
        LET vcodret2 = '958';
        
        SELECT descripcion
          INTO vcodret3
          FROM bdinteg:si_codret
         WHERE codigo_retorno = '958'
           AND sistema = '01';
           
        RETURN vcodret1, vcodret2, vcodret3;
    END IF;
    
    -- // TABLA PARA REPORTE
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sc_rptctasinactivas') THEN
        DROP TABLE "informix".sc_rptctasinactivas;        
    END IF;
    
    CREATE TABLE "informix".sc_rptctasinactivas
    ( 
      producto   CHAR(4), 
      cliente    CHAR(20),
      cuenta     CHAR(20),
      tel_casa   CHAR(13),
      tel_cel    CHAR(13),
      tel_ofi    CHAR(13),
      email      CHAR(60),
      sucursal   CHAR(4),
      sdo_cuenta DECIMAL(18,2)
    ) 
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_rptctasinact ON "informix".sc_rptctasinactivas(producto,cuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sc_rptctasinactivas;

    -- // PARAMETROS DE CONSULTA PARA MOVIMIENTOS HISTORICOS
    SELECT valor 
      INTO vfechconmovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor 
      INTO vfechconmovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    -- // TABLA TEMPORAL DE MOVIMIENTOS DEL MES
    SELECT mov.cuenta, mov.producto, mae.num_cte, mae.sucursal, mae.sdo_actual
      FROM sc_movhis_old mov,
           sc_maechq mae
     WHERE mov.empresa = pempresa
       AND mov.cuenta = mae.cuenta
       AND mov.fech_alt BETWEEN vfecha_ini and vfecha_fin
       AND mov.fech_alt >= vfechconmovhisold
       AND mov.fech_alt < vfechconmovhis
       AND mov.cancelad <> 'S'
       AND mov.transacc = '3232'
       AND mae.empresa = mov.empresa
       AND mae.cuenta = mov.cuenta
       AND mae.status_cta <> '2'
       AND mae.sdo_actual > 1000.00
    UNION ALL
    SELECT mov.cuenta, mov.producto, mae.num_cte, mae.sucursal, mae.sdo_actual
      FROM sc_movhis mov,
           sc_maechq mae
     WHERE mov.empresa = pempresa
       AND mov.cuenta = mae.cuenta
       AND mov.fech_alt BETWEEN vfecha_ini AND vfecha_fin
       AND mov.fech_alt >= vfechconmovhis
       AND mov.cancelad <> 'S'
       AND mov.transacc = '3232'
       AND mae.empresa = mov.empresa
       AND mae.cuenta = mov.cuenta
       AND mae.status_cta <> '2'
       AND mae.sdo_actual > 1000.00
    INTO TEMP tmp_movscobrocom WITH NO LOG;
    CREATE INDEX idx_movscobrocom ON tmp_movscobrocom(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movscobrocom;
    
    SELECT UNIQUE num_cte
      FROM tmp_movscobrocom
      INTO TEMP tmp_ctesinact WITH NO LOG;
    CREATE INDEX idx_ctesinact ON tmp_ctesinact(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesinact;
       
    FOREACH WITH HOLD
        SELECT num_cte
          INTO vnumcte
          FROM tmp_ctesinact
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        /* ###########################################################################################################################
        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),
               tel1.telefono, tel2.telefono, tel3.telefono, core.correo_elec
          INTO vnombre, vtel_casa, vtel_cel, vtel_ofi, vcorreo
          FROM bdinteg:si_cliente cte
		  left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
	      left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
		  left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
	      left outer join bdinteg:si_correos core on (core.numcte = cte.numcte and core.tipo_correo = 1 and core.status_correo ='A')
         WHERE cte.numcte = vnumcte;
        ########################################################################################################################### */
        
        SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),
               tel1.telefono, tel2.telefono, tel3.telefono
          INTO vnombre, vtel_casa, vtel_cel, vtel_ofi
          FROM bdinteg:si_cliente cte
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
	      LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
		  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
         WHERE cte.numcte = vnumcte;
         
        SELECT correo_elec
          INTO vcorreo
          FROM bdinteg:si_correos
         WHERE numcte = vnumcte
           AND tipo_correo = 1
           AND status_correo = 'A'
           AND secuencia = ( SELECT max(secuencia) FROM bdinteg:si_correos WHERE numcte = vnumcte AND tipo_correo = 1 AND status_correo = 'A' );          
   
        FOREACH
            SELECT UNIQUE cuenta, producto, sucursal, sdo_actual
              INTO vcuenta, vproducto, vsucursal, vsaldo
              FROM tmp_movscobrocom
             WHERE num_cte = vnumcte
            
            INSERT INTO sc_rptctasinactivas(producto, cliente, cuenta, tel_casa, tel_cel, tel_ofi, email, sucursal, sdo_cuenta)
            VALUES(vproducto, vnombre, vcuenta, vtel_casa, vtel_cel, vtel_ofi, vcorreo, vsucursal, vsaldo);
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;
        END FOREACH
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
           
        LET vcuenta = '';
        LET vnumcte = '';
        LET vproducto = '';
        LET vnombre = '';
        LET vsucursal = '';
        LET vsaldo = 0.00;
        LET vtel_casa = '';
        LET vtel_cel = '';
        LET vtel_ofi = '';
        LET vcorreo = '';
    END FOREACH;
    
    IF vcontador2 > 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivas;
    
    -- // DESCARGA EL ARCHIVO DE INFORMACIÓN
    LET vaniomes = TO_CHAR(vfecha_fin, '%Y%m');
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/rptctasinactivas_'||vaniomes||'.csv '||
               ' SELECT * FROM sc_rptctasinactivas ORDER BY producto, cuenta" > /resplogifx/conciliachq/ctasinact.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasinact.sql"; 
    SYSTEM vsql;
    
    UPDATE sc_contproc_cobrocominact
       SET fecha = vfecha_hoy
     WHERE proceso = 'rptctasinactivas'
       AND empresa = pempresa;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3;

END PROCEDURE;