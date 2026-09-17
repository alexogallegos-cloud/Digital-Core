CREATE PROCEDURE "informix".sp_cac_obteninforepnivelautorizacion (pEmpresa CHAR(3),pNumCredito CHAR(20), pEjecutivo CHAR(9), pCompIngreso CHAR(1), pFechaINC CHAR(10))

	RETURNING 	CHAR(6) 		AS Cod_Ret,
				CHAR(80) 		AS mensaje_retorno,
				CHAR(107) 		AS NombreCte,
				CHAR(13) 		AS RFC,
				CHAR(20) 		AS FechaNac,
				CHAR(13) 		AS EstadoCivil,
				CHAR(13) 		AS TelDomicilio,
				CHAR(13) 		AS TelMovil,
				CHAR(13) 		AS TelTrabajo,
				CHAR(30) 		AS Calle,
				INTEGER 		AS Numero,
				CHAR(32) 		AS Colonia,
				CHAR(20) 		AS DeloMunicipio,
				CHAR(30) 		AS NomEstado,
				CHAR(5) 		AS CP,
				CHAR(50) 		AS NombreSuc,
				CHAR(20) 		AS NumeroCuenta,
				CHAR(4) 		AS Sucursal,
				CHAR(1) 		AS Incremento,
				CHAR(1) 		AS CreditoFuncionario,
				CHAR(1) 		AS ObligadoSolidario,
				CHAR(80) 		AS NombrePromotor,
				DECIMAL(18,2) 	AS LinActual,
				DECIMAL(18,2) 	AS NuevaLin,
				DECIMAL(18,2) 	AS MontoIncre,
				INTEGER 		AS iAumento,
				CHAR(50) 		AS NomObligado,
				CHAR(10) 		AS FechaNacObligado,
				CHAR(20) 		AS RFCObligado,
				CHAR(10) 		AS TelCasa,
				CHAR(50) 		AS RelacionCte,
				SMALLINT 		AS MesesHist,
				DECIMAL(18,2) 	AS Ingresos,
				CHAR(1) 		AS BuroCredito,
				CHAR(1) 		AS CirculoCredito,
				CHAR(1) 		AS Coppel,
				CHAR(40) 		AS TipoComprobante,
				CHAR(2) 		AS NivelAutorizacion,
				CHAR(45) 		AS NomNivel1,
				CHAR(45) 		AS NomNivel2,
				CHAR(45) 		AS NomNivel3,
				CHAR(45) 		AS NomNivel4,
				CHAR(2)  		AS RangoAutorizacion,
				CHAR(10)        AS FechaMax,
				CHAR(203)		AS Observ_1,
				CHAR(203)       AS Observ_2,
				CHAR(203)		AS Observ_3,
				CHAR(203)		AS Observ_4;

	--DECLARACION DE VARIABLES
	DEFINE cCodRet    			CHAR(6);
	DEFINE cMensajeRet 			CHAR(80);
	DEFINE iSqlErr, iIsamErr 	INTEGER;
	DEFINE cNivelAutorizacion 	CHAR(2);
	DEFINE cNombre 				CHAR(45);
	DEFINE cPuesto 				CHAR(2);
	--Datos del cliente
	DEFINE cNumcte 				CHAR(20);
	DEFINE cNumCteCop 			CHAR(20);
	DEFINE cNombreCte 			CHAR(107);
	DEFINE cNombre1 			CHAR(26);
	DEFINE cNombre2 			CHAR(26);
	DEFINE cApellido1 			CHAR(26);
	DEFINE cApellido2 			CHAR(26);
	DEFINE cRFC 				CHAR(13);
	DEFINE dtFechaNac 			DATE;
	DEFINE cEstadoCivil 		CHAR(13);
	DEFINE cTelDomicilio		CHAR(13);
	DEFINE cTelMovil			CHAR(13);
	DEFINE cTelTrabajo 			CHAR(13);
	--Domicilio completo
	DEFINE iNumCalle 			INTEGER;
	DEFINE cCalle 				CHAR(30);
	DEFINE cColonia 			CHAR(32);
	DEFINE iNumColonia 			INTEGER;
	DEFINE cDeloMunicipio 		CHAR(20);
	DEFINE cEstado 				CHAR(20);
	DEFINE cNumCiudad 			CHAR(3);
	DEFINE cNomEstado 			CHAR(30);
	DEFINE cCP 					CHAR(5);
	DEFINE cNombreSuc 			CHAR(50);
	DEFINE cNumeroCuenta 		CHAR(20);
	DEFINE cSucursal 			CHAR(4);
	DEFINE cIncremento 			CHAR(1);
	DEFINE cCreditoFuncionario 	CHAR(1);
	DEFINE cObligadoSolidario 	CHAR(1);
	DEFINE cNombrePromotor 		CHAR(80);
	DEFINE dLinActual 			DECIMAL(18,2);
	DEFINE dNuevaLin			DECIMAL(18,2);
	DEFINE dMontoIncre 			DECIMAL(18,2);
	DEFINE iAumento 			INTEGER;
	--Datos obligado solidario
	DEFINE cNomObligado 		CHAR(50);
	DEFINE dFechaNacObligado 	CHAR(10);
	DEFINE cRFCObligado 		CHAR(13);
	DEFINE cTelCasa     		CHAR(10);
	DEFINE cRelacionCte 		CHAR(50);
	--Comentarios y documentación de apoyo
	DEFINE sMesesHist 			SMALLINT;
	DEFINE cBuroCredito 		CHAR(1);
	DEFINE cCirculoCredito 		CHAR(1);
	DEFINE cCoppel 				CHAR(1);
	DEFINE cTipoComprobante 	CHAR(40);
	DEFINE cComentarios 		CHAR(150);
	DEFINE iNivel 				INTEGER;
	DEFINE cRango_autoriz 		CHAR(2);
	DEFINE cNomNivel1 			CHAR(45);
	DEFINE cNomNivel2 			CHAR(45);
	DEFINE cNomNivel3 			CHAR(45);
	DEFINE cNomNivel4 			CHAR(45);
	DEFINE cPromotor 			CHAR(9);
	DEFINE iBanderaColor 		INTEGER;
    DEFINE cFechaMax             DATE;
	DEFINE cObserv				CHAR(200);
	DEFINE cObserv_1			CHAR(203);
	DEFINE cObserv_2			CHAR(203);
	DEFINE cObserv_3			CHAR(203);
	DEFINE cObserv_4			CHAR(203);
	DEFINE dIDP                 DECIMAL(18,2);
	DEFINE dValorSM             DECIMAL(18,2);
	DEFINE dTopeSalMin          DECIMAL(18,2);
	DEFINE dSalarioMin          DECIMAL(18,2);
	DEFINE dIngresoMaximo       DECIMAL(18,2);
	DEFINE dIngresoMensDec      DECIMAL(18,2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dtFechaNumPagos		DATE;
	DEFINE dtFecha_status		DATE;
	DEFINE iPorcIngreso			INTEGER;
	DEFINE dPagosRealizados		DECIMAL(18,2);
	DEFINE dCTP                 DECIMAL(18,2);
	DEFINE dFCP					DECIMAL(18,2);
	DEFINE dImporte_hip		    MONEY (14,2);
	DEFINE dCompromPagoSIC      DECIMAL(14,2);
	DEFINE dCTC					DECIMAL(18,2);
	DEFINE dCMA					DECIMAL(18,2);
	DEFINE dtFechaINC           DATE; 
		
	--INICIALIZACION DE VARIABLES
	LET cCodRet 				= "000000";
	LET iSqlErr 				= 0;
	LET iIsamErr 				= 0;
	LET cMensajeRet 			= "PROCESO EXITOSO";
	LET cNivelAutorizacion 		= "";
	LET cNombre 				= "";
	LET cPuesto 				= "";
	--Datos del cliente
	LET cNumcte 				= "";
	LET cNumCteCop 				= "";
	LET cNombreCte 				= "";
	LET cNombre1 				= "";
	LET cNombre2 				= "";
	LET cApellido1 				= "";
	LET cApellido2 				= "";
	LET cRFC 					= "";
	LET dtFechaNac 				= DATE(1);
	LET cEstadoCivil 			= "";
	LET cTelDomicilio 			= "";
	LET cTelMovil 				= "";
	LET cTelTrabajo 			= "";
	--Domicilio completo
	LET cCalle 					= "";
	LET iNumCalle 				= 0;
	LET cColonia 				= "";
	LET iNumColonia 			= 0;
	LET cDeloMunicipio 			= "";
	LET cEstado 				= "";
	LET cNumCiudad 				= "";
	LET cNomEstado 				= "";
	LET cCP 					= "";
	LET cNombreSuc 				= "";
	LET cNumeroCuenta 			= "";
	LET cSucursal 				= "";
	LET cincremento 			=  "";
	LET cCreditoFuncionario 	= "";
	LET cObligadoSolidario 		= "";
	LET cNombrePromotor 		= "";
	LET dLinActual  			= 0.00;
	LET dNuevaLin				= 0.00;
	LET dMontoIncre 			= 0.00;
	LET iAumento 				= 0;
	--Datos obligado solidario
	LET cNomObligado 			= "";
	LET dFechaNacObligado 		= "";
	LET cRFCObligado 			= "";
	LET cTelCasa     			= "";
	LET cRelacionCte 			= "";
	--Comentarios y documentación de apoyo
	LET sMesesHist 			 	= 0;
	LET cBuroCredito 			= NULL;
	LET cCirculoCredito 		= NULL;
	LET cCoppel 				= NULL;
	LET cTipoComprobante 		= "NO PRESENTA";
	LET cComentarios 			= "";
	LET iNivel 					= 0;
	LET cRango_autoriz 			= "";
	LET cNomNivel1 				= "";
	LET cNomNivel2 				= "";
	LET cNomNivel3 				= "";
	LET cNomNivel4 				= "";
	LET cPromotor 				= "";
	LET iBanderaColor 			= 0;
	LET cFechaMax               = DATE(1);
	LET cObserv				    = '';
	LET cObserv_1			    = '';
	LET cObserv_2			    = '';
	LET cObserv_3			    = '';
	LET cObserv_4			    = '';
	LET dIDP					= 0.0;
	LET dValorSM				= 0.0;
	LET dSalarioMin             = 0.0;
    LET dTopeSalMin             = 0.0;
	LET dIngresoMaximo          = 0.0;
    LET dIngresoMensDec         = 0.0;
	LET iNumPagos				= 0;
	LET dtFechaNumPagos			= DATE(1);
	LET dtFecha_status			= DATE(1);
	LET iPorcIngreso			= 0;
	LET dPagosRealizados		= 0.0;
	LET dCTP                    = 0.0;
	LET dFCP					= 0.0;
    LET dImporte_hip            = 0;
	LET dCompromPagoSIC			= 0.0;
	LET dCTC                    = 0.0;
	LET dCMA					= 0.0;
	LET dtFechaINC				= DATE(1);

	--SET debug FILE TO "/tmp/sp_cac_obteninforepnivelautorizacion.out";
	--trace ON;

    BEGIN
		--MANEJO DE ERRRORES
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet="Error de Informix";
				RETURN cCodRet,cMensajeRet, '', '', '', '', '', '', '', '', 0,
				'', '', '','','','', '', '', '',
				'', '',0, 0,0,0,'', '', '',
				'', '', 0, 0,	'', '','', '','',
				'', '', '', '', '', '', '', '', '', '';
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE CASTEA PARAMETRO DE FECHA DE INCREMENTO PARA OPTIMIZAR COSTOS EN LOS QUERYS DONDE ES UTILIZADO EL PARAMETRO.		
		LET dtFechaINC = pFechaINC::DATE;
		
		--SE VALIDAN PARAMETROS DE ENTRADA QUE NO VENGAN VACÍOS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCredito,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pCompIngreso,'') = '' THEN
			--No se ingresaron correctamento los parametros
			LET cCodRet= '000001';
			LET cMensajeRet='No se ingesaron correctamente los parametros';

		ELIF NOT EXISTS( SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred
						WHERE num_solicitud = pNumCredito AND status='AP' AND fecha_insert = dtFechaINC) THEN

                --El crédito aun no ha sido autorizado
                LET cCodRet= '000002';
                LET cMensajeRet='El crédito aun no ha sido autorizado';
            
		ELIF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
			LET cCodRet= '000003';
			LET cMensajeRet='La empresa ingresa no existe';
		ELSE
			--OBTENCION DE INFORMACION DEL CREDITO,			--OBTENCION DE LOS ANTECEDENTES DE CREDITO Y LOS MESES DE HISTORIA.
			SELECT bau.num_solicitud,bau.sucursal,bau.lincred_actual,bau.lincred_sugerida,
			NVL(antecedentes_buro, ""), NVL(antecedentes_circulo, ""),antiguedad,numcte,user_insert, ingreso_idp,fecha_status															
			INTO cNumeroCuenta,cSucursal,dLinActual, dNuevaLin,cBuroCredito, cCirculoCredito, 
			sMesesHist,cNumcte,cPromotor, dIDP,dtFecha_status
			FROM bdicred:"informix".sd_bitacora_aumlincred bau
			WHERE bau.num_solicitud = pNumCredito
			AND bau.fecha_insert = dtFechaINC;

			--OBTENCION DE DATOS GENERALES
			SELECT cli.nombre1, cli.nombre2, cli.apell_paterno, cli.apell_materno, cli.rfc, cte.fecha_nac, cte.estado_civil,numcte_ref
			INTO cNombre1, cNombre2, cApellido1, cApellido2, cRFC, dtFechaNac, cEstadoCivil,cNumCteCop
			FROM bdinteg:"informix".si_cliente cli,
				 bdinteg:"informix".si_ctepf cte
			WHERE cli.numcte = cte.numcte
			AND cli.numcte = cNumcte;

			LET cNombreCte = TRIM(cNombre1) ||" "|| TRIM(cNombre2) ||" "|| TRIM(cApellido1) ||" "|| TRIM(cApellido2);

			--OBTIENE EL ESTADO CIVIL
			IF cEstadoCivil =  "C" THEN
				LET cEstadoCivil =  "CASADO(a)";
			ELIF cEstadoCivil =  "S" THEN
				LET cEstadoCivil =  "SOLTERO(a)";
			ELIF cEstadoCivil =  "D" THEN
				LET cEstadoCivil =  "DIVORCIADO(a)";
			ELIF cEstadoCivil =  "V" THEN
				LET cEstadoCivil =  "VIUDO(a)";
			ELIF cEstadoCivil =  "U" THEN
				LET cEstadoCivil =  "UNION LIBRE";
			END IF;

			-- OBTENCION DEL DOMICILIO DEL CLIENTE			
			SELECT {+INDEX (bdinteg:si_direcciones_actual idx_diract_ctetpo)}
                   dir.estado, dir.ciudad, tel1.telefono, tel2.telefono, tel3.telefono, dir.numerocalle, dir.numerocolonia, dir.cod_postal
			INTO cEstado, cNumCiudad, cTelDomicilio, cTelMovil, cTelTrabajo, iNumCalle, iNumColonia, cCP
			FROM bdinteg:"informix".si_direcciones_actual dir
            LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
			LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
            LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
            WHERE dir.numcte = cNumcte
			AND dir.tipo_dir = 1;
			--- AND secuencia IN(SELECT MAX(secuencia) FROM BDINTEG:"informix".si_direcciones_actual WHERE numcte = cNumcte AND tipo_dir=1);

			--OBTENCION DEL ESTADO
			SELECT nombre
			INTO cNomEstado
			FROM bdinteg:"informix".si_estados
			WHERE estado = cEstado;

			--OBTENCION DE COLONIA Y MUNICIPIO
			SELECT nombrezona, municipiozona
			INTO cColonia, cDeloMunicipio
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = cNumCiudad
			AND numerocolonia = iNumColonia;

			--OBTENCION DE LA CALLE EN BASE A SU NUMERO
			SELECT nombrecalle
			INTO cCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE numerocalle = iNumCalle;

			--LET cNumero =  iNumCalle;

			---OBTENCION DEL NUMERO

			LET dMontoIncre = dNuevaLin-dLinActual;
			LET iAumento = (dMontoIncre / dLinActual) * 100;

			SELECT rango_autorizacion
				INTO cNivelAutorizacion
			FROM  bdicred:"informix".sd_autorizaciones_cac_aumlincred
			WHERE dMontoIncre BETWEEN monto_minimo AND monto_maximo;

			--OBTENCION DE NOMBRE DE SUCURSAL
			SELECT nombre
			INTO cNombreSuc
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal=cSucursal;

			--OBTIENE L NOMBRE DEL PROMOTOR
			SELECT nombre
			INTO cNombrePromotor
			FROM bdinteg:"informix".si_ejecut
			WHERE empresa = pEmpresa
			AND ejecutivo = cPromotor;
            				
		--OBTENCION DE INGRESOS DEL CREDITO FUNCIONARIO.		
		   SELECT ingreso_mensual
		   INTO dIngresoMensDec
		   FROM  bdisolic:"informix".ss_resum_scor_fin
		   WHERE num_solicitud = pNumCredito;						
			
			-- OBTIENE LOS DATOS DE LA SOLICTUD DE AUMENTO DE LINEA DE CREDITO							
			-- OBTIENE EL VALOR DEL SALARIO MINIMO INCREMENTO DE LINEA
			SELECT TRIM(valor)::DECIMAL(18,2)
			INTO dValorSM
			FROM "informix".sd_param
			WHERE empresa = '001'
				AND cod_param = '013';
			
			LET dSalarioMin = ROUND ((dValorSM * 30.42),-2);
			-- TOPA EL INGRESO MENSUAL AL VALOR DEL SALARIO MINIMON DE INCREMENTO DE LINEA CUANDO ESTE ES MENOR A 1 SM
			IF dIngresoMensDec < dSalarioMin THEN
				LET dIngresoMensDec = dSalarioMin;
			END IF
			-- VALIDA QUE TIENE COMPROBANTE DE INGRESOS
			IF pCompIngreso = '1' THEN
				IF dIDP > dIngresoMensDec THEN	
					LET dIngresoMensDec = dIDP;									
				END IF
			-- VALIDA QUE NO TIENE COMPROBANTE DE INGRESOS
			ELSE															
				SELECT TRIM(valor)::DECIMAL(18,2) --se homologa al tope de ingresos demostrado productivo
				INTO dTopeSalMin
				FROM bdisolic:"informix".ss_param 
				WHERE secuencia = '353'
					AND empresa = pEmpresa;					
				LET dIngresoMaximo= ROUND(dSalarioMin * dTopeSalMin,-2);				
				IF dIngresoMensDec > dIngresoMaximo THEN	
					LET dIngresoMensDec = dIngresoMaximo;									
				END IF	
				
				IF dIDP > dIngresoMensDec THEN	
					LET dIngresoMensDec = dIDP;
				ELSE
					LET dIngresoMensDec = dIngresoMensDec;
				END IF
			END IF					
			
           -- VALIDA SITUACION PAGO COPPEL
			IF cNumCteCop <> ""  THEN
				LET cCoppel =  "0";   ----Situación Buena
			ELSE
				LET cCoppel =  "X";   ----Situación Nula
			END IF;

			--VALIDA QUE TIPO DE PROCESO  ES, SI ES  INCREMENTO, CREDITO FUNCIONARIO O OBLIGADO SOLIDARIO
			LET cIncremento = "1";
			LET cCreditoFuncionario = "0";
			LET cObligadoSolidario = "0";

			--PARA OBTENER EL COMPROBANTE DE INGRESOS JMAH Se corrige consulta por error 284 en documentos digitalizados
            --JMAH 28-04-2014 Se modifica instancia de imagenes de coppelimg_crx a coppelimg_app
			SELECT LIMIT 1 a.prod_nombre
			INTO  cTipoComprobante
			FROM bdidigital@coppelimg_crx:"informix".dg_expediente a
				INNER JOIN bdidigital@coppelimg_crx:"informix".dg_tipodocumento b
				ON a.cod_docto = b.cod_docto
				AND b.cod_grupo = "006"
			WHERE a.cliente = cNumcte
			AND a.fecha_alta = (SELECT MAX(c.fecha_alta) FROM bdidigital@coppelimg_crx:"informix".dg_expediente c
								INNER JOIN bdidigital@coppelimg_crx:"informix".dg_tipodocumento b
									ON a.cod_docto = b.cod_docto
								   AND b.cod_grupo = "006"
								WHERE c.cliente =  a.cliente);
			--PARA OBTENER EL NOMBRE  DE LOS RESPONSABELES DE CADA NIVEL D AUTORIZACION
			FOREACH
			
				SELECT c.nombre, a.puesto, b.nivel, b.rango_autorizacion,a.justificacion					
				INTO cNombre, cPuesto, iNivel, cRango_autoriz, cObserv
				FROM bdicred:"informix".sd_historica_cac_aumlincred a
					INNER JOIN bdicred:"informix".sd_perfiles_cac_aumlincred b
						ON b.ejecutivo = a.ejecutivo
						AND b.rango_autorizacion = a.rango_autorizacion
						AND b.puesto = a.puesto
					INNER JOIN bdinteg:"informix".si_ejecut c
						ON c.ejecutivo = a.ejecutivo
				WHERE a.rango_autorizacion = b.rango_autorizacion
				AND a.solicitud = pNumCredito
				AND a.fecha_insert =dtFechaINC 
				ORDER BY b.nivel

				IF iNivel = 1 THEN
					LET cNomNivel1 = cNombre;
					LET cObserv_1 = "01-"||TRIM(cObserv);	
				ELIF iNivel = 2 THEN
					LET cNomNivel2 = cNombre;
					LET cObserv_2 = "02-"||TRIM(cObserv);	
				ELIF iNivel = 3 THEN
					LET cNomNivel3 = cNombre;
					LET cObserv_3 = "03-"||TRIM(cObserv);	
					IF cRango_autoriz = "02" THEN
						LET iBanderaColor  = 0;  --- Color Naranja
					ELSE
						LET iBanderaColor  = 1;  --- Color Azúl
					END IF;

				ELIF iNivel = 4 THEN
					LET cNomNivel4 = cNombre;
					LET cObserv_4 = "04-"||TRIM(cObserv);	
				END IF;

			END FOREACH;

		END IF;

		RETURN cCodRet, cMensajeRet, cNombreCte, cRFC, dtFechaNac, cEstadoCivil, cTelDomicilio, cTelMovil, cTelTrabajo, cCalle, iNumCalle,cColonia,
		cDeloMunicipio,	cNomEstado,cCP,cNombreSuc,	cNumeroCuenta, cSucursal, cIncremento, cCreditoFuncionario, cObligadoSolidario,
		cNombrePromotor, dLinActual, dNuevaLin, dMontoIncre,iAumento,cNomObligado, dFechaNacObligado, cRFCObligado, cTelCasa, cRelacionCte,
		sMesesHist, dIngresoMensDec, cBuroCredito, cCirculoCredito, cCoppel,cTipoComprobante,cNivelAutorizacion,
		cNomNivel1, cNomNivel2, cNomNivel3, cNomNivel4, cRango_autoriz, dtFecha_status, cObserv_1, cObserv_2, cObserv_3, cObserv_4;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE DATOS GENERALES DEL CLIENTE, ESTADO  Y ANTECEDENTES DEL CRÉDITO E INFORMACION DEL INCREMENTO',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111217.1735',
