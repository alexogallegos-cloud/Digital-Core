CREATE PROCEDURE "informix".sp_cargo_abono_palzo(p_Empresa  CHAR(3),
                                                 p_NumCredito CHAR(20),
                                                 p_Tarjeta CHAR(16),
                                                 p_Monto MONEY(14,2),
                                                 p_Usuario CHAR(8),
                                                 p_Sucursal CHAR(4),
                                                 p_Transacc CHAR(4),
                                                 p_Operacion SMALLINT,
                                                 p_referencia CHAR(16),
												 p_respaldo_crd CHAR(1) DEFAULT '1')

   RETURNING CHAR(6), CHAR(80)

   DEFINE CodRet            CHAR(6);
   DEFINE sql_err           SMALLINT;
   DEFINE isam_err          SMALLINT;
   DEFINE error_info        CHAR(40);
   DEFINE nRows             SMALLINT;
   DEFINE Mensaje           CHAR(80);
   DEFINE wBegin            CHAR(1);
   DEFINE pFecha            CHAR(6);
   DEFINE g_Remanente      	MONEY(14,2);
   DEFINE g_IntMoraCob     	MONEY(14,2);
   DEFINE g_IntVencCob     	MONEY(14,2);
   DEFINE g_CapVencCob     	MONEY(14,2);
   DEFINE g_IntVigCob      	MONEY(14,2);
   DEFINE g_CapVigCob      	MONEY(14,2);
   DEFINE g_Impuesto       	MONEY(14,2);
   DEFINE g_Comision       	MONEY(14,2);
   DEFINE g_Seguro         	MONEY(14,2);
   DEFINE g_IvaCte         	DECIMAL(9,6);
   DEFINE g_PagoCapVencido 	MONEY(14,2);
   DEFINE g_sistema        	CHAR(2);
   DEFINE SaldoCom         	MONEY(14,2);
   DEFINE MtoCgo		   	MONEY(14,2);
   DEFINE MtoCom		   	MONEY(12,2);
   DEFINE vIva		       	MONEY(14,2);
   DEFINE cFolio           	CHAR(16);
   DEFINE v_tipocambio     	DECIMAL(14,6);
   DEFINE v_dv             	CHAR(2);
   DEFINE v_fecha_hoy      	DATE;
   DEFINE pReferencia      	CHAR(40);
   DEFINE  vsdo_ant        	DECIMAL(18,2);
   DEFINE  vcomision       	DECIMAL(18,2);
   DEFINE  viva_com        	DECIMAL(18,2);
   DEFINE  vint_mora       	DECIMAL(18,2);
   DEFINE  viva_int_mora   	DECIMAL(18,2);
   DEFINE  vint_vdo        	DECIMAL(18,2);
   DEFINE  viva_int_vdo    	DECIMAL(18,2);
   DEFINE  vint_ordi       	DECIMAL(18,2);
   DEFINE  viva_int_ordi   	DECIMAL(18,2);
   DEFINE  vcapital        	DECIMAL(18,2);
   DEFINE  vmonto_pago     	DECIMAL(18,2);
   DEFINE  vcuenta_eje     	CHAR(20);
   DEFINE  vsdo_act        	DECIMAL(18,2);
   DEFINE  vpago_min       	DECIMAL(18,2);
   DEFINE  vfecha_limite_pago CHAR(17);
   DEFINE v_val            	DECIMAL(18,2);
   DEFINE v_val1           	CHAR(20);
   DEFINE v_val2           	CHAR(17);
   DEFINE v_val3           	DECIMAL(18,2);
   DEFINE pReferencia23    	CHAR(23);
   DEFINE pRfcComer   		VARCHAR(20);
   DEFINE sSecuenciaTdc		SMALLINT;
   DEFINE cTransacc_Aux		CHAR(4);
   DEFINE cPrefijoCred		CHAR(2);
   DEFINE cNum_Producto		CHAR(4);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet,Mensaje ;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;


   LET CodRet                = "000000";
   LET sql_err               = 0;
   LET isam_err              = 0;
   LET error_info            = "";
   LET nRows                 = 0;
   LET Mensaje               = "Transaccion Exitosa";
   LET wBegin                = "";
   LET pFecha                = "";

   LET g_Remanente		= p_Monto;
   LET g_IntMoraCob		= 0;
   LET g_IntVencCob		= 0;
   LET g_IntVigCob		= 0;
   LET g_CapVigCob		= 0;
   LET g_Seguro         = 0;
   LET g_Comision		= 0;
   LET g_sistema        = "06";
   LET SaldoCom         = 0;
   LET MtoCgo	        = 0;
   LET MtoCom	        = 0;
   LET vIva             = 0;
   LET wBegin           = "N";
   LET cFolio           = "";
   LET v_tipocambio     = 0;
   LET v_dv             = "";
   LET v_fecha_hoy      = DATE(1);
   LET pReferencia      = "";
   LET  vsdo_ant        = 0;
   LET  vcomision       = 0;
   LET  viva_com        = 0;
   LET  vint_mora       = 0;
   LET  viva_int_mora   = 0;
   LET  vint_vdo        = 0;
   LET  viva_int_vdo    = 0;
   LET  vint_ordi       = 0;
   LET  viva_int_ordi   = 0;
   LET  vcapital        = 0;
   LET  vmonto_pago     = 0;
   LET  vcuenta_eje     = "";
   LET  vsdo_act        = 0;
   LET  vpago_min       = 0;
   LET  vfecha_limite_pago = "";
   LET v_val1           = '';
   LET v_val2           = '';
   LET v_val3           = 0;
   LET pReferencia23    = '';
   LET pRfcComer		= '';
   LET sSecuenciaTdc	= 0;
   LET cTransacc_Aux	= '';
   LET cPrefijoCred		= '';
   LET cNum_Producto	= '';

  --SET DEBUG FILE TO "/tmp/sp_cargo_abono_palzo.out";
  --TRACE ON;
  
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;

        SELECT fecha_hoy,
		case when p_Operacion = 1 then USER 		
		when p_Operacion = 3 then 'cobroant' 
		else 'cobroapp' end
               ||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
               ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
               ||SUBSTR(CURRENT,18,2)
          INTO v_fecha_hoy, cFolio
          FROM "informix".sd_fechas a
         WHERE a.empresa = p_Empresa;


        SELECT valor INTO v_dv FROM bdinteg:"informix".si_param WHERE cod_param = 17; -- divisa de cambio

		SELECT precio_venta INTO v_tipocambio
          FROM bdinteg:"informix".si_tpcambio
		 WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
					   FROM bdinteg:"informix".si_tpcambio
					  WHERE empresa = p_Empresa
					    AND divisa = v_dv);
	

    IF p_Operacion = 1 THEN  -- CARGO A TDC

        IF p_Tarjeta is null OR p_Tarjeta = '' THEN
		
			SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
			 WHERE empresa = p_Empresa AND num_credito = p_NumCredito 
			   AND tipo_tarjeta = 'T' AND status_tar = 'A';

            SELECT first 1 num_tarjeta INTO p_Tarjeta
              FROM "informix".sd_tarjeta
             WHERE empresa = p_Empresa
               AND num_credito = p_NumCredito
               AND tipo_tarjeta = "T"
               AND status_tar = "A"
			   AND secuencia = sSecuenciaTdc;
			   
			-- Obtiene numero de producto del credito crd
			LET cPrefijoCred = SUBSTR(p_referencia,1,2);
			SELECT num_producto INTO cNum_Producto FROM bdisolic:ss_solic_producto WHERE prefijo_sol = cPrefijoCred;
			   
			   
            SELECT to_char(fecha, '%d-%b-%y'), 'Cargo ' ||round(( v_fecha_hoy -  fecha   )/30,0) || ' de '|| plazo
			        into  pReferencia23, pRfcComer
              from bdicred:sd_promocion_credito
             where empresa =  p_Empresa
               and num_sol_prestamo  = p_referencia
               --and num_pro_prestamo = '6900'
			   and num_pro_prestamo = cNum_Producto
               and num_credito = p_NumCredito;
          END IF;
          let pReferencia = p_referencia;
          CALL cargo_cred(p_Empresa,p_NumCredito,p_Sucursal,p_Usuario,p_Transacc, p_Monto,cFolio, p_Tarjeta,0, v_tipocambio,v_fecha_hoy,  pReferencia, pRfcComer, pReferencia23)
                RETURNING CodRet;

          IF(CodRet <> "000") THEN
             ROLLBACK WORK;
             -- IF (wBegin = "S") THEN
                 BEGIN WORK;
             -- END IF;
          ELSE
             LET CodRet = "000000";
          END IF;


    ELIF p_Operacion = 2 THEN --     ABONO

           CALL sp_principal_pp(p_Empresa, p_NumCredito, 1, p_Monto, 'informix', '9290', cFolio, p_Transacc)
