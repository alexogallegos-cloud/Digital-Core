CREATE PROCEDURE "informix".sp_parametrospagos (pEmpresa CHAR(3),pNumEmpleado CHAR(9))
	RETURNING CHAR(5),CHAR(2),CHAR(2),CHAR(100),CHAR(45),CHAR(30),DATE,CHAR(2);

	--Declaracion de variables
	DEFINE iSqlErr              INTEGER;
	DEFINE cCodRet              CHAR(5);
	DEFINE cLongitudCliente     CHAR(2);
	DEFINE cCodMonNac           CHAR(2);
	DEFINE cPathRep             CHAR(100);
	DEFINE cNombreUsuario       CHAR(45);
	DEFINE cNombreEmpresa       CHAR(30);
	DEFINE dFecha_Hoy           DATE;
	DEFINE cSistema             CHAR(2);

	--Crea el archivo de monitoreo del proceso
	--SET DEBUG FILE TO "/tmp/sp_ParametrosCheques.out";
	--TRACE ON;

	--inicializacion de  variables
	LET cCodRet= '00000';
	LET cLongitudCliente= '';
	LET cCodMonNac= '';
	LET cPathRep= '';
	LET cNombreUsuario= '';
	LET cNombreEmpresa = '';
	LET dFecha_Hoy = '';
	LET cSistema = '';

	BEGIN
	--Crea el control de errores
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;
			END IF;
		END EXCEPTION;

		--Obtengo el valor longitud del numero de cliente
		SELECT Trim(valor)
		INTO cLongitudCliente
		FROM bdinteg:si_param
		WHERE empresa = pEmpresa AND descripcion = ('longitud cliente');

		--Obtengo el valor codigo de la moneda nacional
		SELECT Trim(valor)
		INTO cCodMonNac
		FROM bdinteg:si_param
		WHERE empresa = pEmpresa AND descripcion = ('codigo mn');

		 --Obtengo el valor path de reportes
		SELECT Trim(desc_valor)
		INTO cPathRep
		FROM bdiprog:pp_parametros
		WHERE cve_param = ('104');

		--Obtengo el nombre del usuario o ejecutivo
		SELECT nombre
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = pNumEmpleado;

		-- Obtengo el nombre de la empresa
		SELECT razon_social
		INTO cNombreEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;

		-- Obtengo Fecha de integral para la Captura de Parametros
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdicheq:sc_fechas;

		--Obtengo codigo del sistema
		SELECT sistema
		INTO cSistema
		FROM bdinteg:si_sistema
		WHERE siglas = 'PP';

		RETURN cCodRet,cLongitudCliente,cCodMonNac,cPathRep,cNombreUsuario,cNombreEmpresa,dFecha_Hoy,cSistema;

	END
	END PROCEDURE
	DOCUMENT
	'DESCRIPCION: Genera una consulta en las tablas si_param, si_ejecut,si_empresas,sc_fechas,si_sistema,pp_parametros',
	'tomando como parametro o dato de entrada, la empresa y el numero de empleado para obtener datos del empleado',
	'Solicito : Armando Mercado F.',
	'AUTOR: Armando Mercado F. ',
	'FECHA: Mayo 2009',
	'VERSION: 20090529',
	'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_aforeconsultaarchivos(pNombre CHAR(30))

RETURNING CHAR(5),CHAR(1),CHAR(10),DATE,DATE, DATE,CHAR(9),CHAR(232),CHAR(2),CHAR(11),CHAR(40),
	CHAR(40),CHAR(40),CHAR(1),CHAR(18),DATE,CHAR(15),CHAR(15),CHAR(11),CHAR(8),CHAR(4),CHAR(3),CHAR(10),
	CHAR(18),CHAR(10),CHAR(16),CHAR(2), CHAR(17),CHAR(17),CHAR(17),CHAR(17),CHAR(17),DATE, CHAR(2),INTEGER, 
	MONEY(10,2),MONEY(12,2);

--DECLARACION DE VARIABLES----------------------
DEFINE vCodRet    					CHAR(5);
DEFINE vSqlErr    					INTEGER;
DEFINE cTipoRegistro				CHAR(1);
DEFINE cFinLinea					CHAR(2);
DEFINE dFecha_Hoy					DATE;
DEFINE cCURP                        CHAR(18);
--ENCABEZADO
DEFINE cNoContratoEmpresa 			CHAR(10);
DEFINE dFechaGen				 	DATE;
DEFINE dFechaInicialInformacion 	DATE;
DEFINE dFechaFinalInformacion 		DATE;
DEFINE cNoMovimientosContenidos 	CHAR(9);
DEFINE cFiller						CHAR(232);
--DETALLE
DEFINE cNSS 						CHAR(11);
DEFINE cNombreBeneficiario 			CHAR(40);
DEFINE cApellidoPaternoBeneficiario CHAR(40);
DEFINE cApellidoMaternoBeneficiario CHAR(40);
DEFINE cFormasPago 					CHAR(1);
DEFINE cCLABE 						CHAR(18);
DEFINE dFechaCaptura 				DATE;
DEFINE cImporteDocumentoNetoPagar 	CHAR(15);
DEFINE cImporteDocumentoAntesImpuesto CHAR(15);
DEFINE cImpuestoRetenido 			CHAR(11);
DEFINE cNumeroFolioServicio 		CHAR(8);
DEFINE cNumeroTienda 				CHAR(4);
DEFINE cTipoRetiro 					CHAR(3);
DEFINE cConsecutivoRetiro 			CHAR(10);
DEFINE cRFC 						CHAR(10);
DEFINE cStatus 						CHAR(2);
DEFINE cNombre 						CHAR(30);
DEFINE cFolio_suc 					CHAR(16);

--SUMARIO
DEFINE cNumeroTotalMovimientosContenidos	CHAR(9);
DEFINE cImporteTotalNeto					CHAR(17);
DEFINE cImporteTotalAntesImpuesto			CHAR(17);
DEFINE cImporteRetenido						CHAR(17);
DEFINE cImporteTotalRetirosPagadosEfectivo  CHAR(17);
DEFINE cImporteTotalRetirosPagadosDeposito	CHAR(17);

--Encabezado		
DEFINE dFechaMovimientos 	DATE; 
--detalle
DEFINE cNumeroMovimientos 	CHAR(4);
DEFINE cMonto 				MONEY(10,2);DEFINE v_Cuenta				CHAR(11);
--sumario
DEFINE iSumamon 			MONEY(12,2);DEFINE iSumamov 			INTEGER;

--INICIALIZACION DE VARIABLES-------------------------
LET cTipoRegistro 	= '';
LET cFinLinea		= '';
LET dFecha_Hoy 		= '';
LET cNombre 		= '';
--ENCABEZADO
LET vCodRet						= "0000";
LET cNoContratoEmpresa 			= '';
LET dFechaGen 					= '';
LET dFechaInicialInformacion 	= '';
LET dFechaFinalInformacion 		= '';
LET cNoMovimientosContenidos 	= '';
LET cFiller						= '';
--DETALLE
LET cNSS 						= '';
LET cNombreBeneficiario 		= '';
LET cApellidoPaternoBeneficiario = '';
LET cApellidoMaternoBeneficiario = '';
LET cFormasPago 				= '';
LET cCLABE 						= '';
LET dFechaCaptura 				= '';
LET cImporteDocumentoNetoPagar 	= '';
LET cImporteDocumentoAntesImpuesto = '';
LET cImpuestoRetenido 			= '';
LET cNumeroFolioServicio 		= '';
LET cNumeroTienda 				= '';
LET cTipoRetiro 				= '';
LET cConsecutivoRetiro 			= '';
LET cRFC 						= '';
LET cStatus 					= '';
LET cFolio_suc 					= '';

--SUMARIO
LET cNumeroTotalMovimientosContenidos	= '';
LET cImporteTotalNeto					= '';
LET cImporteTotalAntesImpuesto			= '';
LET cImporteRetenido					= '';
LET cImporteTotalRetirosPagadosEfectivo = '';
LET cImporteTotalRetirosPagadosDeposito	= '';				
--CONTROL 
LET dFechaMovimientos 	= ''; 
LET cNumeroMovimientos 	= '';
LET cMonto 				= '';
LET iSumamon 			= '0';
LET iSumamov			= '0';

