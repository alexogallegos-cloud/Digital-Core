CREATE PROCEDURE "informix".sp_cat_gen_info_admin(pTipo smallint, PMora smallint)
       RETURNING char(6), char(150);

--  execute procedure "informix".sp_cat_gen_info_admin(1, 1)
--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			  INTEGER;
DEFINE isam_err 		  INTEGER;
DEFINE error_info		  CHAR(150);
DEFINE cMensaje 		  CHAR(150);
DEFINE cMensajeTel 		  CHAR(150);
DEFINE cCod_ret           CHAR(6);
DEFINE vvccod_ret         CHAR(6);
DEFINE cExito             CHAR(6);
DEFINE cProceso           CHAR(30);
------------------------------------------------------------
DEFINE  vlCodigo          CHAR(5);
DEFINE  vlDecCodigo       CHAR(150);
------------------------------------------------------------
------------------------------------------------------------
DEFINE vempresa           CHAR(3);
DEFINE vnumcte            CHAR(20);
DEFINE vnum_credito       CHAR(20);
DEFINE vpagos_vencidos    INTEGER;
DEFINE vdia, vlMaxFecha	  DATE;
DEFINE vdia2              DATE;
DEFINE vhora			  CHAR(8);
DEFINE vsituacion_car     CHAR(10);
DEFINE vnum_producto      CHAR(4);
DEFINE vstatus_cred		  CHAR(2);
DEFINE vnum_prod		  CHAR(4);
DEFINE vfecha_ultimo_pago DATE;
DEFINE vmto_fin_ven_trasp DECIMAL(18,2);
DEFINE vnum_vencidos	  SMALLINT;
-------------------------------------------------------------
DEFINE vsituacion         CHAR(1);
DEFINE vcausa             SMALLINT;
DEFINE vinstruccion       CHAR(1);
DEFINE vkeys              INTEGER;
-------------------------------------------------------------
DEFINE vtcCod_ret		  CHAR(5);
DEFINE vfecha_hoy         DATE;
DEFINE vlTipoLogica            SMALLINT;
DEFINE vsituacionespecial       CHAR(1);  
define vfechas date;
DEFINE vbandera				CHAR(1);
DEFINE vBandera2			CHAR(1);

--SET DEBUG FILE TO '/ifxsif01/Felix/PruebaMarco/sp_cat_gen_info_admin.out';
--TRACE ON;

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';
LET cProceso      = '0001';
LET cExito        = '000000';
LET vempresa      = '001';
LET vkeys         = 0;
LET vtcCod_ret	  = '00000';
LET vnum_producto = '';
LET vstatus_cred  = '';
LET vnum_prod	  = '';
LET cMensajeTel   = '';
LET vfecha_hoy    = DATE(1);
let vlTipoLogica  = 0;
let vsituacionespecial      ='';
LET vbandera				= '';
LET vBandera2				= '';
LET vfecha_ultimo_pago		= DATE(1);
LET vmto_fin_ven_trasp		= 0;
LET vnum_vencidos			= 0;



BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err; 
		LET cMensaje = error_info;
	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
	            RETURNING vvcCod_ret;
	    RETURN cCod_ret, cMensaje;
    END EXCEPTION;
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	  
    SELECT valor_alfabetico
        INTO vsituacion_car
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = vempresa
        AND grupo_parametro= 'SIT_CARTER'
        AND num_parametro= 1
        AND tipo_campania= 1;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
	            RETURNING vvcCod_ret;

--    SELECT MAX(fecha_insert)
--        INTO vlMaxFecha 
--        FROM bdicobranza:cb_cat_directorio_cte 
--        WHERE empresa = vempresa 
--        AND tipo_cobranza ='A';

--    LET  vlMaxFecha =NVL(vlMaxFecha,TODAY);   

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
	
	select fecha_hoy 
	  into vfecha_hoy 
	  from bdicred:sd_fechas 
     where empresa = vempresa;

--temporal solo para pruebas
--let vfecha_hoy = mdy('11','20','2022');
--temporal solo para pruebas

/*	
	SELECT  d.numcte, d.num_credito, d.num_producto
            FROM bdicred:"informix".sd_maecred d
	        WHERE d.empresa = vempresa
	        AND d.status_cred IN ('BT','BA')
	        AND d.numcte not in ( select numcte 
                                   from bdicobranza:cb_cat_directorio_cte 
                                    where empresa = vempresa 
                                    and tipo_cobranza ='A' 
                                    and fecha_insert = vlMaxFecha  ) 
	into temp directorio_cte;
*/	

FOREACH WITH HOLD
	SELECT valor_alfabetico INTO vnum_prod
	FROM "informix".cb_param_campania 
	WHERE empresa = vempresa AND tipo_campania = 61
	AND grupo_parametro = 'A'
	AND valor_numerico = DAY(vfecha_hoy)

	IF vnum_prod IS NULL OR vnum_prod = '' THEN
		LET cCod_ret = '000123';
		LET cMensaje = 'PRODUCTO NO EXISTE';
		RETURN cCod_ret, cMensaje;
	END IF;

-- CREDITOS TRANSITORIOS
	SELECT a.numcte, a.num_credito, a.num_producto, a.status_cred, 2 meses_vencidos
	FROM bdicred:"informix".sd_maecred a
	INNER JOIN bdicred:"informix".sd_maesdos b ON (b.num_credito = a.num_credito AND NVL(b.monto_vencido + b.mto_venc_trasp,0) > 0)
	WHERE a.empresa = vempresa
	  AND a.status_cred IN ('BA','E1')
      AND a.campo_trab3 <> 'BAJA'
      AND a.num_producto = vnum_prod
	 into temp directorio_cte WITH NO LOG;

	FOREACH WITH HOLD
-- CREDITOS VIGENTES
		--SELECT {+INDEX (bdicred:"informix".sd_maecred maecred3)} a.numcte, a.num_credito, a.num_producto, a.status_cred, 1
		SELECT a.numcte, a.num_credito, a.num_producto, a.status_cred, 1
		INTO vnumcte, vnum_credito, vnum_producto, vstatus_cred, vpagos_vencidos
		FROM bdicred:"informix".sd_maecred a
		INNER JOIN bdicred:"informix".sd_maesdos b ON (b.num_credito = a.num_credito AND NVL(b.monto_vencido + b.mto_venc_trasp,0) = 0)
		WHERE a.empresa = vempresa
		  AND a.status_cred IN ('AA','E1')
		  AND a.campo_trab3 <> 'BAJA'
		  AND a.num_producto = vnum_prod
		  AND b.monto_financiado > 0

		BEGIN WORK;
			INSERT INTO directorio_cte
					(numcte, num_credito, num_producto, status_cred, meses_vencidos)
				VALUES(vnumcte, vnum_credito, vnum_producto, vstatus_cred, vpagos_vencidos);
		COMMIT WORK;
		
		LET vnumcte, vnum_credito, vnum_producto, vstatus_cred, vpagos_vencidos = '', '', '', '', 0;
	END FOREACH;

