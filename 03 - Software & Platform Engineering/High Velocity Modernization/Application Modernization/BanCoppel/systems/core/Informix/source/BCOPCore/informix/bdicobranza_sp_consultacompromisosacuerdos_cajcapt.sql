CREATE PROCEDURE "informix".sp_consultacompromisosacuerdos_cajcapt( pEmpresa CHAR(3), pSucursal CHAR(4), pNumCte CHAR(20), pTipo CHAR(1))
RETURNING 	CHAR(6) AS Codret,
			CHAR(20) AS Numcredito,
			CHAR(40) AS Nombreprod,
			CHAR(2) AS Plazo,
			INTEGER AS Importe,
			DATE AS Fecha,
			SMALLINT AS Totalctas,
			SMALLINT AS Totalconv,
			CHAR(1) AS Tipo,
			CHAR(1) AS Activo,
			CHAR(1) AS Flagcompac,
			SMALLINT AS Origen,
			CHAR(13) AS TelefonoParticular,
			CHAR(13) AS TelefonoCelular,
			CHAR(100) AS CorreoElectronico;

--------------------------------------------------------------
--ACTIVIDAD: CONSULTA LA INFORMACION DE LOS CONVENIOS ACTIVOS
--POR DETERMINADO NUMERO DE CLIENTE.
--------------------------------------------------------------

--DEFINICION DE VARIABLES
DEFINE cCodret        				CHAR(6);
DEFINE cNumcredito    				CHAR(20);
DEFINE cPlazo         				CHAR(2);
DEFINE cNombreprod    				CHAR(40);
DEFINE cTipo          				CHAR(1);
DEFINE cActivo        				CHAR(1);
DEFINE cFlagcompac    				CHAR(1);
DEFINE cTelParticular 				CHAR(13);
DEFINE cTelCelular 					CHAR(13);
DEFINE cCorreoElectronico			CHAR(100);

DEFINE iImporte       INTEGER;
DEFINE iCodret        INTEGER;
DEFINE iCont1 		  INTEGER;
DEFINE iCont2 		  INTEGER;

DEFINE sFlag          SMALLINT;
DEFINE sTotalctas     SMALLINT;
DEFINE sTotalconv     SMALLINT;
DEFINE sOrigen        SMALLINT;
DEFINE sDiasplazo     SMALLINT;
DEFINE sDiasfecha     SMALLINT;
DEFINE sActivo        SMALLINT;

DEFINE dtFecha         DATE;

--INICIALIZACION DE VARIABLES
LET cCodret        = '000';
LET cNumcredito    = '';
LET cPlazo         = '';
LET cNombreprod    = '';
LET cTipo          = '';
LET cActivo        = '';
LET cFlagcompac    = '';
LET iImporte       = 0;
LET iCodret        = 0;
LET sFlag          = 0;
LET sTotalctas     = 0;
LET sTotalconv     = 0;
LET sOrigen        = 0;
LET sDiasplazo     = 0;
LET sDiasfecha     = 0;
LET sActivo        = 0;
LET iCont1 		   = 0;
LET iCont2		   = 0;
LET dtFecha		   = DATE(1);
LET cTelParticular = "";
LET cTelCelular    = "";
LET cCorreoElectronico = "";

--DEBUG FLAG
--SET debug file to "sp_consultacompromisosacuerdos_cajcapt.out";
--TRACE ON;

	
BEGIN

