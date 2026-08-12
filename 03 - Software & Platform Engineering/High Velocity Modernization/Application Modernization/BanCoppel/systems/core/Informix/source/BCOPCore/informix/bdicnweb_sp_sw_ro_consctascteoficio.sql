CREATE PROCEDURE "informix".sp_sw_ro_consctascteoficio(pUsuario CHAR(8), pIdFunciON CHAR(10), pIdOficio INT, pIdCliente INT, 
                                                                                        pNumCliente CHAR(20), pRegistros INT, pRecuperaciON INT)
        RETURNING CHAR(5) AS codret,
                INT AS id_cliente,
                CHAR(2) AS tipo_cuenta, 
                CHAR(10) AS desc_tipo_cuenta,
                CHAR(20) AS cuenta,
                CHAR(4) AS cod_producto, 
                CHAR(1) AS ind_datos_titular,
                CHAR(1) AS ind_fecha_apertura,
                CHAR(1) AS ind_sucursal_apertura,
                CHAR(1) AS ind_domicilio_sucursal,
                CHAR(1) AS ind_saldo,
                CHAR(1) AS ind_reportar_status_cuenta,
                CHAR(1) AS ind_cta_bloqueada,
                CHAR(1) AS ind_cta_bloqueada_por_sistema,
                CHAR(1) AS ind_detalles_movimientos,
                CHAR(1) AS ind_certifica_imagenes,
                CHAR(1) AS ind_certifica_edoscta,
                CHAR(100) AS titular,
                CHAR(10) AS fecha_apertura,
                CHAR(60) AS sucursal_apertura,
                CHAR(150) AS domicilio_sucursal,
                money(14,2) AS saldo,
                CHAR(30) AS status_cuenta,
                CHAR(10) AS fecha_bloqueo,
                CHAR(40) AS motivo_bloqueo,
                CHAR(60) AS oficio,
                CHAR(10) AS fecha_recepcion_oficio,
                money(14,2) AS saldo_actual,
                CHAR(1) AS ind_tarjetas,
                CHAR(1) AS ind_beneficiarios,
                CHAR(1) AS ind_facultados,
                SMALLINT AS id_participe,
				CHAR(40) AS nombre_producto;
				
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNoRegistros INT;
        DEFINE iIdCte INT;
        DEFINE iTipoCliente CHAR(1);
        DEFINE cNombreTitular CHAR(100);
        DEFINE cTipoCuenta CHAR(2);
        DEFINE cDescTipoCuenta CHAR(10);
        DEFINE cCuenta CHAR(20);
        DEFINE cIndDatosTitular CHAR(1);
        DEFINE cIndFechaApertura CHAR(1);
        DEFINE cIndSucursalApertura CHAR(1);
        DEFINE cIndDomicilioSucursal CHAR(1);
        DEFINE cIndSaldo CHAR(1);
        DEFINE cIndReportarStatusCuenta CHAR(1);
        DEFINE cIndCtaBloqueada CHAR(1);
        DEFINE cIndCtaBloqueadaPorSistema CHAR(1);
        DEFINE dFechaApertura DATE;
        DEFINE cSucursalApertura CHAR(60);
        DEFINE cDomicilioSucursal CHAR(150);
        DEFINE mSaldo money(14,2);
        DEFINE cStatusCuenta CHAR(30);
        DEFINE dFechaBloqueo DATE;
        DEFINE cMotivoBloqueo CHAR(40);
        DEFINE cOficio CHAR(60);
        DEFINE dFecRecepcionOficio DATE;
        DEFINE mSaldoActual money(14,2);
        DEFINE cProducto CHAR(4);
        DEFINE cIndMovimientos CHAR(1);
        DEFINE cIndImagenes CHAR(1);
        DEFINE cIndEdosCta CHAR(1);
        DEFINE cNoSucursal CHAR(4);
        DEFINE cIndTarjetas CHAR(1);
        DEFINE cIndBeneficiarios CHAR(1);
        DEFINE cIndFacultados CHAR(1);
        DEFINE iIdTipoParticipe SMALLINT;
		DEFINE cNombreProducto CHAR(40);
		
		DEFINE cCodRetPtf varchar(5); 
		DEFINE cIdptf varchar(5); 
		DEFINE cTipos varchar(1); 
		DEFINE cClavesit char(3); 
		DEFINE cFechasit date; 
		DEFINE cCalles varchar(100); 
		DEFINE cNumext varchar(6); 
		DEFINE cNumint varchar(5); 
		DEFINE cCvecol char(8); 
		DEFINE cColonias varchar(100); 
		DEFINE cCvemun char(5); 
		DEFINE cMunicipio varchar(60); 
		DEFINE cVelocalidades char(14); 
		DEFINE cLocalidades varchar(60); 
		DEFINE cCps char(5);                     
		DEFINE cCiudades char(3); 
		DEFINE cEstados INTEGER; 
		DEFINE cLatitudes varchar(10); 
		DEFINE cLongitudes varchar(11); 
		DEFINE cTels1 varchar(14); 
		DEFINE cTels2 varchar(14); 

		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        LET iIdCte = 0;
        LET iTipoCliente = '';
        LET cNombreTitular = '';
        LET cTipoCuenta = '';
        LET cDescTipoCuenta = '';
        LET cCuenta = '';
        LET cIndDatosTitular = '';
        LET cIndFechaApertura = '';
        LET cIndSucursalApertura = '';
        LET cIndDomicilioSucursal = '';
        LET cIndSaldo = '';
        LET cIndReportarStatusCuenta = '';
        LET cIndCtaBloqueada = '';
        LET cIndCtaBloqueadaPorSistema = '';
        LET dFechaApertura = NULL;
        LET cSucursalApertura = '';
        LET cDomicilioSucursal = '';
        LET mSaldo = 0;
        LET cStatusCuenta = '';
        LET dFechaBloqueo = NULL;
        LET cMotivoBloqueo = '';
        LET cOficio = '';
        LET dFecRecepcionOficio = NULL;
        LET mSaldoActual = 0;
        LET cProducto = '';
        LET cIndMovimientos = '';
        LET cIndImagenes = '';
        LET cNoSucursal = '';
        LET cIndEdosCta = '';
        LET cIndTarjetas = '';
        LET cIndBeneficiarios = '';
        LET cIndFacultados = '';
        LET iIdTipoParticipe = 0;
		LET cNombreProducto = '';
		
		LET cCodRetPtf = '';
		LET cIdptf = ''; 
		LET cTipos = ''; 
		LET cClavesit = ''; 
		LET cFechasit = ''; 
		LET cCalles = ''; 
		LET cNumext = ''; 
		LET cNumint = ''; 
		LET cCvecol = ''; 
		LET cColonias = ''; 
		LET cCvemun = ''; 
		LET cMunicipio = ''; 
		LET cVelocalidades = ''; 
		LET cLocalidades = ''; 
		LET cCps = ''; 		
		LET cCiudades = ''; 
		LET cEstados = 0; 
		LET cLatitudes = ''; 
		LET cLongitudes = ''; 
		LET cTels1 = ''; 
		LET cTels2 = ''; 

        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                        cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                        cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END EXCEPTION;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
                IF pUsuario = '' 
                        or pIdFunciON = '' 
                        or pIdOficio = '' 
                        or pNumCliente = '' 
                        or pRegistros = '' 
                        or pRecuperaciON = '' 
                        or pIdCliente = '' 
                        then
                                LET cCodRet = '00003';
                                RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                                cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                                cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                                cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                                cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                                cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                                cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                                cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END IF;
                IF pRecuperaciON <= 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                        cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                        cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura, 
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END IF;
                IF pRegistros < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                        cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                        cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END IF;
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                        cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                        cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END IF;
                
                FOREACH
                                SELECT skip pRegistros FIRST pRecuperaciON DISTINCT 
                                        a.id_resulcte
                                        , b.tipo_cliente
                                        , a.tipo_cuenta
                                        , decode(a.tipo_cuenta, '01', 'CAPTACION', '03', 'INVERSION', '06', 'CREDITO')
                                        , a.cuenta
                                        , a.producto
                                        , a.ind_datos_titular
                                        , a.ind_fecha_apertura
                                        , a.ind_sucursal_apertura
                                        , a.ind_domicilio_sucursal
                                        , a.ind_saldo
                                        , a.ind_reportar_status
                                        , a.ind_cuenta_ya_bloqueada
                                        , a.ind_bloqueo_cta_por_sistema
                                        , a.detalle_movimientos
                                        , a.certifica_imagenes
                                        , a.fecha_apertura
                                        , a.sucursal
                                        , CASE WHEN a.ind_saldo = '1' THEN nvl(a.sdo_actual, 0) ELSE 0 END saldo
                                        , CASE WHEN a.ind_reportar_status = '1' THEN a.status_cuenta ELSE '' END status_cuenta
                                        , CASE WHEN a.ind_cuenta_ya_bloqueada = '1' THEN a.fecha_bloqueo END fecha_bloqueo
                                        , CASE WHEN a.ind_cuenta_ya_bloqueada = '1' THEN a.motivo_bloqueo ELSE '' END motivo_bloqueo
                                        , CASE WHEN a.ind_bloqueo_cta_por_sistema = '1' THEN c.oficio ELSE '' END oficio
                                        , CASE WHEN a.ind_bloqueo_cta_por_sistema = '1' THEN c.fecha_recepciON END fecha_recepcion_oficio
                                        , CASE WHEN a.ind_bloqueo_cta_por_sistema = '1' THEN a.sdo_actual ELSE 0 END saldo_actual
                                        , a.certifica_edocuenta
                                        , a.ind_beneficiarios
                                        , a.ind_facultados
                                        , a.id_tipo_participe
                                INTO iIdCte, iTipoCliente, cTipoCuenta, cDescTipoCuenta, 
                                                cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                                cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                                cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                                dFechaApertura, cNoSucursal, mSaldo, cStatusCuenta,
                                                dFechaBloqueo, cMotivoBloqueo, cOficio, dFecRecepcionOficio, 
                                                mSaldoActual, cIndEdosCta, cIndBeneficiarios, cIndFacultados,
                                                iIdTipoParticipe
                                FROM sw_ro_ctecta a, sw_ro_resulper b, sw_ro_maeoficios c
                                WHERE a.id_oficio = pIdOficio
                                        AND a.id_resulcte = pIdCliente
                                        AND a.numcte = pNumCliente
                                        AND a.status = '1'
                                        AND a.ind_terminado = '1'
                                        AND b.id_oficio = a.id_oficio
                                        AND b.ind_omitir = '0'
                                        AND b.id_busqueda = a.id_busqueda
                                        AND c.id_oficio = a.id_oficio
                        IF cIndDatosTitular = '1' THEN
                                
                                        SELECT DISTINCT TRIM(TRIM(nombre1_titular)||' '||TRIM(nombre2_titular))||' '||
                                                                                TRIM(TRIM(apell_paterno_titular)||' '||TRIM(apell_materno_titular))||' '||
                                                                                TRIM(razon_social_titular)
                                        INTO cNombreTitular
                                        FROM sw_ro_cte_ctatitular
                                        WHERE id_oficio = pIdOficio
                                                AND numcte = pNumCliente 
                                                AND cuenta = cCuenta;

                        END IF; 
						
						EXECUTE FUNCTION bdinteg:"informix".sp_si_ptf(cNoSucursal) 
						INTO 
						cCodRetPtf, cIdptf, cTipos, cClavesit, cFechasit, cCalles, cNumext, cNumint, cCvecol, cColonias, cCvemun, cMunicipio, 
						cVelocalidades, cLocalidades, cCps, cCiudades, cEstados, cLatitudes, cLongitudes, cTels1, cTels2;   

                        IF cIndSucursalApertura = '1' THEN
                                
                                SELECT a.sucursal||' '||a.nombre sucursal
                                INTO cSucursalApertura
                                FROM (bdinteg:si_sucursales a LEFT JOIN bdinteg:si_ciudades b ON b.ciudad = a.ciudad AND b.estado = a.estado)
                                        LEFT JOIN bdinteg:si_estados c ON c.estado = a.estado
                                WHERE a.sucursal = cNoSucursal;
                                IF cSucursalApertura is null THEN
                                        LET cSucursalApertura = '';
                                END IF;
                        END IF;
                        IF cIndDomicilioSucursal = '1' THEN
                                
                                SELECT cIdptf||' '||a.nombre sucursal, 
                                        TRIM(cCalles || ' ' || cNumext)||' '||
                                        TRIM(nvl(UPPER(cColonias) || ' ' || cCps, ''))||', '||
                                        TRIM(nvl(b.nombre, '')||', '||
                                        nvl(c.nombre, ''))
                                INTO cSucursalApertura, cDomicilioSucursal
                                FROM (bdinteg:si_sucursales a LEFT JOIN bdinteg:si_ciudades b ON b.ciudad = a.ciudad AND b.estado = a.estado)
                                        LEFT JOIN bdinteg:si_estados c ON c.estado = a.estado
                                WHERE a.sucursal = cNoSucursal;
                                IF cSucursalApertura is null THEN
                                        LET cSucursalApertura = '';
                                END IF;
                                IF cDomicilioSucursal is null THEN
                                        LET cDomicilioSucursal = '';
                                END IF;
                        END IF;
                        -- Revisamos si la cuenta tiene tarjetas
                        
                        SELECT CASE WHEN COUNT(num_tarjeta) > 0 THEN '1' ELSE '0' END AS ind_tarjeta
                        INTO cIndTarjetas
                        FROM v_sw_ro_tarjetasclientes
                        WHERE cuenta = cCuenta
                                AND id_oficio = pIdOficio;
								
						-- Se busca la descripciÃÂ³n del producto dependiendo del sistema cuenta
						IF cTipoCuenta = '01' THEN
							SELECT NVL(nombre, '')
							INTO cNombreProducto
							FROM bdicheq:sc_producto
							WHERE producto = cProducto;
						ELIF cTipoCuenta = '03' THEN
							SELECT NVL(nombre, '')
							INTO cNombreProducto
							FROM bdinvers:sv_instrum
							WHERE cod_instrum = cProducto;
						ELIF cTipoCuenta = '06' THEN
							SELECT DISTINCT NVL(nombre_prod, '')
							INTO cNombreProducto
							FROM 
								(SELECT num_producto, nombre_prod
								 FROM bdicred:sd_definicion
							UNION
								 SELECT num_producto, nombre_prod
								 FROM bdicred:sd_definicioncrd)
							WHERE num_producto = cProducto;
						END IF;
								
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, cIndReportarStatusCuenta, 
                                        cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, cIndImagenes, 
                                        cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto 
                                WITH RESUME;
                        LET iNoRegistros = iNoRegistros + 1;
                END FOREACH;
                IF iNoRegistros = 0 THEN
                        LET cCodRet = '01001';
                        RETURN cCodRet, iIdCte, cTipoCuenta, cDescTipoCuenta, 
                                        cCuenta, cProducto, cIndDatosTitular, cIndFechaApertura, 
                                        cIndSucursalApertura, cIndDomicilioSucursal, cIndSaldo, 
                                        cIndReportarStatusCuenta, cIndCtaBloqueada, cIndCtaBloqueadaPorSistema, cIndMovimientos, 
                                        cIndImagenes, cIndEdosCta, cNombreTitular, dFechaApertura, cSucursalApertura,
                                        cDomicilioSucursal, mSaldo, cStatusCuenta, dFechaBloqueo, 
                                        cMotivoBloqueo, cOficio, dFecRecepcionOficio, mSaldoActual, 
                                        cIndTarjetas, cIndBeneficiarios, cIndFacultados, iIdTipoParticipe, cNombreProducto;
                END IF;
        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/10/2014',