--CREDITOS VENCIDOS
	FOREACH WITH HOLD
		SELECT a.numcte, a.num_credito, a.num_producto, a.status_cred, c.fecha_ultimo_pago, c.num_vencidos, b.mto_fin_ven_trasp
		INTO vnumcte, vnum_credito, vnum_producto, vstatus_cred, vfecha_ultimo_pago, vnum_vencidos, vmto_fin_ven_trasp
		FROM bdicred:"informix".sd_maecred a,
			 bdicred:"informix".sd_maesdos b,
			 bdicred:sd_indicador_cred c
		WHERE a.empresa = vempresa
		  AND a.empresa = b.empresa
		  AND a.num_credito = b.num_credito
		  AND a.empresa = c.empresa
		  AND a.num_credito = c.num_credito
		  AND a.status_cred IN ('BT','E2','E3')
		  AND a.num_producto = vnum_prod
		  AND a.campo_trab3 <> 'BAJA'

		  IF vfecha_ultimo_pago = vfecha_hoy THEN
			LET vpagos_vencidos = vnum_vencidos + 1;
		  ELSE
			LET vpagos_vencidos = vmto_fin_ven_trasp + 1;
		  END IF;

		BEGIN WORK;
			INSERT INTO directorio_cte
					(numcte, num_credito, num_producto, status_cred, meses_vencidos)
				VALUES(vnumcte, vnum_credito, vnum_producto, vstatus_cred, vpagos_vencidos);
		COMMIT WORK;

		LET vnumcte, vnum_credito, vnum_producto, vstatus_cred, vpagos_vencidos, vfecha_ultimo_pago, vnum_vencidos, vmto_fin_ven_trasp = '', '', '', '', 0, DATE(1), 0, 0;
	END FOREACH;

	CREATE INDEX indx_directorio_cte ON directorio_cte(num_producto);
	UPDATE statistics medium FOR TABLE directorio_cte;


	FOREACH WITH HOLD
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
        SELECT numcte, num_credito, num_producto, meses_vencidos
            INTO vnumcte, vnum_credito, vnum_producto, vpagos_vencidos
	        FROM directorio_cte WHERE num_producto = vnum_prod
	        
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--        SELECT COUNT(num_credito)                                             -- Pagos Vencidos
--            INTO vpagos_vencidos
--		    FROM bdicred:"informix".sd_amortiza_credito
--		    WHERE empresa     = vempresa
--		    AND num_credito = vnum_credito
--		    AND capital_status IN ('2','7');

        IF ((vpagos_vencidos =PMora) AND (PTipo=1)) or (pTipo=0) THEN
				  -- LET vkeys = vkeys;
		      --           CONTINUE FOREACH;
		      --      END IF;

            LET vsituacion = NULL;
	        LET vcausa     = NULL;

            SELECT FIRST 1 situacion,  causa
                INTO    vsituacion, vcausa
	            FROM    bdisitesp:"informix".se_ctessitespcte
	            WHERE   numcte = vnumcte;

            LET vinstruccion = 1;
				      --No se tomaran en cuenta los clientes con situacion T y causa 1. RQM 09 217
            IF vsituacion='T' AND vcausa=1 THEN
						    CONTINUE FOREACH;
            ELSE
                IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN

                    SELECT FIRST 1 instruccion
                        INTO   vinstruccion
                        FROM   bdisitesp:"informix".se_situacionaccion
                        WHERE  situacion= vsituacion
                        AND    causa= vcausa
                        AND    idaccion = 9;
                        
                END IF;

               SELECT a.situacion
               INTO vsituacionespecial
               FROM bdisitesp:"informix".se_ctessitespcte a
               WHERE a.idmovto=(SELECT MAX(aux.idmovto)
                                  FROM bdisitesp:"informix".se_ctessitespcte aux
                                 WHERE aux.idmovto = aux.idmovto
                                   AND a.empresa   = aux.empresa
                                   AND a.numcte    = aux.numcte)
                 AND a.empresa   = vempresa
                 AND a.numcte    = vnumcte;

                IF vsituacionespecial IS NULL THEN LET vsituacionespecial = ''; END IF;

				SELECT limit 1 tipo_logica INTO vlTipoLogica 
				 FROM cb_cat_logicas
			  	WHERE tipo_cobranza ='A'
                  AND num_vencidos =vpagos_vencidos;

                IF vlTipoLogica >0 THEN 
					SELECT FIRST 1 '1'
					INTO vBandera2
					FROM "informix".cb_cat_situacion_esp
					WHERE tipo_cobranza = 'A'
					AND situacion = vsituacionespecial;

					IF ( vBandera2 = '' OR vBandera2 IS NULL ) THEN          
					  
						--IF (vinstruccion = 1) THEN
						IF (nvl(vinstruccion,'1') <> '0') THEN
							LET vkeys = NVL(vkeys,0) + 1;
							
							IF EXISTS (SELECT num_credito FROM bdicobranza:cb_cat_directorio_cte WHERE empresa = vempresa AND tipo_cobranza = 'A' AND fecha_insert = vfecha_hoy AND num_credito = vnum_credito) THEN
								LET cMensaje = "Credito Repetido: " || TRIM(vnum_credito);
								CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, cMensaje,'02' ) RETURNING vvcCod_ret;
								LET cMensaje = 'PROCESO EXITOSO';
								
							ELSE
								BEGIN WORK;
								INSERT INTO bdicobranza:"informix".cb_cat_directorio_cte
										(empresa, tipo_cobranza, numcte, fecha_insert, puntualidad, eficiencia, calificacion, pago_venc, prioridad,
										tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, num_credito, num_producto,
										digitos_selec)
									VALUES(vempresa, 'A', vnumcte, vfecha_hoy, '', 0, 0, vpagos_vencidos, 0, vlTipoLogica , vkeys, 0, user, 'AC', 0, vnum_credito, vnum_producto,
									substr(vnumcte,8,2));
	
									LET vbandera = '1';
								COMMIT WORK;
							END IF;
						END IF;
					END IF;
               END IF;
            END IF;
        END IF;	
    END FOREACH;

	DROP TABLE directorio_cte;

	IF vbandera = '1' THEN
		UPDATE bdicobranza:"informix".cb_param SET descripcion = 'S' WHERE empresa = vempresa AND valor = vnum_prod;
	ELSE
		UPDATE bdicobranza:"informix".cb_param SET descripcion = 'N' WHERE empresa = vempresa AND valor = vnum_prod;
	END IF;

	LET vbandera, vBandera2 = '', '';
	LET vnum_prod = '';
