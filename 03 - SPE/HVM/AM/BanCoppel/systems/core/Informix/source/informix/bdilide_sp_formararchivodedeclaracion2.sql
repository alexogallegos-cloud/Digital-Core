CREATE PROCEDURE "informix".sp_formararchivodedeclaracion2(p_cFechaXML VARCHAR(6), p_cDeclaracion CHAR(1),p_cTipoDeclaracion CHAR(1))
    RETURNING VARCHAR(6),VARCHAR(20);

--Declaracion de variables generales
DEFINE v_cRetorno        VARCHAR(6);
DEFINE iSqlError         INTEGER;
DEFINE v_cFiller         VARCHAR(32);
DEFINE v_cNumReg         CHAR(1);
DEFINE v_iNumComplementaria INTEGER;
DEFINE v_cDomicilio      VARCHAR(90);
DEFINE v_cArchivo        VARCHAR(20);
DEFINE v_dFechaPres      DATE;
DEFINE v_cNumFolioAnt    VARCHAR(20);
DEFINE v_cDiaUltimo      CHAR(2);
DEFINE v_cVarPrueba1     VARCHAR(128);
DEFINE v_cVarPrueba2     VARCHAR(128);
DEFINE v_cVarPrueba3     VARCHAR(128);
DEFINE v_cVarPrueba4     VARCHAR(128);
DEFINE v_cMes            CHAR(2);
DEFINE v_cAnio           VARCHAR(4);
DEFINE v_dFechOper       DATE;
DEFINE v_mMontoOper      MONEY(16,2);
DEFINE v_cTipoOper       CHAR(2);
DEFINE v_iContador		 INTEGER ;
--Declaracion de variables stattmp_anualxmlfisica, stattmp_anualxmlmoral
DEFINE v_cCliente        VARCHAR(20);
DEFINE v_cTipoPersona    CHAR(2);
DEFINE v_cRfc            VARCHAR(13);
DEFINE v_cCurp           VARCHAR(20);
DEFINE v_cRazonSocial    VARCHAR(60);
DEFINE v_cApPaterno      VARCHAR(26);
DEFINE v_cApMaterno      VARCHAR(26);
DEFINE v_cNombre1        VARCHAR(26);
DEFINE v_cNombre2        VARCHAR(26);
DEFINE v_cCalle          VARCHAR(30);
DEFINE v_cNumInterior    VARCHAR(10);
DEFINE v_cNumExterior    VARCHAR(10);
DEFINE v_cColonia        VARCHAR(30);
DEFINE v_cCP             VARCHAR(5);
DEFINE v_mMontoExcedente MONEY(16,2);
DEFINE v_mImpDeterminado MONEY(16,2);
DEFINE v_dImpRecaudado   DECIMAL;
DEFINE v_mRecPendiente   MONEY(16,2);
--Declaracion de variables stattmp_ctasfisicas,stattmp_ctasmorales
DEFINE v_cCuenta         VARCHAR(20);
DEFINE v_siCotitulares   SMALLINT;
DEFINE v_mPorcion        MONEY(10,4);
DEFINE v_dImpRecaudadoDet DECIMAL;
--Declaracion de variables de parametros para encabezado
DEFINE v_cEsquemaXSD     VARCHAR(20);
DEFINE v_cRfcDeclarante  VARCHAR(13);
DEFINE v_cInstitucion    VARCHAR(50);
DEFINE v_cRfcLegal       VARCHAR(13);
DEFINE v_cCurpLegal      VARCHAR(20);
DEFINE v_cNomLegal       VARCHAR(60);
DEFINE v_cVersionXSD     VARCHAR(5);
DEFINE v_cNomInstitucion VARCHAR(60);
DEFINE v_cRfcInstitucion VARCHAR(13);
--Declaracion de variables de totales
DEFINE v_mImpDeterminadoTotal MONEY(16,2);
DEFINE v_mImpRecaudadoTotal   MONEY(16,2);
DEFINE v_mMontoExcedenteTotal MONEY(16,2);
DEFINE v_i8NumOperaciones     INT8;
--Declaracion de variables de totales Mensuales
DEFINE v_mRemTotal       MONEY(16,2);
DEFINE v_mIdeTotal       MONEY(16,2);
DEFINE v_mRecaudadoTotal MONEY(16,2);
DEFINE v_mPendienteTotal MONEY(16,2);
DEFINE v_i8OperacionTotal INT8;
DEFINE v_mDepositoTotal  MONEY(16,2);
DEFINE v_mEnteroTotal    MONEY(16,2);
--Declaracion de variables de enteros Mensuales
DEFINE v_cNumOper      VARCHAR(20);
DEFINE v_mMontoMensual MONEY(16,2);
DEFINE v_dFechaOper    DATE;
DEFINE v_dFechaEntero  DATE;
DEFINE v_smesenero	   VARCHAR(6);

--Declaracion de variables menxml
DEFINE v_dFechaRet              DATE;
DEFINE v_mRemRecaudadoMensual   MONEY(16,2);

--DSB 25/03/2013
--DEFINE v_cCorreoElec 		VARCHAR(100); --DSB 09/01/2020
DEFINE v_cTelefono1 		VARCHAR(15);
DEFINE v_cTelefono2 		VARCHAR(15);
DEFINE v_msaldopenrec   	MONEY(16,2);
DEFINE v_cTipoCuenta		VARCHAR(50);
DEFINE v_mtotsaldopenrec	MONEY(16,2);

DEFINE iTransOpen INTEGER; --DSB 09/01/2020

DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;

--LET v_cCorreoElec = ''; --DSB 09/01/2020
LET v_cTelefono1 = '';
LET v_cTelefono2 = '';
LET v_msaldopenrec = 0;
LET v_cTipoCuenta = '';
LET v_mtotsaldopenrec = 0;



--Inicializacion de variables generales
LET v_cRetorno = '000000';
LET iSqlError = 0;
LET v_cFiller = ' ';
LET v_cNumReg = ' ';
LET v_iNumComplementaria = 0;
LET v_cDomicilio = ' ';
LET v_cArchivo = ' ';
LET v_dFechaPres = '01-01-1900';
LET v_cNumFolioAnt = ' ';
LET v_cDiaUltimo = '';
LET v_cVarPrueba1 = ' ';
LET v_cVarPrueba2 = ' ';
LET v_cVarPrueba3 = ' ';
LET v_cVarPrueba4 = ' ';
LET v_cMes = '';
LET v_cAnio = '';
LET v_dFechOper = '01-01-1900';
LET v_mMontoOper = 0;
LET v_cTipoOper = ' ';
LET v_iContador = 0;
--Inicializacion de variables stattmp_anualxmlfisica, stattmp_anualxmlmoral
LET v_cCliente = ' ';
LET v_cTipoPersona = ' ';
LET v_cRfc = ' ';
LET v_cCurp = ' ';
LET v_cRazonSocial = ' ';
LET v_cApPaterno = ' ';
LET v_cApMaterno = ' ';
LET v_cNombre1 = ' ';
LET v_cNombre2 = ' ';
LET v_cCalle = ' ';
LET v_cNumInterior = ' ';
LET v_cNumExterior = ' ';
LET v_cColonia = ' ';
LET v_cCP = ' ';
LET v_mMontoExcedente = 0;
LET v_mImpDeterminado = 0;
LET v_dImpRecaudado = 0;
LET v_mRecPendiente = 0;
--Inicializacion de variables stattmp_ctasfisicas,stattmp_ctasmorales
LET v_cCuenta = ' ';
LET v_siCotitulares = 0;
LET v_mPorcion = 0;
LET v_dImpRecaudadoDet = 0;
--Inicializacion de variables de parametros para encabezado
LET v_cEsquemaXSD = ' ';
LET v_cRfcDeclarante = ' ';
LET v_cInstitucion = ' ';
LET v_cRfcLegal = ' ';
LET v_cCurpLegal = ' ';
LET v_cNomLegal = ' ';
LET v_cVersionXSD = ' ';
LET v_cNomInstitucion = ' ';
LET v_cRfcInstitucion = ' ';
--Inicializacion de variables de totales
LET v_mImpDeterminadoTotal = 0;
LET v_mImpRecaudadoTotal = 0;
LET v_mMontoExcedenteTotal = 0;
LET v_i8NumOperaciones = 0;
--Inicializacion de variables de totales Mensuales
LET v_mRemTotal = 0;
LET v_mIdeTotal = 0;
LET v_mRecaudadoTotal = 0;
LET v_mPendienteTotal = 0;
LET v_i8OperacionTotal = 0;
LET v_mDepositoTotal = 0;
LET v_mEnteroTotal = 0;
--Inicializacion de variables de enteros Mensuales
LET v_cNumOper = ' ';
LET v_mMontoMensual = 0;
LET v_dFechaOper = '01-01-1900';
LET v_dFechaEntero = '01-01-1900';
LET v_smesenero = '';