--           CALL sp_principal_pp(p_Empresa, p_NumCredito, 1, p_Monto, 'informix', '9290', cFolio, '4230')
--           CALL sp_principal_pp(p_Empresa, p_NumCredito, 1, p_Monto, 'informix', '9290', cFolio, '7506')
           RETURNING CodRet,Mensaje,vsdo_ant,vcomision,viva_com,vint_mora, viva_int_mora, vint_vdo, viva_int_vdo, vint_ordi, viva_int_ordi, vcapital,
                     vmonto_pago,vcuenta_eje, vsdo_act, vpago_min, vfecha_limite_pago;

          IF(CodRet <> "00000") THEN
             ROLLBACK WORK;
             --IF (wBegin = "S") THEN
                 BEGIN WORK;
             --END IF;
          ELSE
             LET CodRet = "000000";
          END IF;

    ELIF p_Operacion = 3 THEN --     PAGO ANTICIPADO
	
		-- Obtiene numero de producto del credito crd
		LET cPrefijoCred = SUBSTR(p_NumCredito,1,2);
		SELECT num_producto INTO cNum_Producto FROM bdisolic:ss_solic_producto WHERE prefijo_sol = cPrefijoCred;

		IF cNum_Producto = '6900' THEN		-- Pago Credisoluciones
			LET cTransacc_Aux = '4210';				
		ELSE
			LET cTransacc_Aux = p_Transacc;	-- Pago Msi
		END IF;
	
		--CALL sp_pago_anticipado_pp(p_Empresa, p_NumCredito, p_Usuario, p_Sucursal,cFolio, '4210', p_Monto, '1')
		--CALL sp_pago_anticipado_pp(p_Empresa, p_NumCredito, p_Usuario, p_Sucursal,cFolio, '4210', p_Monto, p_respaldo_crd)
		CALL sp_pago_anticipado_pp(p_Empresa, p_NumCredito, p_Usuario, p_Sucursal,cFolio, cTransacc_Aux, p_Monto, p_respaldo_crd)
				RETURNING CodRet,Mensaje,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;

          IF(CodRet <> "00000") THEN
             ROLLBACK WORK;
             --IF (wBegin = "S") THEN
                 BEGIN WORK;
             --END IF;
          ELSE
             LET CodRet = "000000";
          END IF;

   END IF

        IF p_Operacion = 1 THEN
            SELECT descripcion
              INTO Mensaje
              FROM bdinteg:si_codret
             WHERE sistema = g_sistema
               AND codigo_retorno = CodRet;
        END IF;