END FOREACH;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,'000000', 'INICIA PROCESO TIPO LOGICA','02' )
        --    RETURNING vvcCod_ret;
    --CALL bdicobranza:"informix".sp_cat_tipologicacte(vempresa,'A') returning vlCodigo, vlDecCodigo ;
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,vlCodigo, 'FINALIZA PROCESO TIPO LOGICA','02' )
      --      RETURNING vvcCod_ret;
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,'000000', 'INICIA PROCESO PRIORIDAD','02' )
      --      RETURNING vvcCod_ret;
    --CALL bdicobranza:"informix".sp_cat_prioridadcte('A') returning vlCodigo, vlDecCodigo;
    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,vlCodigo, 'FINALIZA PROCESO PRIORIDAD','02' )
      --      RETURNING vvcCod_ret;
	  
/*Se comenta porque pasan a ser opciones independientes para su ejecución
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '00000', 'INICIA PROCESO GENERACION DE TESTIGO','02')
            RETURNING vvcCod_ret;
	CALL bdicobranza:"informix".sp_cat_genera_testigo(vfecha_hoy, 'A') RETURNING vtcCod_ret;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, vtcCod_ret, 'FINALIZA PROCESO GENERACION DE TESTIGO','02')
            RETURNING vvcCod_ret;

    IF cCod_ret =cExito THEN

        CALL bdicobranza:sp_carga_telefonos('A') RETURNING vvcCod_ret, cMensajeTel;        

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,'', '','03' )
                RETURNING vvcCod_ret;

    ELSE*/--Se comenta porque pasan a ser opciones independientes para su ejecución


	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, cMensaje,'02' )
			RETURNING vvcCod_ret;
--    END IF;

    RETURN cCod_ret, cMensaje;

END;
END PROCEDURE                                   
DOCUMENT
'MODIFICA    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza para excluir los clientes que se encuentren con una situacion especial T y causa 1',
'FECHA       : 08 de junio de 2010',
'VERSION     : 20110608.1900',
'BD          : BDICOBRANZA',
'MODIFICACION: MACF',
'FECHA: 2022/12/13',
'DESCRIPCION: Se modifica para evitar cuentas duplicadas cuando se presente ya que son casos atípicos',
'VERSION:20221213.0700';

CREATE PROCEDURE "informix".sp_obtener_datos_cv(pEmpresa CHAR(3),pNumCte CHAR(10), pInicia SMALLINT)
RETURNING   CHAR(6)     AS cCodRetCV,
			CHAR(26) 	AS cApellidoCV,
			CHAR(3) 	AS cSecuenciaCV,
			CHAR(3) 	AS cContadorCV,
			CHAR(60)	AS cNomProductoCV,
			CHAR(20)	AS cNumCredTarCV,
			CHAR(1)		AS btnPagoCV,
			CHAR(1)		AS btnAceptarCV,
			CHAR(4)     AS cNumProductoCV,
			CHAR(3)		AS cTransacCV,
			CHAR(21)	AS cNoGenIntCV,
			CHAR(20)	AS cNumCreditoCV;

						
DEFINE cCodRet             	CHAR(6);
DEFINE iSqlErr             	INTEGER;
DEFINE iIsamErr            	INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodigoRetornoCS		CHAR(6);
DEFINE iConvenio			INTEGER;
DEFINE iRealizarConvenio	INTEGER;
DEFINE cActivo				CHAR(6);
DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPago		DATE;  
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
DEFINE dImpSdoTotalCS 		DECIMAL(18,2);
DEFINE dSaldoVencido		DECIMAL(18,2);
DEFINE cNumCredito 			CHAR(20);
DEFINE btnConvenio			CHAR(1);
DEFINE btnPago				CHAR(1);
DEFINE cCodRetCDG			CHAR(6);
DEFINE cMensajeCDG 			CHAR(80);
DEFINE cNumCredCDG 			CHAR(20);
DEFINE cNumCteCDG 			CHAR(20);
DEFINE cNomProductoCDG		CHAR(40);
DEFINE cNumTarjetaCDG    	CHAR(20);
DEFINE cNomCteCDG     		CHAR(150);
DEFINE iCOntador			INTEGER;
DEFINE cSecuencia			CHAR(3);
DEFINE cDesc1 				CHAR(10);
DEFINE cDesc2  				CHAR(60);
DEFINE cDesc3				CHAR(20);
DEFINE cDesc4 				CHAR(1);
DEFINE cDesc5 				CHAR(1);
DEFINE cDesc6 				CHAR(21);
DEFINE cNumProducto			CHAR(4);
DEFINE cProducto 			CHAR(4);
DEFINE cTransac				CHAR(3);
DEFINE cTransacCV			CHAR(3);
DEFINE iOrganizador			INTEGER;
DEFINE cApellidoPaterno		CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cNumCreditoCV		CHAR(20);
DEFINE dFecha_hoy           DATE;
DEFINE iMotivo              SMALLINT;
-----------------------------------------------------------