--Inicializacion de variables menxml
LET v_dFechaRet = '01-01-1900';
LET v_mRemRecaudadoMensual = 0;

LET iTransOpen = 0; --DSB 09/01/2020

LET bInTransaction = 'f';
LET ven_transacc = 0;

BEGIN

	ON EXCEPTION SET iSqlError
		IF iSqlError <> 0  THEN
			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			LET  v_cRetorno = iSqlError;
			RETURN v_cRetorno,v_cArchivo;
		END IF;
	END  EXCEPTION;
	
	ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/ilopez/IDE_MENSUAL_ANUAL/sp_formararchivodedeclaracion.out";
	--TRACE ON;
	
	IF NVL(p_cFechaXML,'') = '' OR NVL(p_cDeclaracion,'') = '' OR NVL(p_cTipoDeclaracion,'') = '' THEN
		LET v_cRetorno = '000001';
	END IF;
	
	BEGIN WORK;
			
	IF bInTransaction = 'f' THEN
		COMMIT WORK;
	END IF;

	LET v_cMes = SUBSTRING(p_cFechaXML FROM 5 FOR 2);
	LET v_cAnio = SUBSTRING(p_cFechaXML FROM 1 FOR 4);
	LET v_smesenero = v_cAnio || '01';

	IF (v_cMes = '01' OR v_cMes = '03' OR v_cMes = '05' OR v_cMes = '07' OR v_cMes = '08' OR v_cMes = '10' OR v_cMes = '12') THEN
		LET v_cDiaUltimo = '31';
	ELIF (v_cMes = '04' OR v_cMes = '06' OR v_cMes = '09' OR v_cMes = '11') THEN
		LET v_cDiaUltimo = '30';
	ELSE
		LET v_cDiaUltimo = '28';
	END IF;

	/* ******************OBTENCION DE PARAMETROS ********************************** */
	SELECT TRIM(desc_valor)
	INTO v_cEsquemaXSD
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '20'
	AND valor = '01';

	SELECT TRIM(desc_valor)
	INTO v_cRfcDeclarante
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '01';

	SELECT TRIM(desc_valor)
	INTO v_cInstitucion
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '02';

	SELECT TRIM(desc_valor)
	INTO v_cRfcLegal
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '03';

	SELECT TRIM(desc_valor)
	INTO v_cCurpLegal
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '04';

	SELECT TRIM(desc_valor)
	INTO v_cNomLegal
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '05';

	SELECT TRIM(desc_valor)
	INTO v_cRfcInstitucion
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '06';

	SELECT TRIM(desc_valor)
	INTO  v_cNomInstitucion
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '08'
	AND valor = '07';

	SELECT TRIM(valor)
	INTO v_cVersionXSD
	FROM bdilide:"informix".sl_parametros
	WHERE cve_param = '24';

	
	/* ******************DECLARACION  MENSUAL********************************** */
	IF p_cDeclaracion = 'M' THEN
		IF EXISTS(SELECT {+ INDEX (bdilide:"informix".sl_menxml idx_sl_menxml02)} num_cte FROM bdilide:"informix".sl_menxml WHERE fechaxml = p_cFechaXML) THEN
			LET v_cNumReg = '1';
		ELSE
			LET v_cNumReg = '0';
		END IF;

		IF p_cTipoDeclaracion = 'N' THEN
			LET v_cArchivo = 'DIM137_'||v_cMes||v_cAnio||'_0.xml';
		ELSE
			SELECT NVL(MAX(no_compl),0) INTO v_iNumComplementaria FROM bdilide:"informix".sl_declinfor WHERE aniomes = p_cFechaXML AND normal = 'C' AND no_compl IS NOT NULL;

			IF NOT EXISTS(SELECT fecha_pres, no_folio_ant FROM bdilide:"informix".sl_declinfor WHERE aniomes = p_cFechaXML AND normal ='C' AND no_compl = v_iNumComplementaria) THEN
				LET v_cRetorno = '000002';
			ELSE
				LET v_cArchivo = 'DIM137_'||v_cMes||v_cAnio||'_'||v_iNumComplementaria||'.xml';
			END IF;
		END IF;

		IF v_cRetorno = '000000' THEN
			--DELETE FROM bdilide:"informix".sl_archivoxml WHERE nomarchivo = v_cArchivo; --DSB 09/01/2020
			--TRUNCATE TABLE bdilide:"informix".sl_archivoxml; --DSB 09/01/2020
			BEGIN;
				TRUNCATE TABLE bdilide:"informix".sl_archivoxml; 
			COMMIT;
			
			/* ************************ FORMACION DE ENCABEZADO DE ARCHIVO MENSUAL ***************** */
			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo, '<?xml version="1.0" encoding="utf-8" ?>');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo, '<DeclaracionInformativaMensualIDE xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="'||NVL(TRIM(v_cEsquemaXSD),'')||'" rfcDeclarante="'||NVL(TRIM(v_cRfcDeclarante),'')||'" denominacion="'||NVL(TRIM(v_cInstitucion),'')|| '" version="'||NVL(TRIM(v_cVersionXSD),'')||'">');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<RepresentanteLegal rfc="'||NVL(TRIM(v_cRfcLegal),'')||'" curp="'|| NVL(TRIM(v_cCurpLegal),'') || '">');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'<Nombre >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<NombreCompleto >');

            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo, LPAD(v_cFiller, 16, ' ')|| NVL(TRIM(v_cNomLegal),''));

            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo, LPAD(v_cFiller, 12, ' ')||'</NombreCompleto >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'</Nombre >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'</RepresentanteLegal>');

			IF p_cTipoDeclaracion = 'N' THEN
				INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<Normal ejercicio="'||NVL(v_cAnio,'')||'" periodo="'||NVL(v_cMes,'')||'"/>');
			ELSE
				SELECT fecha_pres, no_folio_ant
				INTO v_dFechaPres, v_cNumFolioAnt
				FROM bdilide:"informix".sl_declinfor
				WHERE aniomes = p_cFechaXML AND normal ='C' AND no_compl = v_iNumComplementaria;

				INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<Complementaria ejercicio="'||v_cAnio||
				'" periodo="'||NVL(TRIM(v_cMes),'')||'" opAnterior="'||NVL(TRIM(v_cNumFolioAnt),'')||'" fechaPresentacion="'||YEAR(v_dFechaPres)||'-'||LPAD(MONTH(v_dFechaPres), 2, '0')||'-'||LPAD(DAY(v_dFechaPres), 2, '0')||'"/>');
			END IF;

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<InstitucionDeCredito >');

			/* ******************INICIA FORMACION DE CUERPO DE ARCHIVO CON INFORMACION DE PERSONAS FISICAS MENSUALES******************** */
			IF v_cNumReg = '1' THEN
				--FOREACH
					--SELECT NVL(num_operacion, '0'), NVL(ROUND(monto, 0),0), NVL(fech_operacion,''), NVL(fech_entero,'')
					--INTO v_cNumOper,v_mMontoMensual,v_dFechaOper, v_dFechaEntero
					--FROM bdilide:"informix".sl_enteros
					--WHERE MONTH(fech_entero) = v_cMes AND
					--YEAR(fech_entero) = v_cAnio AND (monto > 0 OR DAY(fech_entero) = v_cDiaUltimo )
					--ORDER BY fech_entero

					IF EXISTS(SELECT {+ INDEX (bdilide:"informix".sl_menxml idx_sl_menxml01)} tpo_persona FROM bdilide:"informix".sl_menxml WHERE fechaxml = p_cFechaXML --AND fecha_ret = v_dFechaEntero 
					AND tpo_persona IS NOT NULL)THEN
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'<ReporteDeRecaudacionYEnteroDiaria fechaDeCorte="'||v_cAnio||'-'||v_cMes||'-'||v_cDiaUltimo||'">');
						--VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'<ReporteDeRecaudacionYEnteroDiaria fechaDeCorte="'||YEAR(v_dFechaEntero)||'-'||LPAD(MONTH(v_dFechaEntero), 2, '0')||'-'||LPAD(DAY(v_dFechaEntero), 2, '0')||'">');
						FOREACH WITH HOLD
							SELECT {+ INDEX (bdilide:"informix".sl_menxml idx_sl_menxml01)} num_cte, tpo_persona, NVL(rfc,''), curp, razon_soc, NVL(apell_pat,''), NVL(apell_mat,''), NVL(nombre1,''), NVL(nombre2,''), nom_calle, num_int, num_ext, nom_colonia, --DSB 25/03/2013
							cod_post, NVL(impdeterminado,0), NVL(recpendiente,0), NVL(remrecaudado,0), NVL(montoexcedente,0), NVL(imprecaudado,0), fecha_ret, NVL(saldopenrec,0)
							INTO v_cCliente,v_cTipoPersona,v_cRfc,v_cCurp,v_cRazonSocial,v_cApPaterno,v_cApMaterno,
								v_cNombre1,v_cNombre2,v_cCalle,v_cNumInterior,v_cNumExterior,v_cColonia,
								v_cCP,v_mImpDeterminado,v_mRecPendiente,v_mRemRecaudadoMensual, v_mMontoExcedente,
								v_dImpRecaudado,v_dFechaRet,v_msaldopenrec
							FROM bdilide:"informix".sl_menxml
							WHERE fechaxml = p_cFechaXML --AND fecha_ret = v_dFechaEntero 
							AND tpo_persona = '01'
							ORDER BY  fecha_ret
							
							--DSB 25/03/2013
							--SELECT correo_elec
							--INTO v_cCorreoElec
							--FROM bdinteg:"informix".si_correos
							--WHERE numcte = v_cCliente AND status_correo = 'A';
							
							SELECT telefono
							INTO v_cTelefono1
							FROM bdinteg:"informix".si_telefonos_actual
							WHERE numcte = v_cCliente AND tipo_tel = 1 AND status_tel = 'A';
							
							SELECT telefono
							INTO v_cTelefono2
							FROM bdinteg:"informix".si_telefonos_actual
							WHERE numcte = v_cCliente AND tipo_tel = 2 AND status_tel = 'A';
							
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"<RegistroDeDetalle>");

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)							
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<PersonaFisica rfc="'||NVL(TRIM(v_cRfc),'')
							--VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<PersonaFisica rfc="'||NVL(TRIM(v_cRfc),'')||'" curp="'|| NVL(TRIM(v_cCurp),'') MLF
							--||'" numeroCliente="'||NVL(TRIM(v_cCliente),'')||'" correoElectronico="'||NVL(TRIM(v_cCorreoElec),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">'); MLF
							||'" NumeroCliente="'||NVL(TRIM(v_cCliente),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<Nombre>");

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ')||"<NombreCompleto>" );

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 28, ' ')|| NVL(TRIM(v_cApPaterno),'')||" "||NVL(TRIM(v_cApMaterno),'')||" "||NVL(TRIM(v_cNombre1),'')||" "||NVL(TRIM(v_cNombre2),''));

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ')|| "</NombreCompleto>" );

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"</Nombre>");

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<Domicilio >");

							LET v_cDomicilio =  TRIM(v_cCalle)||" "||NVL(TRIM(v_cNumInterior),'') ||" "||NVL(TRIM(v_cNumExterior),'') ||" "||NVL(TRIM(v_cColonia),'')||" "||NVL(TRIM(v_cCP),'');

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ')||"<DomicilioCompleto >");

							IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN
                                INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                                VALUES (v_cArchivo,LPAD(v_cFiller, 28, ' ')||"DOMICILIO NO REGISTRADO");
							ELSE
								INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                                VALUES (v_cArchivo,LPAD(v_cFiller, 28, ' ') ||NVL(TRIM(v_cDomicilio),''));
							END IF;

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ')|| "</DomicilioCompleto >" );

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"</Domicilio >");
							
							--DSB 25/03/2013
							FOREACH WITH HOLD
								SELECT DISTINCT num_cta
								INTO v_cCuenta					
								FROM bdilide:"informix".sl_movefec_his 
								WHERE num_cte = v_cCliente AND aniomes = p_cFechaXML	
								
								LET v_iContador = v_iContador  + 1;
									
								IF v_iContador = 1 AND iTransOpen = 0 THEN --DSB 09/01/2020
									LET iTransOpen = 1;
									BEGIN WORK;
								END IF;
								
								INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
								VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<numeroCuenta>"||NVL(TRIM(v_cCuenta),'')||"</numeroCuenta>");
								
								IF v_iContador = 2500 AND iTransOpen = 1 THEN --DSB 09/01/2020
									COMMIT WORK;
									LET v_iContador = 0;
									LET iTransOpen = 0;
								END IF;
								
								CONTINUE FOREACH; --DSB 09/01/2020
							END FOREACH;
														
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</PersonaFisica>");

							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<DepositoEnEfectivo impuestoDeterminado="0'||'" recaudacionPendiente="0' || '" remanentePeriodosAnteriores="0' ||
							'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="0'||'" saldoPendienteRecaudar="0'|| '">'||'</DepositoEnEfectivo>' );
							
							/*VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<DepositoEnEfectivo impuestoDeterminado="' || NVL(ROUND(v_mImpDeterminado::INT8),0) || ---Se modifica para la generaciÃ³n de la Declaracion informativa.20/05/2014 MLFS
							'" recaudacionPendiente="' || NVL(ROUND(v_mRecPendiente::INT8),0) || '" remanentePeriodosAnteriores="' || NVL(ROUND(v_mRemRecaudadoMensual::INT8),0) ||
							'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="'|| NVL(ROUND(v_dImpRecaudado::INT8 ),0)||'" saldoPendienteRecaudar="'|| NVL(ROUND(v_msaldopenrec::INT8 ),0)|| '">'||'</DepositoEnEfectivo>' );	--DSB 25/03/2013*/
							--'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="'|| NVL(ROUND(v_dImpRecaudado::INT8 ),0)|| '">'||'</DepositoEnEfectivo>' );  --DSB 17-11-2011

							--INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)      --DSB 17-11-2011
							--VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</DepositoEnEfectivo>");  --DSB 17-11-2011

							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</RegistroDeDetalle>");

							CONTINUE FOREACH; --DSB 09/01/2020

						END FOREACH;

						IF iTransOpen = 1 THEN --DSB 09/01/2020
							COMMIT WORK;
							LET iTransOpen = 0;
						END IF;
			
						/* ******************INICIA FORMACION DE CUERPO DE ARCHIVO CON INFORMACION DE PERSONAS MORALES MENSUALES******************** */
						
						LET v_iContador = 0; --DSB 09/01/2020
						
						FOREACH
							--dsb-14/05/2012
							/*SELECT {+ INDEX (bdilide:"informix".sl_menxml idx_sl_menxml01)} tpo_persona, rfc, curp, razon_soc, apell_pat, apell_mat, nombre1, nombre2, nom_calle, num_int, num_ext, nom_colonia,
							cod_post, NVL(impdeterminado,0), NVL(recpendiente,0), NVL(remrecaudado,0), NVL(montoexcedente,0), NVL(imprecaudado,0), fecha_ret
							INTO v_cTipoPersona,v_cRfc,v_cCurp,v_cRazonSocial,v_cApPaterno,v_cApMaterno,
								v_cNombre1,v_cNombre2,v_cCalle,v_cNumInterior,v_cNumExterior,v_cColonia,
								v_cCP,v_mImpDeterminado,v_mRecPendiente,v_mRemRecaudadoMensual, v_mMontoExcedente,
								v_dImpRecaudado,v_dFechaRet
							FROM bdilide:"informix".sl_menxml
							WHERE fechaxml = p_cFechaXML AND fecha_ret = v_dFechaEntero AND tpo_persona = '02'
							ORDER BY  fecha_ret*/
							
							SELECT {+ INDEX (bdilide:"informix".sl_menxml idx_sl_menxml01)} xml.num_cte, xml.tpo_persona, xml.rfc, xml.curp, TRIM(xml.razon_soc) ||" "||TRIM(NVL(suf.descripcion,'')), xml.apell_pat, xml.apell_mat, xml.nombre1, xml.nombre2, xml.nom_calle, xml.num_int, xml.num_ext, xml.nom_colonia, xml.cod_post, NVL(xml.impdeterminado,0), NVL(xml.recpendiente,0), NVL(xml.remrecaudado,0), NVL(xml.montoexcedente,0), NVL(xml.imprecaudado,0), xml.fecha_ret, NVL(xml.saldopenrec,0) --DSB 25/03/2013
							INTO v_cCliente,v_cTipoPersona,v_cRfc,v_cCurp,v_cRazonSocial,v_cApPaterno,v_cApMaterno,
								v_cNombre1,v_cNombre2,v_cCalle,v_cNumInterior,v_cNumExterior,v_cColonia,
								v_cCP,v_mImpDeterminado,v_mRecPendiente,v_mRemRecaudadoMensual, v_mMontoExcedente,
								v_dImpRecaudado,v_dFechaRet,v_msaldopenrec
							--dsb-04/06/2012
							--FROM bdilide:"informix".sl_menxml xml, bdinteg:"informix".si_ctepm cte, bdinteg:"informix".si_sufijos suf
							FROM bdilide:"informix".sl_menxml xml, bdinteg:"informix".si_ctepm cte
							LEFT JOIN bdinteg:"informix".si_sufijos suf  ON cte.sufijo = suf.codigo
							WHERE xml.fechaxml = p_cFechaXML AND xml.tpo_persona = '02' AND xml.num_cte = cte.numcte --AND xml.fecha_ret = v_dFechaEntero 
							ORDER BY  fecha_ret
							
							--DSB 25/03/2013
							--SELECT correo_elec
							--INTO v_cCorreoElec
							--FROM bdinteg:"informix".si_correos
							--WHERE numcte = v_cCliente AND status_correo = 'A';
							
							SELECT telefono
							INTO v_cTelefono1
							FROM bdinteg:"informix".si_telefonos_actual
							WHERE numcte = v_cCliente AND tipo_tel = 1 AND status_tel = 'A';
							
							SELECT telefono
							INTO v_cTelefono2
							FROM bdinteg:"informix".si_telefonos_actual
							WHERE numcte = v_cCliente AND tipo_tel = 2 AND status_tel = 'A';
							
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"<RegistroDeDetalle>");

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)							
							--VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<PersonaMoral rfc="'||NVL(TRIM(v_cRfc),'')||'">'); --DSB 25/03/2013
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<PersonaMoral rfc="'||NVL(TRIM(v_cRfc),'')||'" NumeroCliente="'||NVL(TRIM(v_cCliente),'')
							--||'" correoElectronico="'||NVL(TRIM(v_cCorreoElec),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
							||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<Denominacion>");

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ') || NVL(TRIM(v_cRazonSocial),''));

                            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
                            VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ') || "</Denominacion>" );

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<Domicilio >");

							LET v_cDomicilio =  NVL(TRIM(v_cCalle),'')||" "||NVL(TRIM(v_cNumInterior),'') ||" "|| NVL(TRIM(v_cNumExterior),'') ||" "||NVL(TRIM(v_cColonia),'')||" "||NVL(TRIM(v_cCP),'');
                          
    						IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN
								INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
								VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto > DOMICILIO NO REGISTRADO </DomicilioCompleto >" );
							ELSE
								INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
								VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto >" ||TRIM(NVL(v_cDomicilio,'')) ||"  </DomicilioCompleto >" );
							END IF;
													                            
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"</Domicilio >");
							
							--DSB 25/03/2013
							FOREACH
								SELECT DISTINCT num_cta
								INTO v_cCuenta
								FROM bdilide:"informix".sl_movefec_his 
								WHERE num_cte = v_cCliente AND aniomes BETWEEN v_smesenero AND p_cFechaXML
								--UNION
								--SELECT DISTINCT cuenta_ret							
								--FROM bdilide:"informix".sl_detlide
								--WHERE num_cte = v_cCliente AND fecha_ret = v_dFechaEntero)
								
								LET v_iContador = v_iContador  + 1;
									
								IF v_iContador = 1 AND iTransOpen = 0 THEN --DSB 09/01/2020
									LET iTransOpen = 1;
									BEGIN WORK;
								END IF;
								
								INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
								VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<numeroCuenta>"||NVL(TRIM(v_cCuenta),'')||"</numeroCuenta>");
								
								IF v_iContador = 2500 AND iTransOpen = 1 THEN --DSB 09/01/2020
									COMMIT WORK;
									LET v_iContador = 0;
									LET iTransOpen = 0;
								END IF;
								
								CONTINUE FOREACH; --DSB 09/01/2020
								
							END FOREACH;

							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</PersonaMoral>");
												
							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<DepositoEnEfectivo impuestoDeterminado="0' ||'" recaudacionPendiente="0' ||
							'" remanentePeriodosAnteriores="0' ||'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="0'||
							'" saldoPendienteRecaudar="0'|| '">'||'</DepositoEnEfectivo>' );
							
							/*VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<DepositoEnEfectivo impuestoDeterminado="' || NVL(ROUND(v_mImpDeterminado::INT8),0) || Se modifica para la generaciÃ³n de la Declaracion informativa.20/05/2014 MLFS
							'" recaudacionPendiente="' || NVL(ROUND(v_mRecPendiente::INT8),0) || '" remanentePeriodosAnteriores="' || NVL(ROUND(v_mRemRecaudadoMensual::INT8),0) ||
							'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="'|| NVL(ROUND(v_dImpRecaudado::INT8 ),0)||'" saldoPendienteRecaudar="'|| NVL(ROUND(v_msaldopenrec::INT8 ),0)|| '">'||'</DepositoEnEfectivo>' );	--DSB 25/03/2013*/
							--'" montoExcedente="' || NVL(ROUND(v_mMontoExcedente::INT8),0) || '" impuestoRecaudado="'|| NVL(ROUND(v_dImpRecaudado::INT8 ),0) || '">'||'</DepositoEnEfectivo>' );  --DSB 17-11-2011
																					
							--INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)     --DSB 17-11-2011
							--VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</DepositoEnEfectivo>"); --DSB 17-11-2011

							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</RegistroDeDetalle>");
						END FOREACH;
												
						
						IF v_mMontoMensual > 0 THEN
							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<EnteroPropio noOperacion="'||TRIM(v_cNumOper)||'" impuestoEnterado="'||
							v_mMontoMensual::INT8||'" nombreInstitucion="'||NVL(TRIM(v_cNomInstitucion),'')||'" rfcInstitucion="'||TRIM(v_cRfcInstitucion)||
							'" fechaEntero="'||LPAD(YEAR(v_dFechaOper), 4, '0')||'-'||LPAD(MONTH(v_dFechaOper), 2, '0')||'-'||LPAD(DAY(v_dFechaOper), 2, '0')||'" fechaRecaudacion="'||YEAR(v_dFechaEntero)||'-'||LPAD(MONTH(v_dFechaEntero), 2, '0')||'-'||LPAD(DAY(v_dFechaEntero), 2, '0')||'"/>'); --dsb-29/04/2013
							
						END IF;
						
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'</ReporteDeRecaudacionYEnteroDiaria>');
					END IF;
				--END FOREACH;
										
			END IF;
			/* ******************  FORMACION DEL TRAILER DEl ARCHIVO  ******************** */
			SELECT ROUND(total_reman,0) , ROUND(total_ide,0) , ROUND( total_rec,0) ,ROUND( total_pend,0) , 
			ROUND(total_oper,0), ROUND(total_depositos,0),ROUND( total_entero,0), ROUND( total_saldopenrec,0)	--DSB 25/03/2013		
			INTO v_mRemTotal, v_mIdeTotal, v_mRecaudadoTotal, v_mPendienteTotal, v_i8OperacionTotal, v_mDepositoTotal, v_mEnteroTotal, v_mtotsaldopenrec
			FROM bdilide:"informix".sl_declinfor
			WHERE aniomes = p_cFechaXML
			AND normal = p_cTipoDeclaracion
			AND no_compl = (SELECT NVL(MAX(no_compl),0)
			FROM bdilide:"informix".sl_declinfor WHERE aniomes = p_cFechaXML AND normal = p_cTipoDeclaracion AND no_compl IS NOT NULL);
			
			LET v_cVarPrueba1 = LPAD(v_cFiller, 8, ' ')||'<Totales importeRemanenteDepositos="0'||'" importeCheques="0"';
			LET v_cVarPrueba2 = ' importeDeterminadoDepositos="0'||'" importeRecaudadoDepositos="0'||'" importePendienteRecaudacion="0';
			LET v_cVarPrueba3 = '" operacionesRelacionadas="'||NVL(ROUND(v_i8OperacionTotal::INT8),0)||'" importeExcedenteDepositos="'||NVL(ROUND(v_mDepositoTotal::int8),0);
			LET v_cVarPrueba4 = '" importeEnterado="0'||'" importeSaldoPendienteRecaudar="0'||'" ></Totales>';
			
			/*LET v_cVarPrueba1 = LPAD(v_cFiller, 8, ' ')||'<Totales importeRemanenteDepositos="'||NVL(ROUND(v_mRemTotal::INT8),0)||'" importeCheques="0"';
			LET v_cVarPrueba2 = ' importeDeterminadoDepositos="'||NVL(ROUND(v_mIdeTotal::INT8),0)||'" importeRecaudadoDepositos="'||NVL(ROUND(v_mRecaudadoTotal::INT8),0)||'" importePendienteRecaudacion="';
			LET v_cVarPrueba3 = NVL(ROUND(v_mPendienteTotal::INT8),0)||'" operacionesRelacionadas="'||NVL(ROUND(v_i8OperacionTotal::INT8),0)||'" importeExcedenteDepositos="'||NVL(ROUND(v_mDepositoTotal::int8),0);
			LET v_cVarPrueba4 = '" importeEnterado="'|| NVL(ROUND(v_mEnteroTotal::INT8),0)||'" importeSaldoPendienteRecaudar="'|| NVL(ROUND(v_mtotsaldopenrec::INT8),0)||'" ></Totales>'; --DSB 25/03/2013
			Se comenta esta secciÃ³n para la generaciÃ³n de las DIM informativa 20/05/2014*/
			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,SUBSTRING(v_cVarPrueba1 FROM 1 FOR LENGTH(v_cVarPrueba1)) || SUBSTRING(v_cVarPrueba2 FROM 1 FOR LENGTH(v_cVarPrueba2))|| SUBSTRING(v_cVarPrueba3 FROM 1 FOR LENGTH(v_cVarPrueba3))|| SUBSTRING(v_cVarPrueba4 FROM 1 FOR LENGTH(v_cVarPrueba4)));

			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'</InstitucionDeCredito>');

			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,'</DeclaracionInformativaMensualIDE>');
			
			IF iTransOpen = 1 THEN --DSB 09/01/2020
				COMMIT WORK;
			END IF;
			
		END IF;

	/* ******************DECLARACION ANUAL ********************************** */
	ELSE

		IF EXISTS(SELECT {+ INDEX(bdilide:"informix".sl_anualxml idx_anualxml)} num_cte FROM bdilide:"informix".sl_anualxml WHERE fechaxml = p_cFechaXML) THEN
			LET v_cNumReg = '1';
		ELSE
			LET v_cNumReg = '0';
		END IF;

		IF p_cTipoDeclaracion = 'N' THEN
			LET v_cArchivo = 'DIA137_'||v_cAnio||'_0.xml';
		ELSE
			SELECT NVL(MAX(no_compl),0) INTO v_iNumComplementaria FROM bdilide:"informix".sl_declinfor WHERE aniomes = p_cFechaXML AND normal = 'C' AND no_compl IS NOT NULL;

			IF NOT EXISTS(SELECT fecha_pres, no_folio_ant FROM bdilide:"informix".sl_declinfor WHERE aniomes = p_cFechaXML AND normal ='C' AND no_compl = v_iNumComplementaria) THEN
				LET v_cRetorno = '000002';
			ELSE
				LET v_cArchivo = 'DIA137_'||v_cAnio||'_'||v_iNumComplementaria||'.xml';
			END IF;
		END IF;

		IF v_cRetorno = '000000' THEN
			IF v_cNumReg = '1' THEN
				--DELETE FROM bdilide:"informix".sl_archivoxml WHERE nomarchivo = v_cArchivo; --DSB 09/01/2020
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".sl_archivoxml; --DSB 09/01/2020
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_anualxmlfisica;
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_anualxmlmoral;
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_ctasfisicas;
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_ctasmorales;
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_movctasfisicas;
				COMMIT;
				BEGIN;
				TRUNCATE TABLE bdilide:"informix".stattmp_movctasmorales;
				COMMIT;
				
        
				/* ***********DIVIDE LA TABLA sl_anualxml EN DOS TEMPORALES ESTATICAS, UNA PARA PERSONAS MORALES Y OTRA PARA PERSONAS FISICAS ******** */
				INSERT INTO bdilide:"informix".stattmp_anualxmlfisica
				SELECT {+ INDEX (bdilide:"informix".sl_anualxml idx_anualxml02)} num_cte, tpo_persona, rfc, curp, razon_soc, apell_pat, apell_mat, nombre1,
						nombre2, nom_calle, num_int, num_ext, nom_colonia, cod_post, montoexcedente, impdeterminado, imprecaudado, recpendiente, fechaxml
				FROM bdilide:"informix".sl_anualxml
				WHERE fechaxml = p_cFechaXML
				AND tpo_persona =  '01';

				INSERT INTO bdilide:"informix".stattmp_anualxmlmoral
				SELECT {+ INDEX (bdilide:"informix".sl_anualxml idx_anualxml02)} num_cte, tpo_persona, rfc, curp, razon_soc, apell_pat, apell_mat, nombre1,
						nombre2, nom_calle, num_int, num_ext, nom_colonia, cod_post, montoexcedente, impdeterminado, imprecaudado, recpendiente, fechaxml
				FROM bdilide:"informix".sl_anualxml
				WHERE fechaxml = p_cFechaXML
				AND tpo_persona =  '02';

				/* ***********DIVIDE LA TABLA sl_ctas EN DOS TEMPORALES ESTATICAS, UNA PARA PERSONAS MORALES Y OTRA PARA PERSONAS FISICAS ********** */
				INSERT INTO bdilide:"informix".stattmp_ctasfisicas
				SELECT {+ INDEX (bdilide:"informix".stattmp_anualxmlfisica idx_stattmp_anualxmlfisica01)}
				b.num_cte, b.num_cta, b.cotitulares, b.porcion, b.imprecaudado, b.fechaxml
				FROM bdilide:"informix".stattmp_anualxmlfisica a INNER JOIN bdilide:"informix".sl_ctas b
				ON b.num_cte = a.num_cte
				AND b.fechaxml = p_cFechaXML;

				INSERT INTO bdilide:"informix".stattmp_ctasmorales
				SELECT {+ INDEX (bdilide:"informix".stattmp_anualxmlmoral idx_stattmp_anualxmlmoral01)}
				b.num_cte, b.num_cta, b.cotitulares, b.porcion, b.imprecaudado, b.fechaxml
				FROM bdilide:"informix".stattmp_anualxmlmoral a INNER JOIN bdilide:"informix".sl_ctas b
				ON b.num_cte = a.num_cte
				WHERE b.fechaxml = p_cFechaXML;

				/* ***********DIVIDE LA TABLA sl_movctas EN DOS TEMPORALES ESTATICAS, UNA PARA PERSONAS MORALES Y OTRA PARA PERSONAS FISICAS ********** */
				INSERT INTO bdilide:"informix".stattmp_movctasfisicas
				SELECT {+ INDEX (bdilide:"informix".stattmp_ctasfisicas idx_stattmp_ctasfisicas01)}
				b.keyx, b.num_cte, b.num_cta, b.tipo_oper, b.monto_oper, b.fecha_oper, b.fechaxml
				FROM bdilide:"informix".stattmp_ctasfisicas a INNER JOIN bdilide:"informix".sl_movctas b
				ON b.num_cte = a.num_cte AND b.num_cta = a.num_cta
				WHERE keyx > 0
				AND b.fechaxml = p_cFechaXML;
																
				INSERT INTO bdilide:"informix".stattmp_movctasmorales
				SELECT {+ INDEX (bdilide:"informix".stattmp_ctasmorales idx_stattmp_ctasmorales01)}
				b.keyx, b.num_cte, b.num_cta, b.tipo_oper, b.monto_oper, b.fecha_oper, b.fechaxml
				FROM bdilide:"informix".stattmp_ctasmorales a INNER JOIN bdilide:"informix".sl_movctas b
				ON b.num_cte = a.num_cte AND b.num_cta = a.num_cta
				WHERE keyx > 0
				AND b.fechaxml = p_cFechaXML;
			
			END IF;
			/* ************************ FORMACION DE ENCABEZADO DE ARCHIVO***************** */

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo, '<?xml version="1.0" encoding="utf-8" ?>');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo, '<DeclaracionInformativaAnualIDE xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="'||TRIM(v_cEsquemaXSD)||'" rfcDeclarante="'||TRIM(v_cRfcDeclarante)||'" denominacion="'||TRIM(v_cInstitucion)|| '" version="'||TRIM(v_cVersionXSD)||'">');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<RepresentanteLegal rfc="'||NVL(TRIM(v_cRfcLegal),'')||'" curp="'|| NVL(TRIM(v_cCurpLegal),'') || '">');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'<Nombre >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<NombreCompleto >');

            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo, LPAD(v_cFiller, 16, ' ')|| NVL(TRIM(v_cNomLegal),''));

            INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
            VALUES (v_cArchivo, LPAD(v_cFiller, 12, ' ')||'</NombreCompleto >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'</Nombre >');

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'</RepresentanteLegal>');

			IF p_cTipoDeclaracion = 'N' THEN
				INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<Normal ejercicio="'|| NVL(TRIM(v_cAnio),'')||'"/>');
			ELSE
				SELECT fecha_pres, no_folio_ant
				INTO v_dFechaPres, v_cNumFolioAnt
				FROM bdilide:"informix".sl_declinfor
				WHERE aniomes = p_cFechaXML AND normal ='C' AND no_compl = v_iNumComplementaria;

				INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
				VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<Complementaria ejercicio="'||NVL(v_cAnio,'')||
				'" opAnterior="'||v_cNumFolioAnt||'" fechaPresentacion="'||YEAR(v_dFechaPres)||'-'||LPAD(MONTH(v_dFechaPres), 2, '0')||'-'||LPAD(DAY(v_dFechaPres), 2, '0')||'"/>');
			END IF;

			INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'<InstitucionDeCredito >');

			/* ******************INICIA FORMACION DE CUERPO DE ARCHIVO CON INFORMACION DE PERSONAS FISICAS******************** */
			IF v_cNumReg = '1' THEN
				FOREACH WITH HOLD
					SELECT {+ INDEX (bdilide:"informix".stattmp_anualxmlfisica idx_stattmp_anualxmlfisica01)} num_cte, tpo_persona, NVL(rfc,''), curp, razon_soc, apell_pat, apell_mat, nombre1, nombre2, nom_calle, num_int,
							num_ext, nom_colonia, cod_post, montoexcedente, impdeterminado, imprecaudado, recpendiente
					INTO v_cCliente, v_cTipoPersona, v_cRfc, v_cCurp, v_cRazonSocial, v_cApPaterno, v_cApMaterno, v_cNombre1, v_cNombre2, v_cCalle, v_cNumInterior,
						 v_cNumExterior, v_cColonia, v_cCP, v_mMontoExcedente, v_mImpDeterminado, v_dImpRecaudado, v_mRecPendiente
					FROM bdilide:"informix".stattmp_anualxmlfisica
					
					--DSB 14/03/2013
					IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
						--REALIZAR
						LET v_cNumReg = '1';
					ELSE
						--NO REALIZAR
						LET v_cNumReg = '0';
					END IF;
					IF v_cNumReg = '1' THEN
						
						--DSB 25/03/2013
						--SELECT correo_elec
						--INTO v_cCorreoElec
						--FROM bdinteg:"informix".si_correos
						--WHERE numcte = v_cCliente AND status_correo = 'A';
						
						SELECT telefono
						INTO v_cTelefono1
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = v_cCliente AND tipo_tel = 1 AND status_tel = 'A';
						
						SELECT telefono
						INTO v_cTelefono2
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = v_cCliente AND tipo_tel = 2 AND status_tel = 'A';
						
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||"<RegistroDeDetalle>");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<PersonaFisica rfc="'|| NVL(TRIM(v_cRfc),'')
						--VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<PersonaFisica rfc="'||NVL(TRIM(v_cRfc),'')||'" curp="'|| NVL(TRIM(v_cCurp),'')
						--||'" numeroCliente="'||NVL(TRIM(v_cCliente),'')||'" correoElectronico="'||NVL(TRIM(v_cCorreoElec),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
						||'" NumeroCliente="'||NVL(TRIM(v_cCliente),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"<Nombre>");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<NombreCompleto>");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 24, ' ')|| NVL(TRIM(v_cApPaterno),'')||" "|| NVL(TRIM(v_cApMaterno),'')||" "|| NVL(TRIM(v_cNombre1),'')||" "||NVL(TRIM(v_cNombre2),''));

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')|| "</NombreCompleto>" );

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</Nombre>");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"<Domicilio >");

						LET v_cDomicilio =  NVL(TRIM(v_cCalle),'')||" "||NVL(TRIM(v_cNumInterior),'') ||" "|| NVL(TRIM(v_cNumExterior),'') ||" "||NVL(TRIM(v_cColonia),'')||" "||NVL(TRIM(v_cCP),'');

						IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto > DOMICILIO NO REGISTRADO </DomicilioCompleto >" );
						ELSE
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto >" ||TRIM(NVL(v_cDomicilio,'')) ||"  </DomicilioCompleto >" );
						END IF;

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</Domicilio >");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</PersonaFisica>");

						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<DepositoEnEfectivo impuestoDeterminado="' || NVL(v_mImpDeterminado::INT8,0) || '" recaudacionPendiente="' || NVL(v_mRecPendiente::INT8,0) || '" montoExcedente="' || NVL(v_mMontoExcedente::INT8,0) || '" impuestoRecaudado="'|| NVL(v_dImpRecaudado::INT8,0) || '">' );
						
						/*--dsb 27/02/2012
						IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
							--REALIZAR
							LET v_cNumReg = '1';
						ELSE
							--NO REALIZAR
							LET v_cNumReg = '0';
						END IF;
						
						IF v_cNumReg = '1' THEN*/
						
						FOREACH WITH HOLD
							SELECT {+ INDEX (bdilide:"informix".stattmp_ctasfisicas idx_stattmp_ctasfisicas01)} num_cta, cotitulares, porcion, imprecaudado
							INTO v_cCuenta, v_siCotitulares, v_mPorcion, v_dImpRecaudadoDet
							FROM bdilide:"informix".stattmp_ctasfisicas
							WHERE num_cte = v_cCliente
							
							--DSB 25/03/2013
							SELECT nombre
							INTO v_cTipoCuenta
							FROM bdicheq:"informix".sc_producto
							WHERE producto = (SELECT producto FROM bdicheq:"informix".sc_maechq 
												WHERE cuenta = v_cCuenta AND producto IS NOT NULL);
							--dsb 15/05/2013
							IF NVL(v_cTipoCuenta,'') = '' THEN
								SELECT nombre_prod
								INTO v_cTipoCuenta
								FROM bdicred:"informix".sd_definicion
								WHERE num_producto = (SELECT num_producto FROM bdicred:"informix".sd_maecred 
														WHERE num_credito = v_cCuenta AND num_producto IS NOT NULL);
							END IF;

							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)							
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<Cuenta numeroCuenta="' || NVL(TRIM(v_cCuenta),'') || '" proporcion="' || NVL(v_mPorcion::DECIMAL(10,4),0) || '" cotitulares="' || NVL(v_siCotitulares,0) || '" impuestoRecaudado="'|| NVL(v_dImpRecaudadoDet::INT8 ,0) ||'" tipoCuenta="' || NVL(TRIM(v_cTipoCuenta),'') ||'" tipoMoneda="MXN">' );	--DSB 25/03/2013

							/*
							--dsb 22/02/2012
							IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
								--REALIZAR
								LET v_cNumReg = '1';
							ELSE
								--NO REALIZAR
								LET v_cNumReg = '0';
							END IF;
							
							IF v_cNumReg = '1' THEN*/
							
							FOREACH WITH HOLD
								SELECT {+ INDEX (bdilide:"informix".stattmp_movctasfisicas idx_stattmp_movctasfisicas01)}fecha_oper,monto_oper,tipo_oper
								INTO v_dFechOper, v_mMontoOper, v_cTipoOper
								FROM bdilide:"informix".stattmp_movctasfisicas
								WHERE num_cta = v_cCuenta
								AND num_cte = v_cCliente
								ORDER BY fecha_oper
								IF v_mMontoOper > 0 THEN
								
									LET v_iContador = v_iContador  + 1;
									
									IF v_iContador = 1 AND iTransOpen = 0 THEN --DSB 09/01/2020
										LET iTransOpen = 1;
										BEGIN WORK;
									END IF;
								
									INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)									
									VALUES(v_cArchivo,LPAD(v_cFiller, 20, ' ')||'<Movimiento fechaOperacion="'||LPAD(YEAR(v_dFechOper), 4, '0')||'-'||LPAD(MONTH(v_dFechOper), 2, '0')||'-'||LPAD(DAY(v_dFechOper), 2, '0')||'" montoOperacion="'||v_mMontoOper::INT8||'" tipoOperacion="'||DECODE(v_cTipoOper,'01', 'deposito', '02', 'retiro')||'" montoOperacionMonedaNacional="'||v_mMontoOper::INT8||'"></Movimiento>');	--DSB 25/03/2013
									
									IF v_iContador = 2500 AND iTransOpen = 1 THEN --DSB 09/01/2020
										COMMIT WORK;
										LET v_iContador = 0;
										LET iTransOpen = 0;
									END IF;
									
									CONTINUE FOREACH; --DSB 09/01/2020
																		
									--DSB 09/01/2020
									/*IF v_iContador  = 50000 THEN  --DSB 01-11-2011
										UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_archivoxml;
										LET v_iContador = 0;
									END IF;*/
								END IF;
								
							END FOREACH;
							--END IF
																		
							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</Cuenta>");
							
						CONTINUE FOREACH; --DSB 09/01/2020
			
						END FOREACH; --stattmp_ctasfisicas
						--END IF
						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</DepositoEnEfectivo>");

						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||"</RegistroDeDetalle>");
						
					END IF;

				CONTINUE FOREACH; --DSB 09/01/2020
									
				END FOREACH;   -- tmpanualxmlfisica
				
				IF iTransOpen = 1 THEN --DSB 09/01/2020
					COMMIT WORK;
					LET iTransOpen = 0;
				END IF;

				/* ******************INICIA FORMACION DE CUERPO DE ARCHIVO CON INFORMACION DE PERSONAS MORALES******************** */
				
				LET v_iContador = 0; --DSB 09/01/2020
								
				FOREACH WITH HOLD
					--dsb-14/05/2012
					/*SELECT {+ INDEX (bdilide:"informix".stattmp_anualxmlmoral idx_stattmp_anualxmlmoral01)}
						num_cte, tpo_persona, rfc, curp, razon_soc, apell_pat, apell_mat, nombre1, nombre2, nom_calle, num_int,
						num_ext, nom_colonia, cod_post, montoexcedente, impdeterminado, imprecaudado, recpendiente
					INTO v_cCliente, v_cTipoPersona, v_cRfc, v_cCurp, v_cRazonSocial, v_cApPaterno, v_cApMaterno, v_cNombre1, v_cNombre2, v_cCalle, v_cNumInterior,
						 v_cNumExterior, v_cColonia, v_cCP, v_mMontoExcedente, v_mImpDeterminado, v_dImpRecaudado, v_mRecPendiente
					FROM bdilide:"informix".stattmp_anualxmlmoral*/
					
					SELECT {+ INDEX (bdilide:"informix".stattmp_anualxmlmoral idx_stattmp_anualxmlmoral01)}
					xml.num_cte, xml.tpo_persona, xml.rfc, xml.curp, TRIM(xml.razon_soc)||" "||TRIM(suf.descripcion), xml.apell_pat, xml.apell_mat, xml.nombre1, xml.nombre2, xml.nom_calle, xml.num_int, xml.num_ext, xml.nom_colonia, xml.cod_post, xml.montoexcedente, xml.impdeterminado, xml.imprecaudado, xml.recpendiente
					INTO v_cCliente, v_cTipoPersona, v_cRfc, v_cCurp, v_cRazonSocial, v_cApPaterno, v_cApMaterno, v_cNombre1, v_cNombre2, v_cCalle, v_cNumInterior,v_cNumExterior, v_cColonia, v_cCP, v_mMontoExcedente, v_mImpDeterminado, v_dImpRecaudado, v_mRecPendiente					
					--FROM bdilide:"informix".stattmp_anualxmlmoral xml, bdinteg:"informix".si_ctepm cte, bdinteg:"informix".si_sufijos suf	--dsb-04/06/2012
					FROM bdilide:"informix".stattmp_anualxmlmoral xml, bdinteg:"informix".si_ctepm cte
					LEFT JOIN bdinteg:"informix".si_sufijos suf ON cte.sufijo = suf.codigo
					WHERE xml.num_cte = cte.numcte --AND cte.sufijo = suf.codigo
					
					--DSB 14/03/2013
					IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
						--REALIZAR
						LET v_cNumReg = '1';
					ELSE
						--NO REALIZAR
						LET v_cNumReg = '0';
					END IF;
					IF v_cNumReg = '1' THEN
						
						--DSB 25/03/2013
						--SELECT correo_elec
						--INTO v_cCorreoElec
						--FROM bdinteg:"informix".si_correos
						--WHERE numcte = v_cCliente AND status_correo = 'A';
						
						SELECT telefono
						INTO v_cTelefono1
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = v_cCliente AND tipo_tel = 1 AND status_tel = 'A';
						
						SELECT telefono
						INTO v_cTelefono2
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = v_cCliente AND tipo_tel = 2 AND status_tel = 'A';
												
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||"<RegistroDeDetalle>");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						--VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<PersonaMoral rfc="'||NVL(TRIM(v_cRfc),'')||'">');	--DSB 25/03/2013
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<PersonaMoral rfc="'||NVL(TRIM(v_cRfc),'')||'" NumeroCliente="'||NVL(TRIM(v_cCliente),'')
						--||'" correoElectronico="'||NVL(TRIM(v_cCorreoElec),'')||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');
						||'" telefono1="'||LPAD(NVL(TRIM(v_cTelefono1),'000000000000000'),15,'0')||'" telefono2="'||LPAD(NVL(TRIM(v_cTelefono2),'000000000000000'),15,'0')||'">');

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"<Denominacion>" || NVL(TRIM(v_cRazonSocial),'') ||" > </Denominacion>" );
						
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"<Domicilio >");
										
						LET v_cDomicilio =  TRIM(v_cCalle)||" "||TRIM(v_cNumInterior) ||" "|| TRIM(v_cNumExterior) ||" "||TRIM(v_cColonia)||" "||TRIM(v_cCP);

						IF v_cDomicilio = ' ' OR v_cDomicilio IS NULL THEN
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto > DOMICILIO NO REGISTRADO </DomicilioCompleto >" );
						ELSE
							INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 20, ' ')||"<DomicilioCompleto >" ||TRIM(v_cDomicilio) ||"  </DomicilioCompleto >" );
						END IF;
														
						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</Domicilio >");

						INSERT INTO bdilide:"informix".sl_archivoxml (nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</PersonaMoral>");

						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||'<DepositoEnEfectivo impuestoDeterminado="' || NVL(v_mImpDeterminado::INT8,0) || '" recaudacionPendiente="' || NVL(v_mRecPendiente::INT8,0) || '" montoExcedente="' || NVL(v_mMontoExcedente::INT8,0) || '" impuestoRecaudado="'|| NVL(v_dImpRecaudado::INT8 ,0)|| '">' );

						/*--dsb 27/02/2012
						IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
							--REALIZAR
							LET v_cNumReg = '1';
						ELSE
							--NO REALIZAR
							LET v_cNumReg = '0';
						END IF;
						
						IF v_cNumReg = '1' THEN*/											
						
						FOREACH WITH HOLD
							SELECT {+ INDEX (bdilide:"informix".stattmp_ctasmorales idx_stattmp_ctasmorales01)} num_cta, cotitulares, porcion, imprecaudado
							INTO v_cCuenta, v_siCotitulares, v_mPorcion, v_dImpRecaudadoDet
							FROM bdilide:"informix".stattmp_ctasmorales
							WHERE num_cte = v_cCliente
							
							--DSB 25/03/2013
							SELECT nombre
							INTO v_cTipoCuenta
							FROM bdicheq:"informix".sc_producto
							WHERE producto = (SELECT producto FROM bdicheq:"informix".sc_maechq 
												WHERE cuenta = v_cCuenta AND producto IS NOT NULL);
							
							IF NVL(v_cTipoCuenta,'') = '' THEN
								SELECT nombre_prod
								INTO v_cTipoCuenta
								FROM bdicred:"informix".sd_definicion
								WHERE num_producto = (SELECT num_producto FROM bdicred:"informix".sd_maecred 
														WHERE num_credito = v_cCuenta AND num_producto IS NOT NULL);
							END IF;

							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)							
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||'<Cuenta numeroCuenta="' || NVL(TRIM(v_cCuenta),'') || '" proporcion="' || NVL(v_mPorcion::DECIMAL(10,4),0) || '" cotitulares="' || NVL(v_siCotitulares,0) || '" impuestoRecaudado="'|| NVL(v_dImpRecaudadoDet::INT8,0) ||'" tipoCuenta="' || NVL(TRIM(v_cTipoCuenta),'') ||'" tipoMoneda="MXN">' );	--DSB 25/03/2013

							/*
							--dsb 22/02/2012
							IF v_mRecPendiente > 0 THEN -- SI TIENE IDE PENDIENTE POR RECAUDAR
								--REALIZAR
								LET v_cNumReg = '1';
							ELSE
								--NO REALIZAR
								LET v_cNumReg = '0';
							END IF;
							
							IF v_cNumReg = '1' THEN*/							
								
							FOREACH WITH HOLD
								SELECT {+ INDEX (bdilide:"informix".stattmp_movctasmorales idx_stattmp_movctasmorales01)} fecha_oper,monto_oper,tipo_oper
								INTO v_dFechOper, v_mMontoOper, v_cTipoOper
								FROM bdilide:"informix".stattmp_movctasmorales
								WHERE num_cta = v_cCuenta
								AND num_cte = v_cCliente
								ORDER BY fecha_oper

								IF v_mMontoOper > 0 THEN
									
									LET v_iContador = v_iContador  + 1;
									
									IF v_iContador = 1 AND iTransOpen = 0 THEN --DSB 09/01/2020
										LET iTransOpen = 1;
										BEGIN WORK;
									END IF;
									
									INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)									
									VALUES(v_cArchivo,LPAD(v_cFiller, 20, ' ')||'<Movimiento fechaOperacion="'||LPAD(YEAR(v_dFechOper), 4, '0')||'-'||LPAD(MONTH(v_dFechOper), 2, '0')||'-'||LPAD(DAY(v_dFechOper), 2, '0')||'" montoOperacion="'||v_mMontoOper::INT8||'" tipoOperacion="'||DECODE(v_cTipoOper,'01', 'deposito', '02', 'retiro')||'" montoOperacionMonedaNacional="'||v_mMontoOper::INT8||'"></Movimiento>');	--DSB 25/03/2013
									
									IF v_iContador = 2500 AND iTransOpen = 1 THEN --DSB 09/01/2020
										COMMIT WORK;
										LET v_iContador = 0;
										LET iTransOpen = 0;
									END IF;
									
									CONTINUE FOREACH; --DSB 09/01/2020
																	
									--DSB 09/01/2020
									/*IF v_iContador  = 50000 THEN  --DSB 01-11-2011
										UPDATE STATISTICS MEDIUM FOR TABLE bdilide:"informix".sl_archivoxml;
										LET v_iContador = 0;
									END IF;*/
								END IF;
								
							END FOREACH;
							--END IF
														
							INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
							VALUES (v_cArchivo,LPAD(v_cFiller, 16, ' ')||"</Cuenta>");
														
							CONTINUE FOREACH; --DSB 09/01/2020

						END FOREACH; --stattmp_ctasmorales
												
						--END IF
						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 12, ' ')||"</DepositoEnEfectivo>");

						INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
						VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||"</RegistroDeDetalle>");
					END IF;
										
					CONTINUE FOREACH; --DSB 09/01/2020
					
				END FOREACH;   -- stattmp_anualxmlmoral

			IF iTransOpen = 1 THEN --DSB 09/01/2020
				COMMIT WORK;
				LET iTransOpen = 0;
			END IF;
				
			END IF;
			/* ******************  FORMACION DEL TRAILER DEl ARCHIVO  ******************** */

			SELECT {+ INDEX(bdilide:"informix".sl_anualxml idx_anualxml)}--NVL(ROUND(SUM(impdeterminado),0),0), NVL(ROUND(SUM(imprecaudado),0),0), NVL(ROUND(SUM(montoexcedente),0),0), COUNT(*)
			SUM(ROUND(NVL(impdeterminado,0),0)) , SUM(ROUND(NVL(imprecaudado,0),0)) , SUM(ROUND(NVL(montoexcedente,0),0)) ,  COUNT(num_cte)  
			INTO v_mImpDeterminadoTotal, v_mImpRecaudadoTotal, v_mMontoExcedenteTotal, v_i8NumOperaciones
			FROM bdilide:"informix".sl_anualxml WHERE fechaxml = p_cFechaXML;

			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 8, ' ')||'<Totales importeDeterminadoDepositos="'|| NVL(ROUND(v_mImpDeterminadoTotal::INT8),0)||
			'" importeRecaudadoDepositos="'||NVL(ROUND(v_mImpRecaudadoTotal::INT8),0)||'" operacionesRelacionadas="'||NVL(ROUND(v_i8NumOperaciones),0)||
			'" importeExcedenteDepositos="' ||NVL(ROUND(v_mMontoExcedenteTotal::int8),0)||'" importePendienteDepositos="'||
			NVL(ROUND(v_mImpDeterminadoTotal::INT8),0) - NVL(ROUND(v_mImpRecaudadoTotal::INT8),0)||'" ></Totales>' );

			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,LPAD(v_cFiller, 4, ' ')||'</InstitucionDeCredito>');

			INSERT INTO bdilide:"informix".sl_archivoxml(nomarchivo, registro)
			VALUES (v_cArchivo,'</DeclaracionInformativaAnualIDE>');
			
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_anualxmlfisica;
			COMMIT;
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_anualxmlmoral;
			COMMIT;
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_ctasfisicas;
			COMMIT;
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_ctasmorales;
			COMMIT;
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_movctasfisicas;
			COMMIT;
			BEGIN;
			TRUNCATE TABLE bdilide:"informix".stattmp_movctasmorales;
			COMMIT;
		END IF;
	
	END IF;
	
	LET ven_transacc = 0;
			
	IF bInTransaction = 't' THEN
		BEGIN WORK;
	END IF;

	RETURN v_cRetorno,v_cArchivo;
END;
END PROCEDURE
