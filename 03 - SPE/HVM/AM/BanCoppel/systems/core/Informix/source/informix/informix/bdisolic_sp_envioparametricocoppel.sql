CREATE  PROCEDURE  "informix".sp_envioparametricocoppel(p_Empresa CHAR(3), p_NumCte VARCHAR(20), p_NumSolicitud CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) AS CodigoRetorno,
	LVARCHAR(15000) AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE sql_err			INTEGER;
	DEFINE vCodRet			CHAR(5);
	DEFINE cResidencia		CHAR(2);
	DEFINE iValor			MONEY(14,2);
	DEFINE cFecAnt			CHAR(10);
	DEFINE cNumSolSIC		CHAR(20);
	DEFINE iLogFinal		INTEGER;
	DEFINE v_Cadena			LVARCHAR(1000);
	DEFINE v_Cadena2		LVARCHAR(10000);
	DEFINE v_Cadena3		LVARCHAR(1000);
	DEFINE cEdoCiv 			CHAR(2);
	DEFINE cTimOcupacion    CHAR(2);
	DEFINE iClave       	SMALLINT;
	DEFINE cSubClave    	CHAR(5); --SubClave
	DEFINE iValorSeguridad	INTEGER; --Valor Seguridad
	DEFINE iVersion			INTEGER; --Version
	DEFINE iNumCd       	SMALLINT;
	DEFINE iNumCol   		SMALLINT;
	DEFINE cTipoCasa 		CHAR(1); --Tipo de casa
	DEFINE cGenero			CHAR(1); --Sexo
	DEFINE cEdoCivil		CHAR(1); --Estado Civil
	DEFINE cFecNac			CHAR(10);
	DEFINE cTiempReside 	CHAR(10);
	DEFINE iHabDom		    SMALLINT;
	DEFINE cEscolaridad 	CHAR(1); --Nivel de Escolaridad
	DEFINE iDependiente 	SMALLINT;
	DEFINE vNivIngreso  	SMALLINT;
	DEFINE cPuesto			CHAR(1); --Puesto
	DEFINE iOpcionPuesto 	SMALLINT;
	DEFINE iSubOpcioPuesto 	SMALLINT;
	DEFINE cTiempoDesc  	CHAR(10);
	DEFINE cTimEdoCiv   	CHAR(10);
	DEFINE cFecHoy      	CHAR(10);
	DEFINE iMesesAntiguedad SMALLINT;
	DEFINE iPeorPago		SMALLINT;
	DEFINE iNumSols			SMALLINT;
	DEFINE iCteBCPL			INTEGER; --CLienteBCPL
	DEFINE iNumCred			INT8; 	 --NumeroCredito
	DEFINE cInstitucion 	CHAR(2); --TipoConsulta
	DEFINE cFolioConsul 	CHAR(9); --Folio Consulta
	DEFINE cFechaSIC		CHAR(10);
	DEFINE iIngMensual  	INTEGER; --Ingreso Mensual
	DEFINE cResSIC      	LVARCHAR(10000); --Respuesta SIC
	DEFINE cVar01			CHAR(1); --Variable 1
	DEFINE cVar02			CHAR(1); --Variable 2
	DEFINE cVar03			CHAR(1); --Variable 3
	DEFINE cVar04			CHAR(1); --Variable 4
	DEFINE cVar05			CHAR(1); --Variable 5
	DEFINE iVar06			INTEGER; --Variable 6
	DEFINE iVar07			INTEGER; --Variable 7
	DEFINE iVar08			INTEGER; --Variable 8
	DEFINE iVar09			INTEGER; --Variable 9
	DEFINE iVar10			INTEGER; --Variable 10
	DEFINE dtFechSol		DATE;
	DEFINE iRenglonMinimo	INT8;
	--dsb-07/11/2012
	DEFINE iCiudadBanco INTEGER;
	DEFINE cFolioSucursal CHAR(4);

-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
    DEFINE vcasa,vcelular   CHAR(1);
    DEFINE vtipomovimiento  CHAR(1);
    DEFINE vnumsolicitudref CHAR(20);
    DEFINE ref1numerociudad, ref1numerocolonia, ref2numerociudad, ref2numerocolonia INTEGER;