-- InicializaciÃÂÃÂ³n de variables
LET cCodRet                 = '000000';
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cErrorInfo 				= '';
LET cCodigoRetornoCS		= '';
LET iConvenio				= 0;
LET iRealizarConvenio		= 0;
LET cActivo					= '';
LET cMensajeRetornoCSG		= '';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPago			= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0	;
LET cSitEspCredCSG			= '';
LET dSaldoVencido			= 0;
LET dImpSdoTotalCS			= 0;
LET cNumCredito				= '';
LET btnConvenio				= '';
LET btnPago					= '';
LET cCodRetCDG				= '';
LET cMensajeCDG 			= '';
LET cNumCredCDG 		 	= '';
LET cNumCteCDG 				= '';
LET cNomProductoCDG			= '';
LET cNumTarjetaCDG   		= '';
LET cNomCteCDG     			= '';
LET iContador				= 0;
LET cSecuencia				= '';
LET cDesc1 					= '';
LET cDesc2  				= '';
LET cDesc3					= '';
LET cDesc4 					= '';
LET cDesc5 					= '';
LET cDesc6  				= '';
LET cNumProducto			= '';
LET cProducto				= '';
LET cTransac				= '';
LET cTransacCV				= '';
LET iOrganizador			= 0;
LET cApellidoPaterno		= '';
LET cApellPat				= '';
LET cNumCreditoCV			= '';
LET dFecha_hoy              = DATE(1);
LET iMotivo                 = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	BEGIN	
		

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo		
			  LET cCodRet = iSqlErr;			   
			  RETURN cCodRet,'','','','','','','','','','','';
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/home/sysifx/Lerma/log_sp_obtener_datos_cv.sql'; 		
		--SET DEBUG FILE TO '/ifxsif01/macf/sp_obtener_datos_cv.out'; 		
		--TRACE ON;
		
		SELECT fecha_hoy INTO dFecha_hoy
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;
		
		IF pEmpresa <> "" AND pNumCte <> "" THEN
		
			SELECT apell_paterno 
			INTO cApellidoPaterno
			FROM bdinteg:"informix".si_cliente 			
			WHERE empresa = pEmpresa AND numcte = pNumCte;
				--AAME RMQ 10 1177 Se agregan los nuevos prestamos para los convenios de cobranza('9100','9300','8600')
				FOREACH	
					SELECT SKIP pInicia a.num_credito, a.num_producto, (CASE WHEN a.num_producto IN ('6001', '6600', '7000', '8100', '8500') THEN  '600' 
														  --WHEN num_producto IN ('6011', '6400', '6300', '7600', '7700', '6800') THEN  '611' 
														  ELSE '' 
													 END)
					FROM  bdicred:"informix".sd_maecred a, bdicred:sd_maesdos b
					WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito AND a.numcte = pNumCte AND b.monto_financiado > 0
					UNION ALL
					SELECT a.num_credito, a.num_producto, (CASE WHEN a.num_producto IN ('6011', '6400', '6300', '7600', '7700', '6800','9100','9300','8600') THEN  '611' 
														  --WHEN num_producto IN ('6001', '6600', '7000', '8100', '8500') THEN  '600'
														  ELSE '' 
													 END)
					INTO  cNumCredito, cNumProducto, cTransac	
					FROM  bdicred:"informix".sd_maecredcrd a, bdicred:sd_maesdoscrd b
					WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito 
					AND a.numcte = pNumCte AND b.monto_financiado > 0 
					
					LET cCodRet = '000000';				
					
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',cNumCredito,'','','','')
					INTO cCodRetCDG,cMensajeCDG,cNumCredCDG,cNumCteCDG,cNomProductoCDG,cNumTarjetaCDG,cNomCteCDG;
					IF cCodRetCDG::INTEGER <> 0 THEN
						LET cCodRet = '00002';
					END IF;				
					
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, cNumCredito)
						INTO cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPago,
						dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
						dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
						dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
						dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
						cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
						iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
				
					EXECUTE PROCEDURE bdicred: "informix".sp_consulta_saldocortemin(pEmpresa,cNumCredito, 0)
					INTO cCodigoRetornoCS,dImpSdoTotalCS;

					--LET dSaldoVencido = dSdoActTotalCapCSG + dCapTransCSG + dIntMoratoriosCSG + dIvaIntMoratoriosCSG + dIntVdoCSG + dIvaIntVdoCSG;
					LET dSaldoVencido = dCapTransCSG + dCapVdoExigCSG + dIntMoratoriosCSG + dIvaIntMoratoriosCSG + dIntVdoCSG + dIvaIntVdoCSG;
					
					SELECT LIMIT 1 activo
					  INTO cActivo
					  FROM "informix".cb_compac 
					 WHERE numcuenta = cNumCredito
					   AND activo <> '0';

					LET iConvenio = dbinfo("sqlca.sqlerrd2");
					
					----2020-05-15 MACF Obtener motivo de rechazo si hay
					SELECT LIMIT 1 motivo INTO iMotivo 
					  FROM bdicobranza:cb_compac_bit_realiza
                     WHERE empresa = pEmpresa AND numcuenta = cNumCredito AND fh_movimiento = dFecha_hoy
                       AND negociar_convenio in('N','NT');
					
                    LET iMotivo = dbinfo("sqlca.sqlerrd2");					

					SELECT CASE WHEN realizar_convenio = 'S' THEN 1 ELSE 0 END
						INTO iRealizarConvenio
					FROM bdicred:"informix".sd_definicion 
					WHERE empresa = pEmpresa 
					AND  num_producto = cNumProducto;
					
					--IF iConvenio = 0 AND iRealizarConvenio = 1 THEN
					IF iConvenio = 0 AND iRealizarConvenio = 1 AND iMotivo <= 0 THEN
						LET btnConvenio = '1';
					--ELIF iConvenio > 0 THEN
					ELIF iConvenio > 0 OR iMotivo > 0 THEN	
						LET btnConvenio = '0';
						LET cCodRet = '000004';
					ELIF iRealizarConvenio = 0 THEN
						LET btnConvenio = '0';
					END IF;
					
					LET btnPago = '1';
					
					IF cCodRet = '000000' THEN
						IF TRIM(cTransac) = "" THEN
							LET cCodRet = '000002';
						ELIF dSaldoVencido <= 0 THEN
							LET cCodRet = '000003';
						ELIF dPagosVdosCSG > 0 THEN
							LET cCodRet = '000000';
						ELIF cTransac = '600' THEN
							LET btnConvenio = '0';
							LET cCodRet = '000001';
						ELSE
							LET cCodRet = '000003';
						END IF;
					END IF;
									
					
					WHILE (iContador < 6) LOOP
						IF iContador = 0 THEN
							LET cApellPat = cApellidoPaterno;
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = cNomProductoCDG;
							IF cTransac = '600' THEN
								LET cDesc3 = cNumTarjetaCDG;
							ELSE 
								LET cDesc3 = cNumCredito;
							END IF;						
							LET cDesc4 = btnPago;
							LET cDesc5 = btnConvenio;
							LET cDesc6  = dImpSdoTotalCS;
							LET cProducto =  cNumProducto;
							LET cTransacCV = cTransac;
							LET cNumCreditoCV = cNumCredito;
							LET iContador = iContador + 1;
						ELIF iContador = 1 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							IF cTransac = '600' THEN
								LET cDesc2 = 'El pago minimo es de';
							ELSE 
								LET cDesc2 = 'La mensualidad de su prestamo es de';
							END IF;							
							
							LET cDesc3 = dPagoMinimoCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;					
						ELIF iContador = 2 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Pago(s) vencido(s)';
							LET cDesc3 = dPagosVdosCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;	
						ELIF iContador = 3 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Saldo vencido';
							LET cDesc3 = dSaldoVencido;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;
						ELIF iContador = 4 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'El pago total es de ';
							LET cDesc3 = dTotalLiquidacionCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;
						ELIF iContador = 5 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Fecha limite de pago';
							IF cCodRet = '000000' THEN
								LET cDesc3 = 'DE INMEDIATO';
							ELSE 
								LET cDesc3 = dFechaProxPago;
							END IF;								
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;						
						END IF;	
					
					RETURN cCodRet,cApellPat,cSecuencia,cDesc1,cDesc2,cDesc3,cDesc4,cDesc5,cProducto,cTransacCV,cDesc6, cNumCreditoCV WITH RESUME;
					END LOOP;
					LET iContador = 0;	
					LET iOrganizador = iOrganizador + 1;
				END FOREACH;
		ELSE
			LET cCodRet = '000002';
			RETURN cCodRet,cApellPat,cSecuencia,cDesc1,cDesc2,cDesc3,cDesc4,cDesc5,cProducto,cTransacCV,cDesc6, cNumCreditoCV;
		END IF;
	END; 