--           IF CodRet < 0 AND p_Operacion = 1 THEN
--               LET Mensaje = "Ocurrio un error en informix";
--           ELSE
--               COMMIT WORK;
--           END IF;

    IF CodRet <> "000000" THEN
        INSERT INTO bdicred:sd_bitacora_promocion VALUES('001',p_NumCredito,'sp_cargo_abono_palzo',TODAY,CURRENT,'',p_Operacion,CodRet);
    ELSE
       LET CodRet = "000000";
    END IF;

	COMMIT WORK;

	IF wBegin = "S" THEN
		BEGIN WORK;
	END IF;

   RETURN CodRet,Mensaje;

END PROCEDURE
DOCUMENT
'Programa de Cargos y Abonos para creditos a plazo',
'Es llamado desde el cierre de prestamo personal',
'Sistema Credito',
'AUTOR : Leonardo HernÃÂÃÂ¡ndez Moreno',
'FECHA : 06/Marzo/2012',
'VERSION: 1.0.0',
'---------------------------------------------------------',
'Folio: 1397',
'Autor: 94912599 - JOSUE ZAZUETA',
'Fecha: 27/12/2013',
'DescripciÃÂÃÂ³n: Se corrige el llamado al procedimiento sp_pago_anticipado_pp',
'ya que anteriormente se mandaba llamar con parametros erroneos',
'Sustento: RQM 10 214-4 Ademdum Credisoluciones Efec_Vf_cancela.doc',
'Solicita: Faviola Martinez Juarez',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_chi_cre_result_consulta_sic (
	p_cCodProc CHAR(1), p_iIdInicial INTEGER
) RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Isaac Flores Ruiz
	--Fecha de creación: 23/03/2021
	--Peticion: 
	-------------------------------------------------------------------------------------
	-- Peticion: Hipotecario Infonavit - Actualización a reporte de consulta sics y montos límites de créditos
	-- Modificado por: Miguel Alejandro Sánchez Mojica
	-- Fecha de modificación: 11/01/2022
	-- Modificación: Se modifica las consultas encargadas de extraer la información para los reportes y se agregan dos columnas a los reportes de resultotal
	-- BD: bdiburo
	-- ID Rational:
	-------------------------------------------------------------------------------------
	-- Peticion: Hipotecario Infonavit - 
	-- Modificado por: Isaac Flores Ruiz
	-- Fecha de modificación: 11/01/2022
	-- Modificación: 
	-- BD: bdicred
	-- ID Rational:
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
	DEFINE		sql_err					INTEGER;
	DEFINE		isam_err				INTEGER;
	DEFINE		error_info				CHAR(40);
	DEFINE		cod_ret					CHAR(6);
	DEFINE		mensaje_ret				VARCHAR(255);
	DEFINE		cod_ret_aux				CHAR(6);
	DEFINE		mensaje_ret_aux			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE		v_iid                   INTEGER;
	DEFINE		v_sind_validado         SMALLINT;
	DEFINE		v_sind_listas_negras    SMALLINT;
	DEFINE		v_cnombre_aux           CHAR(104);
	DEFINE		v_cnombre_completo      CHAR(104);
	DEFINE		v_capellido_p           CHAR(26);
	DEFINE		v_capellido_m           CHAR(26);
	DEFINE		v_cnombre1              CHAR(26);
	DEFINE		v_cnombre2              CHAR(26);
	DEFINE		v_cfecha_nac            CHAR(10);
	DEFINE		v_crfc                  CHAR(13);
	DEFINE		v_ccurp                 CHAR(18);
	DEFINE		v_ctipo_resi            CHAR(1);
	DEFINE		v_cedo_civil            CHAR(1);
	DEFINE		v_cgenero               CHAR(1);
	DEFINE		v_cnum_dep              CHAR(2);
	DEFINE		v_cdir1                 CHAR(40);
	DEFINE		v_cdir2                 CHAR(40);
	DEFINE		v_ccolonia              CHAR(40);
	DEFINE		v_cdelegacion           CHAR(40);
	DEFINE		v_cciudad               CHAR(40);
	DEFINE		v_cestado               CHAR(30);
	DEFINE		v_ccp                   CHAR(5);
	DEFINE		v_ctipo_dom             CHAR(1);
	DEFINE		v_cnum_credito          CHAR(25);
	DEFINE		v_cprod                 CHAR(4);
	DEFINE		v_cmonto_cred           MONEY(18, 2);
	DEFINE		v_cfecha_carga          DATE;
	DEFINE		v_cempresa              CHAR(3);
	DEFINE		v_sind_segnom_valido    CHAR(1);
	DEFINE		v_sind_fondeo_mont_prod CHAR(1);
	DEFINE		v_cclave_proc           CHAR(1);
	DEFINE		v_cclave_status         CHAR(1);
	DEFINE		v_sfondeo               SMALLINT;
	DEFINE		v_sclastat              SMALLINT;
	DEFINE		v_cmotivo               CHAR(30);
	DEFINE		v_cdescsta              CHAR(30);
	DEFINE		v_mop              		CHAR(2);
	DEFINE		v_rechazo_monto         INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE		cRuta					CHAR(100);
	DEFINE		cSQL					CHAR(1000);
	DEFINE		cDia					CHAR(2);
	DEFINE		cMes					CHAR(2);
	DEFINE		cYear					CHAR(4);
	DEFINE		cArchivoHito			CHAR(100);
	DEFINE		cArchivoUsr				CHAR(100);
	DEFINE		cArchivoRepHito			CHAR(100);
	DEFINE		cArchivoRepUsr			CHAR(100);
	DEFINE		cNombreArchivo			CHAR(100);
	DEFINE		cNombreArchivo2			CHAR(100);
	
	DEFINE 		vCodUdi       			CHAR(2);
	DEFINE 		vCodUs        			CHAR(2);
	DEFINE 		vclase        			CHAR(1);
	DEFINE 		vTpCambioUdi  			DECIMAL(14,6);
	DEFINE 		vTpCambioUs   			DECIMAL(14,6);
	DEFINE 		vMaxMtoUdi    			DECIMAL(14,2);
	DEFINE 		vFechaHoy     			DATE;
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET			sql_err					= 0;
	LET			isam_err				= 0;
	LET			cod_ret 				= '00000'; 
	LET			mensaje_ret 			= 'PROCESO EXITOSO';
	LET			cod_ret_aux 			= '00000'; 
	LET			mensaje_ret_aux 		= '';
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET			v_iid                   = 0;
	LET			v_sind_validado         = 0;
	LET			v_sind_listas_negras    = 0;
	LET			v_cnombre_aux           = '';
	LET			v_cnombre_completo      = '';
	LET			v_capellido_p           = '';
	LET			v_capellido_m           = '';
	LET			v_cnombre1              = '';
	LET			v_cnombre2              = '';
	LET			v_cfecha_nac            = '';
	LET			v_crfc                  = '';
	LET			v_ccurp                 = '';
	LET			v_ctipo_resi            = '';
	LET			v_cedo_civil            = '';
	LET			v_cgenero               = '';
	LET			v_cnum_dep              = '';
	LET			v_cdir1                 = '';
	LET			v_cdir2                 = '';
	LET			v_ccolonia              = '';
	LET			v_cdelegacion           = '';
	LET			v_cciudad               = '';
	LET			v_cestado               = '';
	LET			v_ccp                   = '';
	LET			v_ctipo_dom             = '';
	LET			v_cnum_credito          = '';
	LET			v_cprod                 = '';
	LET			v_cmonto_cred           = 0.0;
	LET			v_cempresa              = '001';
	LET			v_sind_segnom_valido    = '0';
	LET			v_sind_fondeo_mont_prod = '0';
	LET			v_cclave_proc           = '0';
	LET			v_cclave_status         = '0';
	LET			v_sfondeo               = 0;
	LET			v_sclastat              = 0;
	LET			v_cmotivo               = '';
	LET			v_cdescsta              = '';
	
	LET 		vCodUdi       			= '0';
	LET 		vCodUs        			= '0';
	LET 		vTpCambioUdi  			= 0.0;
	LET 		vTpCambioUs   			= 0.0;
	LET 		vMaxMtoUdi    			= 0.0;
	LET 		vFechaHoy     			= DATE(1);
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET			cRuta		 			= "/RESPALDOSNEW/hipotecario_infonavit/sics/";
	LET			cSQL					= "";
	LET			cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET			cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET			cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET			cArchivoHito			= "chi_cre_resultotal_consulta_sic_";
	LET			cArchivoUsr			    = "chi_cre_valiresult_consulta_sic_";
	LET			cArchivoRepHito			= "chi_cre_resultotal_reprocesa_consic_";
	LET			cArchivoRepUsr			= "chi_cre_valiresult_reprocesa_consic_";
	LET			cNombreArchivo			= "";
	LET			cNombreArchivo2			= "";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS O LONGITUDES';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-391) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'VERIFICAR CAMPOS, INSERCIÓN DE NULOS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-846) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '66666';		
				LET mensaje_ret = 'NÚMERO DE VALORES NO ES IGUAL AL NUMERO DE COLUMNAS';
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--*****************************************************************
		--*						Debug del Procedure                     --*        
		--*****************************************************************
		--SET DEBUG FILE TO '/RESPALDOSNEW/hipotecario_infonavit/sics/sp_chi_cre_result_consulta_sic.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
		SELECT LPAD(YEAR(fecha_hoy), 4, '0'), 
			LPAD(MONTH(fecha_hoy), 2, '0'), 
			LPAD(DAY(fecha_hoy), 2, '0')
			, fecha_hoy
		INTO cYear, cMes, cDia, vFechaHoy
		FROM bdicred:sd_fechas 
		WHERE empresa = v_cempresa;

			