-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel

	--INICIALIZACION DE VARIABLES--
	LET sql_err 	 	= 0;
	LET vCodRet 	 	= '00000';
	LET cResidencia  	= " ";
	LET ivalor		 	= 0;
	LET cFecAnt      	= " ";
	LET cNumSolSIC   	= " ";
	LET iLogFinal 	 	= 0;
	LET v_Cadena	 	= " ";
	LET v_Cadena2	 	= " ";
	LET v_Cadena3	 	= " ";
	LET cEdoCiv		 	= " ";
	LET cTimOcupacion 	= " ";
	LET iClave       	= 90;
	LET cSubClave    	="0016";
	LET iValorSeguridad = 0;
	LET iVersion	 	= 0;
	LET iNumCd       	= 0;
	LET iNumCol 	 	= 0;
	LET cTipoCasa 	 	= " ";
	LET cGenero		 	= " ";
	LET cEdoCivil	 	= " ";
	LET cFecNac		 	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET cTiempReside 	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET iHabDom      	= 0;
	LET cEscolaridad 	= " ";
	LET iDependiente 	= 0;
	LET vNivIngreso  	= 0;
	LET cPuesto		 	= "0";
	LET iOpcionPuesto 	= 0;
	LET iSubOpcioPuesto = 0;
	LET cTiempoDesc  	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET cTimEdoCiv   	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET cFecHoy      	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET iMesesAntiguedad = -1;
	LET iPeorPago	 	= -1;
	LET iNumSols     	= -1;
	LET iCteBCPL     	= 0;
	LET iNumCred	 	= 0;
	LET cInstitucion 	= "NC";
	LET cFolioConsul 	= " ";
	LET cFechaSIC    	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET iIngMensual  	= 0;
	LET cResSIC      	= " ";
	LET cVar01		 	= " ";
	LET cVar02		 	= " ";
	LET cVar03		 	= " ";
	LET cVar04		 	= " ";
	LET cVar05		 	= " ";
	LET iVar06		 	= 0;
	LET iVar07		 	= 0;
	LET iVar08		 	= 0;
	LET iVar09		 	= 0;
	LET iVar10		 	= 0;
	LET dtFechSol		=DATE(1);
	LET iRenglonMinimo = 0;
	--dsb-07/11/2012
	LET iCiudadBanco = 0;
	LET cFolioSucursal = "";

-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
    LET vcasa            = " ";
    LET vcelular         = " ";
    LET vtipomovimiento  = " ";
    LET vnumsolicitudref = " "; 
    LET ref1numerociudad = 0;
    LET ref1numerocolonia = 0;
    LET ref2numerociudad = 0;
    LET ref2numerocolonia = 0;
