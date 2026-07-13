CREATE PROCEDURE "informix".sp_envioaltactecoppel(p_empresa CHAR(3), p_NumCte VARCHAR(20), p_NumSolicitud CHAR(20))
RETURNING
    CHAR(5),
    CHAR(1050); --- Trama conformada

    --- DECLARACIONES
    DEFINE v_cod_ret                        CHAR(5);
    DEFINE iSqlErr                          INTEGER;
    DEFINE iSamErr                          INTEGER;
    DEFINE vDesErr                          CHAR(60);
    ---Campos SS_OsClientesSupervisar...
    DEFINE lValorSeguridad                  INTEGER;
    DEFINE cClave                           CHAR(1);
    DEFINE iTienda                          INTEGER;
    DEFINE v_NumcteRef                      VARCHAR(20);
    DEFINE v_Nombre                         VARCHAR(15);
    DEFINE v_ApellPat                       VARCHAR(15);
    DEFINE v_ApellMat                       VARCHAR(15);
    DEFINE vnumerociudad                    INTEGER;
    DEFINE vnumerocolonia                   INTEGER;
    DEFINE vnumerocalle                     INTEGER;
    DEFINE vcasa                            CHAR(10);
    DEFINE vletrasnumcasa                   VARCHAR (10);
    DEFINE v_Rumbo                          CHAR(1);
    DEFINE v_Observaciones                  VARCHAR(30);
    DEFINE v_flaguhc                        CHAR(1);
    DEFINE v_manzana                        INTEGER;
    DEFINE v_otros                          INTEGER;
    DEFINE v_andador                        INTEGER;
    DEFINE v_etapa                          INTEGER;
    DEFINE v_lote                           INTEGER;
    DEFINE v_edificio                       INTEGER;
    DEFINE v_entrada                        INTEGER;
    DEFINE vtelefono1                       CHAR(11);
    DEFINE vtelefono2                       CHAR(13);
    --Se dejo  porke se usa en euna  consulta
    DEFINE v_Habita_en                      CHAR(2);
    -------------------------------------------------------
    DEFINE v_Sexo                           CHAR(1);
    DEFINE v_EdoCivil                       CHAR(1);
    DEFINE v_DiaNac                         CHAR(2);
    DEFINE v_MesNac                         CHAR(2);
    DEFINE v_AnioNac                        CHAR(4);
    DEFINE v_ingreso_mensual                INTEGER;
    DEFINE vsituacionespecial               CHAR(1);
    DEFINE vcausasituacionespecial          SMALLINT;
    DEFINE v_LugarTrabajo                   CHAR(60);
    DEFINE vnumerociudadTrabajo             INTEGER;
    DEFINE vnumerocoloniaTrabajo            INTEGER;
    DEFINE vnumerocalleTrabajo              INTEGER;
    DEFINE vcasatrabajo                     CHAR(10);
    DEFINE vletrasnumcasatrabajo            VARCHAR(10) ;
    DEFINE vtelefono1Trabajo                CHAR(11);
    DEFINE vextension                       INTEGER;
    DEFINE vnombreref                       CHAR(15);
    DEFINE vapellpatred                     CHAR(15);
    DEFINE vapellmatref                     CHAR(15);
    DEFINE lCasaReferencia                  INTEGER;
    DEFINE vtelref                          CHAR(11);
    DEFINE lEmpleadoEfectuo                 CHAR(8);
    DEFINE iDiaAltaCliente                  INTEGER;
    DEFINE iMesAltaCliente                  INTEGER;
    DEFINE iYearAltaCliente                 INTEGER;
    DEFINE cEmpresa                         CHAR(3);
    --DEFINE vlimitecredito                   DECIMAL(18,2);
    ---Campos CrCliente y MovimientosCrCliente...
    DEFINE v_Puntualidad                    CHAR(1);
    DEFINE v_ReposicionTarjeta              CHAR(1);
    --Se dejo  porke se usa en euna  consulta para obtener el Ingreso Mensual... Hector Bojorquez
    DEFINE v_smc                            INTEGER;
    -------------------------------------------
    DEFINE iParametricosCelulares           INTEGER;
    DEFINE cTipoMovto                       CHAR(1);
    DEFINE iCaja                            INTEGER;
    DEFINE cCiudadTiendaMov                 CHAR(4);
    DEFINE cArea                            CHAR(1);
    ------------------------------------------------------------------------------------------
    --Definicion de variables que se ocupan para la nueva estructura de envio de datos para la alta de clientes...Hector Bojorquez
    ------------------------------------------------------------------------------------------
    DEFINE iTipoMensaje                     INTEGER;
    DEFINE iFlagclienteAnexo                INTEGER;
    DEFINE iFlagCobxTel                     INTEGER;
    DEFINE iFlagDescuentoEspecial           INTEGER;
    DEFINE iFlagActualizarDatos             INTEGER;
    DEFINE iFlagHuella                      INTEGER;
    DEFINE iMesesTranscurridos              INTEGER;
    DEFINE iNipTitular                      INTEGER;
    DEFINE iNipAdicional1                   INTEGER;
    DEFINE iNipAdicional2                   INTEGER;
    DEFINE iGrupoSemaforoCN                 INTEGER;
    DEFINE iStatusAfore                     INTEGER;
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    DEFINE v_Cad1                           LVARCHAR(350);
    DEFINE v_Cad2                           LVARCHAR(350);
    DEFINE v_Cad3                           LVARCHAR(350);
    DEFINE dFechaMaxima  DATE;

	------NUEVAS DEFINICIONES----
	DEFINE cSucursal CHAR(4);
	DEFINE cCiudadSucursal CHAR(4);
	DEFINE cEstadoSucursal CHAR(2);
	DEFINE cCiudadCoppel INTEGER;
	DEFINE cColoniaCoppel INTEGER;
	DEFINE cCiudadCoppelTrabajo INTEGER;
	DEFINE cColoniaCoppelTrabajo INTEGER;
	DEFINE iIngreso INTEGER;
	DEFINE cValor CHAR(20);
	DEFINE vLimiteCredito SMALLINT;
	DEFINE vingresomensual SMALLINT;
	DEFINE sSecuenciaMax1 SMALLINT;
	DEFINE sSecuenciaMax2 SMALLINT;
	DEFINE iSecuenciaRef1 INTEGER;
	DEFINE iSecuenciaRef2 INTEGER;
	DEFINE iSecuenciaRef3 INTEGER;
	DEFINE iSecuenciaRef4 INTEGER;

    SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
        RETURN v_cod_ret, NULL;
    END EXCEPTION;