END PROCEDURE
DOCUMENT
'Folio: 587',
'Autor:95572217 Omar Lerma',
'Fecha:19/07/2019',
'DESCRIPCION: Procedimineto que consulta cuentas vencidas',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'Modifico: 97879606 Adrian Lizarraga',
'Fecha: 19/08/2019',
'DESCRIPCION: Se agrega al retorno del sp el numero de credito en las transaccionse 600 y 611',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_obtener_datos_cv_web(pEmpresa CHAR(3),pNumCte CHAR(10), pInicia SMALLINT)
RETURNING   CHAR(5)     AS cCodRetCV,
			CHAR(26) 	AS cApellidoCV,
			CHAR(3) 	AS cSecuenciaCV,
			CHAR(3) 	AS cContadorCV,
			CHAR(60)	AS cNomProductoCV,
			CHAR(20)	AS cNumCredTarCV,
			CHAR(1)		AS btnPagoCV,
			CHAR(1)		AS btnAceptarCV,
			CHAR(4)     AS cNumProductoCV,
			CHAR(3)		AS cTransacCV,
			CHAR(21)	AS cNoGenIntCV,
			CHAR(20)	AS cNumCreditoCV;

						
DEFINE cCodRet             	CHAR(5);
DEFINE iSqlErr             	INTEGER;
DEFINE iIsamErr            	INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodigoRetornoCS		CHAR(6);
DEFINE iConvenio			INTEGER;
DEFINE iRealizarConvenio	INTEGER;
DEFINE cActivo				CHAR(6);
DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPago		DATE;  
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
DEFINE dImpSdoTotalCS 		DECIMAL(18,2);
DEFINE dSaldoVencido		DECIMAL(18,2);
DEFINE cNumCredito 			CHAR(20);
DEFINE btnConvenio			CHAR(1);
DEFINE btnPago				CHAR(1);
DEFINE cCodRetCDG			CHAR(6);
DEFINE cMensajeCDG 			CHAR(80);
DEFINE cNumCredCDG 			CHAR(20);
DEFINE cNumCteCDG 			CHAR(20);
DEFINE cNomProductoCDG		CHAR(40);
DEFINE cNumTarjetaCDG    	CHAR(20);
DEFINE cNomCteCDG     		CHAR(150);
DEFINE iCOntador			INTEGER;
DEFINE cSecuencia			CHAR(3);
DEFINE cDesc1 				CHAR(10);
DEFINE cDesc2  				CHAR(60);
DEFINE cDesc3				CHAR(20);
DEFINE cDesc4 				CHAR(1);
DEFINE cDesc5 				CHAR(1);
DEFINE cDesc6 				CHAR(21);
DEFINE cNumProducto			CHAR(4);
DEFINE cProducto 			CHAR(4);
DEFINE cTransac				CHAR(3);
DEFINE cTransacCV			CHAR(3);
DEFINE iOrganizador			INTEGER;
DEFINE cApellidoPaterno		CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cNumCreditoCV		CHAR(20);
DEFINE dFecha_hoy           DATE;
DEFINE iMotivo              SMALLINT;
DEFINE vCredito1			INTEGER;
DEFINE vCredito2			INTEGER;
-----------------------------------------------------------

-- Inicializacion de variables
LET cCodRet                 = '00000';
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cErrorInfo 				= '';
LET cCodigoRetornoCS		= '';
LET iConvenio				= 0;
LET iRealizarConvenio		= 0;
LET cActivo					= '';
LET cMensajeRetornoCSG		= '';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPago			= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0	;
LET cSitEspCredCSG			= '';
LET dSaldoVencido			= 0;
LET dImpSdoTotalCS			= 0;
LET cNumCredito				= '';
LET btnConvenio				= '';
LET btnPago					= '';
LET cCodRetCDG				= '';
LET cMensajeCDG 			= '';
LET cNumCredCDG 		 	= '';
LET cNumCteCDG 				= '';
LET cNomProductoCDG			= '';
LET cNumTarjetaCDG   		= '';
LET cNomCteCDG     			= '';
LET iContador				= 0;
LET cSecuencia				= '';
LET cDesc1 					= '';
LET cDesc2  				= '';
LET cDesc3					= '';
LET cDesc4 					= '';
LET cDesc5 					= '';
LET cDesc6  				= '';
LET cNumProducto			= '';
LET cProducto				= '';
LET cTransac				= '';
LET cTransacCV				= '';
LET iOrganizador			= 0;
LET cApellidoPaterno		= '';
LET cApellPat				= '';
LET cNumCreditoCV			= '';
LET dFecha_hoy              = DATE(1);
LET iMotivo                 = 0;
LET vCredito1				= 0;
LET vCredito2				= 0;



	BEGIN	
		

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo		
			  LET cCodRet = iSqlErr;			   
			  RETURN cCodRet,'','','','','','','','','','','';
		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy INTO dFecha_hoy
		FROM bdicred:sd_fechas
		WHERE empresa = pEmpresa;
		
		IF pEmpresa <> "" AND pNumCte <> "" THEN
		
			SELECT apell_paterno 
			INTO cApellidoPaterno
			FROM bdinteg:"informix".si_cliente 			
			WHERE empresa = pEmpresa AND numcte = pNumCte;
			
			LET vCredito1 = (SELECT count(a.num_credito) FROM  bdicred:"informix".sd_maecred a, bdicred:sd_maesdos b WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito AND a.numcte = pNumCte AND b.monto_financiado > 0);
			LET vCredito2 = (SELECT count(a.num_credito) FROM  bdicred:"informix".sd_maecredcrd a, bdicred:sd_maesdoscrd b WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito AND a.numcte = pNumCte AND b.monto_financiado > 0);
			
			IF vCredito1 = 0 AND vCredito2 = 0 THEN 
				LET cCodRet = '00001';
				LET cDesc2 = 'Sin Datos';
				RETURN cCodRet,cApellPat,cSecuencia,cDesc1,cDesc2,cDesc3,cDesc4,cDesc5,cProducto,cTransacCV,cDesc6, cNumCreditoCV WITH RESUME;
			END IF;
				
				FOREACH	
					SELECT SKIP pInicia a.num_credito, a.num_producto, (CASE WHEN a.num_producto IN ('6001', '6600', '7000', '8100', '8500') THEN  '600' 
														  --WHEN num_producto IN ('6011', '6400', '6300', '7600', '7700', '6800') THEN  '611' 
														  ELSE '' 
													 END)
					FROM  bdicred:"informix".sd_maecred a, bdicred:sd_maesdos b
					WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito AND a.numcte = pNumCte AND b.monto_financiado > 0
					UNION ALL
					SELECT a.num_credito, a.num_producto, (CASE WHEN a.num_producto IN ('6011', '6400', '6300', '7600', '7700', '6800','9100','9300','8600') THEN  '611' 
														  --WHEN num_producto IN ('6001', '6600', '7000', '8100', '8500') THEN  '600'
														  ELSE '' 
													 END)
					INTO  cNumCredito, cNumProducto, cTransac	
					FROM  bdicred:"informix".sd_maecredcrd a, bdicred:sd_maesdoscrd b
					WHERE a.empresa = pEmpresa AND a.num_credito = b.num_credito 
					AND a.numcte = pNumCte AND b.monto_financiado > 0 
					
					LET cCodRet = '00000';				
					
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_datos_general(pEmpresa, '',cNumCredito,'','','','')
					INTO cCodRetCDG,cMensajeCDG,cNumCredCDG,cNumCteCDG,cNomProductoCDG,cNumTarjetaCDG,cNomCteCDG;
					IF cCodRetCDG::INTEGER <> 0 THEN
						LET cCodRet = '00002';
					END IF;				
					
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, cNumCredito)
						INTO cCodRet, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPago,
						dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
						dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
						dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
						dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
						cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
						iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
				
					EXECUTE PROCEDURE bdicred: "informix".sp_consulta_saldocortemin(pEmpresa,cNumCredito, 0)
					INTO cCodigoRetornoCS,dImpSdoTotalCS;

					--LET dSaldoVencido = dSdoActTotalCapCSG + dCapTransCSG + dIntMoratoriosCSG + dIvaIntMoratoriosCSG + dIntVdoCSG + dIvaIntVdoCSG;
					LET dSaldoVencido = dCapTransCSG + dCapVdoExigCSG + dIntMoratoriosCSG + dIvaIntMoratoriosCSG + dIntVdoCSG + dIvaIntVdoCSG;
					
					SELECT LIMIT 1 activo
					  INTO cActivo
					FROM "informix".cb_compac 
					WHERE numcuenta = cNumCredito
					   AND activo <> '0';

					LET iConvenio = dbinfo("sqlca.sqlerrd2");
					
					----2020-05-15 MACF Obtener motivo de rechazo si hay
					SELECT LIMIT 1 motivo INTO iMotivo 
					FROM bdicobranza:cb_compac_bit_realiza
                    WHERE empresa = pEmpresa AND numcuenta = cNumCredito AND fh_movimiento = dFecha_hoy
                       AND negociar_convenio in('N','NT');
					
                    LET iMotivo = dbinfo("sqlca.sqlerrd2");					

					SELECT CASE WHEN realizar_convenio = 'S' THEN 1 ELSE 0 END
						INTO iRealizarConvenio
					FROM bdicred:"informix".sd_definicion 
					WHERE empresa = pEmpresa 
					AND  num_producto = cNumProducto;
					
					--IF iConvenio = 0 AND iRealizarConvenio = 1 THEN
					IF iConvenio = 0 AND iRealizarConvenio = 1 AND iMotivo <= 0 THEN
						LET btnConvenio = '1';
					--ELIF iConvenio > 0 THEN
					ELIF iConvenio > 0 OR iMotivo > 0 THEN	
						LET btnConvenio = '0';
						LET cCodRet = '00004';
					ELIF iRealizarConvenio = 0 THEN
						LET btnConvenio = '0';
					END IF;
					
					LET btnPago = '1';
					
					IF cCodRet = '00000' THEN
						IF TRIM(cTransac) = "" THEN
							LET cCodRet = '00002';
						ELIF dSaldoVencido <= 0 THEN
							LET cCodRet = '00003';
						ELIF dPagosVdosCSG > 0 THEN
							LET cCodRet = '00000';
						ELIF cTransac = '600' THEN
							LET btnConvenio = '0';
							LET cCodRet = '00001';
						ELSE
							LET cCodRet = '00003';
						END IF;
					END IF;
									
					
					WHILE (iContador < 6) LOOP
						IF iContador = 0 THEN
							LET cApellPat = cApellidoPaterno;
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = cNomProductoCDG;
							IF cTransac = '600' THEN
								LET cDesc3 = cNumTarjetaCDG;
							ELSE 
								LET cDesc3 = cNumCredito;
							END IF;						
							LET cDesc4 = btnPago;
							LET cDesc5 = btnConvenio;
							LET cDesc6  = dImpSdoTotalCS;
							LET cProducto =  cNumProducto;
							LET cTransacCV = cTransac;
							LET cNumCreditoCV = cNumCredito;
							LET iContador = iContador + 1;
						ELIF iContador = 1 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							IF cTransac = '600' THEN
								LET cDesc2 = 'El pago minimo es de';
							ELSE 
								LET cDesc2 = 'La mensualidad de su prestamo es de';
							END IF;							
							
							LET cDesc3 = dPagoMinimoCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;					
						ELIF iContador = 2 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Pago(s) vencido(s)';
							LET cDesc3 = dPagosVdosCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;	
						ELIF iContador = 3 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Saldo vencido';
							LET cDesc3 = dSaldoVencido;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;
						ELIF iContador = 4 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'El pago total es de ';
							LET cDesc3 = dTotalLiquidacionCSG;
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;
						ELIF iContador = 5 THEN
							LET cApellPat = '';
							LET cSecuencia =  iOrganizador;
							LET cDesc1 = iContador;
							LET cDesc2 = 'Fecha limite de pago';
							IF cCodRet = '00000' THEN
								LET cDesc3 = 'DE INMEDIATO';
							ELSE 
								LET cDesc3 = dFechaProxPago;
							END IF;								
							LET cDesc4 = '';
							LET cDesc5 = '';
							LET cDesc6  = '';
							LET cProducto =  '';
							LET cTransacCV = '';
							LET cNumCreditoCV = '';
							LET iContador = iContador + 1;						
						END IF;	
					
					RETURN cCodRet,cApellPat,cSecuencia,cDesc1,cDesc2,cDesc3,cDesc4,cDesc5,cProducto,cTransacCV,cDesc6, cNumCreditoCV WITH RESUME;
					END LOOP;
					LET iContador = 0;	
					LET iOrganizador = iOrganizador + 1;
				END FOREACH;
		ELSE
			LET cCodRet = '00002';
			RETURN cCodRet,cApellPat,cSecuencia,cDesc1,cDesc2,cDesc3,cDesc4,cDesc5,cProducto,cTransacCV,cDesc6, cNumCreditoCV;
		END IF;
	END; 

END PROCEDURE
DOCUMENT
'Folio: 587',
'Autor:95572217 Omar Lerma',
'Fecha:19/07/2019',
'DESCRIPCION: Procedimineto que consulta cuentas vencidas',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'Modifico: 97879606 Adrian Lizarraga',
'Fecha: 19/08/2019',
'DESCRIPCION: Se agrega al retorno del sp el numero de credito en las transaccionse 600 y 611',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_archivo_compac(p_FechaIni DATE, p_FechaFin DATE)
RETURNING CHAR(6) AS cCod_Ret, CHAR(6) AS isam_cCodRet, CHAR(80) AS cMensajeRet;
/*______________________________________________________________________________________________________________________________________________________________________________________	
--Modificado por: Abrham Lopez L.
--Fecha: 08/12/2011
--Descripcion:Consulta para sacar convenios que se realizan el dÃ­a de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
--Base de Datos: BDCOBRANZA
_______________________________________________________________________________________________________________________________________________________________________________________*/
 
 
    DEFINE cCodRet 			CHAR(6);
	DEFINE isam_cCodRet 	CHAR(6);
	DEFINE cMensaje 		CHAR(80);
	DEFINE sql_err 			INTEGER;
	DEFINE isam_err 		INTEGER;
	DEFINE var_rga 			CHAR(05);
	DEFINE cNombreArchivo 	CHAR(100);
	DEFINE cMesAnio 		CHAR(4);
	DEFINE cEmpresa 		CHAR(3);		
	DEFINE cSql 			CHAR(1024);
	DEFINE p_FechaIni1 		DATE;
	DEFINE vRuta            CHAR(50);
	DEFINE vproceso         CHAR(4);
	DEFINE cCodRet_2        CHAR(6);
	
--DeclaraciÃ³n de variables 
DEFINE vFeccom DATE;
DEFINE vOrig SMALLINT;
DEFINE vEfecom INTEGER;
DEFINE vImport INTEGER;
DEFINE vEmp_Cap INTEGER;
DEFINE vSuc_P CHAR(4);
DEFINE vSuc_C CHAR(4);
DEFINE vPlazo CHAR(2);
DEFINE cSql1 CHAR(6204);
DEFINE cSql2 CHAR(6204);	
DEFINE cCod_Ret CHAR(6);
DEFINE vTip_com CHAR(1);
DEFINE vCliente CHAR(20);
DEFINE vNum_Prod CHAR(4);
DEFINE vNum_Tar CHAR(20);
DEFINE vNum_Cred CHAR(20);
DEFINE cMensajeRet CHAR(125);
DEFINE i_partnum INTEGER;
DEFINE v_folio_ultimo_pago CHAR(16);
DEFINE v_codigo_fun CHAR(3);

-- InicializaciÃ³n de Variables --

-- SET DEBUG FILE TO "/ifxsif01/macf/sp_archivo_compac.out";
--TRACE ON;

LET vFeccom = DATE(1);
LET p_FechaIni1 = DATE(1);
LET vOrig = 0;
LET vEfecom = 0;
LET vImport = 0;
LET sql_err = 0;
LET isam_err = 0;
LET vEmp_Cap = 0;
LET vSuc_P = '';
LET vSuc_C = '';
LET cSql = '';
LET vRuta = '';
LET vPlazo = '';
LET cCod_Ret = '';
LET vTip_com = '';
LET cMesAnio = '';
LET cEmpresa = '';		
LET vCliente = '';	
LET vNum_Tar = '';
LET cMensaje = '';
LET vNum_Prod = '';
LET vNum_Cred = '';	
LET cMensajeRet = '';
LET vproceso = '0297';
LET isam_cCodRet = '';
LET cNombreArchivo = '';
LET cCodRet_2 = '000000';
LET i_partnum = 0;
LET v_folio_ultimo_pago = '';
LET v_codigo_fun = '';