-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel


	--SET DEBUG FILE TO "/tmp/Josue/sp_envioparametricocoppel_out.sql";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN  vCodRet, v_Cadena ||"|"|| v_Cadena2 ||"|"|| v_Cadena3 ||"|";
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		IF (p_Empresa IS NULL OR p_Empresa = '') OR (p_NumCte IS NULL OR p_NumCte = '')  OR (p_NumSolicitud IS NULL OR p_NumSolicitud = '') THEN
				RETURN '00001', NULL;
		ELSE
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = p_NumCte) THEN
				--NumeroCiudad y NumeroColonia
				SELECT a.numerociudadcoppel, a.numerocoloniacoppel
				INTO iNumCd, iNumCol
				FROM bdinteg:"informix".si_catzonas a
				WHERE a.numerociudad = (SELECT b.numerociudad FROM bdinteg:"informix".si_direcciones_actual b WHERE b.numcte = p_NumCte AND b.tipo_dir = 1)
				AND a.numerocolonia =(SELECT c.numerocolonia FROM bdinteg:"informix".si_direcciones_actual c WHERE c.numcte = p_NumCte and c.tipo_dir = 1);
			END IF;
			
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = p_NumCte) THEN
				--TipoDeCasa, Genero, EstadoCivil, FechaNacimiento,HabitantesEnDomicilio
				SELECT ctepf.habita_en, ctepf.sexo, ctepf.estado_civil, TO_CHAR(ctepf.fecha_nac, '%Y-%m-%d'), CAST(cte.string2 AS SMALLINT)
				INTO cTipoCasa, cGenero, cEdoCivil, cFecNac, iHabDom
				FROM bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_cliente cte
				WHERE ctepf.numcte = p_NumCte AND cte.numcte = p_NumCte;

				--FechaEvaluacion
				SELECT TO_CHAR(fecha_hoy, '%Y-%m-%d') INTO cFecHoy FROM bdicred:"informix".sd_fechas;
			END IF;

			IF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_detalle_scoring WHERE num_solicitud = p_NumSolicitud) THEN
				--Tiempo de Residencia
				SELECT SUBSTR(descripcion,1,2)
				INTO cResidencia
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 6 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 6 AND num_solicitud = p_NumSolicitud);

			  /*SELECT fecha_insert - cResidencia::INTEGER units YEAR
				INTO cTiempReside
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;*/
				--RTV
				SELECT fecha_insert, sucursal--dsb-07/11/2012
					INTO dtFechSol, cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				--dsb-07/11/2012
				IF NVL(iNumCd, 0) = 0 THEN
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
					INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
					
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO iNumCd FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
				END IF;
				IF NVL(iNumCol, 0) = 0 THEN
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END
					INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
					
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO iNumCol FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
				END IF;
				
				IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
					LET dtFechSol = dtFechSol -1 units DAY;
				END IF

				LET cTiempReside = dtFechSol - cResidencia::INTEGER units YEAR;

				--Nivel de escolaridad
				SELECT elemento
				INTO cEscolaridad
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 21 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 21 AND num_solicitud = p_NumSolicitud);

				--Numero de dependientes
				SELECT descripcion::INTEGER
				INTO iDependiente
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 11 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 11 AND num_solicitud = p_NumSolicitud);

				--Tiempo de Ocupacion
				SELECT SUBSTR(descripcion,1,2)
				INTO cTimOcupacion
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 8 and elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 8 AND num_solicitud = p_NumSolicitud);

				IF cTimOcupacion = "No" THEN
					LET cTimOcupacion = "1900-01-01";
				ELSE
					/*SELECT fecha_insert - cTimOcupacion::INTEGER units YEAR
					INTO cTiempoDesc
					FROM bdisolic:"informix".ss_solicitudes
					WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;*/
					SELECT fecha_insert
					INTO dtFechSol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
					LET dtFechSol = dtFechSol -1 units DAY;
				END IF

				LET cTiempoDesc = dtFechSol - cTimOcupacion::INTEGER units YEAR;

				END IF;

				IF (cEdoCivil <> "S") THEN
					--TiempoDeEstadoCivil(AÑOS)
					SELECT SUBSTR(descripcion,1,2)
					INTO cEdoCiv
					FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 4 and elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 4 AND num_solicitud = p_NumSolicitud);

					IF (TRIM(cEdoCiv) <> "0") THEN

						IF cEdoCiv = "No" THEN
							LET cTimEdoCiv = "1900-01-01";
						ELSE

							/*SELECT fecha_insert - cEdoCiv::INTEGER units YEAR
							INTO cTimEdoCiv
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;	*/

							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

							LET cTimEdoCiv = bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -12);
							