-- ****************************************************************************
-- *                                TIPO DE DIVISA                            *
-- ****************************************************************************	
			SELECT TRIM(valor) 
				INTO vCodUdi
				FROM bdinteg:si_param
			WHERE empresa = v_cempresa
				AND cod_param = 16;

			SELECT TRIM(valor) 
				INTO vCodUs
				FROM bdinteg:si_param
			WHERE empresa = v_cempresa
				AND cod_param = 17;
			   
			SELECT TRIM(valor) 
			INTO vClase
			FROM bdicred:sd_param
			WHERE empresa = v_cempresa
				AND cod_param = '336';
		 
			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(v_cempresa, vFechaHoy,vCodUdi,vClase,'0')
			INTO cod_ret,vTpCambioUdi;

			IF cod_ret<>'00000' THEN
			  RETURN cod_ret;
			END IF;

			EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(v_cempresa, vFechaHoy,vCodUs,vClase,'1')
			INTO cod_ret,vTpCambioUs;

			IF cod_ret<>'00000' THEN
			  RETURN cod_ret;
			END IF;

			SELECT valor 
				INTO vMaxMtoUdi
				FROM bdisolic:ss_param
			WHERE empresa = v_cempresa
				AND secuencia = "309";
-- ****************************************************************************
-- *                       ARCHIVOS PROCESAMIENTO                             *
-- ****************************************************************************	
		IF p_ccodproc = 'P' THEN
			LET cNombreArchivo = TRIM(cArchivoHito) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2	MOP	RECHAZO POR MONTO' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			LET cNombreArchivo2 = TRIM(cArchivoUsr) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "ID REGISTRO	NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM cSQL;
