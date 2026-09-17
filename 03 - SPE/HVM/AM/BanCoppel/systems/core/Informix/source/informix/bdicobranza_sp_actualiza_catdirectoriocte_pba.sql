CREATE PROCEDURE "informix".sp_actualiza_catdirectoriocte_pba(pTipo_Cobranza char(1), pFecha date)
RETURNING CHAR(150);


-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-- Modificado por: MACF 23/01/2013.
-- Modificación: obteber datos de saldos.

DEFINE cCodRet      char(6);
DEFINE viSqlErr     integer;
DEFINE error_info   char(80);
DEFINE isam_err     integer;
DEFINE cMensaje     char(150);
DEFINE cNumCte      char(20);
DEFINE cEmpresa     char(3);
DEFINE cSitEsp      char(1);
DEFINE iCausa       smallint;
DEFINE cNumCredito  char(20);
DEFINE cPagoMinimo  char(20);
DEFINE cCiudad      char(3);
DEFINE cEstado      char(2);
DEFINE dSaldoTotal  decimal (18,2);
DEFINE cApell_Paterno char(26);
DEFINE cApell_Materno char(26);
DEFINE cNombre1     char(26);
DEFINE cNombre2     char(26);
DEFINE cProceso     char(30);
DEFINE cExito       char(6);
DEFINE vvcCod_ret   char(6);
define c_codret0    char(5);
define c_codretOK    char(5);
DEFINE dFechaProc, vfechacorte, vfechaultpago, vproxfchpago	DATE;
DEFINE vnum_rows,vnumpagos    integer;
DEFINE vtarjeta     CHAR(20);
DEFINE vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, vPagoMinimo decimal (18,2);
DEFINE vmontofinanciado, vsdomoratorio, vmontopagos, vinteresiva, vmoras, vpagounamora            decimal (18,2); 
DEFINE vmontootorgado, vsdo_intereses, vmensualidad_act                              decimal (18,2);

LET viSqlErr = 0;
LET isam_err = 0;
LET cMensaje = 'PROCESO EXITOSO';
LET cEmpresa = '001';
LET cNumCte = '';
LET cSitEsp = '';
LET iCausa = 0;
LET cNumCredito = '';
LET cPagoMinimo = '0';
LET dSaldoTotal = 0.00;
LET cApell_Paterno = '';
LET cApell_Materno = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET cProceso = '0050';
LET cExito   = '000000';
LET vvcCod_ret = '';
LET cCodRet = '';
let c_codret0 = "";
let c_codretOK = '00000';
let cCiudad = '';
let cEstado = '';
LET dFechaProc = pFecha;
LET vnum_rows = 0;
LET vtarjeta = ''; 
LET vsdo_capital = 0; LET vmonto_vencido = 0; LET vmtovenctrasp = 0; LET vcaptrasnovenci = 0; LET vsdocapinsoluto = 0;
LET vmontofinanciado = 0; LET vsdomoratorio = 0; LET vinteresiva = 0; LET vmoras = 0; LET vpagounamora = 0;
LET vmontootorgado = 0; LET vsdo_intereses = 0; LET vmensualidad_act = 0; LET vPagoMinimo = 0;

BEGIN
    ON EXCEPTION SET viSqlErr, isam_err, error_info
        LET cCodRet = viSqlErr;
        LET cMensaje = error_info;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '02')
            RETURNING vvcCod_ret;

        RETURN cCodRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/macf/sp_actualiza_catdirectoriocte.out";
    --TRACE ON;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '01')
            RETURNING vvcCod_ret;

    SET LOCK MODE TO WAIT 3;

	SELECT MAX(fecha_insert) INTO dFechaProc
		FROM bdicobranza:cb_cat_directorio_cte
		WHERE empresa = cEmpresa
		AND tipo_cobranza = pTipo_Cobranza
		AND fecha_insert <= pFecha;

    LET vfechacorte = dFechaProc - 1 units day;

    --Validar si hay info sin actualizar
    SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio_3)} LIMIT 1 nombre1 INTO cNombre1
     FROM bdicobranza:cb_cat_directorio_cte  
    WHERE tipo_cobranza = pTipo_Cobranza
      AND fecha_insert <= dFechaProc
      AND nombre1 is null;

    LET vnum_rows = dbinfo("sqlca.sqlerrd2");          

    IF vnum_rows > 0 THEN 

          FOREACH
              SELECT {+ INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio)} cat.numcte, cat.num_credito, cte.apell_paterno,
                          nvl(cte.apell_materno, ' '), nvl(cte.nombre1, ' '), nvl(cte.nombre2, ' ')
                  INTO cNumCte, cNumCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2
                  FROM bdinteg:si_cliente cte, bdicobranza:cb_cat_directorio_cte cat
                  WHERE cte.numcte = cat.numcte
      			  AND cte.empresa = cat.empresa
                    AND cat.tipo_cobranza = pTipo_Cobranza
                    AND cat.fecha_insert <= dFechaProc
            /*      
              SELECT {+ INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 nvl(a.situacion, ' '), nvl(a.causa, 0)
                  INTO cSitEsp, iCausa
                  FROM bdisitesp:se_ctessitespcte a
                  WHERE a.numcte    = cNumCte
                    AND a.idmovto   = (SELECT {+ INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} MAX(aux.idmovto)
                                          FROM bdisitesp:se_ctessitespcte aux
                                         WHERE aux.idmovto = aux.idmovto
                                           AND a.empresa   = aux.empresa
                                           AND a.numcte    = aux.numcte);
      
      			   IF cSitEsp IS NULL THEN LET cSitEsp = ''; END IF; 
      		     IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
      
              CALL bdicobranza:sp_saldos_tdc(cEmpresa, cNumCredito, pTipo_Cobranza)
                      RETURNING cCodRet, cMensaje, cPagoMinimo, dSaldoTotal;
			*/
              SELECT {+ INDEX (bdinteg:si_direcciones inx_puntocardinales)} FIRST 1 nvl(d.ciudad, ''), nvl(d.estado, '')
                  INTO cCiudad, cEstado
                  FROM bdinteg:si_direcciones_actual d
                  WHERE d.numcte = cNumCte
                  AND d.tipo_dir = '1';
              
              select FIRST 1 num_tarjeta, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, sdo_cap_insoluto, monto_financiado, moratorio,
                     interes_iva, mto_fin_ven_trasp, fecha_ult_pago, pago_una_mora, monto_otorgado, prox_fecha_pago, sdo_intereses, mensualidad_actual
                into vtarjeta, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, vmontofinanciado, vsdomoratorio, 
                     vinteresiva, vmoras, vfechaultpago, vpagounamora, vmontootorgado, vproxfchpago, vsdo_intereses, vmensualidad_act 
                from bdicred:sd_sdos_cartera_linea
                where num_credito = cNumCredito;
              
              SELECT first 1 NVL(num_pagos_h, 0), NVL(monto_pagos_h,0) INTO vnumpagos, vmontopagos
                FROM bdicred:sd_indicador_cred 
               WHERE num_credito = cNumCredito;
                
              LET vPagoMinimo = vmonto_vencido + vmtovenctrasp + vsdomoratorio + vinteresiva + vmensualidad_act;
                
              UPDATE bdicobranza:cb_cat_directorio_cte
                  SET /*situacion = cSitEsp, causa = iCausa,  pago_minimo = cPagoMinimo,*/ estado = cEstado,
                            ciudad = cCiudad, /*saldo_total =  dSaldoTotal,*/ apell_paterno = cApell_Paterno, apell_materno = cApell_Materno,
                            nombre1 = cNombre1, nombre2 = cNombre2,
                      monto_vencido = vmonto_vencido, moratorio = vsdomoratorio, fecha_ult_pago = vfechaultpago, 
                      pago_una_mora = vpagounamora, num_pagos = vnumpagos , monto_pagos = vmontopagos,
                      interes_iva = vinteresiva, mto_venc_trasp = vmtovenctrasp, pagomin_total = vPagoMinimo    
                  WHERE empresa = cEmpresa
                  AND tipo_cobranza = pTipo_Cobranza
                  AND fecha_insert = dFechaProc
                  AND numcte = cNumCte;
      
          END FOREACH;

          IF pTipo_Cobranza = 'A' THEN
              CALL bdicobranza:"informix".sp_cat_obtenerpuntualidad() returning c_codret0;
          END IF;
      
          IF c_codret0 = c_codretOK THEN
              LET cCodRet = cExito;
          ELSE
              LET cCodRet = c_codret0;
          END IF;
      
          IF cCodRet =cExito THEN
              CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'', '','03' )
                  RETURNING vvcCod_ret;
          ELSE
              CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, cMensaje,'02' )
                  RETURNING vvcCod_ret;
          END IF;
      
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, ' Inicia Archivos Carteras' ,'02' ) RETURNING vvcCod_ret;
      
          CALL bdicobranza:"informix".sp_cat_cargeneracion(cEmpresa,dFechaProc,pTipo_Cobranza) RETURNING vvcCod_ret ;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, 'Finaliza Generacion:'||vvcCod_ret,'02' ) RETURNING vvcCod_ret;
      
          CALL bdicobranza:"informix".sp_cat_cartelefonos(cEmpresa,dFechaProc, pTipo_Cobranza,'AC') RETURNING vvcCod_ret;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, 'Finaliza Telefonos:'||vvcCod_ret,'02' ) RETURNING vvcCod_ret;
      
          CALL bdicobranza:"informix".sp_cat_carproductos(cEmpresa,dFechaProc, pTipo_Cobranza) RETURNING vvcCod_ret;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, 'Finaliza Productos:'||vvcCod_ret,'02' ) RETURNING vvcCod_ret;

    ELSE
      LET cMensaje = 'INFO. COMPLEMENTARIA YA ACTUALIZADA.';
      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,cCodRet, cMensaje,'02' )
                  RETURNING vvcCod_ret;
    END IF;

    Return cMensaje;

END;
END PROCEDURE
DOCUMENT 
'MODIFICACIÓN: Validar si existe información que tenga que actualizarse. Que se actualice de la fecha que se esta pasando como param. hacia atrás.',
'AUTOR : Marco A. Campos ',
'FECHA : 2012-02-13',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_medidores_pago_min_fechas(pFechaIni date, pFechaFin date, pEjecMedCompac char(1) )
       RETURNING char(6), char(80);
 
--declaracion de variables
------------------------------------------------------------
DEFINE sql_err                             INTEGER;
DEFINE isam_err                            INTEGER;
DEFINE error_info                          CHAR(80);
DEFINE cMensaje                            CHAR(80);
DEFINE cCod_ret                            CHAR(6);
DEFINE vProceso							   CHAR(5);
------------------------------------------------------------
DEFINE pUsuario                            CHAR(8);
DEFINE vlNumInsert                         INTEGER;
------------------------------------------------------------
DEFINE v_sucursal                          CHAR(4);
DEFINE v_numero_convenios                  INTEGER;
DEFINE v_importe_conveniado_compromiso     DECIMAL(16,2);
DEFINE v_importe_pagado                    DECIMAL(16,2);
DEFINE v_numero_acuerdos                   INTEGER;
DEFINE v_importe_acuerdos                  DECIMAL(16,2);
DEFINE v_importe_pagado_acuerdo            DECIMAL(16,2);
DEFINE vhora                               CHAR(8);
DEFINE v_tipo_compac                       CHAR(1);
DEFINE v_importe                           DECIMAL(16,2);
DEFINE v_pagado                            DECIMAL(16,2);
------------------------------------------------------------
DEFINE v_minimo                            DECIMAL(16,2);                             
DEFINE v_pagomin                           DECIMAL(16,2);                             
DEFINE v_vencido                           DECIMAL(16,2);
DEFINE v_pagoven                           DECIMAL(16,2);      
DEFINE i                                   INTEGER;                       
DEFINE fecha_ini_periodo                   DATE;
DEFINE v_num_credito                       CHAR(20);
DEFINE v_monto                             DECIMAL(16,2);
DEFINE vv_sucursal                         CHAR(20);
DEFINE fecha_ini                           DATE;
DEFINE fecha_fin                           DATE;
DEFINE dtFechaCorte                        DATE;
 

     
      LET fecha_ini = pFechaIni;
      LET fecha_fin = pFechaFin;
      LET dtFechaCorte = pFechaFin;
      LET fecha_ini_periodo = fecha_ini - 1 UNITS DAY;
      
--SET DEBUG FILE TO '/tmp/sp_medidores_pago_min.out';
--TRACE ON;

      LET i = 1;  
      LET cCod_ret      = '000000';
      LET sql_err       = 0;
      LET isam_err      = 0;
      LET error_info    = '';
      LET cMensaje      = 'PROCESO EXITOSO';
	  LET vProceso		= '2005';
------------------------------------------------------------
      LET pUsuario      = user;
------------------------------------------------------------
      
BEGIN        
 
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '02');
			RETURN cCod_ret, cMensaje;
        END EXCEPTION;
 
        	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '01');
			
			--SET DEBUG FILE TO "/ids10_uc9/elizarraga/medidorpago.out";
			--TRACE ON; 

            --RETURN cCod_ret, cMensaje;
 
--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 
     
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
    BEGIN;
        DELETE cb_credito_ven_min;
    COMMIT;

   --se obtiene la informacion
   SET ISOLATION TO dirty READ;
----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
    
    FOREACH WITH HOLD
        select num_credito,  sum(monto), sucursal
        into v_num_credito,  v_monto, vv_sucursal
        from bdicred:sd_movhis
        WHERE empresa = '001' 
          and fecha_mov between fecha_ini and fecha_fin
          and num_credito = num_credito 
          and codigo_fun in ('033', '334', '335', '336', '337') 
          and codigo_ref = 1
          and reversado = 'N'
        --and num_credito = vcNumCuenta
        group by num_credito,sucursal
        
        BEGIN WORK;
            INSERT INTO "informix".cb_credito_ven_min(credito, monto, sucursal) 
            VALUES(v_num_credito,  v_monto, vv_sucursal);
        COMMIT WORK;
    END FOREACH;

    BEGIN;
        DELETE cb_medidor_pago_min where fecha_corte = dtFechaCorte; 
    COMMIT;
    
   FOREACH
     SELECT  SUCURSAL INTO v_sucursal  FROM BDINTEG:si_sucursales where empresa = '001' and sucursal<=1000
 
      INSERT INTO cb_medidor_pago_min (EMPRESA, CANAL, FECHA_CORTE, SUCURSAL)
      VALUES ('001', 2, dtFechaCorte, v_sucursal);
   END FOREACH;
 
    FOREACH WITH HOLD
       
            select  ccv.sucursal, --see.num_credito, 
                (see.capital_tc)+
                (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc ) Minimo , 
            case when (see.capital_tc+ see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )>
                monto then monto
            else (see.capital_tc+ see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )
            end PagoMin,        
                (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc ) vencido ,         
            case when (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )>
                        monto then monto
            else (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )
            end PagoVen
            INTO  v_sucursal, v_minimo, v_pagomin, v_vencido, v_pagoven
            from  bdicred@pld_tcp:sd_encabezado2_edocta see, cb_credito_ven_min ccv
            where see.fecha_emision = fecha_ini_periodo 
            and see.num_credito =  ccv.credito
            
            BEGIN WORK;
                  UPDATE "informix".cb_medidor_pago_min
                    SET pago_min =nvl(pago_min,0)+ v_minimo, 
                        pago_min_recup = nvl(pago_min_recup,0)+ v_pagomin, 
                        vencido = nvl(vencido,0)+ v_vencido, 
                        vencido_recup = nvl(vencido_recup,0)+ v_pagoven, 
                        fecha_insert =today
                  WHERE empresa ='001'     
                    AND canal  = 2    
                    AND fecha_corte  =dtFechaCorte    
                    AND sucursal =v_sucursal;
            COMMIT WORK;
          
    END FOREACH;
    
    IF NVL(pEjecMedCompac,'') = 'S' THEN 
        CALL "informix".sp_medidores_compac(fecha_ini, fecha_fin)
        RETURNING cCod_ret, cMensaje;   
    END IF;
     
   CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '03');
 
  RETURN cCod_ret, cMensaje;
        END;
 
END PROCEDURE
DOCUMENT 
'Se modifica procedimiento para que contemple el cambio de nombre del campo perido de la tabla cb_medidor_pago_min por fecha_corte',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110405.0850',
'2013/04/03 Modificar origen de tabla de estados de cuenta. Modificó: Marco A. Campos';

CREATE PROCEDURE "informix".sp_consultarsucursales_division(pEmpresa CHAR(3) ,pDivision SMALLINT ,pSucursal CHAR(4))
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(4) AS SUCURSAL,
	CHAR(40) AS NOMSUCURSAL; 
	
--Muestra las sucursales dependiendo del numero de sucursal, si no se envia el numero de sucursal se realiza por numero de region.  
	
	--DECLARACIONES
    DEFINE iSqlErr         INTEGER;
    DEFINE cCodRet         CHAR(6);
	DEFINE cNomSucursal    CHAR(40);
	DEFINE cNumSuc         CHAR(4);
	DEFINE VSQL            CHAR(5000);

	---INICIALIZACIONES
    LET iSqlErr            = 0;
    LET cCodRet            = '000000';
	LET cNomSucursal       = '';
	LET cNumSuc            = '0000';
	LET VSQL               = '';
	
BEGIN

    ON EXCEPTION SET iSqlErr
       IF iSqlErr <> 0 THEN
          LET cCodRet = iSqlErr;
          RETURN TRIM(cCodRet),TRIM(NVL(cNumSuc,'')),TRIM(NVL(cNomSucursal,''));
       END IF;
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/dbexportb/carlos/cobranza/dinamica/sp_consultarsucursales_division.out";
	--TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR (NVL(pDivision,0)= 0 AND NVL(pSucursal,'') = '') THEN			
		LET cCodRet = '000001';		RETURN TRIM(cCodRet),TRIM(NVL(cNumSuc,'')),TRIM(NVL(cNomSucursal,''));
	END IF;
	
	IF NVL(pSucursal,'') <> '' THEN

		SELECT sucursal, nombre  
		INTO cNumSuc, cNomSucursal 
		FROM bdinteg:"informix".si_sucursales 
		WHERE sucursal = NVL(pSucursal,'');

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002';
			LET cNumSuc = TRIM(pSucursal);
			LET cNomSucursal = 'No se Encuentra la Sucursal Requerida';
			RETURN TRIM(cCodRet),TRIM(cNumSuc),TRIM(cNomSucursal); 
		END IF	 

		RETURN TRIM(cCodRet),TRIM(NVL(cNumSuc,'')),TRIM(NVL(cNomSucursal,''));
		
	ELSE
		LET VSQL = '	SELECT suc.sucursal,suc.nombre                          '  ;
		LET VSQL = TRIM(VSQL) || '	FROM bdinteg:"informix".si_sucursales suc,              ';
		LET VSQL = TRIM(VSQL) || '		 bdinteg:"informix". si_ciudades ciu,               ' ;
		LET VSQL = TRIM(VSQL) || '		 bdinteg:"informix".si_catciudades cat,             ' ;
		LET VSQL = TRIM(VSQL) || '		 bdinteg:"informix".si_regiones reg                 '  ;
		LET VSQL = TRIM(VSQL) || '	WHERE suc.sucursal = suc.sucursal 	'  ; --PARA ACTIVAR INDICE
		LET VSQL = TRIM(VSQL) || " 	AND suc.empresa = '" || TRIM(pEmpresa) ||"' "  ;
		LET VSQL = TRIM(VSQL) || '	AND suc.tpo_sucursal = "S"	                            '  ;
		LET VSQL = TRIM(VSQL) || '	AND ciu.estado = suc.estado 	                        '  ;
		LET VSQL = TRIM(VSQL) || '	AND ciu.ciudad = suc.ciudad 	                        '  ;
		LET VSQL = TRIM(VSQL) || '	AND cat.numerociudad = ciu.ciudad_coppel 	            ' ;
		LET VSQL = TRIM(VSQL) || '	AND reg.numero_region = cat.numero_region	            '  ;
		IF NVL(pDivision, 0) <> 0 THEN
		   LET VSQL =  TRIM(VSQL) || "	  AND reg.division = '" || pDivision || "'              "  ;
		ELSE 
		   LET VSQL = TRIM(VSQL) ||  "	  AND reg.division = reg.division                       "  ;
		END IF;
		LET VSQL = TRIM(VSQL) ||  "     ORDER BY suc.sucursal                                  "  ;

		
		  PREPARE xsql FROM TRIM(VSQL); --Prepara en memoria la instruccion a partir de la cadena con instr sql
		  DECLARE xcur CURSOR FOR xsql; --prepara la estructura del cursor de salidad
		  OPEN xcur;		 --abre el cursor para ser accesado mediante el fetch, posiciona el puntero en el 1er registro 
				FETCH  xcur INTO cNumSuc, cNomSucursal; --empieza a barrer y depositar en las variables los campos leidos
				
				WHILE  SQLCODE= 0
					RETURN TRIM(cCodRet),TRIM(NVL(cNumSuc,'')),TRIM(NVL(cNomSucursal,'')) WITH RESUME;
					FETCH  xcur INTO cNumSuc, cNomSucursal;				END WHILE;
		   CLOSE xcur;
		  FREE xcur;
		  FREE xsql;		
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000003';
			LET cNomSucursal = 'No Existen Sucursales Para la división';
			RETURN TRIM(cCodRet),TRIM(NVL(cNumSuc,'')),TRIM(cNomSucursal);  
		END IF	
		
	END IF;	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una Consulta con la Informacion de las Sucursales de una Determinada Division', 
'AUTOR: MARIO OLIVO',
'FECHA: FEBRERO 2013',
'BASE DE DATOS: bdicobranza',
'VERSION: 20130226.1313';

CREATE PROCEDURE "informix".sp_medidores_pago_min()
       RETURNING char(6), char(80);
 
--declaracion de variables
------------------------------------------------------------
DEFINE sql_err                             INTEGER;
DEFINE isam_err                            INTEGER;
DEFINE error_info                          CHAR(80);
DEFINE cMensaje                            CHAR(80);
DEFINE cCod_ret                            CHAR(6);
DEFINE vProceso							   CHAR(5);
------------------------------------------------------------
DEFINE pUsuario                            CHAR(8);
DEFINE vlNumInsert                         INTEGER;
------------------------------------------------------------
DEFINE v_sucursal                          CHAR(4);
DEFINE v_numero_convenios                  INTEGER;
DEFINE v_importe_conveniado_compromiso     DECIMAL(16,2);
DEFINE v_importe_pagado                    DECIMAL(16,2);
DEFINE v_numero_acuerdos                   INTEGER;
DEFINE v_importe_acuerdos                  DECIMAL(16,2);
DEFINE v_importe_pagado_acuerdo            DECIMAL(16,2);
DEFINE vdia                                DATE;
DEFINE vdia2                               DATE;
DEFINE vhora                               CHAR(8);
DEFINE v_tipo_compac                       CHAR(1);
DEFINE v_importe                           DECIMAL(16,2);
DEFINE v_pagado                            DECIMAL(16,2);
------------------------------------------------------------
DEFINE AnoFin                              CHAR(15);
DEFINE MesFin                              CHAR(15);
DEFINE v_periodo                           CHAR(15);
DEFINE v_minimo                            DECIMAL(16,2);                             
DEFINE v_pagomin                           DECIMAL(16,2);                             
DEFINE v_vencido                           DECIMAL(16,2);
DEFINE v_pagoven                           DECIMAL(16,2);      
DEFINE i                                   INTEGER;                       
DEFINE fecha_ini_periodo                   DATE;
DEFINE v_num_credito                       CHAR(20);
DEFINE v_monto                             DECIMAL(16,2);
DEFINE vv_sucursal                         CHAR(20);
DEFINE fecha_ini                           DATE;
DEFINE fecha_fin                           DATE;
DEFINE vfecha_hoy                          DATE;
DEFINE vfecha_ini_peri                     DATE;
DEFINE d                                   DATE;
DEFINE vfecha_fin_peri                     DATE;
DEFINE e                                   DATE;
DEFINE dtFechaCorte                        DATE;
DEFINE vempresa                            CHAR(3);

LET vempresa = '001';

      SELECT fecha_hoy INTO vfecha_hoy
        FROM bdinteg:si_fechas
        WHERE empresa = vempresa;

      LET vfecha_ini_peri = vfecha_hoy - 2 UNITS MONTH;
      LET d = vfecha_ini_peri + 19 units day;
      LET fecha_ini= d; 

      LET vfecha_fin_peri = vfecha_hoy - 1 UNITS MONTH;
      LET e = vfecha_fin_peri + 18 units day;
      LET fecha_fin= e; 

--SET DEBUG FILE TO '/tmp/sp_medidores_pago_min.out';
--TRACE ON;

      LET i = 1;  
      LET cCod_ret      = '000000';
      LET sql_err       = 0;
      LET isam_err      = 0;
      LET error_info    = '';
      LET cMensaje      = 'PROCESO EXITOSO';
	  LET vProceso		= '2005';
------------------------------------------------------------
      LET pUsuario      = user;
------------------------------------------------------------
      LET AnoFin = year(fecha_fin);
      LET MesFin = month(fecha_fin);
      LET v_periodo =  trim(MesFin)||'-'||'20'||'-'||trim(AnoFin) ;
      LET dtFechaCorte = v_periodo::DATE;
      LET fecha_ini_periodo = fecha_ini - i UNITS DAY;
	  LET vdia = today;
      
BEGIN        
 
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '02');
			RETURN cCod_ret, cMensaje;
        END EXCEPTION;
 
        	CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '01');
			
			--SET DEBUG FILE TO "/ids10_uc9/elizarraga/medidorpago.out";
			--TRACE ON; 

            --RETURN cCod_ret, cMensaje;
 
--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 
     
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
        --se obtiene la informacion
   SET ISOLATION TO dirty READ;