--							IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
--								LET dtFechSol = dtFechSol -1 units DAY;
--							END IF
--
--							LET cTimEdoCiv = dtFechSol - cEdoCiv::INTEGER units YEAR;

						END IF;
					ELSE
						--TiempoDeEstadoCivil(MESES)
						SELECT SUBSTR(descripcion,1,2)
						INTO cEdoCiv
						FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 41 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 41 AND num_solicitud = p_NumSolicitud);

						IF (cEdoCiv <> "0") THEN
							/*SELECT fecha_insert - cEdoCiv::INTEGER units MONTH
							INTO cTimEdoCiv
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;*/

							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

							LET cTimEdoCiv = bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -1);
							
							--DSB-01/10/2013
							/*IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
								LET dtFechSol = dtFechSol -1 units DAY;
							END IF

							LET cTimEdoCiv = dtFechSol - cEdoCiv::INTEGER units MONTH;*/

						END IF;
					END IF;
				END IF;
			END IF;

			IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = p_NumSolicitud) THEN

				--Ingreso Mensual
				--DSB-01/10/2013				
				/*SELECT CAST(ingreso_mensual AS INTEGER), tipo_movimiento, num_solicitud_ref
				INTO iIngMensual, vtipomovimiento, vnumsolicitudref
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE num_solicitud = p_NumSolicitud;*/

				SELECT CAST(ingreso_mensual AS MONEY), tipo_movimiento, num_solicitud_ref
				INTO iValor, vtipomovimiento, vnumsolicitudref
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE num_solicitud = p_NumSolicitud;

				IF iValor > 250000 THEN
					--Actualizar el ingreso maximo a 250000 
					UPDATE bdisolic:"informix".ss_resum_scor_fin SET ingreso_mensual = 250000 WHERE num_solicitud = p_NumSolicitud;
					LET iIngMensual = 250000::INTEGER;
				ELSE
					LET iIngMensual = iValor::INTEGER;
				END IF;
				--Nivel de ingreso
				SELECT valor::DECIMAL(14,2)
				INTO iValor
				FROM bdisolic:"informix".ss_param
				WHERE empresa = p_Empresa AND secuencia = 363;
				--RTV
				LET vNivIngreso = ((((NVL(iIngMensual::DECIMAL(14,2),0))+(iValor/2)))/iValor)::SMALLINT;

				IF vNivIngreso < 1 THEN
					LET vNivIngreso = 1;
				END IF;

			END IF;

			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_ingresos WHERE numcte = p_NumCte) THEN
				--Opcion del Puesto, SubOpcion del Puesto
				SELECT claveopcionpuesto, clavesubopcionpuesto
				INTO iOpcionPuesto, iSubOpcioPuesto
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = p_Empresa
				AND numcte = p_NumCte AND tipo_ingreso = 'T'
				AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = p_NumCte AND tipo_ingreso = 'T');
			ELSE
				IF EXISTS (SELECT numcte FROM bdinteg:si_bitacoraapertura WHERE numcte = p_NumCte) THEN
					SELECT id_act, id_subact
					INTO iOpcionPuesto, iSubOpcioPuesto
					FROM bdinteg:si_bitacoraapertura
					WHERE numcte = p_NumCte AND id_pregunta = 6
					AND id_secuencia = (SELECT MAX(id_secuencia) FROM bdinteg:si_bitacoraapertura WHERE numcte = p_NumCte);
				END IF;
			END IF;
			
			--NumeroCredito
			LET iNumCred = CAST(TRIM(p_NumSolicitud) AS INT8);

			IF EXISTS (SELECT num_solicitud_sic FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud) THEN
				--TipoConsulta
				--SELECT num_solicitud_sic, institucion
				--INTO cNumSolSIC, cInstitucion
				--FROM bdisolic:"informix".ss_solicitudes_sic
				--WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				--DSB-01/10/2013
				SELECT FIRST 1 num_solicitud_sic, institucion 
				  INTO cNumSolSIC, cInstitucion 
				  FROM bdisolic:"informix".ss_solicitudes_sic 
				 WHERE numcte = p_NumCte 
				   AND num_solicitud = p_NumSolicitud  
				   AND fecha_insert = (SELECT MAX(fecha_insert) 
				                         FROM bdisolic:"informix".ss_solicitudes_sic 
									    WHERE numcte = p_NumCte 
										  AND num_solicitud = p_NumSolicitud
										  AND fecha_sic IS NOT NULL)
				   AND fecha_sic IS NOT NULL;

				 LET p_NumSolicitud = cNumSolSIC;
			ELSE
				IF EXISTS (SELECT numcte FROM bdiburo:"informix".br_traslado WHERE numcte = p_NumCte) THEN
					SELECT institucion
					INTO cInstitucion
					FROM bdiburo:"informix".br_traslado
					WHERE numcte = p_NumCte AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_traslado  WHERE numcte = p_NumCte);
				END IF;
			END IF;

			IF EXISTS(SELECT num_cliente FROM bdiburo:"informix".br_rs WHERE num_cliente = p_NumCte AND institucion = cInstitucion AND rs34 IS NOT NULL) THEN

				--Se modifica la forma de obtener la informacion del segmento rs. RTV - 2012/04/11
				SELECT MIN(rowid) INTO iRenglonMinimo FROM bdiburo:"informix".br_rs
				WHERE num_cliente = p_NumCte AND institucion = cInstitucion;

				--Meses de Antigüedad
				SELECT rs34, rs16
				INTO cFecAnt, iNumSols
				FROM bdiburo:"informix".br_rs
				WHERE num_cliente = p_NumCte AND institucion = cInstitucion AND rowid = iRenglonMinimo;

				SELECT CAST(((fecha_insert - cFecAnt)/30.42) AS INTEGER)
				INTO iMesesAntiguedad
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				--Peor Forma de Pago
				EXECUTE PROCEDURE bdisolic:"informix".sp_peorformapago(TRIM(p_NumCte), cInstitucion) INTO vCodRet, iPeorPago;

				--Se comenta ya que se esta obteniendo en una consulta previa. RTV - 2012/04/11
				--Numero de Solicitudes
				--SELECT rs16 INTO iNumSols FROM bdiburo:"informix".br_rs WHERE num_cliente = p_NumCte AND institucion = cInstitucion;
			END IF;

			IF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = p_NumSolicitud) THEN
				--ClienteBCPL
				SELECT CAST(numcte AS INTEGER)
				INTO iCteBCPL
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;
			END IF;

			IF EXISTS(SELECT num_solicitud FROM bdiburo:"informix".sb_regreso WHERE num_solicitud = p_NumSolicitud) THEN
				--RespuestaSIC
               -- Modificacion de cadena 05/05/2015
				SELECT TRIM(replace(regreso,'|',' '))
				INTO cResSIC
				FROM bdiburo:"informix".sb_regreso
				WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion;

				--FolioConsulta
				EXECUTE PROCEDURE bdisolic:"informix".sp_instr(2,cResSIC,'ES05') INTO vCodRet, iLogFinal;

				SELECT SUBSTR(regreso,(iLogFinal+13),9)
				INTO cFolioConsul
				FROM bdiburo:"informix".sb_regreso
				WHERE institucion = cInstitucion AND num_solicitud = p_NumSolicitud;
			END IF;

			IF EXISTS (SELECT solicitud FROM bdiburo:"informix".br_auditor WHERE solicitud = p_NumSolicitud) THEN
				--FechaConsultaSIC
				SELECT TO_CHAR(fecha,'%Y-%m-%d')
				INTO cFechaSIC
				FROM bdiburo:"informix".br_auditor
				WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion
				AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_auditor WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion);
			END IF;

		END IF;