-- ****************************************************************************
-- *                     GENERACIÓN DE REPORTE TOTAL                          *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT 		id, nombre, fecha_nacimiento, rfc, curp, tipo_residencia, 
							estado_civil, genero, numero_dependientes, direccion1, NVL(direccion2, ''), 
							colonia, NVL(delegacion, ''), ciudad, NVL(descripcion, ''), codigo_postal, 
							tipo_domicilio, num_credito, producto, monto_credito, NVL(apell_paterno, ''), 
							NVL(apell_materno, ''), nombre1, NVL(nombre2, '')
							,clave 
							,msn,
							NVL(MOP, ''), id_prod
				INTO 		v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
							v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
							v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
							v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, v_capellido_p, 
							v_capellido_m, v_cnombre1, v_cnombre2, v_sclastat, v_cmotivo,
							v_mop, v_rechazo_monto
				FROM 		(SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
								A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, A.direccion2, 
								A.colonia, A.delegacion, A.ciudad, C.descripcion, A.codigo_postal, 
								A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, A.apell_paterno, 
								A.apell_materno, A.nombre1, A.nombre2
								,(CASE 
											WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN '3'
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '1' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN '0'
											ELSE '0'
										END) AS clave
								,TRIM(CASE 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN TRIM(B.descripcion_status)
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN TRIM(B.descripcion_proceso)
											ELSE ''
											END) AS msn,
								D.MOP, (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END) AS id_prod
							FROM bdicred:"informix".sd_chi_cre_carga_consic_dia A
							INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
							LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
							LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito
										,MAX (DA.tl26) AS MOP 
										,MAX(DA.tl38) AS MOP_HISTORICO
										 FROM 		bdiburo:br_tl DA
										 INNER JOIN bdicred:sd_chi_cre_carga_consic_dia DB 
										 ON DB.num_credito = DA.num_cliente
										 AND DB.fecha_carga_sist = DA.fecha 
										 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
										 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
													OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
																WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(DA.tl24, 0)) / vTpCambioUdi
																WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
																WHEN DA.tl08 = 'UD'                THEN NVL(DA.tl24, 0) 
																ELSE NVL(DA.tl24, 0)
															END, 2) 
														AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
													AND NVL(DA.tl26,'') <> ''
													AND DA.tl04 NOT IN (SELECT tl04 
																		FROM bdiburo:br_tl 
																		WHERE institucion = DA.institucion 
																			AND num_cliente = DA.num_cliente 
																			AND tl02='BANCOPPEL' 
																			AND tl30 = 'RV')
													AND DA.tl02 NOT IN (SELECT tipo_negocio
																		FROM bdisolic:ss_cat_tiponegocio_sic 
																		WHERE institucion = DA.institucion)
													AND DB.buro_status IN ('PRP', 'NPP')
										 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
							INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
							WHERE 		A.empresa = v_cempresa 
								AND (A.buro_status = 'PRP' 
									OR (A.buro_status = 'NPP' AND (A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3'))
							UNION
							SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
										A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, A.direccion2, 
										A.colonia, A.delegacion, A.ciudad, C.descripcion, A.codigo_postal, 
										A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, A.apell_paterno, 
										A.apell_materno, A.nombre1, A.nombre2
										,(CASE 
											WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
												THEN '3'
											WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
												THEN '1' 
											WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
												THEN '0'
											ELSE '0'
										END) AS clave
										,TRIM(CASE 
												WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
													THEN TRIM(B.descripcion_status)
												WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
													OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
													THEN '' 
												WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
														THEN TRIM(B.descripcion_proceso)
												ELSE ''
											END) AS msn,
										D.MOP, (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END) AS id_prod
							FROM 		bdicred:"informix".sd_chi_cre_carga_consic_hist A
							INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
							LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
							LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito, MAX (DA.tl26) AS MOP
										,MAX(DA.tl38) AS MOP_HISTORICO
										 FROM 		bdiburo:br_tl DA
										 INNER JOIN bdicred:sd_chi_cre_carga_consic_hist DB 
										 ON DB.num_credito = DA.num_cliente
										 AND DB.fecha_carga_sist = DA.fecha 
										 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
										 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
													OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
																WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(DA.tl24, 0)) / vTpCambioUdi
																WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
																WHEN DA.tl08 = 'UD'                THEN   NVL(DA.tl24, 0) 
																ELSE NVL(DA.tl24, 0)
															END, 2) 
														AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
													AND NVL(DA.tl26,'') <> ''
													AND DA.tl04 NOT IN (SELECT tl04 
																		FROM bdiburo:br_tl 
																		WHERE institucion = DA.institucion 
																			AND num_cliente = DA.num_cliente 
																			AND tl02='BANCOPPEL' 
																			AND tl30 = 'RV')
													AND DA.tl02 NOT IN (SELECT tipo_negocio
																		FROM bdisolic:ss_cat_tiponegocio_sic 
																		WHERE institucion = DA.institucion)
										 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
							INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
							WHERE 		A.empresa = v_cempresa 
								AND A.buro_status = ('PRP')
					)
				ORDER BY 	id
				
				LET cSQL = ' echo "' || 
					TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) || '	' ||
					v_mop || '	' || v_rechazo_monto ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				SYSTEM TRIM(cSQL);
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_dia 
				SET buro_status = 'PCP'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRP';
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
				SET buro_status = 'PCP'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRP';
			END FOREACH;
			
-- ****************************************************************************
-- *                   GENERACIÓN DE REPORTE NO PROCESADOS                    *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
					A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
					A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
					A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, 
					A.clave_status, B.descripcion_proceso, NVL(A.apell_paterno, ''), NVL(A.apell_materno, ''), A.nombre1, 
					NVL(A.nombre2, ''), B.descripcion_status
				INTO v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
					v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
					v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
					v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred,  
					v_sclastat, v_cmotivo, v_capellido_p, v_capellido_m, v_cnombre1, 
					v_cnombre2, v_cdescsta
				FROM bdicred:"informix".sd_chi_cre_carga_consic_dia A
				INNER JOIN bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa
					AND A.clave_proceso = B.clave_proceso
					AND A.clave_status = B.clave_status			
                LEFT JOIN bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa
                    AND A.estado = C.abrev_larga
				WHERE A.empresa = v_cempresa
					AND buro_status = 'NPP'
					AND A.clave_status = 3
				ORDER BY A.id
				
				LET cSQL = ' echo "' || 
					v_iid || '	' || TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || ' ' || TRIM(v_cdescsta) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
				SYSTEM TRIM(cSQL);
			END FOREACH;
		END IF;
		
-- ****************************************************************************
-- *                      ARCHIVOS REPROCESAMIENTO                            *
-- ****************************************************************************	
		IF p_ccodproc = 'R' THEN
			LET cNombreArchivo = TRIM(cArchivoRepHito) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2	MOP	RECHAZO POR MONTO' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo);
			SYSTEM cSQL;
			
			LET cNombreArchivo2 = TRIM(cArchivoRepUsr) || cYear || cMes || cDia || '.xls ';
			LET cSQL = ' echo "ID REGISTRO	NOMBRE	FECHA DE NACIMIENTO	RFC	CURP	TIPO DE RESIDENCIA	ESTADO CIVIL	GENERO	NUMERO DE DEPENDIENTES	DIRECCION1	DIRECCION2	COLONIA	DELEGACION	CIUDAD	ESTADO	CODIGO POSTAL	TIPO DOMICILIO	num_credito	PRODUCTO	MONTO CREDITO	FONDEO	MOTIVO	APELLIDO PATERNO	APELLIDO MATERNO 	NOMBRE1	NOMBRE2' ||
				"" || '">'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM TRIM(cSQL);
			
			LET cSQL = 'chmod 777 '|| TRIM(cRuta)|| TRIM(cNombreArchivo2);
			SYSTEM cSQL;
			