'MODIFICACIÓN: Se modifíca para agregar el "informix" al CREATE y se obtienen los meses de historia de la tabla "sd_bitacora_aumlincred" en lugar de',
'              la tabla "ss_resum_scor_fin" y Se contemplan reglas de informix.',
'MODIFICÓ: Guadalupe Payan',
'FECHA: 26 SEPTIEMBRE 2012',
'VERSION: 20120926.2216',
'MODIFICACIÓN: Se modifíca para cambiar el tamaño de la variable cTipoComprobante a de char(20) a char(40) ya que en la tabla donde se obtiene el valor lo tiene del tamaño mayor',
'			   y obtener el valor de la variable cComentarios con status = "AT" y ya no por el filtro de ejecutivo para con esto obtener la ultima observacion no importando el ejecutivo',
' 			   que este logiado.',
'MODIFICÓ: Guadalupe Payan',
'FECHA: 11 OCTUBRE 2012',
'VERSION: 20121011.1057',
'MODIFICACIÓN: Se crea la variable "dtFechaINC" para realizar el casteo a DATE del parametro "pFechaINC" para optimizar costos,',
'			   Para las variables Observ_1, Observ_2,Observ_3, Observ_4 se le actualizara el tamaño a char(203) debido que no se contemplo el numerado de las observaciones por cada ejecutivo',
'			   equivalente a 2 caracteres mas un caracter mas para el guion (-).',
'MODIFICÓ: Guadalupe Payan',
'FECHA: 11 OCTUBRE 2012',
'VERSION: 20121011.1057',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_respalda_sd_movhis()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cMensaje 		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE vrowid           INTEGER;
DEFINE VlNumCredito     CHAR(20);
DEFINE iCont			INTEGER;
DEFINE cValor			CHAR(1);
DEFINE dFecha			DATE;	
DEFINE cSql 			CHAR(1000);

	--SET DEBUG FILE TO "/RESPALDOSNEW/sp_respalda_sd_movhis_trace.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';
	LET cSql 		= '';

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		truncate table "informix".temp_creditos_depurar6;
		update "informix".sd_param set valor = '0'
		where empresa = '001' and cod_param = 'DT6';
		LET cSql = '';
		LET cSql = 'echo "" >> /RESPALDOSNEW/instruccion1.sql';
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select trim(valor) into cValor 
	from "informix".sd_param 
	where empresa = '001' and cod_param = 'DT6';

	select date((pri_dia_mes - 1 units year) - 1 units day) into dFecha 
	from "informix".sd_fechas
	where empresa = '001';

	select count(*) into iCont 
	from "informix".temp_creditos_depurar6;

	if iCont = 0 and cValor = '0' then

		insert into "informix".temp_creditos_depurar6
		select num_credito 
		from bdicred:"informix".sd_maecred
		where empresa = '001';

		update "informix".sd_param set valor = '1'
		where empresa = '001' and cod_param = 'DT6';

	else

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

	--DESCARGA EL respaldo
	LET cSql = '';
	LET cSql = 'echo "unload to /RESPALDOSNEW/respaldo_sd_movhis.unl' || ' select * FROM bdicred:"informix".sd_movhis WHERE empresa = "001" and num_credito in (select num_credito from "informix".temp_creditos_depurar6 ) and fecha_mov <= MDY(' ||MONTH(dFecha)|| ',' ||DAY(dFecha)|| ',' ||YEAR(dFecha)|| ')" >> /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'dbaccess bdicred /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/instruccion1.sql';
	SYSTEM cSql;
	-- CARGA EN LA TABLA ESPEJO
	LET cSql = '';
	LET cSql = 'dbload -d bdicred -c /ifxsif01/scripts/pro_206_34_4_respaldo_movhis.sql -l adviser.log -n 1000 -k';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = 'chmod 777 /RESPALDOSNEW/respaldo_sd_movhis.unl';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql ='rm /RESPALDOSNEW/respaldo_sd_movhis.unl';
	SYSTEM cSql;

	RETURN cCod_ret;

	END;

END PROCEDURE;