-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel

    -- Número de habitantes en el domicilio que trabajan
        SELECT elemento 
          INTO iVar06
          FROM bdisolic:"informix".ss_detalle_scoring 
         WHERE num_solicitud = p_NumSolicitud
           AND grupo = 39;

        IF (iVar06 is null) THEN
            LET iVar06 = 0;
        END IF;

-- Telefono de casa          
        SELECT first 1 cofetel
          INTO vcasa
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = p_NumCte
           AND tipo_tel = 1;
           
        IF (vcasa is null) THEN
            LET vcasa = 'F';
        END IF;

-- Telefono de trabajo           
        
        SELECT first 1 cofetel
          INTO vcelular
          FROM bdinteg:si_telefonos_actual
         WHERE numcte = p_NumCte
           AND tipo_tel = 2;
           
        IF (vcelular is null) THEN
            LET vcelular = 'F';
        END IF;

        IF   (vcasa = 'F' and vcelular = 'F') THEN
            LET cVar02 = '0';
        ELIF (vcasa = 'V' and vcelular = 'F') THEN
            LET cVar02 = '1';
        ELIF (vcasa = 'F' and vcelular = 'V') THEN
            LET cVar02 = '2';
        ELSE
            LET cVar02 = '3';
        END IF;

        IF (vtipomovimiento is null) THEN
            LET vtipomovimiento = " ";
        END IF;

        IF (vtipomovimiento = 'M') THEN
        -- Se cambia a la solicitud Bancoppel
            LET p_NumSolicitud = vnumsolicitudref;
        END IF;
            