-- ****************************************************************************
-- *                     GENERACIÓN DE REPORTE TOTAL                          *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT 		A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
							A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
							A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
							A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, NVL(A.apell_paterno, ''), 
							NVL(A.apell_materno, ''), A.nombre1, NVL(A.nombre2, '')
							,(CASE 
								WHEN ((A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
									THEN '3'
								WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
										OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))
									THEN '1' 
								WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
									THEN '0'
								ELSE '0'
							END)
							,TRIM(CASE 
									WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3') 
										THEN TRIM(B.descripcion_status)
									WHEN (((A.clave_proceso = '2' OR A.clave_proceso = '3') AND (A.clave_status = '1' 
										OR (A.clave_status = 0 AND NVL(D.MOP_HISTORICO,'') <> '99' AND NVL(D.MOP,'') <> '99'))))	
										THEN '' 
									WHEN ((A.clave_proceso = '1' OR A.clave_proceso = '2') AND A.clave_status = '0') 
										THEN TRIM(B.descripcion_proceso)
									ELSE ''
									END)
							,NVL(D.MOP, ''), (CASE WHEN A.monto_credito >= E.monto_minimo AND A.monto_credito <= E.monto_maximo THEN 0 ELSE 1 END)
				INTO 		v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
							v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
							v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
							v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, v_capellido_p, 
							v_capellido_m, v_cnombre1, v_cnombre2, v_sclastat, v_cmotivo,
							v_mop, v_rechazo_monto
				FROM 		bdicred:"informix".sd_chi_cre_carga_consic_hist A
				INNER JOIN 	bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa AND A.clave_proceso = B.clave_proceso AND A.clave_status = B.clave_status			
                LEFT JOIN 	bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa AND A.estado = C.abrev_larga
				LEFT JOIN	(SELECT  	DA.num_cliente AS num_credito, MAX (DA.tl26) AS MOP 
							,MAX(DA.tl38) AS MOP_HISTORICO
							 FROM 		bdiburo:br_tl DA
							 INNER JOIN bdicred:sd_chi_cre_carga_consic_hist DB 
							 ON DB.num_credito = DA.num_cliente
							 AND (DB.fecha_carga_sist = DA.fecha OR DB.fecha_reproceso = DA.fecha)
							 INNER JOIN bdisolic:ss_circulo_frecpag DC ON DA.tl11 = DC.tipo
							 WHERE 		(DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 1) 
										OR ((SELECT valor FROM bdisolic:ss_param WHERE empresa = DC.empresa AND secuencia = '309') < ROUND(CASE 
													WHEN DA.tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(DA.tl24, 0)) / vTpCambioUdi
													WHEN DA.tl08 = 'US'                THEN ((NVL(DA.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
													WHEN DA.tl08 = 'UD'                THEN   NVL(DA.tl24, 0) 
													ELSE NVL(DA.tl24, 0)
												END, 2) 
											AND DA.tl26 in (SELECT codigo FROM bdiburo:br_tlmop WHERE status_cons = 3)))
										AND NVL(DA.tl26,'') <> ''
										AND DA.tl04 NOT IN (SELECT tl04 
															FROM bdiburo:br_tl 
															WHERE institucion = DA.institucion 
																AND num_cliente = DA.num_cliente 
																AND tl02='BANCOPPEL' 
																AND tl30 = 'RV')
										AND DA.tl02 NOT IN (SELECT tipo_negocio
															FROM bdisolic:ss_cat_tiponegocio_sic 
															WHERE institucion = DA.institucion)
										AND (DB.buro_status = 'PRR' 
											OR (DB.buro_status = 'NPR' AND (DB.clave_proceso = '2' OR DB.clave_proceso = '3') AND DB.clave_status = '3'))--DB.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
							 GROUP BY	DA.num_cliente) AS D ON A.num_credito = D.num_credito
				INNER JOIN	bdicred:"informix".sd_chi_cre_rango_monto_producto E ON A.empresa = E.empresa AND A.producto = E.producto
				WHERE 		A.empresa = v_cempresa 
					AND (A.buro_status = 'PRR' 
					OR (A.buro_status = 'NPR' AND (A.clave_proceso = '2' OR A.clave_proceso = '3') AND A.clave_status = '3')) --A.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
				ORDER BY 	A.id
				
				LET cSQL = ' echo "' || 
					TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					v_cmotivo || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) || '	' ||
					v_mop || '	' || v_rechazo_monto ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo);
				SYSTEM TRIM(cSQL);
				
				UPDATE bdicred:"informix".sd_chi_cre_carga_consic_hist 
				SET buro_status = 'PCR'
				WHERE id = v_iid 
					AND empresa = v_cempresa 
					AND num_credito = v_cnum_credito
					AND buro_status = 'PRR';
			END FOREACH;
			
-- ****************************************************************************
-- *                   GENERACIÓN DE REPORTE NO PROCESADOS                    *
-- ****************************************************************************	
			FOREACH WITH HOLD
				SELECT A.id, A.nombre, A.fecha_nacimiento, A.rfc, A.curp, A.tipo_residencia, 
					A.estado_civil, A.genero, A.numero_dependientes, A.direccion1, NVL(A.direccion2, ''), 
					A.colonia, NVL(A.delegacion, ''), A.ciudad, NVL(C.descripcion, ''), A.codigo_postal, 
					A.tipo_domicilio, A.num_credito, A.producto, A.monto_credito, 
					A.clave_status, B.descripcion_proceso, NVL(A.apell_paterno, ''), NVL(A.apell_materno, ''), A.nombre1, 
					NVL(A.nombre2, ''), B.descripcion_status
				INTO v_iid, v_cnombre_completo, v_cfecha_nac, v_crfc, v_ccurp, v_ctipo_resi, 
					v_cedo_civil, v_cgenero, v_cnum_dep, v_cdir1, v_cdir2, 
					v_ccolonia, v_cdelegacion, v_cciudad, v_cestado, v_ccp, 
					v_ctipo_dom, v_cnum_credito, v_cprod, v_cmonto_cred, 
					v_sclastat, v_cmotivo, v_capellido_p, v_capellido_m, v_cnombre1, 
					v_cnombre2, v_cdescsta
				FROM bdicred:"informix".sd_chi_cre_carga_consic_hist A
				INNER JOIN bdicred:"informix".sd_chi_cre_status_procesos_segsic B ON A.empresa = B.empresa
					AND A.clave_proceso = B.clave_proceso
					AND A.clave_status = B.clave_status			
                LEFT JOIN bdicred:"informix".sd_chi_cre_edos C ON A.empresa = C.empresa
                    AND A.estado = C.abrev_larga
				WHERE A.empresa = v_cempresa
					--AND A.id IN (SELECT id FROM bdicred:"informix".sd_chi_cre_carga_reproceso_consic)
					AND A.buro_status = 'NPR'
					AND A.clave_status = 3
				ORDER BY A.id
				
				LET cSQL = ' echo "' || 
					v_iid || '	' || TRIM(v_cnombre_completo) || '	' || v_cfecha_nac || '	' || v_crfc || '	' || v_ccurp || '	' || v_ctipo_resi || '	' || 
					v_cedo_civil || '	' || v_cgenero || '	' || v_cnum_dep || '	' || v_cdir1 || '	' || v_cdir2 || '	' || 
					v_ccolonia || '	' || v_cdelegacion || '	' || v_cciudad || '	' || v_cestado || '	' || '''' || v_ccp || '	' || 
					v_ctipo_dom || '	' || '''' || v_cnum_credito || '	' || v_cprod || '	' || TRIM(REPLACE(CAST(v_cmonto_cred AS CHAR(20)), '$', '')) || '	' || v_sclastat || '	' || 
					TRIM(v_cmotivo) || ' ' || TRIM(v_cdescsta) || '	' || TRIM(v_capellido_p) || '	' || TRIM(v_capellido_m) || '	' || TRIM(v_cnombre1) || '	' || TRIM(v_cnombre2) ||
					"" || '">>'||TRIM(cRuta)|| TRIM(cNombreArchivo2);
				SYSTEM TRIM(cSQL);
			END FOREACH;
		END IF;
		
		RETURN cod_ret;
	END
END PROCEDURE;