BEGIN
	ON EXCEPTION SET sql_err, isam_err, cMensaje
    	LET cCod_Ret = sql_err;
    	LET isam_cCodRet = isam_err;
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, cMensaje, '02') returning cCodRet_2;	 
		RETURN cCod_Ret, isam_cCodRet, cMensaje;
   	END EXCEPTION;
 		
   	LET cCod_Ret = "000000";
   	LET isam_cCodRet = "000000";
   	LET cEmpresa = "001";
   	LET cMensaje = "PROCESO CONCLUIDO EXITOSAMENTE";
    
	--Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, 'Inicia sp_archivo_compac', '02') returning cCodRet_2;

    SELECT max(partnum) INTO i_partnum FROM sysmaster:systabnames;
	
	IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE partnum BETWEEN 1 AND i_partnum AND tabname = 'cb_paso_compac'  AND dbsname = 'bdicobranza') THEN
       	DROP TABLE cb_paso_compac;
    END IF;
   
   	CREATE TABLE cb_paso_compac
	(
		numcte            CHAR(20),
		suc_pago          CHAR(4),
		num_tarjeta       CHAR(16),
		num_credito       CHAR(20),
		fecha_compac      DATE,
		efectuo_compac    INTEGER,
		importe           INTEGER,
		plazo             CHAR(2),
		tipo_compac       CHAR(1),
    	origen            SMALLINT,
 		suc_convenio      CHAR(4),
    	empleado_captura  INTEGER,
    	num_producto      CHAR(4)	
	);

   	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO vRuta
    FROM bdicobranza:"informix".cb_param_campania
    WHERE empresa = cEmpresa AND tipo_campania = 1
    AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 92;
    
	IF NVL (vRuta,'') = '' THEN     --Valida que exista la carpeta
        LET cCod_Ret = '104005';

        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, 'Ruta incorrecta - sp_archivo_compac', '02') RETURNING cCodRet_2;
        RETURN cCod_Ret, isam_cCodRet, cMensajeRet;
    END IF;

   	LET cMesAnio = LPAD(TRIM(DAY(p_FechaIni::DATE)::CHAR(2)),2,'0')||LPAD(TRIM(MONTH(p_FechaIni::DATE)::CHAR(2)),2,'0');
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, ' Obtiene inforcion de convenios revolventes TDC', '02') RETURNING cCodRet_2;
	
   	IF p_FechaIni = date(1) AND p_FechaFin = date(1) THEN
    	LET cCod_Ret = "000001";
    	LET cMensaje = "AMBAS FECHAS SON INVALIDAS";
   	ELSE
        IF p_FechaIni = date(1) THEN
    	    LET cCod_Ret = "000002";
    	    LET cMensaje = "FECHA INVALIDA";
        ELSE
            IF p_FechaIni != date(1) AND p_FechaFin != date(1) THEN
			--INSERT INTO bdicobranza:cb_paso_compac
				FOREACH WITH HOLD
					SELECT
					a.numcliente,
					--d.sucursal as Suc_Pago,
					b.num_tarjeta,
					b.num_credito,
					a.fecha_compac,
					a.efectuo_compac,
            	    a.importe::INTEGER,
					a.plazo,
					a.tipo_compac,
					a.origen,
					a.sucursal as Suc_Conv,
					a.empleado_captura,
					cr.num_producto
            	    INTO
				    vCliente, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod
            	    FROM bdicobranza:cb_compac a INNER JOIN bdicred:sd_maecred cr ON a.empresa = cr.empresa AND a.numcuenta = cr.num_credito  
            	    INNER JOIN bdicred:sd_tarjeta b ON a.empresa = b.empresa AND a.numcliente = b.numcte
													AND a.numcuenta = b.num_credito
													AND b.tipo_tarjeta = 'T'
													AND status_tar = 'A'
													AND b.secuencia = (SELECT max(tar.secuencia)
																	   FROM bdicred:sd_tarjeta tar
																	   WHERE tar.empresa = b.empresa 
																	   AND tar.numcte = b.numcte
																	   AND tar.num_credito = b.num_credito
																	   AND tar.tipo_tarjeta = 'T'
																	   AND tar.status_tar = 'A')
            	    /*INNER JOIN bdinteg:si_cliente c ON  a.numcliente = c.numcte
            	      LEFT JOIN bdicred:sd_movhis d ON a.empresa = d.empresa AND a.numcuenta = d.num_credito 
																		   AND codigo_fun in (SELECT
																							  cod_fun
																							  FROM bdicred:sd_conceptospagomanual
																							  WHERE codigo >= '')
																		   AND d.codigo_ref = 1
																		   AND d.secuencia IN (SELECT MAX(m.secuencia) 
																							   FROM bdicred:sd_movhis m 
																							   WHERE m.empresa = d.empresa --AND m.codigo_fun= "001" 
																							   AND m.codigo_fun IN (SELECT
																													cod_fun
																													FROM bdicred:sd_conceptospagomanual
																													WHERE codigo >= '')
																							   AND m.codigo_ref = 1 
																							   AND m.num_credito = d.num_credito) */
            	    WHERE a.empresa = cEmpresa 
				    AND a.origen <> 4
            	    AND a.fecha_compac >= p_FechaIni
					AND a.fecha_compac <= p_FechaFin

				    --GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ,11 , 12, 13;			
				    -- En lugar de buscar codigo_fun 001 y codigo_ref 1, usarÃ© la sd_conceptospagomanualcrd para obtener los pagos como normalmente se hace
				
				SELECT NVL(folio_ultimo_pago,'') INTO v_folio_ultimo_pago
                  FROM bdicred:sd_indicador_cred 
                 WHERE empresa = cEmpresa AND num_credito = vNum_Cred;
				
				SELECT limit 1 NVL(sucursal,'') INTO vSuc_P
				  FROM bdicred:sd_movhis
				 WHERE folio_suc = v_folio_ultimo_pago 
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual WHERE codigo >= '') 
				   AND codigo_ref = 1;
				  

				BEGIN;
				    INSERT INTO bdicobranza:cb_paso_compac
				    (numcte, suc_pago, num_tarjeta, num_credito, fecha_compac,	efectuo_compac, importe, plazo, tipo_compac, origen, suc_convenio, empleado_captura, num_producto)
				    VALUES(vCliente, vSuc_P, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod);
				COMMIT;
			 	    
			    END FOREACH;
				
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, 'Obtiene informacion de convenios revolventes TDC Histoirica', '02') RETURNING cCodRet_2;
				--Sacar convenios que se realizan el dÃ­a de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
				-- INSERT INTO bdicobranza:cb_paso_compac
				
				
				LET v_folio_ultimo_pago = '';
				--INSERT INTO bdicobranza:cb_paso_compac
				-- -- Se implementa Tercer foreach para complemento de tabla bdicobranza:cb_paso_compac
				FOREACH	WITH HOLD
					SELECT
					a.numcliente,
					--d.sucursal,
					'',
					a.numcuenta,
					a.fecha_compac,
					a.efectuo_compac,
                    a.importe::INTEGER,
					a.plazo,
					a.tipo_compac,
					a.origen,
					a.sucursal,
					a.empleado_captura,
					cr.num_producto
					INTO
				    vCliente, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod
					FROM bdicobranza:cb_compac a INNER JOIN bdicred:sd_maecredcrd cr ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
                    --INNER JOIN bdinteg:si_cliente c ON a.numcliente = c.numcte --LEFT JOIN bdicred:sd_movhiscrd d ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 

					WHERE a.empresa = "001" 
					AND a.origen <> 4
					AND a.fecha_compac >=  p_FechaIni
					AND a.fecha_compac <=  p_FechaFin
					-- GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13;
					

                 SELECT NVL(folio_ultimo_pago,'') INTO v_folio_ultimo_pago
                  FROM bdicred:sd_indicador_cred_crd 
                 WHERE empresa = cEmpresa AND num_credito = vNum_Cred;
				
				SELECT limit 1 NVL(sucursal,'') INTO vSuc_P
				  FROM bdicred:sd_movhiscrd
				 WHERE folio_suc = v_folio_ultimo_pago 
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd WHERE num_producto = vNum_Prod) 
				   AND codigo_ref = 1;

					
					BEGIN;
					INSERT INTO bdicobranza:cb_paso_compac
				    (numcte, suc_pago, num_tarjeta, num_credito, fecha_compac,	efectuo_compac, importe, plazo, tipo_compac, origen, suc_convenio, empleado_captura, num_producto)
				    VALUES(vCliente, vSuc_P, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod);
					COMMIT;
				END FOREACH;

				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, 'Obtiene informacion de convenios historicos de Plazo', '02') RETURNING cCodRet_2;

	
    	    END IF;
    	END IF;    
	END IF;

    let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba01.unl''' || ' DELIMITER ' || '''|'''  || 
                       ' SELECT * from bdicobranza:cb_paso_compac;'||
                       ' " > /resplogifx/archivoscartera/ArchivoCompAc.sql';     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/ArchivoCompAc.sql';
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba02.unl''' || ' DELIMITER ' || '''|'''  || 
                       '  SELECT count(*)::INTEGER, sum(importe::INTEGER) ' ||
                       '  FROM bdicobranza:cb_paso_compac ;'||
                       ' " > /resplogifx/archivoscartera/CifrasCompAc.sql';
     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/CifrasCompAc.sql';
             SYSTEM cSql;             
   

   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdos' ||  cMesAnio ||  YEAR(p_FechaIni::DATE)|| '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba01.unl > " || cNombreArchivo;
   SYSTEM cSql;

   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdosCifras' || cMesAnio || YEAR(p_FechaIni::DATE) || '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba02.unl > " || cNombreArchivo;
   SYSTEM cSql;

   let cSql = '';
   LET cSql = "rm /resplogifx/archivoscartera/prueba01.unl /resplogifx/archivoscartera/prueba02.unl /resplogifx/archivoscartera/ArchivoCompAc.sql /resplogifx/archivoscartera/CifrasCompAc.sql ";
   SYSTEM cSql;

   EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCod_Ret,cMensaje,'03')
                      INTO cCodRet_2;
   
   RETURN cCod_Ret,isam_cCodRet,cMensaje;

	
END;	
END PROCEDURE;