----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
    
    BEGIN;
      TRUNCATE cb_credito_ven_min;
    COMMIT;
    
    FOREACH
        select num_credito,  sum(monto), sucursal
        into v_num_credito,  v_monto, vv_sucursal
        from bdicred:sd_movhis
        WHERE empresa = '001' 
          and fecha_mov between fecha_ini and fecha_fin
          and num_credito = num_credito 
          and codigo_fun in ('033', '334', '335', '336', '337') 
          and codigo_ref = 1
          and reversado = 'N'
        --and num_credito = vcNumCuenta
        group by num_credito,sucursal
        
        INSERT INTO "informix".cb_credito_ven_min(credito, monto, sucursal) 
        VALUES(v_num_credito,  v_monto, vv_sucursal);

    END FOREACH;
    
    BEGIN;
      DELETE cb_medidor_pago_min where fecha_corte = dtFechaCorte; 
    COMMIT;
    
   FOREACH
     SELECT  SUCURSAL INTO v_sucursal  FROM BDINTEG:si_sucursales where empresa = '001' and tpo_sucursal = 'S'
 
      INSERT INTO cb_medidor_pago_min (EMPRESA, CANAL, FECHA_CORTE, SUCURSAL)
      VALUES ('001', 2, dtFechaCorte, v_sucursal);
   END FOREACH;
 
    FOREACH
       
            select  ccv.sucursal, --see.num_credito, 
                (see.capital_tc)+
                (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc ) Minimo , 
            case when (see.capital_tc+ see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )>
                monto then monto
            else (see.capital_tc+ see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )
            end PagoMin,        
                (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc ) vencido ,         
            case when (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )>
                        monto then monto
            else (see.capital_ven_tc+see.interes_ven_tc+see.iva_interes_ven_tc+see.moratorios_tc+see.iva_moratorios_tc )
            end PagoVen
            INTO  v_sucursal, v_minimo, v_pagomin, v_vencido, v_pagoven
            from  bdicred@pld_tcp:sd_encabezado2_edocta see, cb_credito_ven_min ccv
            where see.fecha_emision = fecha_ini_periodo 
            and see.num_credito =  ccv.credito
            
 

            UPDATE "informix".cb_medidor_pago_min
              SET pago_min =nvl(pago_min,0)+ v_minimo, 
                  pago_min_recup = nvl(pago_min_recup,0)+ v_pagomin, 
                  vencido = nvl(vencido,0)+ v_vencido, 
                  vencido_recup = nvl(vencido_recup,0)+ v_pagoven, 
                  fecha_insert =today
            WHERE empresa ='001'     
              AND canal  = 2    
              AND fecha_corte  =dtFechaCorte    
              AND sucursal =v_sucursal;
 
    END FOREACH;

    CALL "informix".sp_medidores_compac(fecha_ini, fecha_fin)
    RETURNING cCod_ret, cMensaje;   
   
   CALL bdicobranza:"informix".inserta_bitacora_cob('001', vProceso, cCod_Ret, cMensaje, '03');
 
  RETURN cCod_ret, cMensaje;
        END;
 
END PROCEDURE
DOCUMENT 
'Se modifica procedimiento para que contemple el cambio de nombre del campo perido de la tabla cb_medidor_pago_min por fecha_corte',
'MODIFICO : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110405.0850',
'2013/04/03 Modificar origen de tabla de estados de cuenta. Modificó: Marco A. Campos';

CREATE PROCEDURE "informix".sp_repcob_compago()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cCodRet, vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet			CHAR(80);						
		DEFINE cNombreArchivo	  	CHAR(80); 
		DEFINE cConsulta		  	CHAR(2200);
		DEFINE cSql           		CHAR(1024);
		DEFINE cTabla		      	CHAR(1); 
		DEFINE cRuta		      	CHAR(80);   										
		DEFINE dtFechaHoy 			DATE;		
		DEFINE dtFechaCorteIniCte	DATE;		
		DEFINE dtFechaCorteIniHis	DATE;				
		DEFINE dtFechaCorteFinCte	DATE;				
		DEFINE dtFechaCorteFinHis	DATE;				
		DEFINE cNumCte				CHAR(20);				
		DEFINE dMonPagMinTot		DECIMAL(18,2);				
		DEFINE dMonVenc				DECIMAL(18,2);				
		DEFINE dMonPagSem			DECIMAL(14,2);				
		DEFINE dMonPag				DECIMAL(18,2);				
		DEFINE dtFechaCompConv		DATE;				
		DEFINE iNumPagos			INTEGER;				
		DEFINE cResultConv			CHAR(15);				
		DEFINE iNumEmpleado			INTEGER;				
		DEFINE dtFechaAltConv		DATE;				
		DEFINE cNomJefCat			CHAR(40);				
		DEFINE sCampana				SMALLINT;				
		DEFINE dtFechEnc			DATE;
		DEFINE cFechEnc2			CHAR(10);				
		DEFINE iTotNumCte			INTEGER;
		DEFINE dMonPagMinTot1		DECIMAL(18,2);
		DEFINE dMonVenc1    		DECIMAL(18,2);
		DEFINE dMonPagSem1    		DECIMAL(18,2);
		DEFINE dMonPag1	    		DECIMAL(18,2);
		DEFINE iNumPagos1    		INTEGER;
		DEFINE iResultConv1    		INTEGER;
		DEFINE iNumEmpleado1   		INTEGER;
		DEFINE v_empresa       CHAR(3);
	  DEFINE cProceso        CHAR(4);
	  DEFINE dtFechaMax       DATE;
	  
		---INICIALIZACIONES
		LET iSqlErr            	= 0;
		LET iIsamErr           	= 0;
		LET cCodRet            	= "000000";
		LET cMensajeRet			= "Proceso exitoso";				
		LET cNombreArchivo 		= "";
		LET cConsulta	 		= "";
		LET cSql		 		= "";
		LET cTabla		 		= "N";
		LET cRuta		 		= "";										
		LET dtFechaHoy          = "";		
		LET dtFechaCorteIniCte  = "";
		LET dtFechaCorteIniHis  = "";		
		LET dtFechaCorteFinCte  = "";		
		LET dtFechaCorteFinHis  = "";		
		LET cNumCte			    = "";						
		LET dMonPagMinTot	    = 0.00;						
		LET dMonVenc		    = 0.00;						
		LET dMonPagSem		    = 0.00;						
		LET dMonPag			    = 0.00;						
		LET dtFechaCompConv	    = "";						
		LET iNumPagos		    = 0;						
		LET cResultConv		    = "";						
		LET iNumEmpleado	    = 0;						
		LET dtFechaAltConv	    = "";						
		LET cNomJefCat		    = "";						
		LET sCampana		    = 0;						
		LET dtFechEnc		    = "";						
		LET cFechEnc2 			= "";		
		LET iTotNumCte		 	= 0;
		LET dMonPagMinTot1	 	= 0.00;
		LET dMonVenc1   	 	= 0.00;
		LET dMonPagSem1   	 	= 0.00;
		LET dMonPag1	   	 	= 0.00;
		LET iNumPagos1	   	 	= 0;
		LET iResultConv1   	 	= 0;
		LET iNumEmpleado1  	 	= 0;
		LET v_empresa = '001';
	  LET cProceso = '0077';
    LET vvcCod_ret = '';
    LET dtFechaMax = date(1);
    	
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;			  				
				
				--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compago" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_compago;
				END IF;		
								
				IF cTabla="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG;
				END IF;
				
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
        		
			RETURN cCodRet, cMensajeRet;
				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		--SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_compago.out";
		--TRACE ON;		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compago" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE tmp_compago;
		END IF;		
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELCOMPAG" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP  TABLE TMP_ENCABEZADOSEXCELCOMPAG;
		END IF;
		
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		
    --LET dtFechaHoy = mdy('01','30','2013');   --- TEST MACF mdy('12','13','2012') 214
    
    SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
    				
		--IF DAY(dtFechaHoy) = 1 THEN 			
			--LET cCodRet = '000001';
			--LET cMensajeRet = "No es posible generar el archivo los días primero de cada mes";
		--END IF 
		
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.
  	IF DAY(dtFechaHoy) = 1 THEN
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaCorteFinHis),1,YEAR(dtFechaCorteFinHis));
		ELIF DAY(dtFechaHoy) = 2 THEN
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
    ELSE
       LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
       LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		END IF;

		
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.
		IF DAY(dtFechaHoy) <= 21 THEN 			
			LET dtFechaCorteIniCte = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy)) - 1 UNITS MONTH;
			LET dtFechaCorteFinCte = MDY(MONTH(dtFechaHoy),22,YEAR(dtFechaHoy)) - 1 UNITS MONTH;			
		ELSE 
			LET dtFechaCorteIniCte = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy));
			LET dtFechaCorteFinCte = MDY(MONTH(dtFechaHoy),22,YEAR(dtFechaHoy));			
		END IF 									
		--LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		--LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;		
		
		--SE CALCULA LA FECHA DEL ENCABEZADO DEL ARCHIVO.
		LET dtFechEnc = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		LET cFechEnc2 =  LPAD(DAY(dtFechEnc),2,0)||"/"||LPAD(MONTH(dtFechEnc),2,0)||"/"||YEAR(dtFechEnc);
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG(					
																		NumCte 			CHAR(80),
																		MonPagMinTot 	CHAR(80),
																		MonVencido 		CHAR(80),
																		MonPagSem 		CHAR(80),
																		MonPagdo		CHAR(80),
																		FechaComConv 	CHAR(80),
																		NumPags 		CHAR(80),
																		ResulConv 		CHAR(80),
																		NumEmpleado 	CHAR(80),
																		FechaAltConv 	CHAR(80),
																		NomJefCat 		CHAR(80),
																		TipLog 			CHAR(80)																		
																	);			
		LET cTabla="S";		
		 			
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG (NumCte,MonPagMinTot,MonVencido,MonPagSem,MonPagdo,FechaComConv,NumPags,ResulConv,NumEmpleado,FechaAltConv,NomJefCat,TipLog)
		VALUES("","","","Compromiso de pago (Negociaciones por Supervisor/Desglose","","","","","","","Fecha: "||cFechEnc2,"");				
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG (NumCte,MonPagMinTot,MonVencido,MonPagSem,MonPagdo,FechaComConv,NumPags,ResulConv,NumEmpleado,FechaAltConv,NomJefCat,TipLog)
		VALUES("No. Cliente","Monto pago min. Total","Monto de vencido","Monto pago sembrado","Monto pagado","Fecha comp. De conv.","Num. de pagos","Result. Del conv.","No. Empleado","Fecha alta conv.","Nombre Jefe CAT","Tipo Logica");		
				
		--CONSULTA PARA OBTENER LA INFORMACION DEL COMPROMISO DE PAGO Y SE INSERTA TODA LA INFORMACION EN LA TEMPORAL PARA DESPUES HACER UNOS CALCULOS.
		SELECT NumCte,MonPagMinTot,MonVenc,MonPagSem,MonPag,FechaCompConv,NumPagos,ResultConv,NumEmpleado,FechaAltConv,NomJefCat,Campana					
		FROM TABLE(MULTISET(SELECT 						
							DISTINCT TRIM(NVL(a.numcliente,"")) AS NumCte,
							SUM(NVL(b.pagomin_total,0.00)) AS MonPagMinTot,
							SUM(NVL(b.monto_vencido,0.00)) AS MonVenc,
							SUM(NVL(a.importe,0.00)) AS MonPagSem,
							SUM(NVL(a.imp_pagado,0.00)) AS MonPag,
							TRIM(NVL(a.fecha_insert,"")) AS FechaCompConv,
							NVL(SUM(CASE WHEN a.imp_pagado >= 0 AND a.flag_pago = 1 THEN 1 ELSE 0 END),0) AS NumPagos,
							NVL(CASE WHEN a.flag_pago = 1 THEN "Cumplido" ELSE (CASE WHEN a.flag_pago = 0 THEN "No cumplido" END) END,"") AS ResultConv,
							TRIM(NVL(a.efectuo_compac,0)::CHAR(8)) AS NumEmpleado,
							TRIM(NVL(a.fecha_compac,"")) AS FechaAltConv,
							TRIM(NVL(a.nombre_efectuo,"")) AS NomJefCat,
							SUM(NVL(b.tipo_logica,0)) AS Campana								
						FROM bdicobranza:"informix".cb_compac a							 
							LEFT OUTER JOIN bdicobranza:"informix".cb_cat_directorio_cte b ON(b.numcte = a.numcliente)
						WHERE b.empresa = "001"
							AND b.tipo_cobranza = "A"
							AND b.numcte = a.numcliente
							--AND b.fecha_insert >= dtFechaCorteIniCte AND b.fecha_insert <= dtFechaCorteFinCte
							AND b.fecha_insert = dtFechaMax
							AND b.status_cliente = "AC"
							AND a.fecha_compac >= dtFechaCorteIniHis AND a.fecha_compac <= dtFechaCorteFinHis
						GROUP BY 1,6,8,9,10,11
						))
		UNION ALL 
		SELECT NumCte,MonPagMinTot,MonVenc,MonPagSem,MonPag,FechaCompConv,NumPagos,ResultConv,NumEmpleado,FechaAltConv,NomJefCat,Campana			
		FROM TABLE(MULTISET(SELECT 						
							DISTINCT TRIM(NVL(a.numcliente,"")) AS NumCte,
							SUM(NVL(b.pagomin_total,0.00)) AS MonPagMinTot,
							SUM(NVL(b.monto_vencido,0.00)) AS MonVenc,
							SUM(NVL(a.importe,0.00)) AS MonPagSem,
							SUM(NVL(a.imp_pagado,0.00)) AS MonPag,
							TRIM(NVL(a.fecha_insert,"")) AS FechaCompConv,
							NVL(SUM(CASE WHEN a.imp_pagado >= 0 AND a.flag_pago = 1 THEN 1 ELSE 0 END),0) AS NumPagos,
							NVL(CASE WHEN a.flag_pago = 1 THEN "Cumplido" ELSE (CASE WHEN a.flag_pago = 0 THEN "No cumplido" END) END,"") AS ResultConv,
							TRIM(NVL(a.efectuo_compac,0)::CHAR(8)) AS NumEmpleado,
							TRIM(NVL(a.fecha_compac,"")) AS FechaAltConv,
							TRIM(NVL(a.nombre_efectuo,"")) AS NomJefCat,
							SUM(NVL(b.tipo_logica,0)) AS Campana										
						FROM bdicobranza:"informix".cb_compac_his a							 
							LEFT OUTER JOIN bdicobranza:"informix".cb_cat_directorio_cte b ON(b.numcte = a.numcliente)
						WHERE b.empresa = "001"
							AND b.tipo_cobranza = "A"
							AND b.numcte = a.numcliente
							--AND b.fecha_insert >= dtFechaCorteIniCte AND b.fecha_insert <= dtFechaCorteFinCte
							AND b.fecha_insert = dtFechaMax
							AND b.status_cliente = "AC"
							AND a.fecha_compac >= dtFechaCorteIniHis AND a.fecha_compac <= dtFechaCorteFinHis
						GROUP BY 1,6,8,9,10,11
						))
		INTO TEMP tmp_compago WITH NO LOG;	
									
		FOREACH
			--SE BARRE TODA LA INFORMACION DE LA TABLA TEMPORAL.
			SELECT NumCte,MonPagMinTot,MonVenc,MonPagSem,MonPag,FechaCompConv,NumPagos,ResultConv,NumEmpleado,FechaAltConv,NomJefCat,Campana
			INTO cNumCte,dMonPagMinTot,dMonVenc,dMonPagSem,dMonPag,dtFechaCompConv,iNumPagos,cResultConv,iNumEmpleado,dtFechaAltConv,cNomJefCat,sCampana			
			FROM tmp_compago
			--SE VACIA TODA LA INFORMACION DE LA TEMPORAL YA CON LOS TOTALIZADOS A LA TABLA FINAL.
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG (NumCte,MonPagMinTot,MonVencido,MonPagSem,MonPagdo,FechaComConv,NumPags,ResulConv,NumEmpleado,FechaAltConv,NomJefCat,TipLog)
			VALUES(cNumCte::CHAR(80),'$'||dMonPagMinTot::CHAR(80),'$'||dMonVenc::CHAR(80),'$'||dMonPagSem::CHAR(80),'$'||dMonPag::CHAR(80),dtFechaCompConv::CHAR(80),iNumPagos::CHAR(80),cResultConv::CHAR(80),iNumEmpleado::CHAR(80),dtFechaAltConv::CHAR(80),cNomJefCat::CHAR(80),sCampana::CHAR(80));
		END FOREACH
		
		--SE OBTIENE EL TOTALIZADO DE CLIENTES DE LA TABLA FINAL.			
		SELECT COUNT(DISTINCT NumCte)
		INTO iTotNumCte
		FROM tmp_compago;
		
		--SE OBTIENE LOS TOTALIZADOS DE LA TABLA FINAL.			
		SELECT NVL(SUM(MonPagMinTot),0.00),NVL(SUM(MonVenc),0.00),NVL(SUM(MonPagSem),0.00),NVL(SUM(MonPag),0.00),NVL(SUM(NumPagos),0),
			   NVL(SUM(CASE WHEN ResultConv = "Cumplido" THEN 1 ELSE 0 END),0),NVL(COUNT(DISTINCT NumEmpleado),0)
		INTO dMonPagMinTot1,dMonVenc1,dMonPagSem1,dMonPag1,iNumPagos1,iResultConv1,iNumEmpleado1
		FROM tmp_compago;
		
		--SE INSERTAN LOS TOTALES EN LA TABLA FINAL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG (NumCte,MonPagMinTot,MonVencido,MonPagSem,MonPagdo,FechaComConv,NumPags,ResulConv,NumEmpleado,FechaAltConv,NomJefCat,TipLog)
		VALUES("Total: "||iTotNumCte::CHAR(80),'$'||dMonPagMinTot1::CHAR(80),'$'||dMonVenc1::CHAR(80),'$'||dMonPagSem1::CHAR(80),'$'||dMonPag1::CHAR(80)," ",iNumPagos1::CHAR(80),iResultConv1::CHAR(80),iNumEmpleado1::CHAR(80),"","","");
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compago" AND dbsname= "bdicobranza") THEN
			DROP  TABLE tmp_compago;
		END IF;		
				
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 79;	
			
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
				
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT NumCte,MonPagMinTot,MonVencido,MonPagSem,MonPagdo,FechaComConv,NumPags,ResulConv,NumEmpleado,FechaAltConv,NomJefCat,TipLog FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELCOMPAG";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAG;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el compromiso de pago(Negociaciones por Supervisor/Desglose).', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121109.1214';