'DESCRIPCION: Se agrega el nombre del producto en las variables de retorno';

CREATE PROCEDURE "informix".sp_sw_ro_guardamovtos(pUsuario CHAR(8), pFunciON CHAR(10), pIdOficio INT, pIdBusqueda INT, 
										pIdCte INT, pNumCliente CHAR(20),pNumCuenta CHAR(20), pNumTarjeta CHAR(20), 
										pTipoCuenta CHAR(2), pFechaMovto CHAR(10), pHora CHAR(15), pFolioSucursal CHAR(16), 
										pTransacciON CHAR(4), pDescTransacciON CHAR(50), pReversado CHAR(1), pMonto decimal(18,2), 
										pSucursal CHAR(4), pNaturaleza CHAR(1), pSaldo money(14,2), pProcedencia CHAR(20),
										pDescProcedencia CHAR(50), pReferencia CHAR(40), pIndOmitir CHAR(1), pIp CHAR(15),
										pMac CHAR(12))	
	RETURNING CHAR(5) AS codret,
				INT AS secuencia
	DEFINE iSqlErr INT;
	DEFINE iSecuencia INT;
	DEFINE cCodRet CHAR(5);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE cEstado CHAR(2);
	DEFINE cCiudad CHAR(3);
	DEFINE cDescEstado CHAR(30);
	DEFINE cDescCiudad CHAR(60);
	DEFINE dFechaMovto date;
	
	DEFINE cCodRetPtf varchar(5); 
	DEFINE cIdptf varchar(5); 
	DEFINE cTipos varchar(1); 
	DEFINE cClavesit char(3); 
	DEFINE cFechasit date; 
	DEFINE cCalles varchar(100); 
	DEFINE cNumext varchar(6); 
	DEFINE cNumint varchar(5); 
	DEFINE cCvecol char(8); 
	DEFINE cColonias varchar(100); 
	DEFINE cCvemun char(5); 
	DEFINE cMunicipio varchar(60); 
	DEFINE cVelocalidades char(14); 
	DEFINE cLocalidades varchar(60); 
	DEFINE cCps char(5);                     
	DEFINE cCiudades char(3); 
	DEFINE cEstados INTEGER; 
	DEFINE cLatitudes varchar(10); 
	DEFINE cLongitudes varchar(11); 
	DEFINE cTels1 varchar(14); 
	DEFINE cTels2 varchar(14); 
	
	LET iSqlErr = 0;
	LET iSecuencia = 0;
	LET cCodRet = '00000';
	LET cNombreSucursal = '';
	LET cEstado = '';
	LET cCiudad = '';
	LET cDescEstado = '';
	LET cDescCiudad = '';
	LET dFechaMovto ='';
	
	LET cCodRetPtf = '';
	LET cIdptf = ''; 
	LET cTipos = ''; 
	LET cClavesit = ''; 
	LET cFechasit = ''; 
	LET cCalles = ''; 
	LET cNumext = ''; 
	LET cNumint = ''; 
	LET cCvecol = ''; 
	LET cColonias = ''; 
	LET cCvemun = ''; 
	LET cMunicipio = ''; 
	LET cVelocalidades = ''; 
	LET cLocalidades = ''; 
	LET cCps = ''; 		
	LET cCiudades = ''; 
	LET cEstados = 0; 
	LET cLatitudes = ''; 
	LET cLongitudes = ''; 
	LET cTels1 = ''; 
	LET cTels2 = ''; 
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iSecuencia;
			END IF;
		END EXCEPTION;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pFunciON = ''
				OR pIdOficio = ''
				OR pIdBusqueda = ''
				OR pIdCte = ''
				OR pNumCliente = ''
				OR pFolioSucursal = ''
				OR pNumCuenta = ''
				OR pTipoCuenta = ''
				OR pFechaMovto = ''
				OR pHora = ''
				OR pSucursal = ''
				OR pMonto = ''
				OR pIndOmitir = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iSecuencia;
		END IF;
		IF pIndOmitir NOT IN ('0', '1') THEN
			LET cCodRet = '00077';
			RETURN cCodRet, iSecuencia;
		END IF;
		IF pTipoCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00077';
			RETURN cCodRet, iSecuencia;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pFunciON) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuencia;
		END IF;
		-- ValidaciÃ³n de parametro s por sistema cuenta
		IF pTipoCuenta = '01' THEN
			IF pNaturaleza = '' OR pSaldo = '' THEN --or pReferencia = ''OR pProcedencia = ''OR pDescProcedencia = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iSecuencia;
			END IF;
		ELIF pTipoCuenta = '06' THEN
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_si_ptf(pSucursal) 
		INTO 
		cCodRetPtf, cIdptf, cTipos, cClavesit, cFechasit, cCalles, cNumext, cNumint, cCvecol, cColonias, cCvemun, cMunicipio, 
		cVelocalidades, cLocalidades, cCps, cCiudades, cEstados, cLatitudes, cLongitudes, cTels1, cTels2;   
						
		-- Buscamos los datos de la sucursal		
		SELECT nombre, cEstados, cCiudades 
		INTO cNombreSucursal, cEstado, cCiudad
		FROM bdinteg:si_sucursales 
		WHERE sucursal = pSucursal;
		-- Obtenemos la descripciON del estado		
		SELECT nombre 
		INTO cDescEstado 
		FROM bdinteg:si_estados 
		WHERE estado = cEstado;
		-- Obtenemos la descripciON de la ciudad		
		SELECT nombre 
		INTO cDescCiudad 
		FROM bdinteg:si_ciudades 
		WHERE estado = cEstado 
			AND ciudad = cCiudad;
		-- Guardamos el registro en la base de datos
		
		let dFechaMovto = EXTEND(MDY(SUBSTR(pFechaMovto,6,2),SUBSTR(pFechaMovto,9,2),SUBSTR(pFechaMovto,1,4)), YEAR TO SECOND);
		INSERT INTO sw_ro_movtos(id_resulcte, id_busqueda, id_oficio, numcte, 
									cuenta, tipo_cuenta, fecha_mov, folio_sucursal, 
									transaccion, descripcion_transaccion, reversado, monto, 
									sucursal, nombre_sucursal, estado, ciudad, 
									estado_nombre, ciudad_nombre, user_INSERT, ip_INSERT, 
									mac_INSERT, hora, naturaleza, saldo, 
									procedencia, descripcion_procedencia, referencia, ind_omitido,
									tarjeta)
			VALUES(pIdCte, pIdBusqueda, pIdOficio, pNumCliente, 
					pNumCuenta, pTipoCuenta, dFechaMovto,pFolioSucursal, 
					pTransaccion, pDescTransaccion, pReversado, pMonto,
					pSucursal, cNombreSucursal, cEstado, cCiudad, 
					cDescEstado, cDescCiudad, pUsuario, pIp, 
					pMac, pHora, pNaturaleza, pSaldo, 
					pProcedencia, pDescProcedencia, pReferencia, pIndOmitir, 
					pNumTarjeta);
		-- Se actualiza en estatus en la tabla de cuentas
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_ctecta 
		SET detalle_movimientos = '1' 
		WHERE id_resulcte = pIdCte 
		AND id_busqueda = pIdBusqueda 
		AND id_oficio = pIdOficio
		AND cuenta = pNumCuenta;
		-- Se actualiza en estatus en la tabla de clientes
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_resulcte 
		SET detalle_movimientos = '1' 
		WHERE id_resulcte = pIdCte 
		AND id_busqueda = pIdBusqueda 
		AND id_oficio = pIdOficio;
		-- Se actualiza en estatus en la tabla de clientes
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_maeoficios 
		SET detalle_movimientos = '1' 
		WHERE id_oficio = pIdOficio;
		LET iSecuencia = dbinfo('sqlca.sqlerrd1');
		RETURN cCodRet, iSecuencia;
	END
END PROCEDURE;