ON EXCEPTION SET iCodret
   IF iCodret <> 0 THEN
      LET cCodret = iCodret;
      RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,''));
   END IF;
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_cliente WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

    IF pTipo = '1' THEN
			-- IFRS Cambio por nuevos estatus de crÃÂ©dito 
	        SELECT COUNT(*) INTO sTotalctas FROM( SELECT  a.num_credito, a.numcte,a.empresa, a.num_producto 
									FROM bdicred:"informix".sd_maecred a
										INNER JOIN bdicred:"informix".sd_maesdos b on (a.num_credito = b.num_credito and (b.monto_vencido + b.mto_venc_trasp) > 0)
										WHERE a.empresa = pEmpresa AND a.status_cred in ('BA','BT','E1','E2','E3') AND a.numcte = pNumcte AND a.num_producto IN('6001','6600','7000','8100','8500')		     
								UNION ALL
								SELECT  a.num_credito,a.numcte,a.empresa, a.num_producto 
									FROM bdicred:"informix".sd_maecredcrd a
									     INNER JOIN bdicred:"informix".sd_maesdoscrd b on (a.num_credito = b.num_credito and (b.monto_vencido + b.mto_venc_trasp) > 0)
										WHERE a.empresa = pEmpresa AND a.status_cred in ('BA','BT','VP','E1','E2','E3') AND a.numcte = pNumcte AND a.num_producto in('6011','6300','6400','6800','7600','7700','9100','9300'))AS A
								LEFT JOIN bdicobranza:"informix".cb_compac cc on (cc.empresa = a.empresa and cc.numcliente = a.numcte and cc.numcuenta = a.num_credito)
									WHERE (cc.activo = 0 or cc.activo is null);

        IF sTotalctas <> 0 THEN
			
			SELECT COUNT(*) INTO sTotalconv FROM "informix".cb_compac
            WHERE empresa = pEmpresa AND numcliente = pNumCte;
			
            FOREACH
        ---- PENDIENTE MODIFICAR ESTE QUERY COMO EL DE ARRIBA        
		-- IFRS Cambio por nuevos estatus de crÃÂ©dito 
				SELECT creditos.num_credito, b.nombre_prod, tc.telefono as telefonocelular,tp.telefono as telefonoparticular,c.correo_elec 
				INTO cNumcredito, cNombreprod, cTelCelular,cTelParticular, cCorreoElectronico
				FROM( 	SELECT  a.num_credito, a.numcte,a.empresa, a.num_producto 
						FROM bdicred:"informix".sd_maecred a
							INNER JOIN bdicred:"informix".sd_maesdos b on (a.num_credito = b.num_credito and (b.monto_vencido + b.mto_venc_trasp) > 0)
							WHERE a.empresa = pEmpresa AND a.status_cred in ('BA','BT','E1','E2','E3') AND a.numcte = pNumCte AND a.num_producto IN('6001','6600','7000','8100','8500')  

							
					UNION ALL
						SELECT  a.num_credito,a.numcte,a.empresa, a.num_producto 
						FROM bdicred:"informix".sd_maecredcrd a
						     inner join bdicred:sd_maesdoscrd b on (a.num_credito = b.num_credito and (b.monto_vencido + b.mto_venc_trasp) > 0) 
							WHERE a.empresa = pEmpresa AND a.status_cred in ('BA','BT','VP','E1','E2','E3') AND a.numcte = pNumCte AND a.num_producto in('6011','6300','6400','6800','7600','7700','9100','9300') 
              )AS creditos
						INNER JOIN bdicred:"informix".sd_definicion b ON (b.empresa = creditos.empresa and  b.num_producto = creditos.num_producto)
						LEFT JOIN bdicobranza:"informix".cb_compac cc on (cc.empresa = b.empresa and cc.numcliente = creditos.numcte and cc.numcuenta = creditos.num_credito)
						LEFT JOIN bdinteg:"informix".si_correos c ON ( c.numcte = creditos.numcte AND c.secuencia = (SELECT MAX(secuencia)
																														FROM bdinteg:"informix".si_correos
																															WHERE numcte = c.numcte))
						LEFT JOIN bdinteg:"informix".si_telefonos_actual tc ON ( tc.numcte = creditos.numcte AND tc.tipo_tel ='2' AND tc.secuencia = (SELECT MAX(secuencia)
																																						FROM bdinteg:"informix".si_telefonos_actual
																																							WHERE numcte = tc.numcte AND tipo_tel ='2' ))
						LEFT JOIN bdinteg:"informix".si_telefonos_actual tp ON ( tp.numcte = creditos.numcte AND tp.tipo_tel ='1' AND tp.secuencia = (SELECT MAX(secuencia)
																																						FROM bdinteg:"informix".si_telefonos_actual
																																							WHERE numcte = tp.numcte AND tipo_tel ='1' )) 
				WHERE (cc.activo = 0 or cc.activo is null)

				
                    LET cPlazo = '';
                    LET iImporte = 0;
                    LET dtFecha = '01-01-1900';
                    LET cTipo = '';
                    LET cActivo = '';
                    LET cFlagcompac = '';
                    LET sOrigen = 0;

                RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), 
				NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), 
				TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,'')) WITH RESUME;

				
            END FOREACH;
        ELSE
            -- CLIENTE NO TIENE CUENTAS DE CREDITO
            LET cCodret = '002';
            RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,''));
        END IF;

    ELIF pTipo = '2' THEN

        SELECT COUNT(*) INTO sTotalctas
        FROM bdicred:"informix".sd_maecred
        WHERE empresa = pEmpresa AND status_cred <> 'CC' AND numcte = pNumCte;

        IF sTotalctas <> 0 THEN
		
            SELECT COUNT(*) INTO sTotalconv FROM "informix".cb_compac
            WHERE empresa = pEmpresa AND numcliente = pNumCte;

            FOREACH
                SELECT  a.num_credito, b.nombre_prod,
				SUM(CASE WHEN tipo_tel = 1 THEN 1 ELSE 0 END) AS sTelParticular,
				SUM(CASE WHEN tipo_tel = 2 THEN 1 ELSE 0 END) AS sTelCelular,
				c.correo_elec
				INTO cNumcredito, cNombreprod, iCont1, iCont2, cCorreoElectronico
                FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_definicion b ON (b.empresa = a.empresa and  b.num_producto = a.num_producto)
				LEFT JOIN bdinteg:"informix".si_correos c ON ( c.numcte = a.numcte AND c.secuencia = (SELECT MAX(secuencia)
																								FROM bdinteg:"informix".si_correos
																								WHERE numcte = pNumCte))
				LEFT JOIN bdinteg:"informix".si_telefonos_actual e ON ( e.numcte = a.numcte AND e.tipo_tel IN ('1','2'))
                WHERE a.empresa = pEmpresa AND a.status_cred <> 'CC' AND a.numcte = pNumCte
                GROUP BY a.num_credito, b.nombre_prod, c.correo_elec

                LET cPlazo = '';
                LET iImporte = 0;
                LET dtFecha = '01-01-1900';
                LET cTipo = '';
                LET cActivo = '';
                LET cFlagcompac = '';
                LET sOrigen = 0;

				IF iCont1 > 0 THEN
						SELECT telefono
						INTO cTelParticular
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = pNumCte
						AND tipo_tel = 01;
				END IF

				IF iCont2 > 0 THEN
						SELECT telefono
						INTO cTelCelular
						FROM bdinteg:"informix".si_telefonos_actual
						WHERE numcte = pNumCte
						AND tipo_tel = 02;
				END IF

                IF EXISTS ( SELECT numcuenta FROM "informix".cb_compac_his WHERE empresa = pEmpresa
                            AND numcliente = pNumCte AND numcuenta = cNumcredito ) THEN
                    LET sFlag = 1;

                    FOREACH
                        SELECT plazo, importe, fecha_compac, tipo_compac, activo, flag_pago, origen
                        INTO cPlazo, iImporte, dtFecha, cTipo, cActivo, cFlagcompac, sOrigen
                        FROM "informix".cb_compac_his
                        WHERE empresa = pEmpresa AND numcliente = pNumCte AND numcuenta = cNumcredito
                        ORDER BY fecha_compac

                        RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,'')) WITH RESUME;

                        LET cPlazo = '';
                        LET iImporte = 0;
                        LET dtFecha = '01-01-1900';
                        LET cTipo = '';
                        LET cActivo = '';
                        LET cFlagcompac = '';
                        LET sOrigen = 0;

                    END FOREACH;

                END IF;

            END FOREACH;

            IF sFlag = 0 THEN
                -- POR SI EL CLIENTE NO TIENE CONVENIOS EN NINGUNO DE SUS CREDITOS
                LET cCodret = '003';
                LET cNumcredito = '';
                LET cNombreprod = '';
                RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,''));
            END IF;
        ELSE
            -- CLIENTE NO TIENE CUENTAS DE CREDITO
            LET cCodret = '002';
            RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,''));
        END IF;
    END IF;