--	SET DEBUG FILE TO "/tmp/sp_AforeConsultaArchivos.out";
--	TRACE ON;

    BEGIN
		--MANEJO DE ERRRORES
		ON EXCEPTION SET vSqlErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
				dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0;
			END IF;
		END EXCEPTION;

		--VALIDA QUE EL ARCHIVO EXISTA
		IF NOT EXISTS (SELECT nombre_arch FROM bdiprog:pp_arch_afore WHERE nombre_arch = pNombre ) THEN
			LET vCodRet='10000';
			RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
			dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '', '',
			'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0;
		END IF;
 
		IF pNombre LIKE 'PAGOS%' OR pNombre LIKE 'CONF%' THEN 

			IF pNombre LIKE 'CONF%' THEN 
				LET cNombre = 'PAGOS'||SUBSTR(pNombre,5,9)||'A'||SUBSTR(pNombre,15,30);
			ELSE
				LET cNombre = pNombre;
			END IF;

			--DATOS DEL ENCABEZADO
			SELECT 
				tipo_reg,contrato, fecha_gen, fecha_ini, fecha_fin, no_mov, filler, fin_linea
			INTO 
				cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion, dFechaFinalInformacion,
				cNoMovimientosContenidos, cFiller, cFinLinea
			FROM bdiprog:pp_Encabezado
			WHERE nombre_arch = cNombre; 

			RETURN vCodRet, cTipoRegistro, cNoContratoEmpresa, dFechaGen, dFechaInicialInformacion,
				dFechaFinalInformacion, cNoMovimientosContenidos, cFiller, cFinLinea, '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',	'', 0, 0, 0 WITH RESUME;

			LET cTipoRegistro 	= '';
			LET cFiller 		= '';
			LET cFinLinea		= '';

			FOREACH WITH HOLD
				--DATOS DEL DETALLE
				SELECT {+INDEX(bdiprog:pp_detalle idxdetalle19c)} SUBSTR(a.clabe, 7, 11), a.tipo_reg, a.nss, 
					a.forma_pago, a.clabe, a.fecha_captura, a.imp_netopagar, a.imp_antimpuesto, a.imp_retenido, a.num_folioservicio,
					a.num_tienda, a.tipo_retiro, a.consecutivo_ret, a.curp, a.rfc, a.status, a.filler, a.folio_suc, a.fin_linea,
					a.nom_benef ,a.apell_pat ,a.apell_mat
				INTO v_Cuenta, cTipoRegistro, cNSS, cFormasPago, cCLABE, dFechaCaptura, cImporteDocumentoNetoPagar,
					cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio, cNumeroTienda,
					cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cStatus, cFiller, cFolio_suc, cFinLinea,
					cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario-- se agregaron estor tres campos para obtener el nombre completo de la ppdetalle
				FROM bdiprog:pp_Detalle a
				WHERE a.nombre_arch = cNombre

				IF cNombre = pNombre THEN -- si se trata de archivos PAGOS:::
				
					RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea, cNSS, cNombreBeneficiario,
						cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura,
						cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
						cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, '', '', '', '', '', '', '', '01', 0, 0, 0 WITH RESUME;
				ELSE  -- si se trata de archivos CONF:::
				-- se obtiene el nombre del cliente en la bd
					SELECT NVL(TRIM(c.nombre1) ||' '|| TRIM(c.nombre2), ''), NVL(TRIM(c.apell_paterno), ''), NVL(TRIM(c.apell_materno), '')
					INTO cNombreBeneficiario, cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario
					FROM bdicheq:sc_maechq b
					INNER JOIN bdinteg:si_cliente c ON b.num_cte = c.numcte
					WHERE b.empresa = '001'
					AND b.cuenta = v_Cuenta;

					IF cNombreBeneficiario IS NULL THEN
						LET cNombreBeneficiario = "";
					END IF;
					IF cApellidoPaternoBeneficiario IS NULL THEN
						LET cApellidoPaternoBeneficiario = "";
					END IF;
					IF cApellidoMaternoBeneficiario IS NULL THEN
						LET cApellidoMaternoBeneficiario = "";
					END IF;

					RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea, cNSS, cNombreBeneficiario,
						cApellidoPaternoBeneficiario, cApellidoMaternoBeneficiario, cFormasPago, cCLABE, dFechaCaptura,
						cImporteDocumentoNetoPagar, cImporteDocumentoAntesImpuesto, cImpuestoRetenido, cNumeroFolioServicio,
						cNumeroTienda, cTipoRetiro, cConsecutivoRetiro, cCURP, cRFC, cFolio_suc, '', '', '', '', '', '', '', cstatus, 0, 0,0 WITH RESUME; 
				END IF;
			END FOREACH

						
			LET cFiller		= '';
			LET cFinLinea 	= '';

			--DATOS DEL SUMARIO
			SELECT 
				total_mov, tipo_reg, total_imp_neto, total_imp_antimp, total_imp_retenido, imp_tot_efectivo,
				imp_tot_deposito, filler, fin_linea
			INTO 
				cNumeroTotalMovimientosContenidos, cTipoRegistro, cImporteTotalNeto, cImporteTotalAntesImpuesto, 
				cImporteRetenido, cImporteTotalRetirosPagadosEfectivo, cImporteTotalRetirosPagadosDeposito, 
				cFiller, cFinLinea
			FROM bdiprog:pp_Sumario
			WHERE nombre_arch = cNombre;  

			RETURN vCodRet, cTipoRegistro, '', '', '', '', '', cFiller, cFinLinea , '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', cNumeroTotalMovimientosContenidos, cImporteTotalNeto, 
				cImporteTotalAntesImpuesto,	cImporteRetenido, cImporteTotalRetirosPagadosEfectivo,
				cImporteTotalRetirosPagadosDeposito, '', '', 0, 0, 0 WITH RESUME; 
		ELSE 
			--DATOS DEL ENCABEZADO
			LET cTipoRegistro = 'E';

			SELECT fecha_hoy INTO dFecha_Hoy FROM Bdinteg:si_fechas;

			LET dFechaGen = dFecha_Hoy;
			LET dFechaMovimientos = dFecha_Hoy;

			RETURN vCodRet, cTipoRegistro, '', dFechaGen, '', '', '', '', '', '', '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', '', dFechaMovimientos, '', 0, 0, 0 WITH RESUME;

			LET cNombre = 'PAGOS'||SUBSTR(pNombre,5,9)||'A'||SUBSTR(pNombre,15,30);

			FOREACH	WITH HOLD
				--SE OBTIENEN LOS DATOS DEL DETALLE
				SELECT DISTINCT(status), COUNT(status), SUM(imp_netopagar)
				INTO cStatus, cNumeroMovimientos, cMonto
				FROM bdiprog:pp_detalle
				WHERE nombre_arch  = cNombre
				GROUP BY status		

				LET cTipoRegistro = 'D';
				LET iSumamon = iSumamon + cMonto;
				LET iSumamov = iSumamov + 1; 

				--se obtiene el status con la descripcion
				select status || '-'|| descripcion into cStatus from bdiprog:pp_status_afore where status = trim(cStatus);				
				RETURN vCodRet, cTipoRegistro, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 
					'', '', '', '', '', '', '', '', '', '', '', '', '', dFechaMovimientos, cstatus, cNumeroMovimientos, 
					cMonto, 0 WITH RESUME;

			END FOREACH

			-- SE OBTIENEN LOS DATOS DEL SUMARIO
			LET cTipoRegistro = 'S';

			RETURN vCodRet,cTipoRegistro, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
				'', '', '', '', '', '', '', '', '', '', '', '', '', iSumamov, 0, iSumamon WITH RESUME;

		END IF;
	END	
END PROCEDURE
DOCUMENT
'Consulta los archivos de pagos, confirmacion y control Afore',
'AUTOR: Abigail Vasavilbazo Cañedo',
'FECHA: Mayo 2009',
'BD: BDIPROG',
'CAMBIOS: Este Sp se modificaron el tipo de la variable monto con el fin de que lña retornara con un formato Money',
'         tambien se modifico que cuanso se va a mostrar un archivo dePAGOS.. el nombre delo beneficioario lo obtenga ',
'         de la tabla pp_detalle, y cuandosea un archivo de confirmacion lo obtiene de la si_clientes, tambien se modifico',
'         que regresara el numeron real de movimientos para los archivos de cifras de control ya que regresaba el total ',
'         de de movimientos en el de confirmacion, ademas se modifico variable que mostraba el numero de movimientos ya que la ',
'         retornaba como CHAR(1) y lo mostraba incompleto el numero. tambien se modifico que en la variable estado agragara la',
'         descripcion del mismo.',
'MODIFICO: César Valdéz Figueroa',
'FECHA: 16/Junio/2009',
'VERSION: 20090616';

CREATE PROCEDURE "informix".sp_consultacuentasterceros(pNumCte CHAR(20), pTipoCta CHAR(2), pTipoNaturaleza CHAR(2) )
RETURNING CHAR(5) as retorno,CHAR(60) as mensaje,CHAR(3) as cve_banco,CHAR(20) as num_cta,CHAR(2) as tipo_cta,CHAR(20) as descripcion,CHAR(60) as nombre,CHAR(13) as rfc,CHAR(40) as correo,CHAR(2) as cve_company,CHAR(10) as Num_Celular;
       --codigo,mensaje,cve_banco,num_cta,tipo_cta,descripcion,nombre,   rfc  ,e-mail,cve_comany,No.Celular.

                                --*************************************************
                                --Creado por: Anselmo Verdugo                   --*
                                -- Actividad: Se obtiene cuentas asociadas al un cliente.
                                --  Solicitó: Aymme Osuna                       --*
                                --     Fecha: 27/OCT/2008         
								--* Modifico:Alejandro Osuna
								-- Fecha: Diciembre 2008
								-- Se valida dato por dato los parametros de entrada
                                --*************************************************

DEFINE vcCodRet CHAR(6);
DEFINE sql_err  INTEGER;
DEFINE vcMensaje CHAR(60);
DEFINE vcCveBanco CHAR(3);
DEFINE vcNumCta CHAR(20);
DEFINE vcTipoCta    CHAR(2);
DEFINE vcDescripcion CHAR(20);
DEFINE vcNombre     CHAR(60);
DEFINE vcRfc        CHAR(13);
DEFINE vcEmail      CHAR(40);
DEFINE vcCveCompania CHAR(2);
DEFINE vcNumCelular CHAR(10);
DEFINE vcTodas  CHAR(1);
DEFINE vcTodaNatural  CHAR(1);
DEFINE vcHayCuentas  CHAR(1);




        --MANEJADOR DE EXEPCIONES
        ON EXCEPTION SET sql_err
            LET vcCodRet = sql_err;

            RETURN vcCodRet,'','','','','','','','','','';
        END EXCEPTION;


    --SET DEBUG FILE TO "/home/informix/sp_consultaCuentasPropiasTerceros.out";
	--TRACE ON;


LET vcCodRet = '00000';
LET sql_err  = 0;
LET vcMensaje = '';
LET vcCveBanco = '';
LET vcNumCta = '';
LET vcTipoCta    = '';
LET vcDescripcion = '';
LET vcNombre     = '';
LET vcRfc        = '';
LET vcEmail      = '';
LET vcCveCompania = '';
LET vcNumCelular = '';
LET vcTodas      = 'N';
LET vcTodaNatural = 'N';
LET vcHayCuentas = 'N';


    -- Se validan las variables que se reciben como los parametros.
   -- IF NVL(pNumCte,'') <> '' and NVL(pTipoCta,'') <> '' and NVL(pTipoNaturaleza,'') <> '' THEN

    IF NVL(pNumCte,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '104';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';
	END IF;

	IF NVL(pTipoCta,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '11';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';
	END IF;


	IF NVL(pTipoNaturaleza,'') = '' THEN
		SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '12';
		RETURN vcCodRet,vcMensaje,'','','','','','','','','';

	END IF;

        -- Se valida la existencia del cliente.
        IF EXISTS ( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte )  THEN

            -- Se valida la existencia del tipo de cuenta asociada.
            IF EXISTS ( SELECT descripcion FROM bdiprog:pp_tpcuentasasoc WHERE tipo_asoc = pTipoCta ) THEN

				IF  pTipoNaturaleza = '01' or pTipoNaturaleza = '03' or pTipoNaturaleza = '04' THEN


                        -- Se recupera todos los tipos de cuentas ( PROPIAS Y TERCEROS).
                        IF pTipoCta = '04' THEN
                            LET vcTodas  = 'S';
                        END IF;

                        -- Se recupera las cuentas PROPIAS o TODAS.
                        IF pTipoCta = '01' or vcTodas = 'S' THEN

                            -- Cuentas de todas naturaleza.
                            IF pTipoNaturaleza = '03' THEN
                                LET vcTodaNatural = 'S';
                            END IF;

                            -- Cuentas de CAPTACION.
                            IF pTipoNaturaleza = '01' or vcTodaNatural = 'S' THEN
                                FOREACH
                                    SELECT distinct cuenta INTO vcNumCta FROM bdicheq:sc_maechq maechq
                                    inner join bdiprog:pp_producperm producperm ON producperm.producto = maechq.producto
--                                    WHERE maechq.num_cte = pNumCte and maechq.status_cta = '1' and producperm.permite_prog = 'S'
									WHERE maechq.num_cte = pNumCte and maechq.status_cta <> '2' and producperm.permite_prog = 'S'

                                    LET vcHayCuentas = 'S';

                                    SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    LET vcTipoCta = '01';

                                    SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                   RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,'',vcNombre,vcRfc,'','','' WITH RESUME;
                                    --codigo,mensaje,cve_banco,num_cta,tipo_cta,descripcion,nombre,   rfc  ,e-mail,cve_comany,No.Celular.
                                END FOREACH;
                            END IF;
                            -- Cuentas de CREDITO.
                            IF pTipoNaturaleza = '04' or vcTodaNatural = 'S' THEN
                                FOREACH
                                    SELECT distinct tarjeta.num_tarjeta INTO vcNumCta FROM bdicred:sd_maecred maecred
                                    inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
									INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
                                    WHERE maecred.numcte = pNumCte and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
									AND tarjeta.status_tar = 'A'
									
									--SELECT num_tarjeta INTO vcNumCta FROM  bdicred:sd_tarjeta WHERE  num_credito = vcNumCta ;

                                    LET vcHayCuentas = 'S';

                                    SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    LET vcTipoCta = '04';

                                    SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                    RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,'',vcNombre,vcRfc,'','','' WITH RESUME;

                                END FOREACH;
                            END IF;

                        END IF;


                        -- Se recupera las cuentas de TERCEROS
                        IF (pTipoCta = '02') or vcTodas = 'S' THEN

                            -- -- Se recupera las cuentas de TODAS LAS CUENTAS DE TERCEROS CON CUENTA DIFERENCTE '05'.
                            IF pTipoNaturaleza = '03' THEN
                                --LET vcTodaNatural = 'S';
								FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta <> '05'

									IF vcCveBanco = '137' THEN
										IF (vcTipoCta = '01')  THEN
--										IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta = '1' ) THEN
										IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta <> '2' ) THEN
												LET vcHayCuentas = 'S';
												RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
											ELSE
												continue FOREACH;
											END IF;
										END IF;
										IF (vcTipoCta = '04') THEN
											IF EXISTS( SELECT distinct tarjeta.num_tarjeta FROM bdicred:sd_maecred maecred
													inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
													INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
													WHERE tarjeta.num_tarjeta = vcNumCta and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
													AND tarjeta.status_tar = 'A') THEN
												LET vcHayCuentas = 'S';
												RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
											ELSE
												continue FOREACH;
											END IF;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;
								
								END FOREACH;
                            END IF;

                            -- Cuentas de CAPTACION para TERCEROS.
                            IF pTipoNaturaleza = '01' THEN
                                FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado  = '01'  and cve_cuenta in('01','02','03')
									
									IF (vcCveBanco = '137')  and (vcTipoCta = '01') THEN 