CREATE PROCEDURE "informix".sp_repcob_compago_cantconv()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				            INTEGER;
		DEFINE iIsamErr				            INTEGER;
		DEFINE cTabla, cTabla2		      	CHAR(1);
		DEFINE v_empresa                  CHAR(3);
		DEFINE cProceso                   CHAR(4); 
		DEFINE cCodRet, vvcCod_ret		    CHAR(6);
		DEFINE cFechaNeg, cFechaNegFin, cFechNegEncb, cFechEnc2			CHAR(10);
		DEFINE cMensajeRet, cRuta, cNombreArchivo			              CHAR(80);						
		DEFINE cDescrip				                                      CHAR(100);
		DEFINE cConsulta		  	                                    CHAR(2200);
		DEFINE cSql           		                                  CHAR(1024);
		DEFINE dtFechaHoy, dtFechaCorteMov, dtFechaCorteHis, dtFechEnc, dtFechaIniMesAct, dtFechaMax, dtFechaMaxCart			DATE;		
		DEFINE sTipLog, sCampCatActEncb, sCampCatActEncb2				          SMALLINT;						
		DEFINE sContador, sContador2, sContador3, sCampCatActTmpFin		    SMALLINT;
		DEFINE iTotPorDiaFin, iI	                                        INTEGER;
		DEFINE dPromedioFin, dPromedioEncb, dPromedioEncb2		            DECIMAL(18,2);
		DEFINE iTipLogInfTot1, iTipLogInfTot2, iTipLogInfTot3, iTipLogInfTot4, iTipLogInfTot5, iTipLogInfTot6	    INTEGER;
		DEFINE iTipLogInfTot7, iTipLogInfTot8, iTipLogInfTot9	            INTEGER;
		DEFINE iTipLog1Encb, iTipLog2Encb, iTipLog3Encb, iTipLog4Encb, iTipLog5Encb, iTipLog6Encb, iTipLog7Encb	        INTEGER;
		DEFINE iTipLog8Encb, iTipLog9Encb, iTotPorDiaEncb	                              INTEGER;
		DEFINE iTipLog1Encb2, iTipLog2Encb2, iTipLog3Encb2, iTipLog4Encb2, iTipLog5Encb2, iTipLog6Encb2, iTipLog7Encb2        INTEGER;
		DEFINE iTipLog8Encb2, iTipLog9Encb2, iTotPorDiaEncb2              INTEGER;
		   
	  
    								
		---INICIALIZACIONES
		LET iSqlErr            	= 0;
		LET iIsamErr           	= 0;
		LET cCodRet            	= "000000";
		LET cMensajeRet			= "Proceso exitoso";				
		LET cNombreArchivo 		= "";
		LET cConsulta	 		= "";
		LET cSql		 		= "";
		LET cTabla		 		= "N";
		LET cTabla2		 		= "N";
		LET cRuta		 		= "";										
		LET dtFechaHoy          = "";		
		LET dtFechaCorteMov     = "";		
		LET dtFechaCorteHis     = "";		
		LET sTipLog     		= 0;						
		LET cDescrip     		= "";						
		LET cFechaNeg     		= "";										
		LET sContador	 		= 0;
		LET sContador2	 		= 0;
		LET sContador3	 		= 0;				
		LET cFechaNegFin 		= "";
		LET iTotPorDiaFin 		= 0;
		LET sCampCatActTmpFin	= 0;
		LET iI					= 0;
		LET dPromedioFin		= 0.00;
		LET iTipLogInfTot1 = 0;   LET iTipLogInfTot2 = 0;   LET iTipLogInfTot3 = 0;   LET iTipLogInfTot4 = 0;
		LET iTipLogInfTot5 = 0;		LET iTipLogInfTot6 = 0;		LET iTipLogInfTot7 = 0;		LET iTipLogInfTot8 = 0;
		LET iTipLogInfTot9 = 0;		LET cFechNegEncb		= "";
		LET iTipLog1Encb		= 0;	LET iTipLog2Encb		= 0;	LET iTipLog3Encb		= 0;	LET iTipLog4Encb		= 0;
		LET iTipLog5Encb		= 0;	LET iTipLog6Encb		= 0;	LET iTipLog7Encb		= 0;	LET iTipLog8Encb		= 0;
		LET iTipLog9Encb		= 0;	LET iTotPorDiaEncb	= 0;	LET sCampCatActEncb	= 0;	LET dPromedioEncb		= 0.00;		
		LET iTipLog1Encb2		= 0;	LET iTipLog2Encb2		= 0;	LET iTipLog3Encb2		= 0;	LET iTipLog4Encb2		= 0;
		LET iTipLog5Encb2		= 0;	LET iTipLog6Encb2		= 0;	LET iTipLog7Encb2		= 0;	LET iTipLog8Encb2		= 0;
		LET iTipLog9Encb2		= 0;	LET iTotPorDiaEncb2	= 0;	LET sCampCatActEncb2= 0;	LET dPromedioEncb2		= 0.00;
		LET dtFechEnc			= "";
		LET cFechEnc2			= "";
    LET v_empresa = '001';
	  LET cProceso = '0079';
    LET vvcCod_ret = '';
    LET dtFechaIniMesAct = DATE(1);   LET dtFechaMax = date(1);   LET dtFechaMaxCart = date(1);
    		
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;			  								
				IF cTabla="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON;
				END IF;
				IF cTabla2 ="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_COMPAGMON;
				END IF;							
        
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
        			
				RETURN cCodRet, cMensajeRet;				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

    --SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELCOMPAGMON" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
		 	  DROP  TABLE TMP_ENCABEZADOSEXCELCOMPAGMON;
		END IF;	

    IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_COMPAGMON" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
		 	  DROP  TABLE TMP_COMPAGMON;
		END IF;

		--SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_compago_montconv.out";
		--SET DEBUG FILE TO "/informix/macf/sp_repcob_compago_cantconv.trc";
		--TRACE ON;		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		
		--LET dtFechaHoy = mdy('01','28','2013');   --- TEST MACF
		--LET dtFechaIniMesAct = mdy('01','01','2013');   --- TEST MACF 
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
		SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		  FROM bdicobranza:"informix".cb_cat_movimientos
		 WHERE tipocobranza = 'A';
		
		--IF DAY(dtFechaHoy) = 1 THEN 			
		--	LET cCodRet = '000001';
		--	LET cMensajeRet = "No es posible generar el archivo los días primero de cada mes";
		--	RETURN cCodRet, cMensajeRet;
		--END IF 
		
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.							
		IF DAY(dtFechaHoy) = 1 THEN
		   LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		   LET dtFechaIniMesAct = MDY(MONTH(dtFechaCorteHis),1,YEAR(dtFechaCorteHis));
		ELIF DAY(dtFechaHoy) = 2 THEN
		   LET dtFechaIniMesAct = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		   LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
    ELSE
       LET dtFechaIniMesAct = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
       LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		END IF;
		
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA CORTE.
		IF DAY(dtFechaHoy) <= 21 THEN 			
			LET dtFechaCorteMov = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy)) - 1 UNITS MONTH;			
		ELSE 
			LET dtFechaCorteMov = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy));			
		END IF 									
		
		--LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;		
							
		--SE CALCULA LA FECHA DEL ENCABEZADO DEL ARCHIVO.
		LET dtFechEnc = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		LET cFechEnc2 = LPAD(DAY(dtFechEnc),2,0)||"/"||LPAD(MONTH(dtFechEnc),2,0)||"/"||YEAR(dtFechEnc);
								
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON(					
																			FechNeg		CHAR(80),
																			ValTipLog1	CHAR(80),
																			ValTipLog2	CHAR(80),
																			ValTipLog3	CHAR(80),
																			ValTipLog4	CHAR(80),
																			ValTipLog5	CHAR(80),
																			ValTipLog6	CHAR(80),
																			ValTipLog7	CHAR(80),
																			ValTipLog8	CHAR(80),
																			ValTipLog9	CHAR(80),
																			TotPorDia	CHAR(80),
																			CampCatAct	CHAR(80),
																			Promedio	CHAR(80)																																																				
																		 );			
		--BANDERA PARA DETERMINAR QUE SI SE CREO LA TABLA DE TRABAJO.
		LET cTabla="S";		
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_COMPAGMON(					
																Fech		CHAR(10),
																TipLog1		INTEGER,
																TipLog2		INTEGER,
																TipLog3		INTEGER,
																TipLog4		INTEGER,
																TipLog5		INTEGER,
																TipLog6		INTEGER,
																TipLog7		INTEGER,
																TipLog8		INTEGER,
																TipLog9		INTEGER,
																TotPorDia	INTEGER,
																CampCatAct	SMALLINT,
																Promedio	DECIMAL(18,2)
															  );	
		--BANDERA PARA DETERMINAR QUE SI SE CREO LA TABLA DE TRABAJO.
		LET cTabla2="S";															
				 		
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("","","Compromisos de pago/Convenios sembrados al: "||cFechEnc2,"","","","","","","","","","");						
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		--VALUES("","","","Montos de convenios activados por campana por dia","","","","","","","","","");  						
		VALUES("","","","Cantidad de convenios activados por campana por dia","","","","","","","","","");   --- by MACF
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("Fecha Negociacion","0","0","0","0","0","0","0","0","0","Totales x dia","Campanas CAT Activas","Promedio");						
		
		FOREACH			  				
			--SE OBTIENE LA DESCRIPCION DE LA LOGICA.
			SELECT valor_numerico,descripcion
			INTO sTipLog,cDescrip
			FROM bdicobranza:"informix".cb_param_campania
			WHERE grupo_parametro = "LOGICA"
											
			--SE VALIDA EL TIPO DE LOGICA PARA 
			IF sTipLog = 1 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog1 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog1 = "Valor tipo_logica 1" WHERE NVL(FechNeg,"") <> "";
				END IF						
			ELIF sTipLog = 2 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog2 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog2 = "Valor tipo_logica 2" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 3 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog3 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog3 = "Valor tipo_logica 3" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 4 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog4 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog4 = "Valor tipo_logica 4" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 5 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog5 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog5 = "Valor tipo_logica 5" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 6 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog6 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog6 = "Valor tipo_logica 6" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 7 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog7 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog7 = "Valor tipo_logica 7" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 8 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog8 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog8 = "Valor tipo_logica 8" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 9 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog9 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE				
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog9 = "Valor tipo_logica 9" WHERE NVL(FechNeg,"") <> "";
				END IF			
			END IF 															
		    --SE INCREMENTA CONTADOR PARA SABER CUANTAS TIPO LOGICAS SON.
			LET sContador = sContador + 1;
			
		END FOREACH;
		
		--SE CALCULA EL NUMERO DE LA ULTIMA LOGICA QUE SE ENCUENTRA EN EL CATALOGO.
		LET sContador2 = 9 - sContador; 
		LET sContador3 = sContador2;				
		
		--SE HACE CICLO PARA PONERLE EL TITULO POR DEFAULT A LAS LOGICAS QUE NO ESTUVIERON EN EL CATALOGO.
		FOR iI = sContador2 to 9 		
		    IF sContador2 = 1 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog1 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 2 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog2 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 3 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog3 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 4 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog4 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 5 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog5 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 6 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog6 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 7 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog7 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 8 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog8 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 9 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON SET ValTipLog9 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			END IF;			
			--SE INCREMENTAN CONTADORES PARA EL CICLO Y PARA FORMAR EL NOMBRE DE LOS ENCABEZADOS DEL ARCHIVO.
			LET sContador2 = sContador2 + 1;	
			LET sContador3 = sContador3 + 1;			
		END FOR;
						
		FOREACH 					
			--CONSULTA PARA OBTENER LA INFORMACION DE LOS COMPROMISOS DE PAGO/CONVENIO SEMBRADOS AL "".
			--Reporte 1 Montos de convenios.
			--Reporte 2 Cabtidad de convenios.
			--SE OBTIENE EL TOTALIZADO DE LOS DATOS POR FECHA Y POR CADA LOGICA.						  
			SELECT
				  NVL(SUBSTRING(a.horainicio FROM 1 FOR 10),"") AS FechaNeg,
				  NVL(SUM(CASE WHEN a.tipologica = 1 THEN 1 ELSE 0 END),0) AS TipLogInfTot1,
				  NVL(SUM(CASE WHEN a.tipologica = 2 THEN 1 ELSE 0 END),0) AS TipLogInfTot2,
				  NVL(SUM(CASE WHEN a.tipologica = 3 THEN 1 ELSE 0 END),0) AS TipLogInfTot3,
				  NVL(SUM(CASE WHEN a.tipologica = 4 THEN 1 ELSE 0 END),0) AS TipLogInfTot4,
				  NVL(SUM(CASE WHEN a.tipologica = 5 THEN 1 ELSE 0 END),0) AS TipLogInfTot5,
				  NVL(SUM(CASE WHEN a.tipologica = 6 THEN 1 ELSE 0 END),0) AS TipLogInfTot6,
				  NVL(SUM(CASE WHEN a.tipologica = 7 THEN 1 ELSE 0 END),0) AS TipLogInfTot7,
				  NVL(SUM(CASE WHEN a.tipologica = 8 THEN 1 ELSE 0 END),0) AS TipLogInfTot8,
				  NVL(SUM(CASE WHEN a.tipologica = 9 THEN 1 ELSE 0 END),0) AS TipLogInfTot9				  
			INTO cFechaNeg,iTipLogInfTot1,iTipLogInfTot2,iTipLogInfTot3,iTipLogInfTot4,iTipLogInfTot5,iTipLogInfTot6,iTipLogInfTot7,iTipLogInfTot8,iTipLogInfTot9
			FROM  bdicobranza: "informix".cb_cat_movimientos a
			    LEFT OUTER JOIN bdicobranza:"informix".cb_compac_his b ON(b.numcliente = LPAD(TRIM(a.cliente),9,"0"))				
			WHERE LPAD(TRIM(a.cliente),9,"0") = b.numcliente				
				AND a.horainicio::DATE = b.fecha_compac				
				AND b.origen = 3					
				AND a.cvemovimiento = "C"
				--AND a.fechacartera::DATE = dtFechaCorteMov
        AND a.fechacartera::DATE = dtFechaMaxCart						
				--AND b.fecha_compac = dtFechaCorteHis                           ---by MACF
				AND b.fecha_compac >= dtFechaIniMesAct AND b.fecha_compac <= dtFechaCorteHis  ---by MACF 
			GROUP BY 1
			ORDER BY 1 ASC 			
			--SE INSERTAN LOS TOTALIZADOS.
			INSERT INTO bdicobranza:"informix".TMP_COMPAGMON(Fech,TipLog1,TipLog2,TipLog3,TipLog4,TipLog5,TipLog6,TipLog7,TipLog8,TipLog9,TotPorDia,CampCatAct,Promedio)
			VALUES(cFechaNeg,iTipLogInfTot1,iTipLogInfTot2,iTipLogInfTot3,iTipLogInfTot4,iTipLogInfTot5,iTipLogInfTot6,iTipLogInfTot7,iTipLogInfTot8,iTipLogInfTot9,0,0,0.00);											
		END FOREACH;
		
		FOREACH 
			--SE OBTIENEN LOS TOTALIZADOS DE TOTALES POR DIA, CAMPAÑAS CAT ACTIVAS Y PROMEDIO DEL REPORTE.			
			SELECT FechaNegFin,TotPorDiaFin,(Tip1 + Tip2 + Tip3 + Tip4 + Tip5 + Tip6 + Tip7 + Tip8 + Tip9 ) AS CampCatActTmpFin
			INTO cFechaNegFin,iTotPorDiaFin,sCampCatActTmpFin
			FROM TABLE (MULTISET(   SELECT NVL(Fech,"") AS FechaNegFin, 
										   NVL((TipLog1 + TipLog2 + TipLog3 + TipLog4 + TipLog5 + TipLog6 + TipLog7 + TipLog8 + TipLog9 ),0) AS TotPorDiaFin,					
										   NVL(SUM(CASE WHEN TipLog1 > 0 THEN 1 ELSE 0 END),0) AS Tip1,
										   NVL(SUM(CASE WHEN TipLog2 > 0 THEN 1 ELSE 0 END),0) AS Tip2,
										   NVL(SUM(CASE WHEN TipLog3 > 0 THEN 1 ELSE 0 END),0) AS Tip3,
										   NVL(SUM(CASE WHEN TipLog4 > 0 THEN 1 ELSE 0 END),0) AS Tip4,
										   NVL(SUM(CASE WHEN TipLog5 > 0 THEN 1 ELSE 0 END),0) AS Tip5,
										   NVL(SUM(CASE WHEN TipLog6 > 0 THEN 1 ELSE 0 END),0) AS Tip6,
										   NVL(SUM(CASE WHEN TipLog7 > 0 THEN 1 ELSE 0 END),0) AS Tip7,
										   NVL(SUM(CASE WHEN TipLog8 > 0 THEN 1 ELSE 0 END),0) AS Tip8,
										   NVL(SUM(CASE WHEN TipLog9 > 0 THEN 1 ELSE 0 END),0) AS Tip9													
									FROM bdicobranza:"informix".TMP_COMPAGMON
									GROUP BY 1,2
									ORDER BY 1 ASC
						))														
			--SE CALCULA EL PROMEDIO DE COMPROMISOS DE PAGOS.
			LET dPromedioFin = iTotPorDiaFin/sCampCatActTmpFin;				
			--ACTUALIZAR LOS TOTALES EN LA TABLA TEMPORAL.
			UPDATE bdicobranza:"informix".TMP_COMPAGMON SET TotPorDia = iTotPorDiaFin ,CampCatAct = sCampCatActTmpFin,Promedio = NVL(dPromedioFin,0.00)
			WHERE Fech = cFechaNegFin;
		END FOREACH;
		
		FOREACH 
			--SE OBTIENE LA INFORMACION FINAL DE LA TEMPORAL.
			SELECT Fech,TipLog1,TipLog2,TipLog3,TipLog4,TipLog5,TipLog6,TipLog7,TipLog8,TipLog9,TotPorDia,CampCatAct,Promedio
			INTO cFechNegEncb,iTipLog1Encb,iTipLog2Encb,iTipLog3Encb,iTipLog4Encb,iTipLog5Encb,iTipLog6Encb,iTipLog7Encb,iTipLog8Encb,iTipLog9Encb,iTotPorDiaEncb,sCampCatActEncb,dPromedioEncb			
			FROM bdicobranza:"informix".TMP_COMPAGMON
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
			ORDER BY 1 ASC			
			--SE INSERTA LA INFORMACION FINAL EN LA TABLA DE ENCABEZADOS.
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
			VALUES(cFechNegEncb::CHAR(80),iTipLog1Encb::CHAR(80),iTipLog2Encb::CHAR(80),iTipLog3Encb::CHAR(80),iTipLog4Encb::CHAR(80),iTipLog5Encb::CHAR(80),iTipLog6Encb::CHAR(80),iTipLog7Encb::CHAR(80),iTipLog8Encb::CHAR(80),iTipLog9Encb::CHAR(80),iTotPorDiaEncb::CHAR(80),sCampCatActEncb::CHAR(80),dPromedioEncb::CHAR(80));				
		END FOREACH;
		
		--CALCULAR LOS TOTALES DE TODAS LAS COLUMNAS.
		SELECT NVL(SUM(TipLog1),0),NVL(SUM(TipLog2),0),NVL(SUM(TipLog3),0),NVL(SUM(TipLog4),0),NVL(SUM(TipLog5),0),NVL(SUM(TipLog6),0),NVL(SUM(TipLog7),0),NVL(SUM(TipLog8),0),NVL(SUM(TipLog9),0),NVL(SUM(TotPorDia),0),NVL(SUM(CampCatAct),0),NVL(SUM(Promedio),0.00)
		INTO iTipLog1Encb2,iTipLog2Encb2,iTipLog3Encb2,iTipLog4Encb2,iTipLog5Encb2,iTipLog6Encb2,iTipLog7Encb2,iTipLog8Encb2,iTipLog9Encb2,iTotPorDiaEncb2,sCampCatActEncb2,dPromedioEncb2
		FROM bdicobranza:"informix".TMP_COMPAGMON;
		
		--SE INSERTA LOS TOTALES FINALES JUNTO CON EL NOMBRE DE LA COLUMNA INFERIOR "Totales" EN LA TABLA DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("Total",iTipLog1Encb2::CHAR(80),iTipLog2Encb2::CHAR(80),iTipLog3Encb2::CHAR(80),iTipLog4Encb2::CHAR(80),iTipLog5Encb2::CHAR(80),iTipLog6Encb2::CHAR(80),iTipLog7Encb2::CHAR(80),iTipLog8Encb2::CHAR(80),iTipLog9Encb2::CHAR(80),iTotPorDiaEncb2::CHAR(80),sCampCatActEncb2::CHAR(80),dPromedioEncb2::CHAR(80));				
				
		--SE OBTIENE EL NOMBRE DEL ARCHIVO DEL MONTO DE CONVENIOS ACTIVADOS POR CAMPAÑA POR DIA.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		--WHERE cod_param = 80;	
		WHERE cod_param = 81;   --by MACF
		
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
									
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELCOMPAGMON";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		--SE ELIMINAN LAS TABLAS DE TRABAJO.
		IF cTabla="S" THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGMON;
		END IF;
		IF cTabla2 ="S" THEN
			DROP TABLE bdicobranza:"informix".TMP_COMPAGMON;
		END IF;		
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el compromiso de pago/Convenios sembrados al "" Reporte 1 Montos de convenios.', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121109.1214';

CREATE PROCEDURE "informix".sp_repcob_compago_montconv()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr				INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cCodRet,vvcCod_ret			CHAR(6);
		DEFINE cMensajeRet			CHAR(80);						
		DEFINE cNombreArchivo	  	CHAR(80); 
		DEFINE cConsulta		  	CHAR(2200);
		DEFINE cSql           		CHAR(1024);
		DEFINE cTabla		      	CHAR(1); 
		DEFINE cTabla2		      	CHAR(1); 
		DEFINE cRuta		      	CHAR(80);   										
		DEFINE dtFechaHoy 			DATE;		
		DEFINE dtFechaCorteHis		DATE;		
		DEFINE sTipLog				SMALLINT;						
		DEFINE cDescrip				CHAR(100);						
		DEFINE cFechaNeg			CHAR(10);												
		DEFINE sContador		    SMALLINT;
		DEFINE sContador2		    SMALLINT;
		DEFINE sContador3		    SMALLINT;		
		DEFINE cFechaNegFin	    	CHAR(10);
		DEFINE dTotPorDiaFin	    DECIMAL(18,2);
		DEFINE sCampCatActTmpFin    SMALLINT;
		DEFINE iI				    INTEGER;
		DEFINE dPromedioFin		    DECIMAL(18,2);
		DEFINE dTipLogInfTot1	    DECIMAL(18,2);
		DEFINE dTipLogInfTot2	    DECIMAL(18,2);
		DEFINE dTipLogInfTot3	    DECIMAL(18,2);
		DEFINE dTipLogInfTot4	    DECIMAL(18,2);
		DEFINE dTipLogInfTot5	    DECIMAL(18,2);
		DEFINE dTipLogInfTot6	    DECIMAL(18,2);
		DEFINE dTipLogInfTot7	    DECIMAL(18,2);
		DEFINE dTipLogInfTot8	    DECIMAL(18,2);
		DEFINE dTipLogInfTot9	    DECIMAL(18,2);
		DEFINE cFechNegEncb	        CHAR(10);
		DEFINE dTipLog1Encb	        DECIMAL(18,2);
		DEFINE dTipLog2Encb	        DECIMAL(18,2);
		DEFINE dTipLog3Encb	        DECIMAL(18,2);
		DEFINE dTipLog4Encb	        DECIMAL(18,2);
		DEFINE dTipLog5Encb	        DECIMAL(18,2);
		DEFINE dTipLog6Encb	        DECIMAL(18,2);
		DEFINE dTipLog7Encb	        DECIMAL(18,2);
		DEFINE dTipLog8Encb	        DECIMAL(18,2);
		DEFINE dTipLog9Encb	        DECIMAL(18,2);
		DEFINE dTotPorDiaEncb       DECIMAL(18,2);
		DEFINE sCampCatActEncb      SMALLINT;
		DEFINE dPromedioEncb      	DECIMAL(18,2);		
		DEFINE dTipLog1Encb2	    DECIMAL(18,2);
		DEFINE dTipLog2Encb2	    DECIMAL(18,2);
		DEFINE dTipLog3Encb2	    DECIMAL(18,2);
		DEFINE dTipLog4Encb2	    DECIMAL(18,2);
		DEFINE dTipLog5Encb2	    DECIMAL(18,2);
		DEFINE dTipLog6Encb2	    DECIMAL(18,2);
		DEFINE dTipLog7Encb2	    DECIMAL(18,2);
		DEFINE dTipLog8Encb2	    DECIMAL(18,2);
		DEFINE dTipLog9Encb2	    DECIMAL(18,2);
		DEFINE dTotPorDiaEncb2      DECIMAL(18,2);
		DEFINE sCampCatActEncb2     SMALLINT;
		DEFINE dPromedioEncb2      	DECIMAL(18,2);						
		DEFINE dtFechEnc			DATE;
		DEFINE cFechEnc2			CHAR(10);		
		DEFINE dtFechaIniMesAct  DATE;
    DEFINE v_empresa       CHAR(3);
	  DEFINE cProceso        CHAR(4);
    DEFINE dtFechaMax, dtFechaMaxCart      DATE;
        			
		---INICIALIZACIONES
		LET iSqlErr            	= 0;
		LET iIsamErr           	= 0;
		LET cCodRet            	= "000000";
		LET cMensajeRet			= "Proceso exitoso";				
		LET cNombreArchivo 		= "";
		LET cConsulta	 		= "";
		LET cSql		 		= "";
		LET cTabla		 		= "N";
		LET cTabla2		 		= "N";
		LET cRuta		 		= "";										
		LET dtFechaHoy          = "";		
		LET dtFechaCorteHis     = "";		
		LET sTipLog     		= 0;						
		LET cDescrip     		= "";						
		LET cFechaNeg     		= "";										
		LET sContador	 		= 0;
		LET sContador2	 		= 0;
		LET sContador3	 		= 0;				
		LET cFechaNegFin 		= "";
		LET dTotPorDiaFin 		= 0.00;
		LET sCampCatActTmpFin	= 0;
		LET iI					= 0;
		LET dPromedioFin		= 0.00;
		LET dTipLogInfTot1		= 0.00;
		LET dTipLogInfTot2		= 0.00;
		LET dTipLogInfTot3		= 0.00;
		LET dTipLogInfTot4		= 0.00;
		LET dTipLogInfTot5		= 0.00;
		LET dTipLogInfTot6		= 0.00;
		LET dTipLogInfTot7		= 0.00;
		LET dTipLogInfTot8		= 0.00;
		LET dTipLogInfTot9		= 0.00;
		LET cFechNegEncb		= "";
		LET dTipLog1Encb		= 0.00;
		LET dTipLog2Encb		= 0.00;
		LET dTipLog3Encb		= 0.00;
		LET dTipLog4Encb		= 0.00;
		LET dTipLog5Encb		= 0.00;
		LET dTipLog6Encb		= 0.00;
		LET dTipLog7Encb		= 0.00;
		LET dTipLog8Encb		= 0.00;
		LET dTipLog9Encb		= 0.00;
		LET dTotPorDiaEncb		= 0.00;
		LET sCampCatActEncb		= 0;
		LET dPromedioEncb		= 0.00;		
		LET dTipLog1Encb2		= 0.00;
		LET dTipLog2Encb2		= 0.00;
		LET dTipLog3Encb2		= 0.00;
		LET dTipLog4Encb2		= 0.00;
		LET dTipLog5Encb2		= 0.00;
		LET dTipLog6Encb2		= 0.00;
		LET dTipLog7Encb2		= 0.00;
		LET dTipLog8Encb2		= 0.00;
		LET dTipLog9Encb2		= 0.00;
		LET dTotPorDiaEncb2		= 0.00;
		LET sCampCatActEncb2	= 0;
		LET dPromedioEncb2		= 0.00;
		LET dtFechEnc			= "";
		LET cFechEnc2			= "";
		LET dtFechaIniMesAct = DATE(1);
		LET v_empresa = '001';
	  LET cProceso = '0078';
    LET vvcCod_ret = '';
    LET dtFechaMax = date(1); LET dtFechaMaxCart = date(1); 
    		
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;			  								
				IF cTabla="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN;
				END IF;
				IF cTabla2 ="S" THEN
					DROP TABLE bdicobranza:"informix".TMP_COMPAGCAN;
				END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
        										
				RETURN cCodRet, cMensajeRet;				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_compago_cantconv.out";
		--SET DEBUG FILE TO "/informix/macf/sp_repcob_compago_montoconv.trc"
		--TRACE ON;
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELCOMPAGCAN" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
		 	  DROP TABLE TMP_ENCABEZADOSEXCELCOMPAGCAN;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_COMPAGCAN" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
		 	  DROP TABLE TMP_COMPAGCAN;
		END IF;
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
     
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		
		--LET dtFechaHoy = mdy('01','30','2013');   --- TEST MACF
		--LET dtFechaIniMesAct = mdy('01','01','2013');   --- TEST MACF 
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
		SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		  FROM bdicobranza:"informix".cb_cat_movimientos
		 WHERE tipocobranza = 'A';
		
		--IF DAY(dtFechaHoy) = 1 THEN 			
		--	LET cCodRet = '000001';
		--	LET cMensajeRet = "No es posible generar el archivo los días primero de cada mes";
		--	RETURN cCodRet, cMensajeRet;
		--END IF
     
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA CORTE.
		--IF DAY(dtFechaHoy) <= 21 THEN 			
		--	LET dtFechaCorteMov = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy)) - 1 UNITS MONTH;			
		--ELSE 
		--	LET dtFechaCorteMov = MDY(MONTH(dtFechaHoy),21,YEAR(dtFechaHoy));			
		--END IF 									
		
		--LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;					
		
    --SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.							
		IF DAY(dtFechaHoy) = 1 THEN
		   LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		   LET dtFechaIniMesAct = MDY(MONTH(dtFechaCorteHis),1,YEAR(dtFechaCorteHis));
		ELIF DAY(dtFechaHoy) = 2 THEN
		   LET dtFechaIniMesAct = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		   LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
    ELSE
       LET dtFechaIniMesAct = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
       LET dtFechaCorteHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		END IF;
    
    
    --SE CALCULA LA FECHA DEL ENCABEZADO DEL ARCHIVO.
		LET dtFechEnc = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		LET cFechEnc2 =  LPAD(DAY(dtFechEnc),2,0)||"/"||LPAD(MONTH(dtFechEnc),2,0)||"/"||YEAR(dtFechEnc);
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN(					
																			FechNeg		CHAR(80),
																			ValTipLog1	CHAR(80),
																			ValTipLog2	CHAR(80),
																			ValTipLog3	CHAR(80),
																			ValTipLog4	CHAR(80),
																			ValTipLog5	CHAR(80),
																			ValTipLog6	CHAR(80),
																			ValTipLog7	CHAR(80),
																			ValTipLog8	CHAR(80),
																			ValTipLog9	CHAR(80),
																			TotPorDia	CHAR(80),
																			CampCatAct	CHAR(80),
																			Promedio	CHAR(80)
																		 );			
		--BANDERA PARA DETERMINAR QUE SI SE CREO LA TABLA DE TRABAJO.
		LET cTabla="S";		
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_COMPAGCAN(					
																Fech		CHAR(10),
																TipLog1		DECIMAL(18,2),
																TipLog2		DECIMAL(18,2),
																TipLog3		DECIMAL(18,2),
																TipLog4		DECIMAL(18,2),
																TipLog5		DECIMAL(18,2),
																TipLog6		DECIMAL(18,2),
																TipLog7		DECIMAL(18,2),
																TipLog8		DECIMAL(18,2),
																TipLog9		DECIMAL(18,2),
																TotPorDia	DECIMAL(18,2),
																CampCatAct	SMALLINT,
																Promedio	DECIMAL(18,2)
															  );	
		--BANDERA PARA DETERMINAR QUE SI SE CREO LA TABLA DE TRABAJO.
		LET cTabla2="S";															
				 		
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("","","Compromisos de pago/Convenios sembrados al: "||cFechEnc2,"","","","","","","","","","");						
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		--VALUES("","","","Cantidad de convenios activados por campana por dia","","","","","","","","","");
    VALUES("","","","Montos de convenios activados por campana por dia","","","","","","","","","");						
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("Fecha Negociacion","0","0","0","0","0","0","0","0","0","Totales x dia","Campanas CAT Activas","Promedio");						
		
		FOREACH			  				
			--SE OBTIENE LA DESCRIPCION DE LA LOGICA.
			SELECT valor_numerico,descripcion
			INTO sTipLog,cDescrip
			FROM bdicobranza:"informix".cb_param_campania
			WHERE grupo_parametro = "LOGICA"
											
			--SE VALIDA EL TIPO DE LOGICA PARA 
			IF sTipLog = 1 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog1 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog1 = "Valor tipo_logica 1" WHERE NVL(FechNeg,"") <> "";
				END IF						
			ELIF sTipLog = 2 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog2 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog2 = "Valor tipo_logica 2" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 3 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog3 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog3 = "Valor tipo_logica 3" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 4 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog4 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog4 = "Valor tipo_logica 4" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 5 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog5 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog5 = "Valor tipo_logica 5" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 6 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog6 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog6 = "Valor tipo_logica 6" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 7 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog7 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog7 = "Valor tipo_logica 7" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 8 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog8 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog8 = "Valor tipo_logica 8" WHERE NVL(FechNeg,"") <> "";
				END IF
			ELIF sTipLog = 9 THEN 
				IF NVL(cDescrip,"") <> "" THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog9 = TRIM(cDescrip) WHERE NVL(FechNeg,"") <> "";
				ELSE				
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog9 = "Valor tipo_logica 9" WHERE NVL(FechNeg,"") <> "";
				END IF			
			END IF 															
		    --SE INCREMENTA CONTADOR PARA SABER CUANTAS TIPO LOGICAS SON.
			LET sContador = sContador + 1;
			
		END FOREACH;
		
		--SE CALCULA EL NUMERO DE LA ULTIMA LOGICA QUE SE ENCUENTRA EN EL CATALOGO.
		LET sContador2 = 9 - sContador; 
		LET sContador3 = sContador2;				
		
		--SE HACE CICLO PARA PONERLE EL TITULO POR DEFAULT A LAS LOGICAS QUE NO ESTUVIERON EN EL CATALOGO.
		FOR iI = sContador2 to 9 		
		    IF sContador2 = 1 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog1 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 2 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog2 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 3 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog3 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 4 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog4 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 5 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog5 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 6 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog6 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 7 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog7 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 8 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog8 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			ELIF sContador2 = 9 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN SET ValTipLog9 = "Valor tipo_logica"||sContador3 WHERE NVL(FechNeg,"") <> "";
			END IF;			
			--SE INCREMENTAN CONTADORES PARA EL CICLO Y PARA FORMAR EL NOMBRE DE LOS ENCABEZADOS DEL ARCHIVO.
			LET sContador2 = sContador2 + 1;	
			LET sContador3 = sContador3 + 1;			
		END FOR;
						
		FOREACH 					
			--CONSULTA PARA OBTENER LA INFORMACION DE LOS COMPROMISOS DE PAGO/CONVENIO SEMBRADOS AL "".
			--Reporte 1 Montos de convenios.
			--Reporte 2 Cabtidad de convenios.
			--SE OBTIENE EL TOTALIZADO DE LOS DATOS POR FECHA Y POR CADA LOGICA.						  
			SELECT
				  NVL(SUBSTRING(a.horainicio FROM 1 FOR 10),"") AS FechaNeg,
				  NVL(SUM(CASE WHEN tipologica = 1 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot1,
				  NVL(SUM(CASE WHEN tipologica = 2 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot2,
				  NVL(SUM(CASE WHEN tipologica = 3 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot3,
				  NVL(SUM(CASE WHEN tipologica = 4 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot4,
				  NVL(SUM(CASE WHEN tipologica = 5 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot5,
				  NVL(SUM(CASE WHEN tipologica = 6 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot6,
				  NVL(SUM(CASE WHEN tipologica = 7 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot7,
				  NVL(SUM(CASE WHEN tipologica = 8 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot8,
				  NVL(SUM(CASE WHEN tipologica = 9 THEN b.importe ELSE 0 END),0.00) AS TipLogInfTot9				  
			INTO cFechaNeg,dTipLogInfTot1,dTipLogInfTot2,dTipLogInfTot3,dTipLogInfTot4,dTipLogInfTot5,dTipLogInfTot6,dTipLogInfTot7,dTipLogInfTot8,dTipLogInfTot9
			FROM  bdicobranza: "informix".cb_cat_movimientos a
			    LEFT OUTER JOIN bdicobranza:"informix".cb_compac_his b ON(b.numcliente = LPAD(TRIM(a.cliente),9,"0"))				
			WHERE LPAD(TRIM(a.cliente),9,"0") = b.numcliente				
				AND a.horainicio::DATE = b.fecha_compac				
				AND b.origen = 3	
				AND a.cvemovimiento = "C"				
				--AND a.fechacartera::DATE = dtFechaCorteMov
        AND a.fechacartera::DATE = dtFechaMaxCart										
				--AND b.fecha_compac = dtFechaCorteHis                                        ---by MACF  
        AND b.fecha_compac >= dtFechaIniMesAct AND b.fecha_compac <= dtFechaCorteHis  ---by MACF
			GROUP BY 1
			ORDER BY 1 ASC 			
			--SE INSERTAN LOS TOTALIZADOS.
			INSERT INTO bdicobranza:"informix".TMP_COMPAGCAN(Fech,TipLog1,TipLog2,TipLog3,TipLog4,TipLog5,TipLog6,TipLog7,TipLog8,TipLog9,TotPorDia,CampCatAct,Promedio)
			VALUES(cFechaNeg,dTipLogInfTot1,dTipLogInfTot2,dTipLogInfTot3,dTipLogInfTot4,dTipLogInfTot5,dTipLogInfTot6,dTipLogInfTot7,dTipLogInfTot8,dTipLogInfTot9,0,0,0.00);											
		END FOREACH;
		
		FOREACH 
			--SE OBTIENEN LOS TOTALIZADOS DE TOTALES POR DIA, CAMPAÑAS CAT ACTIVAS Y PROMEDIO DEL REPORTE.			
			SELECT FechaNegFin,TotPorDiaFin,(Tip1 + Tip2 + Tip3 + Tip4 + Tip5 + Tip6 + Tip7 + Tip8 + Tip9 ) AS CampCatActTmpFin
			INTO cFechaNegFin,dTotPorDiaFin,sCampCatActTmpFin
			FROM TABLE (MULTISET(   SELECT NVL(Fech,"") AS FechaNegFin, 
										   NVL((TipLog1 + TipLog2 + TipLog3 + TipLog4 + TipLog5 + TipLog6 + TipLog7 + TipLog8 + TipLog9 ),0.00) AS TotPorDiaFin,					
										   NVL(SUM(CASE WHEN TipLog1 > 0 THEN 1 ELSE 0 END),0) AS Tip1,
										   NVL(SUM(CASE WHEN TipLog2 > 0 THEN 1 ELSE 0 END),0) AS Tip2,
										   NVL(SUM(CASE WHEN TipLog3 > 0 THEN 1 ELSE 0 END),0) AS Tip3,
										   NVL(SUM(CASE WHEN TipLog4 > 0 THEN 1 ELSE 0 END),0) AS Tip4,
										   NVL(SUM(CASE WHEN TipLog5 > 0 THEN 1 ELSE 0 END),0) AS Tip5,
										   NVL(SUM(CASE WHEN TipLog6 > 0 THEN 1 ELSE 0 END),0) AS Tip6,
										   NVL(SUM(CASE WHEN TipLog7 > 0 THEN 1 ELSE 0 END),0) AS Tip7,
										   NVL(SUM(CASE WHEN TipLog8 > 0 THEN 1 ELSE 0 END),0) AS Tip8,
										   NVL(SUM(CASE WHEN TipLog9 > 0 THEN 1 ELSE 0 END),0) AS Tip9													
									FROM bdicobranza:"informix".TMP_COMPAGCAN
									GROUP BY 1,2
									ORDER BY 1 ASC
						))														
			--SE CALCULA EL PROMEDIO DE COMPROMISOS DE PAGOS.
			LET dPromedioFin = dTotPorDiaFin/sCampCatActTmpFin;				
			--ACTUALIZAR LOS TOTALES EN LA TABLA TEMPORAL.
			UPDATE bdicobranza:"informix".TMP_COMPAGCAN SET TotPorDia = dTotPorDiaFin ,CampCatAct = sCampCatActTmpFin,Promedio = NVL(dPromedioFin,0.00)
			WHERE Fech = cFechaNegFin;
		END FOREACH;				
		
		FOREACH 
			--SE OBTIENE LA INFORMACION FINAL DE LA TEMPORAL.
			SELECT Fech,TipLog1,TipLog2,TipLog3,TipLog4,TipLog5,TipLog6,TipLog7,TipLog8,TipLog9,TotPorDia,CampCatAct,Promedio
			INTO cFechNegEncb,dTipLog1Encb,dTipLog2Encb,dTipLog3Encb,dTipLog4Encb,dTipLog5Encb,dTipLog6Encb,dTipLog7Encb,dTipLog8Encb,dTipLog9Encb,dTotPorDiaEncb,sCampCatActEncb,dPromedioEncb			
			FROM bdicobranza:"informix".TMP_COMPAGCAN
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
			ORDER BY 1 ASC			
			--SE INSERTA LA INFORMACION FINAL EN LA TABLA DE ENCABEZADOS.
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
			VALUES(cFechNegEncb::CHAR(80),dTipLog1Encb::CHAR(80),dTipLog2Encb::CHAR(80),dTipLog3Encb::CHAR(80),dTipLog4Encb::CHAR(80),dTipLog5Encb::CHAR(80),dTipLog6Encb::CHAR(80),dTipLog7Encb::CHAR(80),dTipLog8Encb::CHAR(80),dTipLog9Encb::CHAR(80),dTotPorDiaEncb::CHAR(80),sCampCatActEncb::CHAR(80),'$'||dPromedioEncb::CHAR(80));							
		END FOREACH;
		
		--CALCULAR LOS TOTALES DE TODAS LAS COLUMNAS.
		SELECT NVL(SUM(TipLog1),0.00),NVL(SUM(TipLog2),0.00),NVL(SUM(TipLog3),0.00),NVL(SUM(TipLog4),0.00),NVL(SUM(TipLog5),0.00),NVL(SUM(TipLog6),0.00),NVL(SUM(TipLog7),0.00),NVL(SUM(TipLog8),0.00),NVL(SUM(TipLog9),0.00),NVL(SUM(TotPorDia),0.00),NVL(SUM(CampCatAct),0),NVL(SUM(Promedio),0.00)
		INTO dTipLog1Encb2,dTipLog2Encb2,dTipLog3Encb2,dTipLog4Encb2,dTipLog5Encb2,dTipLog6Encb2,dTipLog7Encb2,dTipLog8Encb2,dTipLog9Encb2,dTotPorDiaEncb2,sCampCatActEncb2,dPromedioEncb2
		FROM bdicobranza:"informix".TMP_COMPAGCAN;
		
		--SE INSERTA LOS TOTALES FINALES JUNTO CON EL NOMBRE DE LA COLUMNA INFERIOR "Totales" EN LA TABLA DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN (FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio)
		VALUES("Total",'$'||dTipLog1Encb2::CHAR(80),'$'||dTipLog2Encb2::CHAR(80),'$'||dTipLog3Encb2::CHAR(80),'$'||dTipLog4Encb2::CHAR(80),'$'||dTipLog5Encb2::CHAR(80),'$'||dTipLog6Encb2::CHAR(80),'$'||dTipLog7Encb2::CHAR(80),'$'||dTipLog8Encb2::CHAR(80),'$'||dTipLog9Encb2::CHAR(80),'$'||dTotPorDiaEncb2::CHAR(80),sCampCatActEncb2::CHAR(80),'$'||dPromedioEncb2::CHAR(80));				
				
		--SE OBTIENE EL NOMBRE DEL ARCHIVO DE LA CANTIDAD DE CONVENIOS ACTIVADOS POR CAMPAÑA POR DIA.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 80;	
		
		
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
								
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT FechNeg,ValTipLog1,ValTipLog2,ValTipLog3,ValTipLog4,ValTipLog5,ValTipLog6,ValTipLog7,ValTipLog8,ValTipLog9,TotPorDia,CampCatAct,Promedio FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELCOMPAGCAN";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		--SE ELIMINAN LAS TABLAS DE TRABAJO.
		IF cTabla="S" THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCOMPAGCAN;
		END IF;
		IF cTabla2 ="S" THEN
			DROP TABLE bdicobranza:"informix".TMP_COMPAGCAN;
		END IF;		
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;		
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el compromiso de pago/Convenios sembrados al "" Reporte 2 Cantidad de convenios.', 
'AUTOR: Guadalupe Payan',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121109.1214';

CREATE PROCEDURE "informix".sp_repcob_compago_negsuperv()
	RETURNING
		CHAR(6)  AS COD_RET,
		CHAR(80) AS MENSAJE_RET;
		
		-- DECLARACIONES
		DEFINE iSqlErr					        INTEGER;
		DEFINE iIsamErr					        INTEGER;
    DEFINE cTabla, cTurno_Mat, cTurno_Vesp	      CHAR(1);
    DEFINE cDiaIni      			      CHAR(2);
    DEFINE v_empresa                CHAR(3);
	  DEFINE cProceso                 CHAR(4);				
		DEFINE cCodRet,vvcCod_ret       CHAR(6);
		DEFINE cFechEnc2				        CHAR(10);
		DEFINE cSupervisor              CHAR(20);
		DEFINE cMensajeRet, cNombreArchivo, cRuta, cSupervisor_Mat, cNombre_Mat, cSupervisor_Vesp, cNombre_Vesp				      CHAR(80);
    DEFINE cMensajeRet2             CHAR(200); 		
		DEFINE cConsulta		  		      CHAR(2200);
		DEFINE cSql           			    CHAR(1024);
		 
  
		DEFINE dtFechaHoy, dtFecha, dtFechaCorteIniHis, dtFechaCorteFinHis, dtFechEnc, dtFechMesAnt_Fin		    DATE;						
		DEFINE iDiasTrab, iNegociacionTot, iNegociacionTotMat, iNegociacionTotVes, iNegociacion, iCantSupervMat, iCantSupervVes, iNegociacion_Mat	  		      INTEGER;
		DEFINE dMontoNegTot, dMontoNegTotMat, dMontoNegTotVes, dMontoneg_Mat, dMontoneg_Vesp			      DECIMAL(18,2);
		DEFINE iNegociacion_Vesp, iCanSuperTot		    INTEGER;				

		DEFINE dePorNegoc, dePor_Mat, dePromNegDrio_Mat, dePor_Vesp, dePromNegDrio_Vesp, dPromNegSupMat, dPromNegSupMat2, dPromNegSupVesp        	DECIMAL(14,2);
		DEFINE dePromNegDrio, dPromNegSupVesp2, dPromNegSupTot, dPromNegSupTot2            DECIMAL(14,2);    
		
		-- INICIALIZACIONES
		LET iSqlErr            		= 0;   LET iIsamErr           		= 0;   LET iDiasTrab			        = 0;    LET iNegociacionTot     	= 0;
		LET iNegociacionTotMat    = 0;   LET iNegociacionTotVes    = 0;    LET iNegociacion			    = 0;      LET iCantSupervMat        = 0; 
		LET iCantSupervVes        = 0;   LET iNegociacion_Mat		  = 0;     LET iNegociacion_Vesp		  = 0;    LET iCanSuperTot          = 0; 
    LET cCodRet            		= "000000";
		LET cMensajeRet				    = "Proceso exitoso";
		LET cTabla		 			      = "N";
		LET cNombreArchivo 			  = "";   LET cConsulta	 			      = "";   LET cSql		 			        = "";
		LET cRuta		 			        = "";		LET dtFechaHoy          	= "";		LET dtFecha		          	= "";						
		LET dtFechaCorteIniHis    = "";   LET dtFechaCorteFinHis    = "";		LET cDiaIni               = "";
    LET cSupervisor           = "";   LET cSupervisor_Mat			  = "";   LET cNombre_Mat				    = "";
    LET cTurno_Vesp				    = "";   LET cSupervisor_Vesp		  = "";   LET cNombre_Vesp      		= "";
 		LET dtFechEnc				      = "";   LET cFechEnc2				      = "";	
		LET dMontoNegTot	 		    = 0.00;   LET dMontoNegTotMat 		  = 0.00;   LET dMontoNegTotVes 		  = 0.00;	
		LET dePorNegoc            = 0.00;   LET dePromNegDrio         = 0.00;		LET cTurno_Mat				    = "";
		LET dMontoneg_Mat         = 0.00;		LET dePor_Mat             = 0.00;		LET dePromNegDrio_Mat 		= 0.00;		
		LET dMontoneg_Vesp        = 0.00;   LET dePor_Vesp            = 0.00;		LET dePromNegDrio_Vesp 		= 0.00;		
		LET dPromNegSupMat        = 0.00;		LET dPromNegSupMat2       = 0.00;		LET dPromNegSupVesp       = 0.00;
		LET dPromNegSupVesp2      = 0.00;		LET dPromNegSupTot        = 0.00;		LET dPromNegSupTot2       = 0.00;
		LET v_empresa = '001';              LET cMensajeRet2 = '';
	  LET cProceso = '0080';
    LET vvcCod_ret = '';
    LET dtFechMesAnt_Fin = date(1);
    		
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;
				 
				--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.									 						
	 			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_mat" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
					DROP TABLE tmp_compagconvsem_mat;
				END IF; 
				
		 		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemm" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP TABLE tmp_compagconvsemm;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_vesp" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
					DROP TABLE tmp_compagconvsem_vesp;
				END IF; 
				
		 		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemv" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP TABLE tmp_compagconvsemv;
				END IF;
						
 				IF cTabla = "S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB;
				END IF; 
				
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_repcob_compago_negsuperv.out";
		--TRACE ON;	
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.									 						
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_mat" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
			DROP TABLE tmp_compagconvsem_mat;
		END IF; 
		
 		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemm" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_compagconvsemm;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_vesp" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
			DROP TABLE tmp_compagconvsem_vesp;
		END IF; 
		
 		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemv" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_compagconvsemv;
		END IF;
		
    IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOS_CONSEMB" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE TMP_ENCABEZADOS_CONSEMB;
		END IF;
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		
		--SE OBTIENE LA FECHA DE HOY.
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		
		--LET dtFechaHoy = mdy('01','22','2012');   --- TEST MACF
		--LET dtFechaHoy = mdy('01','02','2012');
    --LET dtFechaHoy = mdy('12','02','2011');   --- TEST MACF   ok
		
		--IF DAY(dtFechaHoy) = 1 THEN 			
			--LET cCodRet = '000002';
			--LET cMensajeRet = "No es posible generar el archivo los dias primero de cada mes";
			--RETURN cCodRet, cMensajeRet;
		--END IF
     
     
		--SE VALIDA LA FECHA DE HOY PARA DETERMINAR LA FECHA INICIAL Y LA FINAL DEL CORTE.							
		IF DAY(dtFechaHoy) = 1 THEN
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaCorteFinHis),1,YEAR(dtFechaCorteFinHis));
		ELIF DAY(dtFechaHoy) = 2 THEN
		   LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
		   LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
    ELSE
       LET dtFechaCorteIniHis = MDY(MONTH(dtFechaHoy),1,YEAR(dtFechaHoy));
       LET dtFechaCorteFinHis = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		END IF;
    
    --LET cMensajeRet2 =  'dtFechaHoy = ' || to_char(dtFechaHoy) || ' - dtFechaCorteIniHis= ' || to_char(dtFechaCorteIniHis) || ' - dtFechaCorteFinHis= ' || to_char(dtFechaCorteFinHis);
    
		
		--SE CALCULA LA FECHA DEL ENCABEZADO DEL ARCHIVO.
		LET dtFechEnc = MDY(MONTH(dtFechaHoy),DAY(dtFechaHoy),YEAR(dtFechaHoy)) - 1 UNITS DAY;
		LET cFechEnc2 =  LPAD(DAY(dtFechEnc),2,0)||"/"||LPAD(MONTH(dtFechEnc),2,0)||"/"||YEAR(dtFechEnc);
		
		--SE OBTIENE LA FECHA DEL DIA ANTERIOR	
		LET dtFecha = dtFechaHoy - 1 UNITS DAY;

		LET cDiaIni = DAY(dtFecha);
		
		--SE OBTINE EL TOTAL DE DIAS TRABAJADOS
		LET iDiasTrab = cDiaIni::INTEGER;
		
    			
		-- SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB(
																		TURNO 				CHAR(10),
																		SUPERVISOR 			CHAR(80),
																		NOMBRE				CHAR(80),
																		NEGOCIACIONES 		CHAR(80),
																		MONTONEG		 	CHAR(80),
																		PORCENTAJE			CHAR(80),
																		PROMNEGDIA			CHAR(80)
																	);		
		
		LET cTabla = "S";
				
 		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
		VALUES("","","Compromisos de pago/convenios sembrados al: "||cFechEnc2,"","","","");
		
		--GENERACION DE TABLA TEMPORAL CON INFORMACION DE LOS CONVENIOS DEL TURNO MATUTINO
		SELECT NVL(cteje.numgrupo, "") AS Turno, NVL(cmp.efectuo_compac, "") AS Supervisor, NVL(TRIM(dts.nombre), " ")||" "||NVL(TRIM(dts.apellidopaterno), " ")||" "||NVL(TRIM(dts.apellidomaterno), " ") AS Nombre, COUNT(cmp.efectuo_compac) AS Negociaciones,SUM(cmp.importe) AS MontoNeg, CAST(0.00 AS DECIMAL(14,2)) AS Porc, CAST(0.00 AS DECIMAL(14,2)) AS PromNegDia
		FROM bdicobranza:"informix".cb_compac cmp
			 LEFT OUTER JOIN bdicobranza:"informix".cb_cat_datosgenerales dts on (dts.numempleado = cmp.efectuo_compac)
			 LEFT OUTER JOIN bdicobranza:"informix".cb_catejecutivos cteje on (cteje.numempleado = cmp.efectuo_compac )
		WHERE cmp.origen = 3				 
			AND SUBSTR(cteje.numgrupo,1,1) = "M"
			AND cmp.fecha_compac >= dtFechaCorteIniHis
			AND cmp.fecha_compac <= dtFechaCorteFinHis
		GROUP BY 1,2,3
			UNION ALL
		SELECT NVL(cteje.numgrupo, "") AS Turno, NVL(cmphis.efectuo_compac, "") AS Supervisor, NVL(TRIM(dts.nombre), " ")||" "||NVL(TRIM(dts.apellidopaterno), " ")||" "||NVL(TRIM(dts.apellidomaterno), " ") AS Nombre, COUNT(cmphis.efectuo_compac) AS Negociaciones,SUM(cmphis.importe) AS MontoNeg, CAST(0.00 AS DECIMAL(14,2)) AS Porc, CAST(0.00 AS DECIMAL(14,2)) AS PromNegDia
		FROM bdicobranza:"informix".cb_compac_his cmphis
			 LEFT OUTER JOIN bdicobranza:"informix".cb_cat_datosgenerales dts on (dts.numempleado = cmphis.efectuo_compac)
			 LEFT OUTER JOIN bdicobranza:"informix".cb_catejecutivos cteje on (cteje.numempleado = cmphis.efectuo_compac)
		WHERE cmphis.origen = 3				
			AND SUBSTR(cteje.numgrupo,1,1) = "M"
			AND cmphis.fecha_compac >= dtFechaCorteIniHis
			AND cmphis.fecha_compac <= dtFechaCorteFinHis
		GROUP BY 1,2,3
		INTO TEMP tmp_compagconvsemm WITH NO LOG;
			
		SELECT turno, supervisor, nombre, SUM(negociaciones) AS negociaciones, SUM(montoneg) AS montoneg,sum(porc) AS porc, sum(promnegdia) AS promnegdia
		FROM tmp_compagconvsemm
		GROUP BY 1,2,3
		INTO TEMP tmp_compagconvsem_mat;
		
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS DEL TURNO MATUTINO.
		SELECT COUNT(supervisor),SUM(Negociaciones),SUM(MontoNeg)
		INTO iCantSupervMat, iNegociacionTotMaT, dMontoNegTotMat
		FROM tmp_compagconvsem_mat;
		
		
		IF iNegociacionTotMaT = 0 OR iDiasTrab = 0 OR iCantSupervMat = 0  THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "Error de datos, NO es posible realizar una division entre Cero";
			--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_mat" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
				DROP TABLE tmp_compagconvsem_mat;
			END IF; 
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemm" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_compagconvsemm;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_vesp" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
				DROP TABLE tmp_compagconvsem_vesp;
			END IF; 
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemv" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_compagconvsemv;
			END IF;
					
			IF cTabla = "S" THEN
				DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB;
			END IF; 				
			
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
			
			LET cCodRet = "000000";
			LET cMensajeRet = "Proceso exitoso";
			
			RETURN cCodRet, cMensajeRet;
		END IF;
				
		--SE OBTIENE EL PORCENTAJE Y EL PROMEDIO DE NEGOCIOACIONES DIARIAS DEL TURNO MATUTINO
		FOREACH
			SELECT Supervisor, Negociaciones
			INTO cSupervisor, iNegociacion
			FROM tmp_compagconvsem_mat
			 	
				LET dePorNegoc = CAST((iNegociacion/iNegociacionTotMaT) * 100 AS DECIMAL(14,2)) ;
				LET dePromNegDrio = CAST((iNegociacion/iDiasTrab)* 100 AS DECIMAL(14,2));
			
			UPDATE tmp_compagconvsem_mat
			SET Porc = NVL(dePorNegoc,0),
				PromNegDia = NVL(dePromNegDrio,0)
			WHERE Supervisor = cSupervisor;						
		END FOREACH
		
		INSERT INTO tmp_compagconvsem_mat (turno, supervisor, nombre, negociaciones, montoneg, porc, promnegdia)
		VALUES("", "", "Total", iNegociacionTotMaT,dMontoNegTotMat,"", ""  );
					
		--GENERACION DE TABLA TEMPORAL CON INFORMACION DE LOS CONVENIOS DEL TURNO VESPERTINO
		SELECT NVL(cteje.numgrupo, "") AS Turno, NVL(cmp.efectuo_compac, "") AS Supervisor, NVL(TRIM(dts.nombre), " ")||" "||NVL(TRIM(dts.apellidopaterno), " ")||" "||NVL(TRIM(dts.apellidomaterno), " ") AS Nombre, COUNT(cmp.efectuo_compac) AS Negociaciones,SUM(cmp.importe) AS MontoNeg, CAST(0.00 AS DECIMAL(14,2)) AS Porc, CAST(0.00 AS DECIMAL(14,2)) AS PromNegDia
		FROM bdicobranza:"informix".cb_compac cmp
			 LEFT OUTER JOIN bdicobranza:"informix".cb_cat_datosgenerales dts on (dts.numempleado = cmp.efectuo_compac)
			 LEFT OUTER JOIN bdicobranza:"informix".cb_catejecutivos cteje on (cteje.numempleado = cmp.efectuo_compac)
		WHERE cmp.origen = 3						
			AND SUBSTR(cteje.numgrupo,1,1) = "V"
		AND cmp.fecha_compac >= dtFechaCorteIniHis
		AND cmp.fecha_compac <= dtFechaCorteFinHis
		GROUP BY 1,2,3		
			UNION ALL		
		SELECT NVL(cteje.numgrupo, "") AS Turno, NVL(cmphis.efectuo_compac, "") AS Supervisor, NVL(TRIM(dts.nombre), " ")||" "||NVL(TRIM(dts.apellidopaterno), " ")||" "||NVL(TRIM(dts.apellidomaterno), " ") AS Nombre, COUNT(cmphis.efectuo_compac) AS Negociaciones,SUM(cmphis.importe) AS MontoNeg, CAST(0.00 AS DECIMAL(14,2)) AS Porc, CAST(0.00 AS DECIMAL(14,2)) AS PromNegDia
		FROM bdicobranza:"informix".cb_compac_his cmphis
			 LEFT OUTER JOIN bdicobranza:"informix".cb_cat_datosgenerales dts on (dts.numempleado = cmphis.efectuo_compac)
			 LEFT OUTER JOIN bdicobranza:"informix".cb_catejecutivos cteje on (cteje.numempleado = cmphis.efectuo_compac)
		WHERE cmphis.origen = 3				
			AND SUBSTR(cteje.numgrupo,1,1) = "V"
		AND cmphis.fecha_compac >= dtFechaCorteIniHis
		AND cmphis.fecha_compac <= dtFechaCorteFinHis
		GROUP BY 1,2,3
		INTO TEMP tmp_compagconvsemv WITH NO LOG;
		
		SELECT turno, supervisor, nombre, SUM(negociaciones) AS negociaciones, SUM(montoneg) AS montoneg,sum(porc) AS porc, sum(promnegdia) AS promnegdia
		FROM tmp_compagconvsemv
		GROUP BY 1,2,3
		INTO TEMP tmp_compagconvsem_vesp;
		
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS DEL TURNO VESPERTINO.
		SELECT COUNT(supervisor), SUM(Negociaciones),SUM(MontoNeg)
		INTO iCantSupervVes, iNegociacionTotVes, dMontoNegTotVes
		FROM tmp_compagconvsem_vesp;
				
		IF iNegociacionTotVes = 0 OR iCantSupervVes = 0 THEN
			LET cCodRet = "000001";
			LET cMensajeRet2 = "Error de datos, NO es posible realizar una division entre Cero (iNegociacionTotVes, iCantSupervVes)";
			--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_mat" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
				DROP TABLE tmp_compagconvsem_mat;
			END IF; 
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemm" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_compagconvsemm;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_vesp" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
				DROP TABLE tmp_compagconvsem_vesp;
			END IF; 
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemv" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_compagconvsemv;
			END IF;
					
			IF cTabla = "S" THEN
				DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB;
			END IF; 				
			
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet2, '02')
            RETURNING vvcCod_ret;
			
			LET cCodRet = "000000";
			LET cMensajeRet = "Proceso exitoso";
			
			RETURN cCodRet, cMensajeRet;
		END IF;
				
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS DE AMBOS TURNOS.
		LET iNegociacionTot = (NVL(iNegociacionTotMaT,0) + NVL(iNegociacionTotVes,0));
		LET dMontoNegTot = (NVL(dMontoNegTotMat,0.00) + NVL(dMontoNegTotVes,0.00));

		--INICIALIZACION DE VARIABLES
		LET iNegociacion = 0;
		LET dePorNegoc = 0.00;
		LET dePromNegDrio = 0.00;
		
		--SE OBTIENE EL PORCENTAJE Y EL PROMEDIO DE NEGOCIOACIONES DIARIAS DEL TURNO VESPERTINO
		FOREACH
			SELECT Supervisor, Negociaciones
			INTO cSupervisor, iNegociacion
			FROM tmp_compagconvsem_vesp
						 	
			LET dePorNegoc = CAST((NVL(iNegociacion,0)/NVL(iNegociacionTotVes,0)) * 100 AS DECIMAL(14,2));
			LET dePromNegDrio = CAST((NVL(iNegociacion,0)/NVL(iDiasTrab,0))* 100 AS DECIMAL(14,2));
			
			UPDATE tmp_compagconvsem_vesp
				SET Porc = NVL(dePorNegoc,0),
					PromNegDia = NVL(dePromNegDrio,0)
			WHERE Supervisor = cSupervisor;						
		END FOREACH
	
		INSERT INTO tmp_compagconvsem_vesp (turno, supervisor, nombre, negociaciones, montoneg, porc, promnegdia)
		VALUES("", "", "Total", iNegociacionTotVes,dMontoNegTotVes,"", ""  );	
	
		INSERT INTO tmp_compagconvsem_vesp (turno, supervisor, nombre, negociaciones, montoneg, porc, promnegdia)
		VALUES("", "Total", "", iNegociacionTot,dMontoNegTot,"", ""  );

		--LET dPromNegSupMat = ((NVL(iNegociacionTotMaT,0)/NVL(iCantSupervMat,0)) * 100);    --- MODIF. MACF		
		LET dPromNegSupMat = (NVL(iNegociacionTotMaT,0)/NVL(iCantSupervMat,0));              --- MODIF. MACF    
		LET dPromNegSupMat2 = NVL(iNegociacionTotMaT,0)/NVL(iDiasTrab,0);
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
		VALUES("","Promedio","de negociaciones por Supervisor Matutino","",NVL(dPromNegSupMat,0.00),"Diarias",NVL(dPromNegSupMat2,0.00));		

		--LET dPromNegSupVesp = ((NVL(iNegociacionTotVes,0)/NVL(iCantSupervVes,0)) * 100);		--- MODIF. MACF
		LET dPromNegSupVesp = (NVL(iNegociacionTotVes,0)/NVL(iCantSupervVes,0));              --- MODIF. MACF
		LET dPromNegSupVesp2 = NVL(iNegociacionTotVes,0)/NVL(iDiasTrab,0);
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
		VALUES("","Promedio","de negociaciones por Supervisor Vespertino","",NVL(dPromNegSupVesp,0.00),"Diarias",NVL(dPromNegSupVesp2,0.00));		
		
		LET iCanSuperTot =  (NVL(iCantSupervMat,0) + NVL(iCantSupervVes,0));
		
		--LET dPromNegSupTot = ((NVL(iNegociacionTot,0)/NVL(iCanSuperTot,0)) * 100);        --- MODIF. MACF
    LET dPromNegSupTot = (NVL(iNegociacionTot,0)/NVL(iCanSuperTot,0));		              --- MODIF. MACF
		LET dPromNegSupTot2 = NVL(iNegociacionTot,0)/NVL(iDiasTrab,0);
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
		VALUES("","Promedio","de negociaciones General","",NVL(dPromNegSupTot,0.00),"Diarias",NVL(dPromNegSupTot2,0.00));	
		
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
		VALUES("Turno","Supervisor","Nombre","Negociaciones","Monto Negociado","%","Promedio Negoc. Diarias");		
		
		FOREACH 		
			SELECT turno, supervisor, nombre, negociaciones, montoneg, porc, promnegdia
			INTO cTurno_Mat, cSupervisor_Mat, cNombre_Mat, iNegociacion_Mat, dMontoneg_Mat, dePor_Mat, dePromNegDrio_Mat 
			FROM tmp_compagconvsem_mat
		
			--SE INSERTA INFORMACION DEL TURNO MATUTINO
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
			VALUES(cTurno_Mat::CHAR(80), cSupervisor_Mat::CHAR(80), cNombre_Mat::CHAR(80), iNegociacion_Mat::CHAR(80), '$'||dMontoneg_Mat::CHAR(80), NVL(dePor_Mat, "")::CHAR(80), NVL(dePromNegDrio_Mat, "")::CHAR(80));				
		END FOREACH
		
		FOREACH 
		
			SELECT turno, supervisor, nombre, negociaciones, montoneg, porc, promnegdia
			INTO cTurno_Vesp, cSupervisor_Vesp, cNombre_Vesp, iNegociacion_Vesp, dMontoneg_Vesp, dePor_Vesp, dePromNegDrio_Vesp 
			FROM tmp_compagconvsem_vesp
		
			--SE INSERTA INFORMACION DEL TURNO VESPERTINO
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB (TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA)
			VALUES(cTurno_Vesp::CHAR(80), cSupervisor_Vesp::CHAR(80), cNombre_Vesp::CHAR(80), iNegociacion_Vesp::CHAR(80),'$'||dMontoneg_Vesp::CHAR(80), NVL(dePor_Vesp, "")::CHAR(80), NVL(dePromNegDrio_Vesp,"")::CHAR(80));		
		
		END FOREACH
		
 		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_mat" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
			DROP TABLE tmp_compagconvsem_mat;
		END IF; 
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemm" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_compagconvsemm;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsem_vesp" AND dbsname= "bdicobranza" AND partnum >1048577) THEN					
			DROP TABLE tmp_compagconvsem_vesp;
		END IF; 
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_compagconvsemv" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_compagconvsemv;
		END IF;

   		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 82;
		
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
			 
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT TURNO,SUPERVISOR,NOMBRE,NEGOCIACIONES,MONTONEG,PORCENTAJE,PROMNEGDIA FROM bdicobranza:'informix'.TMP_ENCABEZADOS_CONSEMB";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla = "S" THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOS_CONSEMB;
		END IF;
		
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';	
 		
 		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
 		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el Promedio de negociaciones por Supervisor por turno.', 
'AUTOR: Hector Bojorquez',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121122.1236';

CREATE PROCEDURE "informix".sp_repcob_crtven_dtsreg()
	RETURNING
		CHAR(6)  AS COD_RET,
		CHAR(80) AS MENSAJE_RET;
		
		-- DECLARACIONES
		DEFINE iSqlErr					INTEGER;
		DEFINE iIsamErr					INTEGER;
		DEFINE cCodRet, vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet				CHAR(80);		
		DEFINE sMaxMora 				SMALLINT;
		DEFINE sCiclo	 				SMALLINT;		
		DEFINE cNombreArchivo		CHAR(80); 
		DEFINE cConsulta		  		CHAR(2200);
		DEFINE cSql           			CHAR(1024);
		DEFINE cTabla		      		CHAR(1); 
		DEFINE cRuta		      		CHAR(80);   
		DEFINE iCtesTelValElec			INTEGER;
		DEFINE iCtesTelValSinElec		INTEGER;
		DEFINE iCtesTelInvElec			INTEGER;
		DEFINE iCtesSinDats				INTEGER;
		DEFINE sMora					SMALLINT;		
		DEFINE iBandera					INTEGER;		
		DEFINE dtFechaHoy 				DATE;		
		DEFINE dtFechaCorteIniCte		DATE;
		DEFINE dtFechaCorteFinCte		DATE;		
		DEFINE iCtesTelValElecTot  		INTEGER;
		DEFINE iCtesTelValSinElecTot	INTEGER;
		DEFINE iCtesTelInvElecTot		INTEGER;
		DEFINE iCtesSinDatsTot			INTEGER;			
		DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE dtFechaMax       DATE;
		
		-- INICIALIZACIONES
		LET iSqlErr            		= 0;
		LET iIsamErr           		= 0;
		LET cCodRet            		= "000000";
		LET cMensajeRet				= "Proceso exitoso";
		LET sMaxMora 				= 0;
		LET sCiclo	 				= 0;
		LET cNombreArchivo 			= "";
		LET cConsulta	 			= "";
		LET cSql		 			= "";
		LET cTabla		 			= "N";
		LET cRuta		 			= "";
		LET iCtesTelValElec		 	= 0;
		LET iCtesTelValSinElec		= 0;
		LET iCtesTelInvElec	 		= 0;
		LET iCtesSinDats	 		= 0;
		LET sMora		 			= 0;		
		LET iBandera		 		= 0;		
		LET dtFechaHoy          	= "";		
		LET dtFechaCorteIniCte     	= "";
		LET dtFechaCorteFinCte     	= "";
		LET iCtesTelValElecTot      = 0;
		LET iCtesTelValSinElecTot	= 0;
		LET iCtesTelInvElecTot		= 0;
		LET iCtesSinDatsTot			= 0;			
		LET v_empresa = '001';
		LET cProceso = '0070';
    LET vvcCod_ret = '';
    LET dtFechaMax = date(1);
     
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;
				
				--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN					
					DROP TABLE tmp_totalesmora;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora2" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
					DROP TABLE tmp_totalesmora2;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora3" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
					DROP TABLE tmp_totalesmora3;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora4" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
					DROP TABLE tmp_totalesmora4;
				END IF;
				
				IF cTabla = "S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1;
				END IF;
				
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
		END EXCEPTION;
		
	  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_crtven_dtsreg.out";
		-- TRACE ON;
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';

		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN					
			DROP TABLE tmp_totalesmora;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora2" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora2;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora3" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora3;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora4" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora4;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELNEC1" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1;
		END IF;
		
		--SE OBTIENE LA FECHA DE HOY.
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa ;

    --LET dtFechaHoy = mdy('11','22','2012');    ----TEST MACF
				
		--SE OBTIENE LA MAXIMA MORA.							
		SELECT Total
		INTO sMaxMora
		FROM TABLE(MULTISET(
							SELECT LIMIT 1 MAX(NVL(pago_venc,0)) AS Total							
							FROM bdicobranza:"informix".cb_cat_directorio_cte 
							--WHERE fecha_insert >= dtFechaCorteIniCte AND fecha_insert <= dtFechaCorteFinCte
              WHERE fecha_insert = dtFechaMax		
								AND pago_venc > 0  
							GROUP BY numcte
							ORDER BY 1 DESC
							));
				
		--SE VALIDA SI EXISTEN MORAS.
		IF NVL(sMaxMora,0) = 0 THEN 
			LET cCodRet = '000001';
			LET cMensajeRet = 'Por el momento no existen moras';
			--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN					
				DROP TABLE tmp_totalesmora;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora2" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
				DROP TABLE tmp_totalesmora2;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora3" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
				DROP TABLE tmp_totalesmora3;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora4" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
				DROP TABLE tmp_totalesmora4;
			END IF;
			
      -- Si no existen moras lo registra en la bitácora pero termina normal.
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
			LET cCodRet = "000000";
			LET cMensajeRet	= "Proceso exitoso";
			
			RETURN cCodRet, cMensajeRet;
		END IF;
		
		--SE OBTIENE EL TOTAL DE MORAS POR CLIENTE.
		SELECT MAX(NVL(pago_venc,0)) AS total, NVL(numcte,'') AS numcte		
		FROM bdicobranza:"informix".cb_cat_directorio_cte 
		--WHERE fecha_insert >= dtFechaCorteIniCte AND fecha_insert <= dtFechaCorteFinCte
		WHERE fecha_insert = dtFechaMax 
			AND pago_venc > 0			
		GROUP BY numcte
		ORDER BY total ASC
		INTO TEMP tmp_totalesmora WITH NO LOG;	
		
		FOR sCiclo = 1 TO sMaxMora				
			IF iBandera = 0 THEN 				
				--SE OBTIENE EL TOTALIZADO POR MORA Y SE CREA LA TEMPORAL PARA GUARDAR LA INFORMACION.			
				SELECT sCiclo AS mora,
					NVL(CASE WHEN NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'V' AND NVL(c.status_correo,'') = 'A' THEN  1 END,0) AS CtesTelValElecTmp,
					NVL(CASE WHEN NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'V' AND (NVL(c.status_correo,'') = 'C' OR NVL(c.status_correo,'') = '') THEN  1 END,0) AS CtesTelValSinElecTmp,
					NVL(CASE WHEN ((NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'F') OR (NVL(b.status_tel,'') = '' AND NVL(b.cofetel,'') = '') )  AND NVL(c.status_correo,'') = 'A' THEN  1 END,0) AS CtesTelInvElecTmp,
					NVL(CASE WHEN ((NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'F' AND (NVL(c.status_correo,'') = 'C' OR NVL(c.status_correo,'') = '')) OR  (NVL(b.status_tel,'') = '' AND NVL(b.cofetel,'') = '' AND NVL(c.status_correo,'') = '')) THEN  1 END,0) AS CtesSinDatsTmp,
					NVL(a.numcte,'') AS numcte
				FROM tmp_totalesmora a
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON(b.numcte = a.numcte)
					LEFT OUTER JOIN bdinteg:"informix".si_correos c ON(c.numcte = a.numcte AND c.secuencia =  (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = a.numcte))
				WHERE a.total = sCiclo
				GROUP BY a.numcte,2,3,4,5 
				INTO TEMP tmp_totalesmora2 WITH NO LOG;	
				
				--SE VALIDA QUE EL CONTEO SEA UNO POR CLIENTE Y POR COLUMNA.				
				SELECT mora1 AS mora11,CASE WHEN ColVal1 > 0 THEN 1 ELSE 0 END AS ColVal11,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 1 THEN 1 ELSE 0 END AS ColVal22,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 0 AND ColVal3 = 1 THEN 1 ELSE 0 END AS ColVal33,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 0 AND ColVal3 = 0 AND ColVal4 = 1 THEN 1 ELSE 0 END AS ColVal44,
					   numcte1 AS numcte11 
				FROM TABLE(MULTISET(SELECT sCiclo AS mora1,CASE WHEN SUM(CtesTelValElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal1,
									   CASE WHEN SUM(CtesTelValSinElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal2,
									   CASE WHEN SUM(CtesTelInvElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal3,
									   CASE WHEN SUM(CtesSinDatsTmp) > 0 THEN 1 ELSE 0 END AS ColVal4,
									   numcte AS numcte1
									FROM tmp_totalesmora2 
									WHERE mora = sCiclo										
									GROUP BY numcte 
						  ))
				INTO TEMP tmp_totalesmora3 WITH NO LOG;	
				
				LET iBandera = 1;						
			ELSE
				--SE OBTIENE EL TOTALIZADO POR MORA.
				INSERT INTO tmp_totalesmora2			
				SELECT sCiclo AS mora,
					NVL(CASE WHEN NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'V' AND NVL(c.status_correo,'') = 'A' THEN  1 END,0) AS CtesTelValElecTmp,
					NVL(CASE WHEN NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'V' AND (NVL(c.status_correo,'') = 'C' OR NVL(c.status_correo,'') = '') THEN  1 END,0) AS CtesTelValSinElecTmp,
					NVL(CASE WHEN ((NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'F') OR (NVL(b.status_tel,'') = '' AND NVL(b.cofetel,'') = '') )  AND NVL(c.status_correo,'') = 'A' THEN  1 END,0) AS CtesTelInvElecTmp,
					NVL(CASE WHEN ((NVL(b.tipo_tel,0) IN (1,2,3) AND NVL(b.cofetel,'') = 'F' AND (NVL(c.status_correo,'') = 'C' OR NVL(c.status_correo,'') = '')) OR  (NVL(b.status_tel,'') = '' AND NVL(b.cofetel,'') = '' AND NVL(c.status_correo,'') = '')) THEN  1 END,0) AS CtesSinDatsTmp,
					NVL(a.numcte,'') AS numcte
				FROM tmp_totalesmora a
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON(b.numcte = a.numcte)
					LEFT OUTER JOIN bdinteg:"informix".si_correos c ON(c.numcte = a.numcte AND c.secuencia =  (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = a.numcte))
				WHERE a.total = sCiclo
				GROUP BY a.numcte,2,3,4,5 ;

				--SE VALIDA QUE EL CONTEO SEA UNO POR CLIENTE Y POR COLUMNA.				
				INSERT INTO tmp_totalesmora3			
				SELECT mora1 AS mora11,CASE WHEN ColVal1 > 0 THEN 1 ELSE 0 END AS ColVal11,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 1 THEN 1 ELSE 0 END AS ColVal22,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 0 AND ColVal3 = 1 THEN 1 ELSE 0 END AS ColVal33,
					   CASE WHEN ColVal1 = 0 AND ColVal2 = 0 AND ColVal3 = 0 AND ColVal4 = 1 THEN 1 ELSE 0 END AS ColVal44,
					   numcte1 AS numcte11 
				FROM TABLE(MULTISET(SELECT sCiclo AS mora1,CASE WHEN SUM(CtesTelValElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal1,
									   CASE WHEN SUM(CtesTelValSinElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal2,
									   CASE WHEN SUM(CtesTelInvElecTmp) > 0 THEN 1 ELSE 0 END AS ColVal3,
									   CASE WHEN SUM(CtesSinDatsTmp) > 0 THEN 1 ELSE 0 END AS ColVal4,
									   numcte AS numcte1
									FROM tmp_totalesmora2 
									WHERE mora = sCiclo										
									GROUP BY numcte 
						  ));				
			END IF  
		END FOR	
		
		--SE INICIALIZA BANDERA PARA REUTILIZARLA EN EL SEGUNDO CICLO.
		LET iBandera = 0;
		--SE TOTALIZA POR MORA DEACUERDO A CADA FILTRO.
		FOR sCiclo = 1 TO sMaxMora		
			IF iBandera = 0 THEN 									
				SELECT sCiclo AS MoraFin,NVL(SUM(ColVal11),0) AS ColVal1Fin,NVL(SUM(ColVal22),0) AS ColVal2Fin,NVL(SUM(ColVal33),0) AS ColVal3Fin ,NVL(SUM(ColVal44),0) AS ColVal4Fin
				FROM tmp_totalesmora3 
				WHERE mora11 = sCiclo														
				INTO TEMP tmp_totalesmora4 WITH NO LOG;					
				LET iBandera = 1;						
			ELSE 
				INSERT INTO tmp_totalesmora4
				SELECT sCiclo AS MoraFin,NVL(SUM(ColVal11),0) AS ColVal1Fin,NVL(SUM(ColVal22),0) AS ColVal2Fin,NVL(SUM(ColVal33),0) AS ColVal3Fin ,NVL(SUM(ColVal44),0) AS ColVal4Fin
				FROM tmp_totalesmora3 
				WHERE mora11 = sCiclo;														
			END IF 
				
		END FOR 
								
		-- SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1(
																		Mora 				CHAR(10),
																		CtesTelValElec 		CHAR(80),
																		CtesTelValSinElec	CHAR(80),
																		CtesTelInvElec 		CHAR(80),
																		CtesSinDats 		CHAR(80)
																	);		
		
		LET cTabla = "S";
				
		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1 (Mora,CtesTelValElec,CtesTelValSinElec,CtesTelInvElec,CtesSinDats)
		VALUES("Mora","Clientes con al menos un telefono valido COFETEL y correo electronico","Clientes con al menos un telefono valido COFETEL sin correo electronico","Clientes sin telefonos validos COFETEL con correo electronico","Clientes sin datos o telefonos invalidos" );		
		
		-- SE ELIMINAN LOS REGISTROS DONDE TODOS LOS TOTALES POR MORA SEAN CEROS YA QUE ESA INFORMACION NO SERA UTIL EN EL ARCHIVO.					 
		DELETE tmp_totalesmora4
		WHERE ColVal1Fin = 0 
			  AND ColVal2Fin = 0 
			  AND ColVal3Fin = 0
			  AND ColVal4Fin = 0;
		
		-- BARRER LA INFORMACION FINAL PARA INSERTARLA EN LA TABLA FINAL.
		FOREACH 
			
			SELECT MoraFin,ColVal1Fin,ColVal2Fin,ColVal3Fin ,ColVal4Fin
			INTO sMora,iCtesTelValElec,iCtesTelValSinElec,iCtesTelInvElec,iCtesSinDats
			FROM tmp_totalesmora4
			ORDER BY MoraFin ASC
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1 (Mora,CtesTelValElec,CtesTelValSinElec,CtesTelInvElec,CtesSinDats)
			VALUES(sMora,iCtesTelValElec,iCtesTelValSinElec,iCtesTelInvElec,iCtesSinDats);					
			
		END FOREACH
		
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS.
		SELECT SUM(ColVal1Fin),SUM(ColVal2Fin),SUM(ColVal3Fin),SUM(ColVal4Fin)
		INTO iCtesTelValElecTot,iCtesTelValSinElecTot,iCtesTelInvElecTot,iCtesSinDatsTot
		FROM tmp_totalesmora4;		
		
		--SE INSERTAN LOS TOTALES DE CADA COLUMNA EN LA TABLA DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1 (Mora,CtesTelValElec,CtesTelValSinElec,CtesTelInvElec,CtesSinDats)
		VALUES("Total",iCtesTelValElecTot,iCtesTelValSinElecTot,iCtesTelInvElecTot,iCtesSinDatsTot);		
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN					
			DROP TABLE tmp_totalesmora;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora2" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora2;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora3" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora3;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmora4" AND dbsname= "bdicobranza"  AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmora4;
		END IF;
		
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 70;
		
		--SE OBTIENE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
			 
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Mora,CtesTelValElec,CtesTelValSinElec,CtesTelInvElec,CtesSinDats FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELNEC1";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla = "S" THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC1;
		END IF;
		
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';	
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el detalle de cartera vencida vs. datos registrados.', 
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121026.1126';

CREATE PROCEDURE "informix".sp_repcob_telvalcftl()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
		
		-- DECLARACIONES
		DEFINE iSqlErr						INTEGER;
		DEFINE iIsamErr						INTEGER;
		DEFINE cCodRet,vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet					CHAR(80);		
		DEFINE sMaxMora 					SMALLINT;
		DEFINE sCiclo	 					SMALLINT;		
		DEFINE cNombreArchivo	  			CHAR(80); 
		DEFINE cConsulta		  			CHAR(2200);
		DEFINE cSql           				CHAR(1024);
		DEFINE cTabla		      			CHAR(1); 
		DEFINE cRuta		      			CHAR(80);   
		DEFINE iCtesTelCelCasVal			INTEGER;
		DEFINE iCtesTelCelValTelCasInv		INTEGER;
		DEFINE iCtesTelCasValCelInv			INTEGER;
		DEFINE iCtesTelsInvs				INTEGER;
		DEFINE sMora						SMALLINT;		
		DEFINE iBandera						INTEGER;		
		DEFINE dtFechaHoy 					DATE;		
		DEFINE dtFechaCorteIniCte			DATE;
		DEFINE dtFechaCorteFinCte			DATE;		
		DEFINE iCtesTelCelCasValTot			INTEGER;
		DEFINE iCtesTelCelValTelCasInvTot	INTEGER;
		DEFINE iCtesTelCasValCelInvTot		INTEGER;
		DEFINE iCtesTelsInvsTot				INTEGER;
		DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE dtFechaMax       DATE;
				
		-- INICIALIZACIONES
		LET iSqlErr            	 		= 0;
		LET iIsamErr           			= 0;
		LET cCodRet            			= "000000";
		LET cMensajeRet					= "Proceso exitoso";
		LET sMaxMora 					= 0;
		LET sCiclo	 					= 0;
		LET cNombreArchivo 				= "";
		LET cConsulta	 				= "";
		LET cSql		 				= "";
		LET cTabla		 				= "N";
		LET cRuta		 				= "";
		LET iCtesTelCelCasVal			= 0;
		LET iCtesTelCelValTelCasInv		= 0;
		LET iCtesTelCasValCelInv		= 0;
		LET iCtesTelsInvs	 			= 0;
		LET sMora		 				= 0;		
		LET iBandera		 			= 0;		
		LET dtFechaHoy          		= "";		
		LET dtFechaCorteIniCte     		= "";
		LET dtFechaCorteFinCte     		= "";		
		LET iCtesTelCelCasValTot		= 0;
		LET iCtesTelCelValTelCasInvTot	= 0;
		LET iCtesTelCasValCelInvTot		= 0;
		LET iCtesTelsInvsTot 			= 0;			
	  LET v_empresa = '001';
		LET cProceso = '0071';
    LET vvcCod_ret = '';
    LET dtFechaMax = date(1);
    
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;	
				LET cMensajeRet = cMensajeRet;
								
				--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_totalesmoratel;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_tipotel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_tipotel;
				END IF;
				
				IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
					DROP  TABLE tmp_totalesmoratel2;
				END IF;
				
				IF cTabla = "S" THEN
					DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2;
				END IF;
			
      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
      	
			RETURN cCodRet, cMensajeRet;
			
		   END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		-- SET DEBUG FILE TO "/respaldosbd/Guadalupe/sp_repcob_telvalcftl.out";
		-- TRACE ON;
		
		--INICIALMENTE SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmoratel;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_tipotel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_tipotel;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmoratel2;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "TMP_ENCABEZADOSEXCELNEC2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2;
		END IF;

		
		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = v_empresa ;
		
		--LET dtFechaHoy = mdy('11','22','2012');    ----TEST MACF
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
				
		--SE OBTIENE LA MAXIMA MORA.	
		SELECT total
		INTO sMaxMora
		FROM TABLE(MULTISET(
							SELECT LIMIT 1 MAX(NVL(pago_venc,0)) AS total							
							FROM bdicobranza:"informix".cb_cat_directorio_cte 
							--WHERE fecha_insert >= dtFechaCorteIniCte AND fecha_insert <= dtFechaCorteFinCte
              WHERE fecha_insert = dtFechaMax		
								AND pago_venc > 0
                and tipo_cobranza = 'A' --MACF  
							GROUP BY numcte
							ORDER BY 1 DESC
							));
		
		--SE VALIDA SI EXISTEN MORAS.
		IF NVL(sMaxMora,0) = 0 THEN 
			LET cCodRet = '000001';
			LET cMensajeRet = 'Por el momento no existen moras';
			--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_totalesmoratel;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_tipotel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_tipotel;
			END IF;
			
			IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
				DROP TABLE tmp_totalesmoratel2;
			END IF;
			
			-- Si no existen moras lo registra en la bitácora pero termina normal.
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
        RETURNING vvcCod_ret;
		
			LET cCodRet = "000000";
		  LET cMensajeRet	= "Proceso exitoso";
			
			RETURN cCodRet, cMensajeRet;
		END IF;
		
		--SE OBTIENE EL TOTAL DE MORAS POR CLIENTE.
		SELECT MAX(NVL(pago_venc,0)) AS total, NVL(numcte,'') AS numcte		
		FROM bdicobranza:"informix".cb_cat_directorio_cte 
		--WHERE fecha_insert >= dtFechaCorteIniCte AND fecha_insert <= dtFechaCorteFinCte
		WHERE fecha_insert = dtFechaMax
			AND pago_venc > 0
      and tipo_cobranza = 'A'			
		GROUP BY numcte
		ORDER BY total ASC
		INTO TEMP tmp_totalesmoratel WITH NO LOG;	
		
		--SE OBTIENE EL TIPO DE TELEFONO YA VALIDADO POR CLIENTE.															
		/*SELECT a.numcte AS numerocte,
			MAX(CASE WHEN NVL(b.tipo_tel,0) = 1 AND NVL(b.status_tel,'') = 'A' AND NVL(b.cofetel,'') = 'V' THEN 1 ELSE 0 END) AS telefonocasa,
			MAX(CASE WHEN NVL(b.tipo_tel,0) = 2 AND NVL(b.status_tel,'') = 'A' AND NVL(b.cofetel,'') = 'V' THEN 1 ELSE 0 END) AS telefonocelular
		FROM bdicobranza:"informix".cb_cat_directorio_cte a 
		LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON (b.numcte = a.numcte)
		WHERE  a.fecha_insert >= dtFechaCorteIniCte AND a.fecha_insert <= dtFechaCorteFinCte
		AND a.pago_venc > 0	
		and a.tipo_cobranza = 'A'   --MACF
		GROUP BY 1
		INTO TEMP tmp_tipotel WITH NO LOG;			
		*/
		
		SELECT a.numcte AS numerocte,
			MAX(CASE WHEN NVL(b.cofetel,'') = 'V' THEN 1 ELSE 0 END) AS telefonocasa,
			MAX(CASE WHEN NVL(c.cofetel,'') = 'V' THEN 1 ELSE 0 END) AS telefonocelular
		FROM bdicobranza:"informix".cb_cat_directorio_cte a 
                                              		LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON (b.numcte = a.numcte)
                                              		LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual c ON (c.numcte = a.numcte)
		--WHERE  a.fecha_insert >= dtFechaCorteIniCte AND a.fecha_insert <= dtFechaCorteFinCte
		WHERE  a.fecha_insert = dtFechaMax
		AND a.pago_venc > 0	
		and a.tipo_cobranza = 'A'   --MACF
		and b.tipo_tel = 1 and b.status_tel = 'A' 
		and c.tipo_tel = 2 and c.status_tel = 'A'
		GROUP BY 1
		INTO TEMP tmp_tipotel WITH NO LOG;
		
		FOR sCiclo = 1 TO sMaxMora				
			IF iBandera = 0 THEN 	
				--SE OBTIENE EL TOTALIZADO POR MORA Y SE CREA LA TEMPORAL PARA GUARDAR LA INFORMACION.
				SELECT sCiclo AS MoraTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 1 AND a2.telefonocelular = 1  THEN 1 ELSE 0 END),0) AS CtesTelCelCasValTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 0 AND a2.telefonocelular = 1  THEN 1 ELSE 0 END),0) AS CtesTelCelValTelCasInvTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 1 AND a2.telefonocelular = 0  THEN 1 ELSE 0 END),0) AS CtesTelCasValCelInvTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 0 AND a2.telefonocelular = 0  THEN 1 ELSE 0 END),0) AS CtesTelsInvsTmp
				FROM tmp_totalesmoratel a,
					 tmp_tipotel a2					 					 
				WHERE a2.numerocte = a.numcte														
					AND a.total = sCiclo				
				INTO TEMP tmp_totalesmoratel2 WITH NO LOG;					
				LET iBandera = 1;				
			ELSE
				--SE OBTIENE EL TOTALIZADO POR MORA.
				INSERT INTO tmp_totalesmoratel2		
				SELECT sCiclo AS MoraTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 1 AND a2.telefonocelular = 1  THEN 1 ELSE 0 END),0) AS CtesTelCelCasValTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 0 AND a2.telefonocelular = 1  THEN 1 ELSE 0 END),0) AS CtesTelCelValTelCasInvTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 1 AND a2.telefonocelular = 0  THEN 1 ELSE 0 END),0) AS CtesTelCasValCelInvTmp,
					NVL(SUM(CASE WHEN a2.telefonocasa = 0 AND a2.telefonocelular = 0  THEN 1 ELSE 0 END),0) AS CtesTelsInvsTmp
				FROM tmp_totalesmoratel a,
					 tmp_tipotel a2					 					 
				WHERE a2.numerocte = a.numcte														
					AND a.total = sCiclo;				
			END IF  
		END FOR	
		
		--SE CREA LA TEMPORAL PARA INSERTAR LOS ENCABEZADOS QUE LLEVARA EL REPORTE.
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2(
																		Mora 					CHAR(10),
																		CtesTelCelCasVal		CHAR(80),
																		CtesTelCelValTelCasInv 	CHAR(80),
																		CtesTelCasValCelInv 	CHAR(80),
																		CtesTelsInvs 			CHAR(80)
																	);		
		
		LET cTabla = "S";

		--SE AGREGA ENCABEZADO AL REPORTE PARA EL ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2 (Mora,CtesTelCelCasVal,CtesTelCelValTelCasInv,CtesTelCasValCelInv,CtesTelsInvs)
		VALUES("Mora","Clientes con telefono celular y telefono de casa validos COFETEL","Clientes con telefono celular valido y telefono de casa invalido COFETEL","Clientes con telefono casa valido y telefono celular invalido COFETEL","Clientes sin datos o telefonos invalidos" );						
		
		--SE ELIMINAN LOS REGISTROS DONDE TODOS LOS TOTALES POR MORA SEAN CEROS YA QUE ESA INFORMACION NO SERA UTIL EN EL ARCHIVO.		
		DELETE tmp_totalesmoratel2
		WHERE CtesTelCelCasValTmp 			= 0
			AND CtesTelCelValTelCasInvTmp 	= 0
			AND CtesTelCasValCelInvTmp 		= 0
			AND CtesTelsInvsTmp				= 0;
				
		FOREACH 
			--BARRE LA INFORMACION FINAL PARA INSERTARLA EN LA TABLA FINAL.
			SELECT MoraTmp,CtesTelCelCasValTmp,CtesTelCelValTelCasInvTmp,CtesTelCasValCelInvTmp,CtesTelsInvsTmp
			INTO sMora,iCtesTelCelCasVal,iCtesTelCelValTelCasInv,iCtesTelCasValCelInv,iCtesTelsInvs
			FROM tmp_totalesmoratel2
			ORDER BY MoraTmp ASC
			--SE INSERTA EN LA TABLA FINAL.
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2 (Mora,CtesTelCelCasVal,CtesTelCelValTelCasInv,CtesTelCasValCelInv,CtesTelsInvs)
			VALUES(sMora,iCtesTelCelCasVal,iCtesTelCelValTelCasInv,iCtesTelCasValCelInv,iCtesTelsInvs);					
		END FOREACH;
		
		--SE OBTIENEN LOS TOTALIZADOS DE TODAS LAS COLUMNAS.
		SELECT SUM(CtesTelCelCasValTmp),SUM(CtesTelCelValTelCasInvTmp),SUM(CtesTelCasValCelInvTmp),SUM(CtesTelsInvsTmp)
		INTO iCtesTelCelCasValTot,iCtesTelCelValTelCasInvTot,iCtesTelCasValCelInvTot,iCtesTelsInvsTot
		FROM tmp_totalesmoratel2;
				
		--SE INSERTAN LOS TOTALES DE CADA COLUMNA EN LA TABLA DE ENCABEZADOS.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2 (Mora,CtesTelCelCasVal,CtesTelCelValTelCasInv,CtesTelCasValCelInv,CtesTelsInvs)
		VALUES("Total",iCtesTelCelCasValTot,iCtesTelCelValTelCasInvTot,iCtesTelCasValCelInvTot,iCtesTelsInvsTot);	
		
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmoratel;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_tipotel" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_tipotel;
		END IF;
		
		IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_totalesmoratel2" AND dbsname= "bdicobranza" AND partnum >1048577) THEN
			DROP TABLE tmp_totalesmoratel2;
		END IF;
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 71;
		
		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
			 
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Mora,CtesTelCelCasVal,CtesTelCelValTelCasInv,CtesTelCasValCelInv,CtesTelsInvs FROM bdicobranza:'informix'.TMP_ENCABEZADOSEXCELNEC2";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		IF cTabla = "S" THEN
			DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELNEC2;
		END IF;
		
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;			
		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener el detalle de teléfonos validos por COFETEL de la cartera vencida.', 
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121031.1053';

CREATE PROCEDURE "informix".sp_formulario_liquidez(pProcAll char(1), 
                                                   pProcPF  char(1), 
                                                   pProcPM  char(1),
                                                   pProcColocRev   char(1), 
                                                   pProcColocNoRev char(1) )
  
RETURNING char(6), char(80);
DEFINE vCodUdi, vClase, v_status_cred, v_totalero       CHAR(2);
DEFINE v_empresa                                        CHAR(3);
DEFINE cproceso                                         CHAR(4);
DEFINE scod_ret                                         char(5);
DEFINE cCod_ret, vvcCod_ret                             CHAR(6);
DEFINE cfecha_dia, cfecha_dia_ant                       CHAR(8);
DEFINE cfecha_corte, cFechaAnt                          CHAR(10);
DEFINE vnumcte, vcuenta, vnum_credito, vnum_credito_2   CHAR(20);
DEFINE vcuenta_tdc, vcuenta_pp                          CHAR(20);
DEFINE cArch_captacion_pf1, cArch_captacion_pf2         CHAR(50);
DEFINE cArch_captacion_pf3, cArch_captacion_pm          CHAR(50);
DEFINE cArch_colocacion_rev, cArch_colocacion_norev     CHAR(50);
DEFINE error_info, cMensaje 			                      CHAR(80);
DEFINE cRuta                                            CHAR(100);
DEFINE cConsulta, cSql		  	                          CHAR(1000);   
DEFINE cSql_1        		                                CHAR(300);

DEFINE vnum_ctasvista, vnum_ctasplazo                   INTEGER; 
DEFINE vnum_ctasvista_inv, vnum_ctasTDC, vcomienza      INTEGER;
DEFINE vnum_ctasPP, vnum_productos, i, iRegistros       INTEGER; 
DEFINE vUDIS_MAXIMO, sql_err, isam_err, iParamRuta      INTEGER;
DEFINE iArch_captacion_pf1, iArch_captacion_pf2         INTEGER;   
DEFINE iArch_captacion_pf3, iArch_captacion_pm          INTEGER;
DEFINE iArch_colocacion_rev, iArch_colocacion_norev     INTEGER;

DEFINE vTpCambioUdi                                     DECIMAL(14,6);
DEFINE vsaldo_ctasplazo, vsaldo_ctasvista               DECIMAL(18,2); 
DEFINE vsaldo_total, vpagominimo                        DECIMAL(18,2);
DEFINE vpago_nogenerar_int, vpago_exigible_mensual      DECIMAL(18,2);
DEFINE vpagoprincipal, vpagoaccesorios                  DECIMAL(18,2); 
DEFINE vsaldo_ctasvista_inv, dPendMesAnteEIntMora       DECIMAL(18,2);
DEFINE v_sdo_cap_insoluto, v_monto_financiado, v_monto_vencido, v_mto_venc_trasp  DECIMAL(18,2); 
DEFINE v_sdo_moratorio, v_int_vencido,  v_iva_int_vencido, v_iva_moratorio  DECIMAL(18,2);  
DEFINE v_iva                                               DECIMAL(5,3);


DEFINE dtFechaHoy, dtFechaIniMes, dfecha_corte 	        DATE;
DEFINE dfecha_corte_12, dfecha_ant, dFecha_apertura, dFecha_compra     DATE;
DEFINE v_comportamiento                                 SMALLINT;

LET dtFechaHoy	= DATE(1);          LET dfecha_corte = DATE(1);       LET dfecha_ant = DATE(1);         LET dtFechaIniMes = DATE(1);
LET dFecha_apertura = DATE(1);      LET dFecha_compra = DATE(1);
LET vUDIS_MAXIMO = 400000;          LET iParamRuta   = 20;            LET iArch_captacion_pf1  = 51;    LET iArch_captacion_pf2  = 60; 
LET iArch_captacion_pf3 = 61;       LET iArch_captacion_pm   = 52;    LET iArch_colocacion_rev = 53;    LET iArch_colocacion_norev=54;  
LET vcomienza = -1;                 LET v_comportamiento = 0;
LET sql_err = 0;                    LET isam_err     = 0;             LET vnum_productos = 0;           LET vpagominimo  = 0.0; 
LET vpago_exigible_mensual = 0.00;  LET vpagoaccesorios = 0.00;       LET i = 0;                        LET dPendMesAnteEIntMora = 0;
LET vnum_ctasplazo = 0;             LET vnum_ctasTDC = 0;             LET vnum_ctasPP = 0;              LET iRegistros = 0;            
LET vnum_ctasvista_inv = 0;         LET vsaldo_ctasvista_inv = 0;     LET vsaldo_ctasplazo = 0;         LET vnum_ctasvista = 0; 
LET vsaldo_ctasvista = 0;
LET cCod_ret     = '000000';        LET v_empresa     = '001';        LET cMensaje= 'PROCESO EXITOSO';  LET error_info   = '';
LET vcuenta_tdc = '';               LET vcuenta_pp = '';              LET cproceso    = '0120';         LET vnumcte = '';
LET vnum_credito = '';              LET vnum_credito_2 = '';          LET cArch_captacion_pf1 = '';     LET cArch_captacion_pf2 = '';
LET cArch_captacion_pf3 = '';       LET cArch_captacion_pm = '';      LET cArch_colocacion_rev = '';    LET cArch_colocacion_norev = '';  
LET cfecha_dia = '';                LET cConsulta = "";               LET cSql = "";                    LET vvcCod_ret = '';
LET cfecha_dia_ant = '';            LET cRuta = '';                   LET cFechaAnt = '';               LET vCodUdi = '';
LET vClase = '';                    LET scod_ret = '';                LET vTpCambioUdi = 0;             LET cSql_1 = '';
LET cfecha_corte = '';              LET v_status_cred = '';           LET v_totalero = '';   
LET v_sdo_cap_insoluto = 0;         LET v_monto_financiado = 0;       LET v_monto_vencido = 0;          LET v_mto_venc_trasp = 0; 
LET v_sdo_moratorio = 0;            LET v_int_vencido = 0;            LET v_iva_int_vencido = 0;        LET v_iva = 0;  
LET v_iva_moratorio = 0;


  --SET DEBUG FILE TO '/informix/macf/sp_formulario_liquidez.trc';
  --TRACE ON;

 BEGIN
        
        ON EXCEPTION SET sql_err, isam_err, error_info
          LET cCod_ret = sql_err;
          LET cMensaje = error_info || 'numcte: ' || nvl(vnumcte,'') || ' - num_credito: ' || nvl(vnum_credito,'') ;
          CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCod_ret, cMensaje, '02')
          RETURNING vvcCod_ret;
          RETURN cCod_ret, cMensaje;
    END EXCEPTION;
      
    IF pProcAll = '' AND pProcPF = '' AND pProcPM = '' AND pProcColocRev = '' AND pProcColocNoRev = '' THEN
       LET cMensaje = 'Debe informar al menos un parámetro de ejecución.';
       LET cCod_ret = '000100';
       RETURN cCod_ret, cMensaje; 
    END IF; 
   
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCod_ret, cMensaje, '01') RETURNING vvcCod_ret;
    SET ISOLATION TO dirty READ;

    SELECT NVL(fecha_hoy ,today) INTO dtFechaHoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = '001';	
    
    --LET dtFechaHoy = mdy('04','02','2013'); --  TEST

    LET dfecha_ant = mdy(month(dtFechaHoy),1,year(dtFechaHoy)) - 1 units day;

    --Obtener Fecha dia seccionada para crear nombres de archivos
    SELECT NVL(pri_dia_mes ,today) INTO dtFechaIniMes
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = '001'; 
   
    LET cfecha_dia = year(dtFechaIniMes) || lpad(month(dtFechaIniMes),2,0) || lpad(day(dtFechaIniMes),2,0);
    
    --Obtiene nombres de archivos
    SELECT valor  INTO cRuta
      FROM bdicobranza:cb_param
     WHERE empresa = v_empresa
       AND cod_param = iParamRuta;
    

    SELECT valor  INTO cArch_captacion_pf1
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_captacion_pf1;

    SELECT valor  INTO cArch_captacion_pf2
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_captacion_pf2;

    SELECT valor  INTO cArch_captacion_pf3
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_captacion_pf3;

    SELECT valor  INTO cArch_captacion_pm
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_captacion_pm;

    SELECT valor  INTO cArch_colocacion_rev
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_colocacion_rev;
       
    SELECT valor  INTO cArch_colocacion_norev
      FROM bdicobranza:cb_param  WHERE empresa = v_empresa
       AND cod_param = iArch_colocacion_norev;

    LET cArch_captacion_pf1 = trim(SUBSTR(cArch_captacion_pf1,1,LENGTH(cArch_captacion_pf1)) || cfecha_dia || '.txt');
    LET cArch_captacion_pf2 = trim(SUBSTR(cArch_captacion_pf2,1,LENGTH(cArch_captacion_pf2)) || cfecha_dia || '.txt');
    LET cArch_captacion_pf3 = trim(SUBSTR(cArch_captacion_pf3,1,LENGTH(cArch_captacion_pf3)) || cfecha_dia || '.txt');
    LET cArch_captacion_pm = trim(SUBSTR(cArch_captacion_pm,1,LENGTH(cArch_captacion_pm)) || cfecha_dia || '.txt');
    LET cArch_colocacion_rev = trim(SUBSTR(cArch_colocacion_rev,1,LENGTH(cArch_colocacion_rev)) || cfecha_dia || '.txt');
    LET cArch_colocacion_norev = trim(SUBSTR(cArch_colocacion_norev,1,LENGTH(cArch_colocacion_norev)) || cfecha_dia || '.txt');
    
   -------------------------------------------- CAPTACION PERSONA FÍSICA ------------------------------------------------------------------
    IF pProcAll = 'S' OR pProcPF = 'S' THEN

       --- PROTEGIDO? Obtener el valor de la UDI
       SELECT TRIM(valor) INTO vCodUdi
         FROM bdinteg:"informix".si_param
        WHERE empresa = v_empresa
          AND cod_param = 16;

       SELECT TRIM(valor) INTO vClase
         FROM bdicred:"informix".sd_param
        WHERE empresa = v_empresa
          AND cod_param = "336";
 
       EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(v_empresa, dfecha_ant, vCodUdi,vClase,'0') INTO scod_ret,vTpCambioUdi;

       IF nvl(vTpCambioUdi,0) <= 0 THEN
          LET cCod_ret = '000100';
          LET cMensaje = 'VALOR DE LA UDI EN CERO.';
          RETURN cCod_ret, cMensaje;   
       END IF;

       -- Cuentas de TDC
       select numcte, count(*) cantidad
         from bdicred:sd_maecredcont
        where empresa = '001'
          and fecha = dfecha_ant
        group by numcte
         into temp creditosTDC with no log;
                   
       create unique index inx_creditosTDC on creditosTDC(numcte);
       update statistics medium for table creditosTDC;

       -- Cuentas de PP
        select numcte, count(*) cantidad
          from bdicred:sd_maecredcontcrd
         where empresa = '001'
           and fecha = dfecha_ant
           and num_credito not matches '6100*'
         group by numcte
          into temp creditosPP with no log;
                   
        create unique index inx_creditosPP on creditosPP(numcte);
        update statistics medium for table creditosPP;

        -- Cuentas vista_inv
        select num_cte, capvig28,capvig29,capvig30,capvig31
             from bdicheq:sc_maechq a,
                  bdicheq:sc_sdodiarioc b
            where a.cuenta = b.cuenta
              and a.fecha_proceso >= dfecha_ant
              and b.aniomes = lpad(year(dfecha_ant),4,0) || lpad(month(dfecha_ant),2,0)
              and a.producto = '1100'  -- Inversión creciente
             into temp cuentasInv with no log;      
    
         create index inx_cuentasInv on cuentasInv(num_cte);
         update statistics medium for table cuentasInv;

         select  num_cte, nvl(sum(
                case when day(dfecha_ant) = 30 then (case when capvig30 > 0 then 1 else 0 end)
                     when day(dfecha_ant) = 31 then (case when capvig31 > 0 then 1 else 0 end)
                     when day(dfecha_ant) = 29 then (case when capvig29 > 0 then 1 else 0 end)
                     when day(dfecha_ant) = 28 then (case when capvig28 > 0 then 1 else 0 end)
                     else 0
                 end),0) cuentas, 
                nvl(sum(
                case when day(dfecha_ant) = 30 then (case when capvig30 > 0 then capvig30 else 0 end)
                     when day(dfecha_ant) = 31 then (case when capvig31 > 0 then capvig31 else 0 end)
                     when day(dfecha_ant) = 29 then (case when capvig29 > 0 then capvig29 else 0 end)
                     when day(dfecha_ant) = 28 then (case when capvig28 > 0 then capvig28 else 0 end)
                     else 0
                 end),0) sumas
         from cuentasInv
         group by num_cte
         into temp cuentasInv_res with no log;      
    
        create unique index inx_cuentasInv_res on cuentasInv_res(num_cte);
        update statistics medium for table cuentasInv_res;

       
       SYSTEM 'echo "numcte|#Productos|#Cuentas_Vista|#Cuentas_Plazo|Saldo_Ctas_Vista|Saldo_Ctas_Plazo|Saldo_Total|Tarj_Cred|Prest_Pers|Transacc|Protegido"' || '> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || trim(cArch_captacion_pf1);
             
       FOREACH WITH HOLD

            select num_cte, nvl(count(*),0), nvl(sum(
                        case when day(dfecha_ant) = 30 then (case when capvig30 > 0 then capvig30 else 0 end)
                             when day(dfecha_ant) = 31 then (case when capvig31 > 0 then capvig31 else 0 end)
                             when day(dfecha_ant) = 29 then (case when capvig29 > 0 then capvig29 else 0 end)
                             when day(dfecha_ant) = 28 then (case when capvig28 > 0 then capvig28 else 0 end)
                             else 0
                         end),0)
              into vnumcte, vnum_ctasvista, vsaldo_ctasvista
            from bdicheq:sc_maechq a,
                 bdicheq:sc_sdodiarioc b
            where a.cuenta = b.cuenta
              and a.fecha_proceso >= dfecha_ant
              and b.aniomes = lpad(year(dfecha_ant),4,0) || lpad(month(dfecha_ant),2,0)
              and a.producto <> '1100'  
            group by num_cte

              IF vnum_ctasvista is null then LET vnum_ctasvista = 0; END IF;    
              IF vsaldo_ctasvista is null then LET vsaldo_ctasvista = 0; END IF;
              
            -- agregar cuentas vista de inversion creciente
               select nvl(cuentas,0), nvl(sumas,0)
                 into vnum_ctasvista_inv, vsaldo_ctasvista_inv
                 from cuentasInv_res    
                where num_cte = vnumcte;
  
               IF vnum_ctasvista_inv is null then LET vnum_ctasvista_inv = 0; END IF;
               IF vsaldo_ctasvista_inv is null then LET vsaldo_ctasvista_inv = 0; END IF;

               LET vnum_ctasvista = vnum_ctasvista + vnum_ctasvista_inv;
               LET vsaldo_ctasvista = vsaldo_ctasvista + vsaldo_ctasvista_inv;

            -- cuentas plazo
               SELECT nvl(count(*),0), nvl(sum(capital),0)
                 into vnum_ctasplazo, vsaldo_ctasplazo
                 FROM bdinvers:sv_maeinv s
                WHERE num_cte = vnumcte
                  AND fecha_venc >= dfecha_ant;
                
                IF vnum_ctasplazo is null then LET vnum_ctasplazo = 0; END IF;
                IF vsaldo_ctasplazo is null then LET vsaldo_ctasplazo = 0; END IF;
                
            -- Cuentas de TDC
               select nvl(cantidad,0)
                 into vnum_ctasTDC
                from creditosTDC
                where numcte = vnumcte;
  
                IF vnum_ctasTDC is null then LET vnum_ctasTDC = 0; END IF;
    
            -- Cuentas de PP
               select nvl(cantidad,0)
                 into vnum_ctasPP
                from creditosPP
                where numcte = vnumcte;
                
                IF vnum_ctasPP is null then LET vnum_ctasPP = 0; END IF;
                 
                LET vnum_productos = vnum_ctasvista+vnum_ctasplazo+vnum_ctasTDC+vnum_ctasPP;

            UPDATE "informix".cb_formulario_liquidez 
               SET num_prods= vnum_productos, 
                   num_ctasvista= vnum_ctasvista, 
                   num_ctasplazo= vnum_ctasplazo, 
                   saldo_ctasvista= vsaldo_ctasvista,
                   saldo_ctasplazo= vsaldo_ctasplazo, 
                   saldo_total= vsaldo_ctasvista+vsaldo_ctasplazo,
                   tarjeta_credito=  vnum_ctasTDC, 
                   prestamo_personal= vnum_ctasPP,  --transaccional='', protegido='', status_cta='',
                   fecha_insert = dfecha_ant
             WHERE numcte = vnumcte;

            LET iRegistros = dbinfo("sqlca.sqlerrd2");
          
            IF iRegistros = 0 THEN
                INSERT INTO "informix".cb_formulario_liquidez(numcte, num_prods, num_ctasvista, num_ctasplazo, saldo_ctasvista, saldo_ctasplazo, saldo_total, tarjeta_credito, prestamo_personal, fecha_insert) 
                VALUES(vnumcte, vnum_productos, vnum_ctasvista, vnum_ctasplazo, vsaldo_ctasvista, vsaldo_ctasplazo, vsaldo_ctasvista+vsaldo_ctasplazo, vnum_ctasTDC, vnum_ctasPP, dfecha_ant);
            END IF;

       END FOREACH;
          
      --LET cFechaAnt = lpad(month(dfecha_ant),2,0) || '/' || lpad(day(dfecha_ant),2,0) || '/' || year(dfecha_ant);
      
      ---- AGREGAR DATOS A ARCHIVO liq_captacion_pf_1_aaaammdd.txt        
             LET cConsulta = 'SELECT {+INDEX(bdicobranza:cb_formulario_liquidez idx_cb_formulario_liquidez)} ' || 
                             'trim(numcte), nvl(num_prods,0), nvl(num_ctasvista,0), nvl(num_ctasplazo,0), nvl(saldo_ctasvista,0), nvl(saldo_ctasplazo,0),' ||
                             'nvl(saldo_total,0),' ||
                             'CASE WHEN tarjeta_credito > 0 THEN ' || '''SI''' || ' ELSE ' || '''NO''' || ' END, CASE WHEN prestamo_personal > 0 THEN ' || '''SI''' || ' ELSE ' || '''N0''' || ' END,' ||
                             'CASE WHEN nvl(num_prods,0) >= 2 THEN ' || '''SI''' || ' WHEN nvl(num_prods,0) = 1 AND tarjeta_credito > 0 AND prestamo_personal <= 0  THEN ' || '''SI''' || 
                                  ' WHEN nvl(num_prods,0) = 1 AND tarjeta_credito <= 0 AND prestamo_personal >= 0  THEN ' || '''SI''' || ' ELSE ' || ''' ''' || ' END,' ||
                             'CASE WHEN nvl(saldo_total,0) > (' || vUDIS_MAXIMO || ' * ' ||  vTpCambioUdi || ' ) THEN ' || '''N0''' || ' ELSE ' || '''SI''' || ' END ' || 
                             'FROM bdicobranza:cb_formulario_liquidez WHERE numcte >= ' || '''000001001'''; 

             LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cArch_captacion_pf1)|| ' DELIMITER '|| '''|'''||' '|| SUBSTR(cConsulta,1,LENGTH(cConsulta))  ||'" > '|| TRIM(cRuta) ||'query1.sql';
                          
              SYSTEM TRIM(cSql);
             --system SUBSTR(cSql,1,LENGTH(cSql));
                                      
             LET cSql = '';
    		     LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
    		     --SYSTEM trim(cSql);
    		     system SUBSTR(cSql,1,LENGTH(cSql));
    		     LET cSql = '';

    END IF; 
    -------------------------------------------- CAPTACION PERSONA FÍSICA ------------------------------------------------------------------FIN

    
    --------------------------------------------- CAPTACION PERSONA MORAL ------------------------------------------------------------------
    IF pProcAll = 'S' OR pProcPM = 'S' THEN           
        ---- INICIAR CALCULO PARA AEGURADOS Y NO ASEGURADOS POR EL IPAB
        --- ASEGURADOS POR EL IPAB
        SYSTEM 'echo "numcte|#Cuenta|Monto_Saldo|Asegurado_IPAB"' || '> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cArch_captacion_pm; 
         FOREACH
            SELECT m.num_cte, m.cuenta, sum(m.sdo_actual) INTO vnumcte, vcuenta, vsaldo_total
              FROM bdicheq:sc_maechq m, bdinteg:si_ctepm p
             WHERE m.num_cte = p.numcte
               AND m.status_cta <> 2
               AND m.num_cte NOT IN (
                                     SELECT numcte FROM bdinteg:si_excluidosipab
               )
             GROUP BY m.num_cte, m.cuenta
             
             --Llenar archivo, agregarle la columna al archivo "Asegurado IPAB" y ponerle "S"
             LET cSql = 'echo "' || trim(vnumcte) || '|' || trim(vcuenta) || '|' || vsaldo_total || '|S' || '">> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cArch_captacion_pm;
             System SUBSTR(cSql,1,LENGTH(cSql)); 
                                 
        END FOREACH;
           
           --- NO ASEGURADOS POR EL IPAB
        FOREACH   
            SELECT m.num_cte, m.cuenta, sum(m.sdo_actual) INTO vnumcte, vcuenta, vsaldo_total
              FROM bdicheq:sc_maechq m, bdinteg:si_ctepm p
             WHERE m.num_cte = p.numcte
               AND m.status_cta <> 2
               AND m.num_cte in (
                                 SELECT numcte FROM bdinteg:si_excluidosipab
             )
             GROUP BY m.num_cte, m.cuenta
                
             --Llenar archivo, agregarle la columna al archivo "Asegurado IPAB" y ponerle "N"
             LET cSql = 'echo "' || trim(vnumcte) || '|' || trim(vcuenta) || '|' || vsaldo_total || '|N' || '">> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cArch_captacion_pm;
             System SUBSTR(cSql,1,LENGTH(cSql)); 
 
        END FOREACH;    
    END IF;
    ------------------------------------------------------  FIN  ------------------------------------------------------------------------------------
    --------------------------------------------- CAPTACION PERSONA MORAL ---------------------------------------------------------------------------

    --- Obtener fecha de corte mes anterior    
    LET dFecha_corte = mdy(month(dfecha_ant),20,year(dfecha_ant));
    --LET dFecha_corte = mdy('03','20','2012');     --- TEST MACF
    
    -- INSERT INTO bdicobranza:cb_bitacora (num_proceso,fecha_ejecucion,cod_ret,mensaje) values(cproceso,today,'000000','cfecha_corte: ' || cfecha_corte);   --- PRUEBA MACF    

    ------------------------------------------ C O L O C A C I O N     N O      R E V O L V E N T E S  ( liq_colocacion_norevolv_aaaammdd.txt )
        
    IF pProcAll = 'S' OR pProcColocNoRev = 'S' THEN     -- COLOCACION NO REV (INI)
        LET cSql = '';
        LET cSql = 'echo "numcte|Pago_Exigible_Mensual|Pago_Principal|Pago_Accesorios"' || '> ' || substr(cRuta,1,length(cRuta)) || cArch_colocacion_norev;
        SYSTEM substr(cSql,1,length(cSql));
                
        SET ISOLATION TO DIRTY READ;     
        FOREACH
              SELECT m.numcte, 
                     sum(a.capital_mto_cuota) as pago_exigible_mens,  
                     sum(a.capital_debe) as pago_principal,  
                     sum(a.interes_debe + a.iva_debe + a.mora_sdo_ordi +  a.mora_sdo_cope) as PagoAccesorios
                INTO vnumcte, vpago_exigible_mensual, vpagoprincipal, vpagoaccesorios
                FROM bdicred:sd_amortiza_creditocrd a, bdicred:sd_maecredcrd m
               WHERE a.empresa = v_empresa
                 AND a.num_credito = m.num_credito
                 --AND a.fecha_cuota = cfecha_corte   Para que tome todo pq cada producto tiene diferente fecha
                 group by m.numcte
       
               LET cSql = 'echo "' || trim(vnumcte) || '|' || vpago_exigible_mensual || '|' || vpagoprincipal || '|' || vpagoaccesorios || '">> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cArch_colocacion_norev;
               System SUBSTR(cSql,1,LENGTH(cSql)); 
      
        END FOREACH;
 
    END IF; -- COLOCACION NO REV (FIN)


    -----------------------------------------   C O L O C A C I O N  ** R E V O L V E N T E S  -------------------------------------------------------------------

    IF pProcAll = 'S' OR pProcColocRev = 'S' THEN   -- COLOCACION REV (INI)
   
        SELECT iva into v_iva FROM bdinteg:si_sucursales WHERE sucursal = '0318';
   
        --SYSTEM 'echo "numcte|pago_minimo|Pago_para_NoGenerarInts|Totalero"' || '> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cArch_colocacion_rev,1,LENGTH(cArch_colocacion_rev));
        
        TRUNCATE bdicobranza:cb_coloca_revolventes; 

        INSERT INTO "informix".cb_coloca_revolventes (numcte,pago_minimo,pago_no_generar_int,totalero)
         VALUES('NUMCTE','PAGO MINIMO','PAGO PARA NO GEBERAR INTS','TOTALERO');
        

         SELECT numcte, num_credito, status_cred  
          FROM bdicred:sd_maecredcont
         WHERE empresa = v_empresa
           and fecha = dfecha_ant
          INTO temp temp_revolventes WITH NO log;
      
         CREATE INDEX idx_temp_revolventes ON temp_revolventes(numcte);
         UPDATE statistics medium FOR TABLE temp_revolventes;
 
         SET LOCK MODE TO WAIT 3;     
         FOREACH WITH HOLD
 
               SELECT numcte, num_credito, status_cred 
                 INTO vnumcte, vnum_credito, v_status_cred  
                 FROM temp_revolventes

                LET v_totalero = 'NO';

                SELECT nvl(sdo_cap_insoluto,0),
                       nvl(monto_financiado,0), -- capital pago minimo 
                       nvl(monto_vencido,0), -- Vencido transitorio
                       nvl(mto_venc_trasp,0), -- Vencido exigible
                       nvl((sdo_moratorio+sdo_contab_mora),0), -- Moratorio
                       --NVL((int_tra_no_exig - sdo_acum_mes_int),0), -- INTERES VENCIDO
                     case when (case when NVL(sdo_int_anticip,0) > 0 then (int_tra_no_exig - sdo_acum_mes_int) else int_tra_no_exig end) > 0 
                          then (case when NVL(sdo_int_anticip,0) > 0 then (int_tra_no_exig - sdo_acum_mes_int) else int_tra_no_exig end) 
                     else 0 
                     end, -- + -- INTERES VENCIDO
                     NVL(mto_venc_int,0) -- IVA VENCIDO
                  INTO v_sdo_cap_insoluto,
                       v_monto_financiado,
                       v_monto_vencido,
                       v_mto_venc_trasp,
                       v_sdo_moratorio,
                       v_int_vencido,
                       v_iva_int_vencido
                FROM bdicred:sd_maesdoshist 
                WHERE empresa = v_empresa
                  AND fecha = dFecha_corte 
                  AND num_credito = vnum_credito;
       
      
                IF (v_monto_vencido + v_mto_venc_trasp) = 0 THEN
                    SELECT f_primer_compra, DECODE(comportamiento, 0, 'NO', 1, 'SI', 2, 'NO', 3, 'N0') 
                      INTO dFecha_compra, v_totalero 
                      FROM bdicred:sd_indicador_cred
                     WHERE empresa = v_empresa 
                       AND num_credito = vnum_credito;

                    IF ( NVL(dFecha_compra,'') = '' OR  dFecha_compra = mdy('01','01','1900') ) THEN
                        LET v_totalero = 'NO';
                    END IF;
                END IF;

                IF ((v_monto_vencido + v_mto_venc_trasp) = 0) THEN
                    let vpagominimo = v_monto_financiado;
                    let dPendMesAnteEIntMora = v_sdo_cap_insoluto;
                ELIF (v_monto_vencido > 0 ) THEN
                    LET v_iva_moratorio = round((nvl(v_sdo_moratorio,0) * v_iva),2);

                    LET vpagominimo = (v_monto_financiado + v_sdo_moratorio) + v_iva_moratorio;  -- IVA DE SUCURSAL  

                    LET dPendMesAnteEIntMora = v_sdo_cap_insoluto + v_sdo_moratorio + v_iva_moratorio; 
                ELSE
                    if (v_int_vencido <= 0 ) then
                        let v_int_vencido = 0;
                        let v_iva_int_vencido = 0;
                    end if;

                    LET vpagominimo = v_monto_financiado + v_int_vencido + v_iva_int_vencido + v_sdo_moratorio + v_iva_moratorio ; 
                    LET dPendMesAnteEIntMora = v_sdo_cap_insoluto + v_int_vencido + v_iva_int_vencido + v_sdo_moratorio + v_iva_moratorio; 
                END IF;
                   
                IF vpagominimo is null or vpagominimo < 0 THEN LET vpagominimo = 0; END IF;
                IF dPendMesAnteEIntMora is null or dPendMesAnteEIntMora < 0 THEN LET dPendMesAnteEIntMora = 0; END IF;
                   
                LET vpago_nogenerar_int = vpagominimo + dPendMesAnteEIntMora;
                
                BEGIN WORK;
                      INSERT INTO bdicobranza:cb_coloca_revolventes(numcte,pago_minimo,pago_no_generar_int, totalero)
                               VALUES(vnumcte, vpagominimo, vpago_nogenerar_int, v_totalero);
                COMMIT WORK;
        END FOREACH;
        
      --- CREAR ARCHIVO
        LET cConsulta = '';
        LET cConsulta = "SELECT numcte, pago_minimo, pago_no_generar_int, totalero FROM bdicobranza:cb_coloca_revolventes;";
       -- LET cConsulta = "SELECT numcte, num_credito FROM temp_nototaleros;";   -- Para prueba pero en el unload no dejo de marcar -668

       LET cSql_1 = '';
       --LET cSql_1 = 'echo "UNLOAD TO ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cArch_colocacion_rev,1,LENGTH(cArch_colocacion_rev)) || '  '|| SUBSTR(cConsulta,1,LENGTH(cConsulta)) ||'" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'query9.sql';
       LET cSql_1 = 'echo "UNLOAD TO ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cArch_colocacion_rev,1,LENGTH(cArch_colocacion_rev)) || ' DELIMITER '|| '''|'''||' '|| SUBSTR(cConsulta,1,LENGTH(cConsulta)) ||'" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'query9.sql';

       system substr(cSql_1,1,length(cSql_1));

       LET cSql_1 = '';
       LET cSql_1 = "dbaccess bdicobranza " ||SUBSTR(cRuta,1,LENGTH(cRuta)) ||'query9.sql';
       system substr(cSql_1,1,length(cSql_1));
       LET cSql_1 = '';
             
    END IF; -- COLOCACION REV (FIN)
    -----------------------------------------   C O L O C A C I O N     R E V O L V E N T E S  --------------------------------------------------------------------------

      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCod_ret, cMensaje, '03')
      RETURNING vvcCod_ret;

      RETURN cCod_ret, cMensaje;
 END

END PROCEDURE
DOCUMENT 
'DESCRIPCION: SP Que genera archivos planos con información de Captación y Colocación los primeros días del mes. ',
'AUTOR: Marco A. Campos. 2012/08/16',
'BD: BDICOBRANZA',
'Ver. que ya tenga cargados los datos en cb_formulario_liquidez',
'2012/11/13 Modifica dividir creación de archivos personas físicas.';

CREATE PROCEDURE "informix".sp_repcob_cdadcampcat()
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;		
			
		---DECLARACIONES
		DEFINE iSqlErr, iIsamErr				                INTEGER;
		DEFINE cTabla		      	                        CHAR(1);
		DEFINE v_empresa                                CHAR(3);
    DEFINE cProceso                                 CHAR(4);
    DEFINE cfin					                            CHAR(5); 
    DEFINE cCodRet,vvcCod_ret, cCod_RESULT          CHAR(6);
    DEFINE vnumempleado                             CHAR(8);
		DEFINE cMensajeRet, cNombreArchivo, cRuta, cDescrip, cCalfLlamad, cJerarquia			CHAR(80);
    DEFINE cHora, cHoraAsign, cHoraReal, cHora2, cHoraAsign2, cHoraReal2				      CHAR(80);						
		DEFINE cConsulta		  	                        CHAR(2200);
		DEFINE cSql           		                      CHAR(1024);
		DEFINE sTipoFechaCorte, sTipLog, sJerarquia, sTipolog		                          SMALLINT;
		DEFINE cContador, cContador2, cContador3, iCont, iTipLogTot, iTotxDia             INTEGER;
		DEFINE log_1, log_2, log_3, log_4, log_5, log_6, log_7, log_8, log_9				      INTEGER;
		DEFINE iTot1, iTot2, iTot3, iTot4, iTot5, iTot6, iTot7, iTot8, iTot9				      INTEGER;
		DEFINE iTotReg1_1, iTotReg1_2, iTotReg1_3, iTotReg1_4, iTotReg1_5			            INTEGER;
		DEFINE iTotReg1_6, iTotReg1_7, iTotReg1_8, iTotReg1_9 		                        INTEGER;
		DEFINE iTotReg2_1, iTotReg2_2, iTotReg2_3, iTotReg2_4, iTotReg2_5			            INTEGER;
		DEFINE iTotReg2_6, iTotReg2_7, iTotReg2_8, iTotReg2_9, iTotReg2                   INTEGER;
		DEFINE iTotReg3, cTotReg, cTotReg3, cTotReg4, cTotReg5, iTotReg4, iTotReg5				INTEGER;
		DEFINE iRegTotxCamp, iTotRegProcXCamp, iRegTotxCamp2, iTotRegProcXCamp2			      INTEGER;
		DEFINE iNumsEmpl, iTotGen,	iTotReg, iCamActivas, iRegistros                      INTEGER;
		DEFINE iExito, iNoExito, iExitoTot1, iExitoTot2, iExitoTot, iTipo, iTotAvance		  INTEGER;
    DEFINE dProm				                                                              DECIMAL(14,2);
		DEFINE dtFechaHoy, dtFechaDiaAnt, dtFechaMax, dtFechaMaxCart	                    DATE;
		DEFINE iConlog				                                                            SMALLINT;
	
		---INICIALIZACIONES
		LET iIsamErr         = 0;   LET iSqlErr          	= 0;
		LET sTipoFechaCorte  = 0;   LET cContador			    = 0;   LET cContador2			    = 0;  LET cContador3			= 0;	
		LET iCont				     = 0; 	LET sJerarquia		    = 0;   LET sTipolog			      = 0;  LET iTipLogTot			= 0;
		LET log_1				     = 0; 	LET log_2				      = 0;   LET log_3				      = 0; 	LET log_4				    = 0; 	LET log_5				= 0;
		LET log_6				     = 0; 	LET log_7				      = 0; 	 LET log_8				      = 0; 	LET log_9				    = 0; 	LET iTot1				= 0;
		LET iTot2				     = 0; 	LET iTot3				      = 0; 	 LET iTot4				      = 0; 	LET iTot5				    = 0; 	LET iTot6				= 0;
		LET iTot7				     = 0; 	LET iTot8				      = 0; 	 LET iTot9				      = 0; 	LET iRegTotxCamp		= 0;  LET iTotxDia		= 0; 
		LET iRegTotxCamp2	   = 0; 	LET iTotRegProcXCamp	= 0; 	 LET iTotRegProcXCamp2	= 0; 	LET iTotReg				  = 0;  LET iTotGen	    = 0;
		LET iCamActivas		   = 0;		LET dProm				      = 0.0; 
		LET iTotReg1_1			 = 0; 	LET iTotReg1_2			  = 0; 	 LET iTotReg1_3			    = 0; 	LET iTotReg1_4			= 0;	LET iTotReg1_5	= 0; 	
    LET iTotReg1_6			 = 0; 	LET iTotReg1_7			  = 0; 	 LET iTotReg1_8			    = 0;	LET iTotReg1_9			= 0; 	LET iTotReg2_1  = 0; 	 
    LET iTotReg2_2			 = 0; 	LET iTotReg2_3			  = 0; 	 LET iTotReg2_4			    = 0; 	LET iTotReg2_5		  = 0; 	LET iTotReg2_6	= 0; 	
    LET iTotReg2_7			 = 0;		LET iTotReg2_8			  = 0; 	 LET iTotReg2_9			    = 0; 	LET iTotReg2	      = 0;
		
		LET iTotReg3			   = 0;		LET iNumsEmpl			    = 0;   LET iExito				      = 0; 	LET iNoExito			  = 0;  LET iExitoTot1	= 0; 	
    LET iExitoTot2			 = 0; 	LET iExitoTot			    = 0;   LET iTotReg4			      = 0;  LET iTotReg5			  = 0;  LET iTipo			  = 0;
		LET iTotAvance			 = 0;   LET iConlog				    = 0;   LET iRegistros         = 0;  		
		 	
		LET v_empresa        = '001';   LET cProceso    = '0076';  LET cTabla		 		= "N";     LET cCodRet        = "000000";    
		LET cMensajeRet			 = "PROCESO EXITOSO";                  LET dtFechaMax   = date(1); LET dtFechaMaxCart = date(1);
    
    LET cNombreArchivo 	 = "";      LET cConsulta	 		= "";    LET cSql		 		  = "";      LET cRuta		 		  = "";
    LET cHora				     = "";	    LET cHoraAsign	  = "";    LET cHoraReal		= ""; 	   LET cHora2				  = "";
    LET cHoraAsign2			 = "";	    LET cHoraReal2	  = "";    LET cfin				  = "";      LET cTotReg			  = "";
    LET cTotReg3			   = "";      LET cTotReg4		  = "";  	 LET cTotReg5			= "";      LET dtFechaDiaAnt  = "";
    LET vnumempleado     = '';      LET vvcCod_ret    = '';    LET dtFechaHoy   = "";      LET cCod_RESULT		= ""; 
		LET cCalfLlamad			 = "";		  LET cJerarquia	  = "";

    
			BEGIN 
				ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
					IF iSqlErr != 0 THEN
						LET cCodRet = iSqlErr;	
						LET cMensajeRet = cMensajeRet;			  				
						--SE BORRA LA TABLA TEMPORAL EN CASO DE QUE EL PROCEDIMIENTO CAIGA EN UN CASO DE ERROR
						IF cTabla ="S" THEN
							DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
						END IF;
					
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '02')
            RETURNING vvcCod_ret;
          			
					  RETURN cCodRet, cMensajeRet;
						
				  END IF;
				END EXCEPTION;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/respaldosbd/josue/sp_repcob_cdadcampcat.out";
		--SET DEBUG FILE TO "/informix/macf/sp_repcob_cdadcampcat.trc";
		--TRACE ON; 
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;
		
		 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'TMP_ENCABEZADOSEXCELCAMPCATXDIA'  AND dbsname = 'bdicobranza' AND partnum >1048577) THEN
        DROP TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
    END IF;
		
		SELECT max(fecha_insert) INTO dtFechaMax 
      FROM bdicobranza:"informix".cb_cat_directorio_cte
     WHERE tipo_cobranza = 'A';
		
		SELECT max(date(fechacartera)) INTO dtFechaMaxCart
		  FROM bdicobranza:"informix".cb_cat_movimientos
		 WHERE tipocobranza = 'A';
		
		--SE OBTIENE LA FECHA DE HOY.
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
    WHERE empresa = v_empresa;
		 
		--LET dtFechaHoy = mdy('01','31','2013');   --- TEST MACF  mdy('12','13','2012') 214 
		
		LET dtFechaDiaAnt = dtFechaHoy - 1 UNITS DAY;
	
		--SE CREA LA TABLA TEMPORAL PARA INSERTAR LOS DATOS QUE LLEVARÁ EL REPORTE.		
		CREATE TABLE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA(					
																		Cod_RESULT 	CHAR(80),
																		Cal_llam 	CHAR(80),
																		Tipo_log_1	CHAR(80),
																		Tipo_log_2  CHAR(80),
																		Tipo_log_3  CHAR(80),
																		Tipo_log_4  CHAR(80),
																		Tipo_log_5  CHAR(80),
																		Tipo_log_6  CHAR(80),
																		Tipo_log_7  CHAR(80),
																		Tipo_log_8  CHAR(80),
																		Tipo_log_9	CHAR(80),
																		Total		CHAR(80),
																		Camp_CAT_act CHAR(80),
																		Promedio    CHAR(80)
																	);			
		LET cTabla="S";			
		
		--SE AGREGA ENCABEZADO "TITULO Y FECHA DEL REPORTE"
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
		--VALUES("","","","Calidad de Campañas CAT del Día","","","","","","",""||dtFechaHoy,"","","");
		VALUES("","","","Calidad de Campañas CAT del Día","","","","","","",""||day(dtFechaDiaAnt)||"/" ||month(dtFechaDiaAnt)|| "/" ||year(dtFechaDiaAnt),"","","");   --by MACF
		
		--SE AGREGA ENCABEZADO DE CADA COLUMNA PARA TABLA DEL REPORTE EN ARCHIVO EXCEL.
		INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
		VALUES("Cod RESULT","CALIFICACIÓN LLAMADA","","","","","","","","","","Total","Campañas CAT Activas","Promedio");	
		
		--SE BUSCA EL NOMBRE DE CADA CAMPAÑA ACTIVA SI LO ENCUENTRA LO AGREGA Y SI NO AGREGA "VALOR TIPO-LOGICA" Y EL NÚMERO DE CADA COLUMNA DE LA TABLA POR TIPO_LOGICA
		FOREACH		
			SELECT valor_numerico,descripcion
				INTO sTipLog,cDescrip
				FROM bdicobranza:"informix".cb_param_campania
				WHERE grupo_parametro = 'LOGICA'
			
			IF sTipLog = 1 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = "Valor Tipo_logica 1" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 2 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = TRIM(cDescrip)WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = "Valor Tipo_logica 2" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 3 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = "Valor Tipo_logica 3" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			ELIF sTipLog = 4 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = "Valor Tipo_logica 4" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 5 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = "Valor Tipo_logica 5" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 6 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = "Valor Tipo_logica 6" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 7 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = "Valor Tipo_logica 7" WHERE Cod_RESULT = "Cod RESULT";
				END IF;				
			ELIF sTipLog = 8 THEN 
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = "Valor Tipo_logica 8" WHERE Cod_RESULT = "Cod RESULT";
				END IF;					
			ELIF sTipLog = 9 THEN 	
				IF NVL(cDescrip,'') <> '' THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = TRIM(cDescrip) WHERE Cod_RESULT = "Cod RESULT";     
				ELSE 
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = "Valor Tipo_logica 9" WHERE Cod_RESULT = "Cod RESULT";
				END IF;
			END IF; 
			LET cContador = cContador + 1;
				
		END FOREACH;
			
		LET cContador2 = 9 - cContador; 
		LET cContador3 = cContador2;
		
		FOR iCont = cContador2 to 9 
		
		    IF cContador2 = 1 THEN				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";
			ELIF cContador2 = 2 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";
			ELIF cContador2 = 3 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 4 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 5 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 6 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 7 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 8 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";				
			ELIF cContador2 = 9 THEN			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = "Valor Tipo_logica"||cContador3 WHERE Cod_RESULT = "Cod RESULT";			
			END IF;
			
			LET cContador2 = cContador2 + 1;	
			LET cContador3 = cContador3 + 1;			
		END FOR
					
		-- SE CONSULTA LA DESCRIPCION Y CÓDIGO DE LOS RESULTADOS QUE SE PUEDA OBTENER EN CADA LLAMADA
		FOREACH 					
			SELECT id_jerarquia, descripcion 
				INTO cCod_RESULT, cCalfLlamad
			FROM bdicobranza:"informix".cb_cat_tipo_resultado 
			ORDER BY id_jerarquia
			-- SE INSERTA LA INFORMACION DE CADA REGISTRO EN DICHA TABLA
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES(cCod_RESULT,cCalfLlamad,"0","0","0","0","0","0","0","0","0","","","");
			
		END FOREACH;
				
		-- SE CONSULTAN LOS TOTALES DE CADA REGISTRO POR TIPO DE LÓGICA
		FOREACH 
			SELECT  CodResult, TipLogica,NVL(TipLogTot,0)
			  INTO sJerarquia,sTipolog,iTipLogTot 
			  FROM TABLE(MULTISET(SELECT b.id_jerarquia AS CodResult,
									                 a.tipologica AS TipLogica,
            						     COUNT(a.tipologica) AS TipLogTot 
            								  FROM bdicobranza: "informix".cb_cat_movimientos a,
            										   bdicobranza: "informix".cb_cat_tipo_resultado b,
            										   bdicobranza: "informix".cb_param_campania c
            								 WHERE a.finllamada = b.codigo_resultado 
            								   AND a.tipocobranza = "A"
            								   AND a.cvemovimiento = "L"
            								   AND a.tipomovimiento = 1
            								   AND a.tipologica = c.valor_numerico      --- by MACF
            								   AND c.grupo_parametro = 'LOGICA'         --- by MACF
            								   AND a.fechacartera::DATE = dtFechaMaxCart
            								   AND a.horainicio::DATE = dtFechaDiaAnt   --- by MACF
            								GROUP BY 1,2
            								ORDER BY 1,2 ASC
						))
						
			--SE ACTUALIZA LOS TOTALIZADOS POR CADA TIPO DE LÓGICA.
			IF sTipolog = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			ELIF sTipolog = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iTipLogTot,0) WHERE Cod_RESULT = sJerarquia:: CHAR(80);
			END IF 
		END FOREACH;
		
		LET iCont = 0;
		
		-- OBTENEMOS EL TOTAL DE LOS REGISTROS PARA OBTENER EL NÚMERO DE RENGLON EN DONDE SE INSERTARÁ LOS REGITROS DE LOS RESULTADOS DE LAS CAMPAÑAS
			SELECT  COUNT(Cod_RESULT) INTO iTotReg 
			FROM bdicobranza: "informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA; 			
			LET iTotReg = iTotReg - 1;
			
			--SE INSERTAN LOS REGITROS DONDE SE ACTUALIZARÁN LOS RESULTADOS DE LAS CAMPAÑAS
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","TOTAL GENERAL","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","REGISTROS TOTALES POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","REGISTROS PROCESADOS POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","TOTAL REGISTROS PENDIENTES","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","HORA DE ASIGNACIÓN DE CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","HORA DE PAUSA/TERMINO DE CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","SUPERVISORES ASIGNADOS","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","AVANCE EN ETAPA TREN DE GESTIÓN","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","LlAMADAS EXITOSAS POR CAMPAÑA","","","","","","","","","","","","");
			
			INSERT INTO bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA (Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio)
			VALUES("","LlAMADAS NO EXITOSAS POR CAMPAÑA","","","","","","","","","","","","");
						
			LET iTotReg = iTotReg - 2;
			
		  -- SE OBTIENE EL TOTAL DE CADA TIPO DE LÓGICA Y EL TOTAL POR CADA TIPO DE RESULTADO
			FOR iCont = 0  TO iTotReg
				LET iCamActivas = 0;
			
				SELECT NVL(Tipo_log_1:: INTEGER,0), NVL(Tipo_log_2:: INTEGER,0),NVL(Tipo_log_3:: INTEGER,0),
				       NVL(Tipo_log_4:: INTEGER,0), NVL(Tipo_log_5:: INTEGER,0),NVL(Tipo_log_6:: INTEGER,0),
				       NVL(Tipo_log_7:: INTEGER,0), NVL(Tipo_log_8:: INTEGER,0),NVL(Tipo_log_9:: INTEGER,0)				
					INTO log_1,log_2,log_3,log_4,log_5,log_6,log_7,log_8,log_9	
					
				FROM bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA
				WHERE Cod_RESULT = iCont:: CHAR(80);
				
				LET iTotxDia = log_1 + log_2 + log_3 + log_4 + log_5 + log_6 + log_7 + log_8 + log_9;
				LET iTotGen = iTotGen + iTotxDia;
				LET iTot1 = iTot1 + NVL(log_1,0);
				LET iTot2 = iTot2 + NVL(log_2,0);
				LET iTot3 = iTot3 + NVL(log_3,0);
				LET iTot4 = iTot4 + NVL(log_4,0);
				LET iTot5 = iTot5 + NVL(log_5,0);
				LET iTot6 = iTot6 + NVL(log_6,0);
				LET iTot7 = iTot7 + NVL(log_7,0);
				LET iTot8 = iTot8 + NVL(log_8,0);
				LET iTot9 = iTot9 + NVL(log_9,0);
				
				-- SE OBTIENE EL TOTAL DE CAMPAÑAS ACTIVAS POR CADA TIPO DE LÓGICA
				IF log_1 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_2 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_3 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_4 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_5 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_6 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_7 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_8 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;				
				IF log_9 <> 0 THEN
					LET iCamActivas = iCamActivas + 1;
				END IF;
				
				-- SE INSERTA EL TOTAL Y PROMEDIO DE CADA LÓGICA Y CADA TIPO DE RESULTADO
				IF iCamActivas <> 0 THEN
					LET dProm = iTotxDia / iCamActivas;
					LET dProm = ROUND(dProm);
				ELSE
					LET iTotxDia = 0;
					LET dProm = 0;
				END IF;
				--SE ACTUALIZA EL TOTAL Y PROMEDIO DE CADA LÓGICA Y CADA TIPO DE RESULTADO
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA 
					SET Total = NVL(iTotxDia,0), Camp_CAT_act = NVL(iCamActivas,0), Promedio = NVL(dProm,0)
				WHERE Cod_RESULT = iCont:: CHAR(80);
								
			END FOR
			
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA 
					SET Tipo_log_1 = NVL(iTot1,0),Tipo_log_2 = NVL(iTot2,0),Tipo_log_3 = NVL(iTot3,0),Tipo_log_4 = NVL(iTot4,0),Tipo_log_5 = NVL(iTot5,0),Tipo_log_6 = NVL(iTot6,0),Tipo_log_7 = NVL(iTot7,0),Tipo_log_8 = NVL(iTot8,0),Tipo_log_9 = NVL(iTot9,0),Total = NVL(iTotGen,0)
				WHERE Cal_llam = "TOTAL GENERAL";
		
		LET iCont = 1;
		LET iTotReg = iTotReg + 2;
		
		-- SE OBTIENEN LOS REGISTROS TOTALES POR CAMPAÑA POR CADA TIPO DE LÓGICA
		FOR  iCont = 1  TO 9
			SELECT  COUNT(tipo_logica)
				INTO iRegTotxCamp
			FROM bdicobranza:"informix".cb_cat_directorio_cte 
			WHERE tipo_cobranza = "A"              --- by MACF
      AND tipo_logica = iCont
			AND fecha_insert = dtFechaMax; 
			
			--SE ACTUALIZAN LOS REGISTROS TOTALES POR CAMPAÑA POR CADA TIPO DE LÓGICA
			IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_1 = iTotReg1_1 + iRegTotxCamp;
			END IF;
			IF iCont = 2 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_2 = iTotReg1_2 + iRegTotxCamp;
			END IF;
			IF iCont = 3 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_3 = iTotReg1_3 + iRegTotxCamp;
			END IF;
			IF iCont = 4 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_4 = iTotReg1_4 + iRegTotxCamp;
			END IF;
			IF iCont = 5 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_5 = iTotReg1_5 + iRegTotxCamp;
			END IF;
			IF iCont = 6 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_6 = iTotReg1_6 + iRegTotxCamp;
			END IF;
			IF iCont = 7 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_7 = iTotReg1_7 + iRegTotxCamp;
			END IF;
			IF iCont = 8 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iRegTotxCamp,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_8 = iTotReg1_8 + iRegTotxCamp;
			END IF;
			IF iCont = 9 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iRegTotxCamp,0) WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
				LET iTotReg1_9 = NVL(iTotReg1_9,0) + NVL(iRegTotxCamp,0);
			END IF;
			LET iRegTotxCamp2 = NVL(iRegTotxCamp2,0) + NVL(iRegTotxCamp,0);
		END FOR
		
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Total = NVL(iRegTotxCamp2,0)	WHERE Cal_llam = "REGISTROS TOTALES POR CAMPAÑA";
		
		
		LET iTotReg = iTotReg + 1;
		
		--SE OBTIENEN LOS REGISTROS PROCESADOS POR CAMPAÑA POR CADA TIPO DE LÓGICA
		FOREACH
				SELECT COUNT(tipologica),tipologica
					INTO  iTotRegProcXCamp,iConlog
				FROM bdicobranza:"informix".cb_cat_movimientos
				WHERE horainicio::DATE = dtFechaDiaAnt
        AND fechacartera::DATE = dtFechaMaxCart 
				AND tipocobranza = 'A'
				AND cvemovimiento = 'L'
				AND tipomovimiento = 1
				GROUP BY tipologica
				ORDER BY tipologica ASC
				
				--SE ACTUALIZAN LOS REGISTROS PROCESADOS POR CAMPAÑA POR CADA TIPO DE LÓGICA
				IF iConlog = 1 THEN
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_1 =  NVL(iTotReg1_1,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 2 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iTotRegProcXCamp,0) WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_2 = NVL(iTotReg1_2,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 3 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_3 = NVL(iTotReg1_3,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 4 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_4 = NVL(iTotReg1_4,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 5 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_5 = NVL(iTotReg1_5,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 6 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_6 = NVL(iTotReg1_6,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 7 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_7 = NVL(iTotReg1_7,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 8 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iTotRegProcXCamp,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_8 = NVL(iTotReg1_8,0) - NVL(iTotRegProcXCamp,0);
				END IF;
				IF iConlog = 9 THEN		
					UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iTotRegProcXCamp,0) WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
					LET iTotReg2_9 = NVL(iTotReg1_9,0) - NVL(iTotRegProcXCamp,0);				
				END IF;
				--SE OBTIENE EL TOTAL DE REGISTROS PROCESADOS POR CAMPAÑA
				LET iTotRegProcXCamp2 = NVL(iTotRegProcXCamp2,0) + NVL(iTotRegProcXCamp,0);	
			END FOREACH
		
				LET iTotReg2 = iTotReg2_1 + iTotReg2_2 + iTotReg2_3	+ iTotReg2_4 + iTotReg2_5 + iTotReg2_6 + iTotReg2_7 + iTotReg2_8 + iTotReg2_9;
				
				--SE ACTUALIZA EL TOTAL  DE REGISTROS PROCESADOS POR CAMPAÑA
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Total = NVL(iTotRegProcXCamp2,0)	WHERE Cal_llam = "REGISTROS PROCESADOS POR CAMPAÑA";
		
		LET iTotReg = iTotReg + 1;	
		
		--SE ACTUALIZAN LOS TOTALIZADOS DE TOTAL REGISTROS PENDIENTES DE CADA TIPO DE LÓGICA
		UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iTotReg2_1,0),Tipo_log_2 = NVL(iTotReg2_2,0),Tipo_log_3 = NVL(iTotReg2_3,0),Tipo_log_4 = NVL(iTotReg2_4,0),Tipo_log_5 = NVL(iTotReg2_5,0),Tipo_log_6 = NVL(iTotReg2_6,0),Tipo_log_7 = NVL(iTotReg2_7,0),Tipo_log_8 = NVL(iTotReg2_8,0),Tipo_log_9 = NVL(iTotReg2_9,0),Total = NVL(iTotReg2,0) WHERE Cal_llam = "TOTAL REGISTROS PENDIENTES";		
		LET iCont = 1;
		LET iTotReg = iTotReg + 1;
		
		-- SE OBTIENE LA HORA DE INICIO Y FIN DE CADA CAMPAÑA
		FOR  iCont = 1  TO 9
			SELECT SUBSTR(MIN(horainicio),12,2), SUBSTR(MAX(horafin),12,2)
				INTO cHora, cfin
			FROM bdicobranza:"informix".cb_cat_movimientos
			WHERE fechacartera::DATE = dtFechaMaxCart
			AND horainicio::DATE = dtFechaDiaAnt
			AND  tipologica = iCont;
			
		-- SE VALIDA LA HORA PARA SABER SI ES "AM" Ó "PM"
			LET cHoraReal = SUBSTR(cHora, 1,2);
			
			IF trim(cHoraReal) = "00" THEN
				  LET cHoraAsign = "12AM";
			ELSE
				IF cHoraReal:: INTEGER >= 12 THEN					
					LET cHoraReal = cHoraReal:: INTEGER - 12;
					LET cHoraAsign = TRIM(cHoraReal)||"PM";								
				ELSE
					LET cHoraAsign = TRIM(cHoraReal)||"AM";
				END IF;	
			END IF;	
			
			LET cHoraReal2 = SUBSTR(cfin, 1,2);
				
			IF trim(cHoraReal2) = "00" THEN
				  LET cHoraAsign2 = "12AM";
			ELSE	
				IF cHoraReal2:: INTEGER >= 12 THEN				
					LET cHoraReal2 = cHoraReal2:: INTEGER - 12;
					LET cHoraAsign2 = TRIM(cHoraReal2)||"PM";								
				ELSE
					LET cHoraAsign2 = TRIM(cHoraReal2)||"AM";
				END IF;
			END IF;	
			
			LET iTotReg3 = iTotReg + 1;
			LET cTotReg  =  iTotReg:: CHAR(80);
			LET cTotReg3 = iTotReg3:: CHAR(80);
			
			-- SE ACTUALIZA LA HORA DE INICIO Y FIN DE CADA CAMPAÑA EN LA TABLA TEMPORAL
			IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";				
			END IF;
			IF iCont = 2 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(cHoraAsign,"00") WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";				
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 3 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 4 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 5 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(cHoraAsign2,"00")	WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 6 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 7 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			IF iCont = 8 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(cHoraAsign,"00")	WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(cHoraAsign2,"00")WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";	
			END IF;
			IF iCont = 9 THEN		
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(cHoraAsign,"00") WHERE Cal_llam = "HORA DE ASIGNACIÓN DE CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(cHoraAsign2,"00") WHERE Cal_llam = "HORA DE PAUSA/TERMINO DE CAMPAÑA";
			END IF;
			LET cHora     = "";
			LET cHoraReal = "";
			LET cHora2     = "";
			LET cHoraReal2 = "";
		END FOR
		
		LET iCont = 1;
		LET iTotReg3 = iTotReg3 + 1;
		LET cTotReg3 = iTotReg3:: CHAR(80);
		
		-- SE OBTIENE EL NÚMERO DE "SUPERVISORES ASIGNADOS"  POR CADA CAMPAÑA
      
		FOR  iCont = 1  TO 9
		   LET iNumsEmpl = 0; 
		   FOREACH
    			    --SELECT COUNT(numempleado)
    			 SELECT  numempleado
    				INTO vnumempleado
    	 		 FROM bdicobranza:"informix".cb_cat_movimientos
    	 		 WHERE fechacartera::DATE = dtFechaMaxCart
    	 		 AND  horainicio::DATE = dtFechaDiaAnt        --- by MACF y 3 sigs. filtros
    	 		 AND  cvemovimiento = 'L'
    	 		 AND  tipomovimiento = 1
           AND  tipocobranza = 'A'    
    			 AND  tipologica = iCont
    			 GROUP BY numempleado
    			 
			     --LET iNumsEmpl = iNumsEmpl +1;
			     
			     LET iRegistros=dbinfo("sqlca.sqlerrd2");
			     LET iNumsEmpl = iNumsEmpl + iRegistros;
       END FOREACH
       			 
			 -- SE ACTUALIZA EL NÚMERO DE "SUPERVISORES ASIGNADOS"  POR CADA CAMPAÑA EN LA TABLA TEMPORAL
			 IF iCont = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;	
			IF iCont = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = iNumsEmpl WHERE Cal_llam = "SUPERVISORES ASIGNADOS";								
			END IF;
		END FOR
		 
		LET iCont = 1;
		LET iTotReg3 = iTotReg3 + 1;
		LET iTotReg4 = iTotReg3 + 1;
		LET iTotReg5 = iTotReg4 + 1;
		
		LET cTotReg3 = iTotReg3:: CHAR(80);
		
		LET cTotReg4 = iTotReg4:: CHAR(10);
		
		LET cTotReg5 = iTotReg5:: CHAR(10);
		
		-- SE OBTIENE EL TOTAL DE LLAMADAS EXITOSAS O NO EXITOSAS DE CADA TIPO DE LÓGICA
		FOREACH
			SELECT SUM(CASE WHEN finllamada IN(1,2,3,4,5,6,7,10,14,15) THEN 1 ELSE 0 END),
				   --SUM(CASE WHEN finllamada IN(8,9,11,12,13,16) THEN 1 ELSE 0 END),tipologica 
				   SUM(CASE WHEN finllamada IN(8,9,11,12,13,16,17,18) THEN 1 ELSE 0 END),tipologica   -- by MACF
			INTO iExito,iNoExito, iTipo
			FROM bdicobranza:"informix".cb_cat_movimientos
			WHERE fechacartera::DATE = dtFechaMaxCart
	 		 AND  horainicio::DATE = dtFechaDiaAnt       --- by MACF y 3 sigs. filtros
	 		 AND  cvemovimiento = 'L'
       AND  tipocobranza = 'A'  
			GROUP BY tipologica
			ORDER BY tipologica
			
			-- SE OBTIENE "AVANCE EN ETAPA TREN DE GESTIÓN" DE CADA TIPO LÓGICA O CAMPAÑA
			LET iExitoTot1 = iExitoTot1 + iExito;
			LET iExitoTot2 = iExitoTot2 + iNoExito;
			LET iExitoTot = iExito + iNoExito;
			LET iTotAvance = iExitoTot2 + iExitoTot1;
			
			-- SE ACTUALIZAN EL TOTAL DE LLAMADAS EXITOSAS,NO EXITOSAS Y AVANCE EN ETAPA TREN DE GESTIÓN DE CADA CAMPAÑA
			IF iTipo = 1 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_1 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";								
			END IF;	
			IF iTipo = 2 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_2 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 3 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_3 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 4 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_4 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 5 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_5 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 6 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_6 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 7 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_7 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 8 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_8 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;	
			IF iTipo = 9 THEN
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iExitoTot,0), Total = NVL(iTotAvance,0) 	WHERE Cal_llam = "AVANCE EN ETAPA TREN DE GESTIÓN";								
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 =  NVL(iExito,0),	 Total = NVL(iExitoTot1,0)  WHERE Cal_llam = "LlAMADAS EXITOSAS POR CAMPAÑA";
				UPDATE bdicobranza:"informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA SET Tipo_log_9 = NVL(iNoExito,0),  Total = NVL(iExitoTot2,0)  WHERE Cal_llam = "LlAMADAS NO EXITOSAS POR CAMPAÑA";
			END IF;
		END FOREACH;
		
		--SE OBTIENE EL NOMBRE DEL ARCHIVO.		
		SELECT valor 
		INTO cNombreArchivo
		FROM bdicobranza:"informix".cb_param 
		WHERE cod_param = 78;

		--SE OBTINE LA RUTA DONDE SE GENERARA EL ARCHIVO.
		SELECT valor_alfabetico
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11
			AND grupo_parametro = "RUTAS" 
			AND num_parametro = 1;
		
		-- SE CREA EL ARCHIVO EXCEL EN LA RUTA OBTENIDA
		--LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||MONTH(dtFechaHoy)||DAY(dtFechaHoy);
		LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
		LET cConsulta = "SELECT Cod_RESULT,Cal_llam,Tipo_log_1,Tipo_log_2,Tipo_log_3,Tipo_log_4,Tipo_log_5,Tipo_log_6,Tipo_log_7,Tipo_log_8,Tipo_log_9,Total,Camp_CAT_act,Promedio FROM bdicobranza: 'informix'.TMP_ENCABEZADOSEXCELCAMPCATXDIA";		
		LET cSql = '';
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
		SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
		SYSTEM cSql;
		LET cSql = '';
		LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
		SYSTEM cSql; 
		
		-- SE BORRA LA TABLA TEMPORAL DESPÚES DE VACIAR LOS DATOS EN EL ARCHIVO EXCEL
		IF cTabla = "S" THEN
			DROP TABLE bdicobranza: "informix".TMP_ENCABEZADOSEXCELCAMPCATXDIA;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';					
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    		
		RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la Calidad de Campañas CAT del día.', 
'AUTOR: Josué R. Zazueta',
'FECHA: Noviembre 2012',
'BD    : BDICOBRANZA',
'VERSION: 20121122.1527';

create procedure "informix".sp_latinia_contador(pcampania char(10),pcontador integer)
returning VARCHAR(6);

DEFINE cCod_ret  	smallint;
DEFINE cMensaje  	char (100);
DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO      VARCHAR(80);
DEFINE P_COD_RET      	VARCHAR(6);
DEFINE P_MENSAJE       	VARCHAR(80);
define vmaxfecha 		date;
define vfecha			date;

	let P_COD_RET = '000000';
	let cCod_ret = '';
    let cMensaje = '';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let vmaxfecha = date(1);
	let vfecha = date(1);


BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     RETURN P_COD_RET;
     END exception;
-- SET DEBUG FILE TO 'compac.out';
-- TRACE ON;
		
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
		
		if exists (select fecha_insert from  bdicred:sd_totalcte_campania where month(fecha_insert) = month(vfecha)
						and year(fecha_insert) = year(vfecha)	and tipocampania = pcampania) then
		
			update bdicred:sd_totalcte_campania  set total = total + pcontador 
				where month(fecha_insert) = month(vfecha) and year(fecha_insert) = year(vfecha)
				and tipocampania = pcampania ;
		else
			insert into bdicred:sd_totalcte_campania (empresa,fecha_insert,tipocampania,total)  
			values('001',today,pcampania,pcontador);
		end if;
	
	
end
RETURN P_COD_RET;
END PROCEDURE;