ELSE
    -- NO EXISTE NUMERO DE CLIENTE
    LET cCodret = '001';
    RETURN TRIM(NVL(cCodret,'')),TRIM(NVL(cNumcredito,'')),TRIM(NVL(cNombreprod,'')),TRIM(NVL(cPlazo,'')),NVL(iImporte, 0) , NVL(dtFecha,DATE(1)), NVL(sTotalctas, 0), NVL(sTotalconv, 0), TRIM(NVL(cTipo,'')), TRIM(NVL(cActivo,'')), TRIM(NVL(cFlagcompac,'')), NVL(sOrigen, 0), TRIM(NVL(cTelParticular,'')),TRIM(NVL(cTelCelular,'')) , TRIM(NVL(cCorreoElectronico,''));

END IF;

END

END PROCEDURE
DOCUMENT
'DESCRIPCION: SE ACTUALIZA PARA AGREGAR CAMPOS TELEFONO PARTICULAR, TELEFONO CELULAR Y CORREO ELECTRONICO.',
'AUTOR: HUGO VAZQUEZ ',
'FECHA DE CREACION: 09/10/2013',
'VERSION: 09102013.1026 .',
'BD:BDICOBRANZA',
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: RICARDO SANCHEZ',
'DESCRIPCION: SE MODIFICA SP PARA QUE MUESTRE SOLO CREDITOS DISPONIBLES A CONVENIAR CUANDO SU STATUS_CRED SEA (BA O BT) Y NO SE ENCUENTRE EN LA TABLA CB_COMPAC',
'FOLIO: 306-RQM 09 340 CONVENIOS DE PAGO COBRANZA CALLE PARA PP TODAS SUS MODALIDADES, CREDINOMINA Y NVOS PRODUCTOS',
'FECHA: 14/09/2017',
'BD:BDICOBRANZA';