--									IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta = '1' ) THEN
									IF EXISTS(SELECT empresa FROM bdicheq:sc_maechq WHERE cuenta = vcNumCta AND status_cta <> '2' ) THEN
											LET vcHayCuentas = 'S';
											RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
										ELSE
											continue FOREACH;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;									
                                END FOREACH;
                            END IF;

                            -- Cuentas de CREDITO para Terceros.
                            IF pTipoNaturaleza = '04' THEN
                                FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco  FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta = '04'
									
									IF vcCveBanco = '137' THEN
										IF EXISTS( SELECT distinct tarjeta.num_tarjeta FROM bdicred:sd_maecred maecred
													inner join bdiprog:pp_producperm producperm ON producperm.producto = maecred.num_producto
													INNER JOIN bdicred:sd_tarjeta tarjeta ON maecred.num_credito = tarjeta.num_credito
													WHERE tarjeta.num_tarjeta = vcNumCta and maecred.status_cred <> 'CV' and producperm.permite_prog = 'S'
													AND tarjeta.status_tar = 'A') THEN
											LET vcHayCuentas = 'S';
											RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
										ELSE
											continue FOREACH;
										END IF;
									ELSE
										LET vcHayCuentas = 'S';
										RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;
									END IF;
                                END FOREACH;

                            END IF;


                        END IF;

						-- SE VAN A RECUPERAR LAS CUENTAS DE SERVICIOS.
						IF ( pTipoCta = '03') or vcTodas = 'S' THEN

							IF pTipoNaturaleza = '03' THEN
							    FOREACH
									SELECT distinct cuenta,descrip_cta, direc_correo,cve_compania,no_celular, nombre, rfc, cve_cuenta, cve_banco  INTO vcNumCta, vcDescripcion, vcEmail, vcCveCompania, vcNumCelular, vcNombre, vcRfc, vcTipoCta, vcCveBanco   FROM bdiprog:pp_ctasterceros
									WHERE num_cte = pNumCte and  cve_estado = '01' and cve_cuenta = '05'

                                    LET vcHayCuentas = 'S';

                                    --SELECT valor INTO vcCveBanco FROM bdiprog:pp_parametros WHERE cve_param = '01';
                                    --LET vcTipoCta = pTipoNaturaleza;

                                    --SELECT (trim(nombre1) || ' ' || trim(nombre2) || ' ' || trim(apell_paterno) || ' ' || trim(apell_materno)), rfc  INTO vcNombre, vcRfc FROM bdinteg:si_cliente WHERE numcte = pNumCte;

                                    RETURN vcCodRet,vcMensaje,vcCveBanco,vcNumCta,vcTipoCta,vcDescripcion,vcNombre,vcRfc,vcEmail,vcCveCompania,vcNumCelular WITH RESUME;

                                END FOREACH;

							END IF;

						END IF;
                        IF  vcHayCuentas = 'N' THEN
                            -- Se regresa informacion sobre que no hubo cuenta para el cliente.
                            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '13';
                            RETURN vcCodRet,vcMensaje,'','','','','','','','','';
                        END IF;

				ELSE
					-- Se regresa que el numero de cliente no existe.
		            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '12';
		            RETURN vcCodRet,vcMensaje,'','','','','','','','','';
				END IF;

            ELSE
                -- Se regresa la NO existencia del tipo de cuenta asociada.
                SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '11';
                RETURN vcCodRet,vcMensaje,'','','','','','','','','';

            END IF;

        ELSE
            -- Se regresa que el numero de cliente no existe.
            SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '04';
            RETURN vcCodRet,vcMensaje,'','','','','','','','','';

        END IF;
   /* ELSE
        --REGREGAR PARAMETROS RECIBIDOS NO DEBER ESTAR EN NULO O ESPACIO EN BLANCO.
        SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '01';
        RETURN vcCodRet,vcMensaje,'','','','','','','','','';
    END IF;*/

        --SELECT cod_ret, desc_mensaje INTO vcCodRet,vcMensaje FROM bdiprog:pp_mensajes WHERE cve_mensaje = '13';
        --RETURN vcCodRet,vcMensaje,'','','','','','','','','';


END PROCEDURE;