--SET DEBUG FILE TO '/pisa/pisabanco/sp_EnvioAltaCteCoppel.out';
--TRACE ON;

--- INICIALIZACIONES
LET v_cod_ret = '00000';
LET vDesErr = '';
LET v_NumcteRef                         = '';
LET v_Nombre                            = '';
LET v_ApellPat                          = '';
LET v_ApellMat                          = '';
LET v_Sexo                              = '';
LET v_AnioNac                           = '';
LET v_MesNac                            = '';
LET v_DiaNac                            = '';
LET v_EdoCivil                          = '';
LET vnumerociudad                       = 1;
LET vnumerocolonia                      = 1;
LET vnumerocalle                        = 1;
LET vcasa                               = '';
LET v_Rumbo                             = '';
LET v_Observaciones                     = '';
LET v_flaguhc                           = '';
LET v_manzana                           = 1;
LET v_otros                             = 1;
LET v_andador                           = 1;
LET v_etapa                             = 1;
LET v_lote                              = 1;
LET v_edificio                          = 1;
LET v_entrada                           = 1;
LET vletrasnumcasa                      = '';
LET vtelefono1                          = '';
LET vtelefono2                          = '';
LET v_Habita_en                         = '';
LET v_ReposicionTarjeta                 = '';
LET v_LugarTrabajo                      = '';
---LET v_Niptitular         = '';
---LET v_FechaAlta              = '';
LET iDiaAltaCliente                     = 1;
LET iMesAltaCliente                     = 1;
LET iYearAltaCliente                    = 1;
---LET v_fecha_hoy              = MDY(1,1,1900);
LET vsituacionespecial                  = 'S';
LET vcausasituacionespecial             = 0;
LET vnombreref                          = '';
LET vapellpatred                        = '';
LET vapellmatref                        = '';
LET vtelref                             = '0';
--- LET v_Puntuacion                = 0;
LET vlimitecredito                      = 0;
LET vcasa                               = '';
LET vnumerociudadTrabajo                = 1;
LET vnumerocoloniaTrabajo               = 1;
LET vnumerocalleTrabajo                 = 1;
LET vcasatrabajo                        = '';
LET vletrasnumcasatrabajo               = '';
LET vextension                          = 1;
LET v_ingreso_mensual                   = 0;
LET v_smc                               = 1;
LET v_Puntualidad                       = 'N';
LET lValorSeguridad                     = 1;
LET cClave                              = 'A';
LET iTienda                             = 4;
LET lCasaReferencia                     = 1;
--LET lEmpleadoEfectuo                    = 1;
LET lEmpleadoEfectuo                    = '';
LET cEmpresa                            = 'C';
LET iParametricosCelulares              = 1;
LET cTipoMovto                          = 'C';
LET iCaja                               = 1;
LET cCiudadTiendaMov                    = '';
LET cArea                               = 'C';
--Inicializacion de variables que se ocupan para la nueva estructura de envio de datos para la alta de clientes...Hector Bojorquez
------------------------------------------------------------------------------------------
LET iTipoMensaje                    = 0;
LET iFlagclienteAnexo               = 0;
LET iFlagCobxTel                    = 0;
LET iFlagDescuentoEspecial          = 0;
LET iFlagActualizarDatos            = 0;
LET iFlagHuella                     = 0;
LET iMesesTranscurridos             = 0;
LET iNipTitular                     = 0;
LET iNipAdicional1                  = 0;
LET iNipAdicional2                  = 0;
LET iGrupoSemaforoCN                = 0;
LET iStatusAfore                    = 0;
LET dFechaMaxima  = mdy(01,01,1900);
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------NUEVAS DEFINICIONES----
LET cSucursal = '';
LET cCiudadSucursal = '';
LEt cEstadoSucursal = '';
LET cCiudadCoppel = 0;
LET cColoniaCoppel = 0;
LET cCiudadCoppelTrabajo = 0;
LET cColoniaCoppelTrabajo = 0;
LET iIngreso = 0;
LET cValor = '';
LET vLimiteCredito = 0;
LET vingresomensual = 0;
LET sSecuenciaMax1 = 0;
LET sSecuenciaMax2 = 0;
LET iSecuenciaRef1 = 0;
LET iSecuenciaRef2 = 0;
LET iSecuenciaRef3 = 0;
LET iSecuenciaRef4 = 0;

    IF (p_Empresa IS NULL OR p_Empresa = '')  THEN
        RETURN '00001', NULL;
    ELSE
        IF (p_NumCte IS NULL OR p_NumCte = '')  THEN
            RETURN '00002', NULL;
        ELSE

			--SELECT monto_solicitado
			--INTO vlimitecredito
			--FROM bdisolic:"informix".ss_solicitudes
			--WHERE numcte = p_NumCte
			--AND num_solicitud = p_NumSolicitud;

			--INGRESO MENSUAL
			SELECT ingreso_mensual INTO iIngreso FROM bdisolic:ss_resum_scor_fin WHERE empresa = p_empresa AND num_solicitud = p_NumSolicitud;
			SELECT valor INTO cValor FROM bdisolic:ss_param WHERE secuencia = 303;
			LET vingresomensual = ROUND(NVL(iIngreso,0)/cValor)::INTEGER;

			--MONTO OTORGADO
			IF  vingresomensual < 2  OR vingresomensual = 2 THEN
				SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:ss_catsmcoppel WHERE limiteinferior = 0 AND limitesuperior = 2;
			ELIF vingresomensual = 3 OR vingresomensual > 3 AND vingresomensual < 4 OR vingresomensual = 4 THEN
				SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:ss_catsmcoppel WHERE limiteinferior = 3 AND limitesuperior = 4;
			ELIF vingresomensual = 5  OR vingresomensual > 5 AND vingresomensual < 6 OR vingresomensual = 6  THEN
				SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:ss_catsmcoppel WHERE limiteinferior = 5 AND limitesuperior = 6;
			ELIF vingresomensual = 7  OR vingresomensual > 7 AND vingresomensual < 8 OR vingresomensual = 8 THEN
				SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:ss_catsmcoppel WHERE limiteinferior = 7 AND limitesuperior = 8;
			ELIF vingresomensual = 9 OR vingresomensual > 9 THEN
				SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:ss_catsmcoppel WHERE limiteinferior = 9 AND limitesuperior = 0;
			END IF;
			
			SELECT MAX(secuencia) INTO sSecuenciaMax1 FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = p_NumCte AND tipo_dir = 1;  

			SELECT numeroextcalle
			INTO vcasa
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte AND tipo_dir = '1' AND secuencia = sSecuenciaMax1;

			EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(vcasa) INTO v_cod_ret, vcasa, vletrasnumcasa;
			
			IF vcasa = '0' THEN
				LET vcasa = '1';
			END IF;
			
			SELECT MAX(secuencia) INTO sSecuenciaMax2 FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = p_NumCte AND tipo_dir = 2;
			
			SELECT numeroextcalle
			INTO vcasatrabajo
			FROM bdinteg:si_direcciones
			WHERE numcte = p_NumCte AND tipo_dir = '2' AND secuencia = sSecuenciaMax2;

			EXECUTE PROCEDURE bdinteg:"informix".sp_ConvierteNumerodeCasa(vcasa) INTO v_cod_ret, vcasatrabajo, vletrasnumcasatrabajo;
			
			SELECT numerociudad , numerocolonia, numerocalle, SUBSTR(telefono3, 4, 7), extension::INTEGER
			INTO vnumerociudadTrabajo, vnumerocoloniaTrabajo, vnumerocalleTrabajo, vtelefono1Trabajo, vextension
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte AND tipo_dir = '2' AND secuencia = sSecuenciaMax2;
			
			--------------------------------------------
			SELECT MAX(secuencia)
			INTO iSecuenciaRef2
			FROM bdinteg:"informix".si_refdirecciones
			WHERE numcte = p_NumCte
			AND secuencia > 0;
			
			SELECT MAX(secuencia)
			INTO iSecuenciaRef3
			FROM bdinteg:"informix".si_refdirecciones
			WHERE numcte =  p_NumCte 
			AND secuencia <> iSecuenciaRef2;
			---------------------------------------------
			SELECT MAX(secuencia)
			INTO iSecuenciaRef1
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND numcte = p_NumCte
			AND secuencia > 0;	
			
			SELECT MAX(secuencia)
			INTO iSecuenciaRef4
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND numcte =  p_NumCte
			AND secuencia <> iSecuenciaRef1;
			-----------------------------------------
			SELECT nombre1 || " " || nombre2, apell_paterno, apell_materno
			INTO vnombreref, vapellpatred, vapellmatref
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND numcte = p_NumCte
			AND secuencia = iSecuenciaRef4;
			
			SELECT SUBSTR(telefono1, 4, 7)
			INTO vtelref
			FROM bdinteg:"informix".si_refdirecciones
			WHERE numcte = p_NumCte
			AND secuencia = iSecuenciaRef3;		
			------------------------------------------
											
			SELECT numcte_ref, TRIM(nombre1) || " " || TRIM(nombre2), apell_paterno::CHAR(15), apell_materno::CHAR(15),
			DAY(fecha_insert), MONTH(fecha_insert), YEAR(fecha_insert)	
			INTO v_NumcteRef, v_Nombre, v_ApellPat, v_ApellMat, iDiaAltaCliente, iMesAltaCliente, iYearAltaCliente
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = p_NumCte;
			
			SELECT sexo, YEAR(fecha_nac), MONTH(fecha_nac), DAY(fecha_nac), estado_civil, habita_en
			INTO v_Sexo, v_AnioNac, v_MesNac, v_DiaNac, v_EdoCivil, v_Habita_en
			FROM bdinteg:"informix".si_ctepf
			WHERE numcte = p_NumCte;
			
			SELECT numerociudad, numerocolonia, numerocalle, puntocardinal, observaciones, DECODE(unidadhabitac,'S',1,'1',1,'N',0,'0',0,0), 
				   manzana, otros, andador, etapa, lote, edificio, entrada, SUBSTR(TRIM(telefono1), 4, 7), SUBSTR(TRIM(telefono2), 4, 7)
			INTO vnumerociudad,vnumerocolonia, vnumerocalle, v_Rumbo, v_Observaciones, v_flaguhc, v_manzana, 
				 v_otros, v_andador, v_etapa, v_lote, v_edificio, v_entrada, vtelefono1, vtelefono2
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = '1'
			AND secuencia = sSecuenciaMax1;

			IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_os_solautdirecta WHERE empresa = p_Empresa AND num_solicitud = p_NumSolicitud) >= 1 THEN
				LET vsituacionespecial = 'S';
				LET vcausasituacionespecial = 50;
			ELSE
				SELECT MAX(fecha_solicitud) INTO dFechaMaxima FROM bdisolic:"informix".ss_solicitud_os WHERE empresa = p_Empresa AND num_solicitud = p_NumSolicitud;

				SELECT situacionespecial, causasituacionespecial
				INTO vsituacionespecial, vcausasituacionespecial
				FROM bdisolic:"informix".ss_solicitud_os
				WHERE empresa = p_Empresa AND fecha_solicitud = dFechaMaxima AND num_solicitud = p_NumSolicitud;
			END IF;

			--Selecciona Sucursal y Usuario
			SELECT sucursal, user_insert
			INTO cSucursal, lEmpleadoEfectuo
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_solicitud = p_NumSolicitud;


			--Selecciona la fecha de alta de cuenta coppel
			SELECT DAY(fecha_entrada), MONTH(fecha_entrada), YEAR(fecha_entrada)	
			INTO iDiaAltaCliente, iMesAltaCliente, iYearAltaCliente
			FROM bdisolic:"informix".ss_autorizacion
			WHERE empresa = p_Empresa 
            AND num_solicitud = p_NumSolicitud
            AND status_solicitud = 'AP';

			--Selecciona ciudad de la sucursal en el catalogo relacionado
			SELECT ciudad, estado
			INTO cCiudadSucursal, cEstadoSucursal
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;

			SELECT FIRST 1 ciudad_coppel
			INTO cCiudadTiendaMov
			FROM bdinteg:"informix".si_ciudades
			WHERE ciudad = cCiudadSucursal AND estado = cEstadoSucursal;

			--Selecciona ciudad y colonia del domicilio particular del cliente del catalogo relacionado
			SELECT numerocoloniacoppel, numerociudadcoppel
			INTO cColoniaCoppel, cCiudadCoppel
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = vnumerociudad AND numerocolonia = vnumerocolonia;

			--Selecciona ciudad y colonia del domicilio particular del cliente del catalogo relacionado
			SELECT numerocoloniacoppel, numerociudadcoppel
			INTO cColoniaCoppelTrabajo, cCiudadCoppelTrabajo
			FROM bdinteg:"informix".si_catzonas
			WHERE numerociudad = vnumerociudadTrabajo AND numerocolonia = vnumerocolonia;

            LET v_NumcteRef             = NVL(v_NumcteRef,'');
            LET v_Nombre                = NVL(v_Nombre,'');
            LET v_ApellPat              = NVL(v_ApellPat,'');
            LET v_ApellMat              = NVL(v_ApellMat,'');
            LET v_Sexo                  = NVL(v_Sexo,'');
            LET v_AnioNac               = NVL(v_AnioNac,0);
            LET v_MesNac                = NVL(v_MesNac,0);
            LET v_DiaNac                = NVL(v_DiaNac,0);
            LET v_EdoCivil              = NVL(v_EdoCivil,'');
            LET cCiudadCoppel           = NVL(cCiudadCoppel,0);
            LET cColoniaCoppel          = NVL(cColoniaCoppel,0);
            LET vnumerocalle            = NVL(vnumerocalle,0);
            LET v_Rumbo                 = NVL(v_Rumbo,'');
            LET v_Observaciones         = NVL(v_Observaciones,'');
            LET v_flaguhc               = NVL(v_flaguhc,'');
            LET v_manzana               = NVL(v_manzana,0);
            LET v_otros                 = NVL(v_otros,0);
            LET v_andador               = NVL(v_andador,0);
            LET v_etapa                 = NVL(v_etapa,0);
            LET v_lote                  = NVL(v_lote,0);
            LET v_edificio              = NVL(v_edificio,0);
            LET v_entrada               = NVL(v_entrada,0);
            LET vtelefono1              = NVL(vtelefono1,'');
            LET vtelefono2              = NVL(vtelefono2,'');
            LET v_Habita_en             = NVL(v_Habita_en,'');
            LET iDiaAltaCliente         = NVL(iDiaAltaCliente,0);
            LET iMesAltaCliente         = NVL(iMesAltaCliente,0);
            LET iYearAltaCliente        = NVL(iYearAltaCliente,0);
            LET vletrasnumcasa          = NVL(vletrasnumcasa,'');
            LET vsituacionespecial      = NVL(vsituacionespecial,'');
            LET vcausasituacionespecial = NVL(vcausasituacionespecial,0);
            LET vingresomensual       	= NVL(vingresomensual,0);
            LET vlimitecredito          = NVL(vlimitecredito,0);
            LET cCiudadCoppelTrabajo    = NVL(cCiudadCoppelTrabajo,0);
            LET cColoniaCoppelTrabajo   = NVL(cColoniaCoppelTrabajo,0);
            LET vnumerocalleTrabajo     = NVL(vnumerocalleTrabajo,0);
            LET vcasatrabajo            = NVL(vcasatrabajo,'');
            LET vletrasnumcasatrabajo   = NVL(vletrasnumcasatrabajo,'');
            LET vtelefono1Trabajo       = NVL(vtelefono1Trabajo,0);
            LET vextension              = NVL(vextension,0);
            LET vnombreref              = NVL(vnombreref::CHAR(15),'');
            LET vapellpatred            = NVL(vapellpatred::CHAR(15),'');
            LET vapellmatref            = NVL(vapellmatref::CHAR(15),'' );
            LET vtelref                 = NVL(vtelref,'0');
            LET vcasa                   = NVL(vcasa,'0');
            LET v_Puntualidad           = 'N';
            LET v_ReposicionTarjeta     = '0';

			IF v_Observaciones = '' THEN
				LET v_Observaciones = 'E';
			END IF

        END IF;
    END IF;

    LET v_Cad1 = iTipoMensaje ||"|"||lValorSeguridad ||"|"|| TRIM(v_NumcteRef) ||"|"|| TRIM(v_Nombre) ||"|"|| TRIM(v_ApellPat)
            ||"|"|| TRIM(v_ApellMat) ||"|"|| TRIM(v_Sexo) ||"|"|| TRIM(v_DiaNac) ||"|"|| TRIM(v_MesNac) ||"|"|| TRIM(v_AnioNac)
            ||"|"|| TRIM(v_EdoCivil) ||"|"|| vnumerociudad ||"|"|| vnumerocolonia ||"|"|| vnumerocalle ||"|"|| TRIM(vcasa)
            ||"|"|| TRIM(NVL(v_Rumbo, 'x')) ||"|"|| TRIM(NVL(v_Observaciones, 'x')) ||"|"|| TRIM(v_flaguhc) ||"|"|| v_manzana ||"|"|| v_otros
            ||"|"|| v_andador ||"|"|| v_etapa ||"|"|| v_lote ||"|"|| v_edificio ||"|"|| v_entrada
            ||"|"|| TRIM(DECODE(vletrasnumcasa,'','',vletrasnumcasa)) ||"|"|| TRIM(vtelefono1) ||"|"|| TRIM(vtelefono2) ||"|"|| TRIM(v_Habita_en);

    LET v_Cad2 = TRIM(vsituacionespecial) ||"|"|| vcausasituacionespecial ||"|"|| TRIM(v_Puntualidad) ||"|"||   vingresomensual
            ||"|"|| vlimitecredito::INTEGER ||"|"|| TRIM(v_ReposicionTarjeta) ||"|"|| iFlagClienteAnexo ||"|"|| iFlagCobxTel
            ||"|"|| iFlagDescuentoEspecial ||"|"|| iFlagActualizarDatos ||"|"|| iFlagHuella
            ||"|"|| iMesesTranscurridos ||"|"|| " " ||"|"|| vnumerociudadTrabajo ||"|"|| vnumerocoloniaTrabajo
            ||"|"|| vnumerocalleTrabajo ||"|"|| TRIM(NVL(vcasatrabajo, 'x')) ||"|"|| TRIM(DECODE(vletrasnumcasatrabajo,'','',vletrasnumcasatrabajo))
            ||"|"|| TRIM(vtelefono1Trabajo) ||"|"|| vextension ||"|"|| iNipTitular ||"|"|| iNipAdicional1;

    LET v_Cad3 = iNipAdicional2 ||"|"|| TRIM(DECODE(vnombreref,'','',vnombreref)) ||"|"|| TRIM(DECODE(vapellpatred,'','',vapellpatred))
            ||"|"|| TRIM(DECODE(vapellmatref,'','',vapellmatref)) ||"|"|| TRIM(DECODE(vtelref,'','0',TRIM(vtelref))) ||"|"|| iDiaAltaCliente
            ||"|"|| iMesAltaCliente ||"|"|| iYearAltaCliente ||"|"|| iGrupoSemaforoCN ||"|"|| iStatusAfore
            ||"|"|| iParametricosCelulares ||"|"|| TRIM(cClave) ||"|"|| TRIM(cTipoMovto) ||"|"|| iTienda ||"|"|| iCaja
            ||"|"|| TRIM(lEmpleadoEfectuo) ||"|"|| TRIM(cCiudadTiendaMov) ||"|"|| TRIM(cArea);

    RETURN  v_cod_ret, v_Cad1 || "|" || v_Cad2 || "|" || v_Cad3 || "|";

END;
--##############################################################################
--## Procedimiento       : sp_EnvioAltaCteCoppel
--## Base de Datos       : bdisolic
--## Version             : 1.0
--## Creado por          : Mohamed Carreón
--## Fecha creacion      : Enero de 2009
--##Descripcion          : Obtiene la informacion del cliente coppel para el envio
--## Modificado por      : Héctor Bojórquez
--## Fecha Modificación  : Marzo 2009
--## Modificado por      : Frank Gaxiola
--## Fecha Modificación  : Junio 2011
--##Descripcion          : Se actualiza la información para Alta Unica Paso 5
--##############################################################################
END PROCEDURE;