-- Referencia 1        
        SELECT parentesco, numerociudad, numerocolonia
          INTO cVar01, ref1numerociudad, ref1numerocolonia
          FROM bdinteg:si_refclientes a,
               bdinteg:si_refdirecciones b
         WHERE empresa  = p_Empresa
           AND a.numcte = p_NumCte
           AND a.numcte = b.numcte
           AND a.secuencia = (SELECT MIN(secuencia)
                              FROM bdinteg:si_refclientes 
                             WHERE a.empresa = empresa
                               AND a.numcte = numcte
                               AND num_solicitud = p_NumSolicitud)
           AND a.secuencia = b.secuencia;
    
        IF (cVar01 is null) THEN
            LET cVar01 = " ";
        END IF;

        SELECT first 1 numerociudadcoppel
        INTO ref1numerociudad
        FROM bdinteg:"informix".si_catzonas
        WHERE numerociudad  = ref1numerociudad
          AND numerocolonia = ref1numerocolonia;

        IF NVL(ref1numerociudad, 0) = 0 THEN
            SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
            INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

            SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
            INTO ref1numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
        END IF;

        IF NVL(ref1numerociudad, 0) = 0 THEN
            LET ref1numerociudad = -99;
        END IF;

-- Referencia 2        
        SELECT numerociudad, numerocolonia
          INTO ref2numerociudad, ref2numerocolonia
          FROM bdinteg:si_refclientes a,
               bdinteg:si_refdirecciones b
         WHERE empresa  = p_Empresa
           AND a.numcte = p_NumCte
           AND a.numcte = b.numcte
           AND a.secuencia = (SELECT MAX(secuencia)
                              FROM bdinteg:si_refclientes 
                             WHERE a.empresa = empresa
                               AND a.numcte = numcte
                               AND num_solicitud = p_NumSolicitud)
           AND a.secuencia = b.secuencia;

        SELECT first 1 numerociudadcoppel
        INTO ref2numerociudad
        FROM bdinteg:"informix".si_catzonas
        WHERE numerociudad  = ref2numerociudad
          AND numerocolonia = ref2numerocolonia;

        IF NVL(ref2numerociudad, 0) = 0 THEN
            SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
            INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

            SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
            INTO ref2numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
        END IF;

        IF NVL(ref2numerociudad, 0) = 0 THEN
            LET ref2numerociudad = -99;
        END IF;

        LET iVar07 = ref1numerociudad;
        LET iVar08 = ref2numerociudad;

-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel


		LET v_Cadena = iClave ||"|"|| TRIM(cSubClave) ||"|"|| iValorSeguridad ||"|"|| iVersion ||"|"|| iNumCd
				||"|"|| iNumCol ||"|"|| cTipoCasa ||"|"|| cGenero ||"|"|| cEdoCivil ||"|"|| cFecNac ||"|"|| cTiempReside
				||"|"|| iHabDom ||"|"|| cEscolaridad ||"|"|| iDependiente ||"|"|| vNivIngreso ||"|"|| cPuesto
				||"|"|| iOpcionPuesto ||"|"|| iSubOpcioPuesto ||"|"|| cTiempoDesc ||"|"|| cTimEdoCiv ||"|"|| cFecHoy
				||"|"|| iMesesAntiguedad ||"|"|| iPeorPago ||"|"|| iNumSols ||"|"|| iCteBCPL ||"|"|| iNumCred
				||"|"|| cInstitucion ||"|"|| cFolioConsul ||"|"|| cFechaSIC ||"|"|| iIngMensual;

		LET v_Cadena2 = cResSIC;

		LET v_Cadena3 = cVar01 ||"|"|| cVar02 ||"|"|| cVar03 ||"|"|| cVar04 ||"|"|| cVar05 ||"|"|| iVar06 ||"|"|| iVar07
				||"|"|| iVar08 ||"|"|| iVar09 ||"|"|| iVar10;

		RETURN  vCodRet, v_Cadena ||"|"|| v_Cadena2 ||"|"|| v_Cadena3 ||"|";
	END

END PROCEDURE