CREATE PROCEDURE "informix".sp_registro_evaluacion_objetiva_crd(pEmpresa char(3), pFecha date)

RETURNING CHAR(6), char(80);
  -- Vers 1.0.1 20190912, 1.0.0 20190515
  define vcCodRet CHAR(5);
  define viSqlErr INTEGER;
  define vDataErr	      varchar(64);
  define vcEsTransaccion  CHAR(1);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(80);
  define vEmpresa         char(3);
  define vFechahoy        date;
  define vFechaDiaAnt     date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define vFechaMesAnterior date;
  define cNumCte_movs     char(20);
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dSuma_importe    decimal(18,2);
  define dSuma_importe_2  decimal(18,2);
  define dSuma_importe_his decimal(18,2);
  define dSuma_importe_total decimal(18,2);
  define dtFecha_convenio date;
  define cSucursal_pago   char(4);
  define cSucursal_pago_2 char(4);
  define vNum_credito_2   char(20);
  define iNum_pm_realizados    integer;
  define iNum_pm_no_realizados integer;
  define cCalificacion         char(1);
  define dTotal_importe        decimal(18,2);
  define dImp_pagado_acum      decimal(18,2); 
  define dFecha_vencim    date;
  define vPlazo           char(2);
  define iCteAsisteSuc    integer;
  define cOrigen          char(10);
  define psucursal        char(4);
  define pfechasistema    date;
  define pefectuo_compac  integer;
  define pnombre_efectuo  char(40);
  define pnumcuenta       char(20);
  define pnumproducto		char(4); 
  define pplazo           char(2);
  define porigen	        smallint;
  define ptipo_compac     char(1);
  define pimporte         decimal(18,2);
  define dImp_pagado      decimal(18,2);
  define cUsuario_pago    char(8);
  define cNomUsuario_pago char(45);
  define cCalificado      char(1);

  define dtFecha_ant      date;
  define dPago_minimo_guardado              DECIMAL(18,2);
  define dSaldo_vencido_guardado            DECIMAL(18,2);
  define dPago_minimo_recuperado_guardado   DECIMAL(18,2);
  define dSaldo_vencido_recuperado_guardado DECIMAL(18,2);
  
  define dtFecha_insert   date;
  define cSucursal        char(4);
  define cUsuario         char(8);
  define cNum_producto    char(4);
  define dPago_minimo     decimal(18,2);
  define dPago_realizado  decimal(18,2);
  define dPct_cump_pm     decimal(8,2);   
  define dPct_cump_sv     decimal(8,2);
  define iNum_pago_completo_pm  integer;
  define iNum_pago_parcial_pm   integer;
  define dMonto_vencido   decimal(18,2);
  define iNum_pago_completo_sv  integer;
  define iNum_pago_parcial_sv   integer;
  define dPct_rec_cartera    decimal(8,2);
  define cSucursal_origen    char(4);  
  define cNombre_cajero      char(45);
  define cNum_credito_evobj  char(20);
  define dPct_cump_pm_new    decimal(18,2);
  define dPct_cump_sv_new    decimal(18,2);
  define dPago_realizado_sv  decimal(18,2);
  define dtFecha_insert_guardada   date;
  
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';	  
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let vFechaDiaAnt      = date(1);
  let cNumCte           = '';
  let cProceso          = '0084';
  let cCod_ret_2        = '';
  let vFechaMesAnterior = date(1);
  let cNumCte_movs      = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dSuma_importe     = 0;
  let dSuma_importe_2   = 0;
  let dSuma_importe_his = 0;
  let dSuma_importe_total = 0; 
  
  let dtFecha_convenio  = date(1);
  let cSucursal_pago    = ''; 
  let cSucursal_pago_2  = '';
  let vNum_credito_2    = '';
  let iNum_pm_realizados = 0;
  let iNum_pm_no_realizados = 0;
  let cCalificacion      = '';
  let dTotal_importe     = 0;

  let iCteAsisteSuc    = 0;
  let cOrigen          = '';
  
  let psucursal        = ''; 
  let pfechasistema    = date(1); 
  let pefectuo_compac  = 0;
  let pnombre_efectuo  = '';
  let pnumcuenta       = '';
  let pnumproducto     = '';
  let pplazo           = '';
  let porigen          = 0;
  let ptipo_compac     = '';
  let pimporte         = 0;  
  let dImp_pagado      = 0;
  let vPlazo           = '';
  let dImp_pagado_acum = 0;
  
  let vcCodRet  = '00000';
  let viSqlErr  = 0;
  let vDataErr	= '';
  let vcEsTransaccion = '';
  let dFecha_vencim = date(1);
  let cUsuario_pago = '';
  let cNomUsuario_pago = '';
  let cCalificado   = '';  
  
  let dtFecha_ant   = date(1);
  let dPago_minimo_guardado  = 0;
  let dSaldo_vencido_guardado = 0;
  let dtFecha_insert = date(1);
  let cSucursal = '';
  let cUsuario = '';
  let cNum_producto = '';
  let dPago_minimo = 0;
  let dPago_realizado = 0;
  let dPct_cump_pm    = 0.00;
  let dPct_cump_sv    = 0.00;
  let iNum_pago_completo_pm  = 0;
  let iNum_pago_parcial_pm   = 0;
  let dMonto_vencido = 0;  
  let iNum_pago_completo_sv  = 0;
  let iNum_pago_parcial_sv   = 0;
  let dPct_rec_cartera       = 0;
  let cSucursal_origen       = '';
  let cNombre_cajero         = '';
  let cNum_credito_evobj     = '';
  let dPago_minimo_recuperado_guardado    = 0;
  let dSaldo_vencido_recuperado_guardado  = 0;
  let dPct_cump_pm_new       = 0;
  let dPct_cump_sv_new       = 0; 
  let dPago_realizado_sv     = 0;
  let dtFecha_insert_guardada = date(1);
  
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = trim(cCodRet) || ' ' || vNum_credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_registro_evaluacion_objetiva_crd.out";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
   IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET cCodRet = '000001';
		LET iSqlErr = '000001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
		RETURN cCodRet, trim(cMensaje);
	ELSE
		IF pFecha IS NULL OR pFecha = "" THEN 
			SELECT  fecha_hoy, fecha_ant
			 INTO vFechaHoy, dtFecha_ant
			 FROM BDINTEG:SI_FECHAS
			WHERE empresa = pEmpresa;
			
			--LET vFechaHoy = vFechaHoy;
		ELSE
			LET vFechaHoy = pFecha;
		END IF;
	END IF;
	
	--let vFechaHoy = mdy(10,19,2022); 
	
	FOREACH WITH HOLD
	
	    SELECT a.sucursal, a.fecha_insert, a.usuario, a.num_credito, b.num_producto, a.pago_min, a.pago_realizado,  nvl(a.pct_cump_pm,0), 
               case when a.pago_realizado >= a.pago_min then 1 else 0 end num_pago_completo_pm, 
               case when a.pago_realizado < a.pago_min then 1 else 0 end num_pago_parcial_pm,  
               nvl(a.saldo_vencido,0), nvl(a.pct_cump_sv,0), 
               case when a.pago_realizado >= nvl(a.saldo_vencido,0) then 1 else 0 end num_pago_completo_sv,
               case when a.pago_realizado < nvl(a.saldo_vencido,0) then 1 else 0 end num_pago_parcial_sv, 
			   b.sucursal --, round((a.pct_cump_pm + a.pct_cump_sv)/2,2)  pct_rec_cartera, 
			   INTO cSucursal, dtFecha_insert, cUsuario, vNum_credito, cNum_producto, dPago_minimo, dPago_realizado, dPct_cump_pm,
			   iNum_pago_completo_pm, iNum_pago_parcial_pm, dMonto_vencido, dPct_cump_sv,
			   iNum_pago_completo_sv, iNum_pago_parcial_sv, cSucursal_origen -- dPct_rec_cartera
         FROM  BDICOBRANZA:cb_evaluacion_objetiva_crd_diaria_his a, BDICRED:sd_maecredcrd b, BDINTEG:SI_EJECUT c, BDINTEG:SI_SUCURSALES d
         WHERE a.num_credito = b.num_credito
           AND a.fecha_insert = vFechaHoy 
		   AND a.pago_min > 0 
		   AND a.usuario = c.ejecutivo AND c.sucursal = d.sucursal AND d.tipo = 'S'
           --AND c.ejecutivo NOT IN('informix','interact') 
		   AND a.reversado = 'N'
		   AND a.num_credito NOT IN( SELECT num_credito FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD 
		                              WHERE fecha_insert = vFechaHoy) 
	       ORDER by a.hora_mov
		   
	    let dPct_cump_sv = round(dPct_cump_sv,2);
		let dPct_cump_pm = round(dPct_cump_pm,2);
	
	    SELECT nombre INTO cNombre_cajero 
		  FROM BDINTEG:SI_EJECUT WHERE ejecutivo = cUsuario;
		
		let cNombre_cajero = NVL(cNombre_cajero,'');
	 
		SELECT num_credito, fecha_insert, nvl(monto_pago_minimo,0), nvl(monto_recup_pm,0), nvl(monto_saldo_vencido,0), nvl(monto_recup_sv,0) 
		  INTO cNum_credito_evobj, dtFecha_insert_guardada, dPago_minimo_guardado, dPago_minimo_recuperado_guardado, dSaldo_vencido_guardado, dSaldo_vencido_recuperado_guardado
		  FROM BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD
		 WHERE num_credito = vNum_credito
		   AND fecha_insert = dtFecha_insert;
		 
		 if dMonto_vencido <= 0 then 
		    let dPago_realizado_sv = 0;
			let iNum_pago_completo_sv = 0;
			let iNum_pago_parcial_sv = 0;
		 elif dPago_realizado > dMonto_vencido then --20200227
		    let dPago_realizado_sv = dMonto_vencido;  	
	     else
		    let dPago_realizado_sv = dPago_realizado;
		 end if;
		 
		 		 
		 IF NVL(cNum_credito_evobj,'') <> '' THEN
           IF dtFecha_insert = dtFecha_insert_guardada then 
		    let dPct_cump_pm_new = round(((dPago_realizado + dPago_minimo_recuperado_guardado) / dPago_minimo_guardado) * 100,2);
			
			if dSaldo_vencido_guardado <= 0 then
			   let dPct_cump_sv_new = 0;
			else
			  --let dPct_cump_sv_new = round(((dPago_realizado + dSaldo_vencido_recuperado_guardado) / dSaldo_vencido_guardado) * 100,2);
			  let dPct_cump_sv_new = round(((dPago_realizado_sv + dSaldo_vencido_recuperado_guardado) / dSaldo_vencido_guardado) * 100,2); --20200227
			end if;
            
			if dPct_cump_pm_new > 100 then let dPct_cump_pm_new = 100; end if;
			if dPct_cump_sv_new > 100 then let dPct_cump_sv_new = 100; end if;
			
			if dSaldo_vencido_recuperado_guardado >= dSaldo_vencido_guardado then
			   let dPago_realizado_sv = 0;
			   let iNum_pago_completo_sv = 0;
			   let iNum_pago_parcial_sv = 0;
			elif dSaldo_vencido_recuperado_guardado + dPago_realizado >= dSaldo_vencido_guardado then
			   let iNum_pago_completo_sv = 1;
			   let iNum_pago_parcial_sv = 0;
			   let dPago_realizado_sv = dPago_realizado; 
			else 
			   let iNum_pago_completo_sv = 0;
			   let iNum_pago_parcial_sv = 1;
			   let dPago_realizado_sv = dPago_realizado; 
			end if;
			
			IF dPago_minimo_recuperado_guardado + dPago_realizado >= dPago_minimo_guardado THEN
		       let iNum_pago_completo_pm = 1;
			   let iNum_pago_parcial_pm = 0;
		    ELSE
		       let iNum_pago_completo_pm = 0;
			   let iNum_pago_parcial_pm = 1;
		    END IF;
			
			
				BEGIN;  
				  UPDATE BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD set sucursal_pago = cSucursal, fecha_insert = dtFecha_insert, cajero = cUsuario, 
																   nom_cajero = cNombre_cajero,
																   --monto_pago_minimo = dPago_minimo,
																   monto_recup_pm = monto_recup_pm + dPago_realizado,
																   num_pm_realizados = num_pm_realizados + iNum_pago_completo_pm,
																   num_pm_no_realizados = num_pm_no_realizados + iNum_pago_parcial_pm,
																   --monto_saldo_vencido = dMonto_vencido,
																   monto_recup_sv = monto_recup_sv + dPago_realizado_sv, 
																   num_sv_realizados = num_sv_realizados + iNum_pago_completo_sv,
																   num_sv_no_realizados = num_sv_no_realizados + iNum_pago_parcial_sv,
																   --PCT_CUMP_PM = (dPago_realizado+monto_recup_pm)/monto_pago_minimo,
																   --PCT_CUMP_SV = (dPago_realizado+monto_recup_sv)/monto_saldo_vencido
																   PCT_CUMP_PM = dPct_cump_pm_new,
																   PCT_CUMP_SV = dPct_cump_sv_new
																   
				  WHERE num_credito = cNum_credito_evobj and fecha_insert = dtFecha_insert_guardada;
			   COMMIT;
			   LET iContGral_2 = iContGral_2 +1;
		   end if;   
		ELSE   
		   -- NUEVO		
		       IF dPago_realizado >= dPago_minimo THEN
		          let iNum_pago_completo_pm = 1;
			      let iNum_pago_parcial_pm = 0;
		       ELSE
			      let iNum_pago_completo_pm = 0;
			      let iNum_pago_parcial_pm = 1;
		       END IF;
			   
			   IF dPago_realizado >= dMonto_vencido THEN
			      let iNum_pago_completo_sv = 1;
				  let iNum_pago_parcial_sv = 0;
			   ELSE
				  let iNum_pago_completo_sv = 0;
				  let iNum_pago_parcial_sv = 1;
			   END IF;
			   
			   BEGIN;
				  INSERT INTO BDICOBRANZA:CB_EVALUACION_OBJETIVA_CRD(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				                 monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados,
								 num_sv_no_realizados, pct_cump_pm, pct_cump_sv)

				  VALUES (vNum_credito, cSucursal_origen, cSucursal, dtFecha_insert, cUsuario, cNombre_cajero, cNum_producto, dPago_minimo, dPago_realizado, iNum_pago_completo_pm,
                          iNum_pago_parcial_pm, dMonto_vencido, dPago_realizado_sv, iNum_pago_completo_sv, iNum_pago_parcial_sv, dPct_cump_pm, dPct_cump_sv);
					   
			   COMMIT;
			   
			   LET iContGral = iContGral +1;
		END IF;
		 
	
	END FOREACH;
	
 --let cContGral = iContGral;
 LET cMensaje = trim(cMensaje) || '. UPDS: ' || iContGral_2 || ' INS: ' || iContGral;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE;