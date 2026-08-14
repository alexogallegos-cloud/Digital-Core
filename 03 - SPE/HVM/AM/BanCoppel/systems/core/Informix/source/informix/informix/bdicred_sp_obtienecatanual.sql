CREATE PROCEDURE "informix".sp_obtienecatanual(pEmpresa CHAR(3), pOpcion SMALLINT, pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)        AS codigo_retorno;

DEFINE cCodRet		CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE iContador INTEGER;
DEFINE dtFechaIni	DATE;
DEFINE dtFechaFin	DATE;
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE dCAt            DECIMAL(18,1);
DEFINE dPagoReq      	DECIMAL(18,2);
DEFINE dMonto      	DECIMAL(18,2);
DEFINE dComisiones      	DECIMAL(18,2);
DEFINE dComisiones_gc      	DECIMAL(18,2);
DEFINE dAnualidad      	DECIMAL(18,2);
DEFINE cProd      	CHAR(4);
DEFINE cNumCred      	CHAR(20);
DEFINE dSaldo      	DECIMAL(18,2);
DEFINE dSaldoTotal      	DECIMAL(18,2);
DEFINE dTasaInt      	DECIMAL(18,2);
DEFINE cCampo1      	CHAR(40);
DEFINE cCampo2      	CHAR(40);
DEFINE cCampo3      	CHAR(40);
DEFINE cCampo3_aux      	DECIMAL(18,2);
DEFINE cCampo3_acum     	DECIMAL(18,2);
DEFINE cCampo4      	CHAR(40);
DEFINE cCampo4_aux      	DECIMAL(18,2);
DEFINE cCampo4_acum     	DECIMAL(18,2);

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE mMntoComApert    DECIMAL(18,2);      -- Monto Comision Apertura
DEFINE mMntoComAnual    DECIMAL(18,2);      -- Monto Comision Anualidad
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);
DEFINE cCod_Comis_Anual CHAR(8);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            -- FIN RQM 10 993 CAT

DEFINE v_saldo_promedio		DECIMAL(18,2);		-- Modificacion calculo cal
DEFINE dtasa_prom_pond 		DECIMAL(18,2);		
DEFINE v_dias_periodo_tc  	INTEGER;
DEFINE v_cod_ret_otro	  	CHAR(5);
DEFINE v_periodo_anterior	DATE;				
DEFINE v_interes_tc   		DECIMAL(18,2);		-- Modificacion calculo cal


LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET dtFechaIni 	= DATE(1);
LET dtFechaFin 	= DATE(1);

LET cMensajeRet         = "Se realizó el cálculo correctamente";
LET vCatFinal =0;
LET dCAt =0;
LET dPagoReq =0;
LET dComisiones =0;
LET dComisiones_gc =0;
LET dAnualidad =0;
LET cProd ='';
LET cNumCred ='';
LET dMonto =0;
LET dSaldo =0;
LET dSaldoTotal =0;
LET dTasaInt =0;

LET cCampo1 ='';
LET cCampo2 ='';
LET cCampo3 ='';
LET cCampo3_aux =0;
LET cCampo3_acum =0;
LET cCampo4  ='';
LET cCampo4_aux  =0;
LET cCampo4_acum     =0;

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

LET cCobro_Apertu   = '';           -- INI RQM 10 993 CAT
LET cCodComis_Apert = '';
LET mMntoComApert     = 0;
LET cCobrComisAnual = '';
LET dMtoComAnualTit = 0;
LET dMtoComAnualAdi = 0;
LET cCod_Comis_Anual = '';
LET dClvComAnualTit = '';
LET dClvComAnualAdi = '';      
LET cCat_adicional  = '';           -- FIN RQM 10 993 CAT

LET v_saldo_promedio  = 0;			-- Modificacion calculo cal
LET dtasa_prom_pond   = 0;
LET v_dias_periodo_tc = 0;
LET v_cod_ret_otro 	  = "000";
LET v_periodo_anterior = DATE(1);	
LET	v_interes_tc 	   = 0; 		-- Modificacion calculo cal


BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	DROP TABLE sd_datoscatpromo;
	RETURN NVL(cCodRet,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/mahr/sp_obtienecatanual.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = ""   THEN
		LET cCodRet  = "000001";
		RETURN NVL(cCodRet,'');
	END IF;
	
	IF pOpcion = 1 THEN
		SELECT MONTHADD(pri_dia_mes,-12) ,pri_dia_mes -1 units day
		INTO dtFechaIni,dtFechaFin
		FROM "informix".sd_fechas;
	ELSE
		LET dtFechaIni = pFechaIni;
		LET dtFechaFin = pFechaFin;
	END IF;
	
		  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	Create table "informix".sd_datoscatpromo
	(num_credito CHAR(20),
	linea DECIMAL(18,2),
	tasa_interes DECIMAL(18,2),
	cat DECIMAL(18,1)
	)extent size 32 next size 32;
 
	create index "informix".idx_datcatcrd on "informix".sd_datoscatpromo(num_credito);
	create index "informix".idx_datcatcat on "informix".sd_datoscatpromo(cat);

/*
Create table "informix".sd_mestrascatpromocion
(producto char(4), 
 linea DECIMAL(18,2),
 tasadeinteres DECIMAL(18,3),
 pagorequerido DECIMAL(18,2),
 comisiones DECIMAL(18,2) ,  
 comisiones_gc DECIMAL(18,2) ,  
 anualidad DECIMAL(18,2) ,   
 cat DECIMAL(18,1)
 )extent size 32 next size 32;
 */

	FOREACH WITH HOLD
		SELECT TRIM(valor_alfabetico )
		INTO cProd
		FROM "informix".sd_param_campania
		WHERE tipo_campania ='67'
		AND grupo_parametro ='PRODCATPRO'


        -- Extrae Parametro Comision Apertura y Comision por Anualidad (titular y adicional)
        SELECT nvl(cobro_comis_apertura,'0'), nvl(cod_comision_apertura,''), cobro_comision_anual, cod_comision_anualidad, cat_comi_anual_adicional
          INTO cCobro_Apertu,                 cCodComis_Apert,               cCobrComisAnual,      cCod_Comis_Anual, 	   cCat_adicional
          FROM bdicred:sd_definicion WHERE num_producto = cProd;
		LET dClvComAnualTit = substr(cCod_Comis_Anual,1,4);
		LET dClvComAnualAdi = substr(cCod_Comis_Anual,5,4);
		  
		  
        LET cNombreArchivo = TRIM('TasaPonderada')||TRIM(cProd)||'_'||TO_CHAR(dtFechaFin,'%d%m%y')|| '.txt';
        LET cNombreArchivo1 = TRIM('TasaPonderada_aux')||TRIM(cProd)||'_'||TO_CHAR(dtFechaFin,'%d%m%y')|| '.txt';

        --*--se recalcula el cat para los creditos del año 2016

		--calculo del cat promocional
		TRUNCATE TABLE "informix".sd_datoscatpromo;
		---para creditos de originacion
		INSERT INTO "informix".sd_datoscatpromo
		SELECT a.num_credito,b.monto_solicitado	,a.tasa_interes,NVL(c.cat,0)
		FROM bdicred:"informix".sd_maecred a
		--INNER JOIN bidcred:sd_maesdos maes on (a.num_credito = maes.num_credito)
		LEFT OUTER JOIN	bdisolic:"informix".ss_revision_determinacion c on c.empresa= a.empresa and  c.num_solicitud = a.num_credito ,
		bdisolic:"informix".ss_solicitudes b , bdicred:"informix".sd_maesdos d 
		WHERE a.empresa=b.empresa
		AND a.num_credito =b.num_solicitud
		and  a.num_producto = cProd 
        AND a.num_credito =d.num_credito
		and  a.empresa =d.empresa
		AND a.fecha_apertura >=dtFechaIni
		AND a.fecha_apertura <=dtFechaFin
		AND a.status_cred IN ('AA','E1')
		AND (d.monto_vencido + d.mto_venc_trasp) = 0;

		--para creditos de upgrade se toma la linea con la que se crea el producto
		INSERT INTO "informix".sd_datoscatpromo
		 SELECT a.num_credito, (case when nvl(dosaux.monto_otorgado, 0) > 0 then nvl(dosaux.monto_otorgado,0) else nvl(b.monto_otorgado,0) end) monto_otorgado,
                a.tasa_interes, (case when c.cat >= 0 then c.cat else nvl(to_number(smq.cat),0) end) cat
		   FROM bdicred:"informix".sd_maecred a
           JOIN bdicred:"informix".sd_maesdos b ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.num_producto = cProd and a.status_cred IN ('AA','E1') AND (b.monto_vencido + b.mto_venc_trasp) = 0)
           LEFT OUTER JOIN bdicred:"informix".sd_maesdos dosaux ON (a.empresa = dosaux.empresa and a.credito_externo = dosaux.num_credito )
           LEFT OUTER JOIN bdisolic:"informix".ss_revision_determinacion c ON (a.empresa = c.empresa and a.num_credito = c.num_solicitud )
           LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_maquilatdc smq ON (a.empresa = smq.empresa and a.num_credito = smq.num_credito and a.num_producto = smq.producto )
		WHERE NVL(a.credito_externo,'') <> ''
		  AND a.fecha_apertura >= dtFechaIni
		  AND a.fecha_apertura <= dtFechaFin;

		
		FOREACH WITH HOLD
			SELECT num_credito,linea, tasa_interes
			INTO 	cNumCred, dMonto,dTasaInt
			FROM "informix".sd_datoscatpromo
			WHERE cat = 0

			LET dPagoReq = dMonto * (dTasaInt /100) / 360 * 30 ;
			/*IF cprod in ('7000','8100') THEN 
				IF cprod ='7000' then 
					LET dAnualidad = 1500;
				else
					LET dAnualidad = 250;
				end if
				LET dComisiones = 0;
				LET dComisiones_gc = 0;
			ELSE
				LET dComisiones = 50;
				LET dAnualidad = 0;
			END IF*/

            LET dComisiones_gc = 0;     LET dComisiones = 0;        LET mMntoComApert = 0;
            LET dAnualidad = 0;         LET mMntoComAnual = 0;      LET dMtoComAnualTit = 0;    LET dMtoComAnualAdi = 0;
            
            IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura configurado.
                SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
                LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
            END IF;

            IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
                Select nvl(monto,0) Into dMtoComAnualTit From bdicred:sd_tpcomis Where cod_comis = dClvComAnualTit;    -- Monto anualidad titular
                Select nvl(monto,0) Into dMtoComAnualAdi From bdicred:sd_tpcomis Where cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
                IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
                LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
            END IF;
            LET dComisiones = mMntoComApert;
            LET dAnualidad = mMntoComAnual;
			
			---------------------------------------
			-- Modificaciones al calulo del CAT ini
			EXECUTE PROCEDURE sp_mes_siguiente(date(dtFechaIni),+12,DAY(date(dtFechaIni))) INTO v_cod_ret_otro, v_periodo_anterior, v_dias_periodo_tc;
			IF v_cod_ret_otro <> "000" THEN
				LET v_dias_periodo_tc = 365;
			END IF;
			
			SELECT sum(interes_debe) INTO v_interes_tc
			  FROM bdicred:sd_amortiza_credito WHERE empresa = pempresa AND num_credito = cNumCred AND capital_status IN ('1','3');
		
			IF ( v_interes_tc > 0 ) THEN
				LET v_saldo_promedio = round((v_interes_tc*360)/(v_dias_periodo_tc * (dTasaInt / 100)),2);
			ELSE
				LET v_saldo_promedio = 0;
			END IF;

			IF v_saldo_promedio > 0 THEN
				LET dtasa_prom_pond = ((v_interes_tc / v_saldo_promedio)/ v_dias_periodo_tc ) * 360;
				LET dtasa_prom_pond = dtasa_prom_pond * 100;
			ELSE
				LET dtasa_prom_pond = 0;
			END IF;	
			LET dPagoReq = 10; -- Pago requerido 10% (de acuerdo a indicaciones del area de producto. (???)
			-- Modificaciones al calulo del CAT fin 
			

			--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(dMonto,dPagoReq,36,36,dComisiones,dComisiones_gc,dAnualidad) 
			EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(dMonto, dPagoReq, 36,36, dComisiones, dComisiones_gc, dAnualidad, dtasa_prom_pond) 
			INTO cCodRet, cMensajeRet, vCatFinal;	

			IF NVL(vCatFinal, 0) <= 0 THEN
				LET vCatFinal = 0 ;				
			END IF;

			IF vCatFinal > 160.1 THEN
				LET vCatFinal = 160.1 ;			
			END IF;
			
	
			UPDATE "informix".sd_datoscatpromo SET cat = vCatFinal WHERE num_credito = cNumCred;
			UPDATE bdisolic:"informix".ss_revision_determinacion SET cat = vCatFinal   WHERE empresa= pEmpresa and num_solicitud = cNumCred;
			--INSERT INTO "informix".sd_mestrascatpromocion( producto ,linea , tasadeinteres ,pagorequerido,comisiones ,comisiones_gc,anualidad,  cat )
			--VALUES (cProd,dMonto,dTasaInt,dPagoReq,dComisiones,dComisiones_gc,dAnualidad,vCatFinal);

		END FOREACH
		
		SELECT AVG(cat)
		INTO dCAt	
		FROM "informix".sd_datoscatpromo
		WHERE  cat > 0;		
		

	--calculo de la tasa de interes	
		--set isolation to dirty read;
		--SELECT SUM(sdo_cap_insoluto) / 1000 as sdo_cap_insoluto, tasa_interes as tasa_interes
		--FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_indicador_cred c
		--WHERE a.empresa=b.empresa and a.num_credito = b.num_credito 
		--and  a.num_producto =cProd 
		--and a.fecha_apertura >= dtFechaIni
		--and a.fecha_apertura <= dtFechaFin
		--AND a.status_cred in ('AA','BA','BT')
		--and a.num_credito = c.num_credito
		--and c.comportamiento <> 1
		--group by a.tasa_interes
		-- INTO TEMP tmp_CalTasaPon WITH NO LOG;
 	set isolation to dirty read;
	SELECT SUM(sdo_cap_insoluto) / 1000 as sdo_cap_insoluto, tasa_interes as tasa_interes
	  FROM "informix".sd_maecred a JOIN "informix".sd_maesdos b ON ( a.num_credito = b.num_credito and a.fecha_apertura >= dtFechaIni and a.fecha_apertura <= dtFechaFin )
	  JOIN "informix".sd_indicador_cred c ON ( a.empresa = c.empresa and a.num_credito = c.num_credito and c.comportamiento <> 1 )
	 WHERE a.num_producto = cProd
       AND a.status_cred in ('AA','BA','BT','E1','E2','E3') 
	 GROUP BY a.tasa_interes
	INTO TEMP tmp_CalTasaPon WITH NO LOG;

	 
	--clientes con credisoluciones
	INSERT INTO tmp_CalTasaPon
	SELECT  SUM(sdo_cap_insoluto)/ 1000,a.tasa_interes
	FROM "informix".sd_maecredcrd a , "informix".sd_maesdoscrd b, "informix".sd_maecred c, "informix".sd_promocion_credito d
	WHERE  a.empresa=b.empresa and a.num_credito = b.num_credito 
	and a.num_producto ='6900' and a.status_cred IN ('AA','E1') 
	and d.num_credito = c.num_credito
	and d.num_sol_prestamo= a.num_credito
	and c.num_producto = cProd
	and a.fecha_apertura >= dtFechaIni
		and a.fecha_apertura <= dtFechaFin
	group by a.tasa_interes;
	
		
	SELECT  SUM(sdo_cap_insoluto)
		INTO dSaldoTotal
	FROM tmp_CalTasaPon;
	
	FOREACH WITH HOLD	
	SELECT  NVL(sdo_cap_insoluto,0),NVL(tasa_interes,0)
	INTO dSaldo, dTasaInt
	FROM tmp_CalTasaPon		
		
		LET cCampo1 = "$ " ||NVL(dSaldo,0);
		LET cCampo2 = NVL(dTasaInt,0) ||" %";
		LET cCampo3_aux = CASE WHEN NVL(dSaldoTotal,0) > 0 THEN (Round((NVL(dSaldo,0) / NVL(dSaldoTotal,0)),2)*100) ELSE 0 END  ;
		LET cCampo3_acum = cCampo3_acum + cCampo3_aux;
		LET cCampo3 = cCampo3_aux||" %";
		LET cCampo4_aux =  CASE WHEN NVL(dSaldoTotal,0) > 0 THEN Round(NVL(dTasaInt,0)*(NVL(dSaldo,0) / NVL(dSaldoTotal,0)),2) ELSE 0 END  ;
		LET cCampo4_acum = cCampo4_acum +  cCampo4_aux;
		LET cCampo4 = cCampo4_aux||" %";
			
		LET cConsulta = TRIM(NVL(cCampo1,''))||'|'|| TRIM(NVL(cCampo2,''))||'|'||TRIM(NVL(cCampo3,''))||'|'||NVL(cCampo4,'');			
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;		
	END FOREACH;

		LET cCampo1 = "Total";
		LET cCampo2 = " - ";
		LET cCampo3 = cCampo3_acum||" %";
		LET cCampo4 = cCampo4_acum||" %";
			
		LET cConsulta = TRIM(NVL(cCampo1,''))||'|'|| TRIM(NVL(cCampo2,''))||'|'||TRIM(NVL(cCampo3,''))||'|'||NVL(cCampo4,'');
			---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
	
		SYSTEM cEncabezado;		
		LET cCampo1 = "CAT Promocional";
		LET cCampo2 = dCAt;
		LET cCampo3 = "";
		LET cCampo4 = "";
			
		LET cConsulta = TRIM(NVL(cCampo1,''))||'|'|| TRIM(NVL(cCampo2,''))||'|'||TRIM(NVL(cCampo3,''))||'|'||NVL(cCampo4,'');
			---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

				---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Saldo del portafolio (Miles)'||'|'||'Tasa'||'|'||'Ponderación'||'|'||'Tasa Ponderada'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   	
		DROP TABLE tmp_CalTasaPon;
		LET cCampo3_aux =0;
		LET cCampo3_acum =0;
		LET cCampo4_aux =0;
		LET cCampo4_acum =0;
	END FOREACH;		 
	DROP TABLE sd_datoscatpromo;
	
	RETURN NVL(cCodRet,'');
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para calcular el cat promocional de los productos de credito existentes',
'FECHA: 08/noviembre/2016',
'BD: bdicred',
'AUTOR: Jesus Manuel Aguilar Heredia';

CREATE PROCEDURE "informix".sp_obtienecatanual_pdn(pEmpresa CHAR(3), pOpcion SMALLINT, pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)        AS codigo_retorno;

DEFINE cCodRet		CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE iContador INTEGER;
DEFINE dtFechaIni	DATE;
DEFINE dtFechaFin	DATE;
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE dCAt            DECIMAL(18,1);
DEFINE dPagoReq      	DECIMAL(18,2);
DEFINE dMonto      	DECIMAL(18,2);
DEFINE dComisiones      	DECIMAL(18,2);
DEFINE dComisiones_gc      	DECIMAL(18,2);
DEFINE dAnualidad      	DECIMAL(18,2);
DEFINE cProd      	CHAR(4);
DEFINE cNumCred      	CHAR(20);
DEFINE dSaldo      	DECIMAL(18,2);
DEFINE dSaldoTotal      	DECIMAL(18,2);
DEFINE dTasaInt      	DECIMAL(18,2);
DEFINE cCampo1      	VARCHAR(100,1);
DEFINE cCampo2      	VARCHAR(100,1);
DEFINE cCampo3      	VARCHAR(100,1);
DEFINE cCampo3_aux      	DECIMAL(18,2);
DEFINE cCampo3_acum     	DECIMAL(18,2);
DEFINE cCampo4      	VARCHAR(100,1);
DEFINE cCampo4_aux      	DECIMAL(18,2);
DEFINE cCampo4_acum     	DECIMAL(18,2);
DEFINE iFrecuencia    INTEGER;
DEFINE iPlazo     	INTEGER;
DEFINE dPorcComisionAper     	DECIMAL(18,2);
DEFINE mComisionApertura     	DECIMAL(18,2);
DEFINE cPeriodo_plazo     	CHAR(15);

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);


LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET dtFechaIni 	= DATE(1);
LET dtFechaFin 	= DATE(1);

LET cMensajeRet         = "Se realizó el cálculo correctamente";
LET vCatFinal =0;
LET dCAt =0;
LET dPagoReq =0;
LET dComisiones =0;
LET dComisiones_gc =0;
LET dAnualidad =0;
LET cProd ='';
LET cNumCred ='';
LET dMonto =0;
LET dSaldo =0;
LET dSaldoTotal =0;
LET dTasaInt =0;

LET cCampo1 ='';
LET cCampo2 ='';
LET cCampo3 ='';
LET cCampo3_aux =0;
LET cCampo3_acum =0;
LET cCampo4  ='';
LET cCampo4_aux  =0;
LET cCampo4_acum     =0;
LET iFrecuencia     =0;
LET iPlazo     =0;
LET dPorcComisionAper     =0;
LET mComisionApertura     =0;
LET cPeriodo_plazo     ='';

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	DROP TABLE sd_datoscatpromo_pdn;
	RETURN NVL(cCodRet,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/inccat/sp_obtienecatanual_pdn.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = ""   THEN
		LET cCodRet  = "000001";
		RETURN NVL(cCodRet,'');
	END IF;
	
	IF pOpcion = 1 THEN
		SELECT MONTHADD(pri_dia_mes,-12) ,pri_dia_mes -1 units day
		INTO dtFechaIni,dtFechaFin
		FROM "informix".sd_fechas;
	ELSE
		LET dtFechaIni = pFechaIni;
		LET dtFechaFin = pFechaFin;
	END IF;
	
		  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	Create table "informix".sd_datoscatpromo_pdn
	(num_credito CHAR(20),
	linea DECIMAL(18,2),
	tasa_interes DECIMAL(18,2),
	cat DECIMAL(18,1),	
	plazo INTEGER,
	periodo_plazo CHAR(15)
	)extent size 320 next size 32;
 
 

		SELECT valor INTO dPorcComisionAper
		FROM   "informix".sd_param
		WHERE  cod_param = '040';

		
		IF ( dPorcComisionAper is null ) THEN LET dPorcComisionAper = 0; END IF;

	


	LET cNombreArchivo = TRIM('CATPromocional_PDN_')||'_'||TO_CHAR(dtFechaFin,'%d%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('TasaPonderada_aux')||'_'||TO_CHAR(dtFechaFin,'%d%m%y')|| '.txt';

	  --*--se recalcula el cat para los creditos del año 2016

		--calculo del cat promocional
		TRUNCATE TABLE "informix".sd_datoscatpromo_pdn;
		---para creditos de originacion
		INSERT INTO "informix".sd_datoscatpromo_pdn
		SELECT a.num_credito,b.monto_otorgado	,a.tasa_interes,NVL(c.cat,0),plazo,TRIM(DECODE(periodo_plazo,"M","MENSUAL","Q","QUINCENAL","MENSUAL"))
		FROM "informix".sd_maecredcrd a
		INNER JOIN	"informix".sd_maesdoscrd b on b.empresa= a.empresa and  b.num_credito = a.num_credito 
		INNER JOIN	"informix".sd_maecredanexocrd c on c.empresa= a.empresa and  c.num_credito = a.num_credito 
		WHERE a.empresa=b.empresa
		AND a.num_credito =b.num_credito
		and  a.num_producto ='6400' 
		and a.fecha_apertura >= dtFechaIni
		and a.fecha_apertura <= dtFechaFin
		AND a.status_cred In ('AA','E1')
		AND (b.monto_vencido + b.mto_venc_trasp) = 0;			
		
		
		FOREACH WITH HOLD
			SELECT num_credito,linea, tasa_interes,frecuencia_pgo, plazo
			INTO 	cNumCred, dMonto,dTasaInt, iFrecuencia, iPlazo
			FROM "informix".sd_datoscatpromo_pdn	a
			inner join  bdisolic:"informix".ss_sol_nomina nom ON  (nom.empresa = '001' and nom.num_solicitud= a.num_credito)
			WHERE cat = 0
		
		
		LET dPagoReq = dMonto / ((1- pow((1+((dTasaInt /100)/( iFrecuencia * 12 ))),-iPlazo)) / ((dTasaInt /100)/( iFrecuencia * 12 )) ) ;
			
		IF ( dPorcComisionAper > 0 ) then
			LET mComisionApertura= ROUND(dMonto * (dPorcComisionAper/100),2);
		END IF

		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp
			(dMonto,dPagoReq,iPlazo,(12 * iFrecuencia),mComisionApertura) 
			into cCodRet,cMensajeRet,vCatFinal;	
		
	
			UPDATE "informix".sd_datoscatpromo_pdn SET cat = vCatFinal WHERE num_credito = cNumCred;
			UPDATE bdicred:"informix".sd_maecredanexocrd SET cat = vCatFinal  WHERE empresa= pEmpresa and num_credito = cNumCred;
		
		END FOREACH
		
		FOREACH WITH HOLD
			SELECT periodo_plazo,plazo, SUM(linea *cat) / SUM(linea)
				INTO cPeriodo_plazo ,iPlazo, dCAt	
			FROM "informix".sd_datoscatpromo_pdn
			WHERE  cat > 0
			GROUP BY periodo_plazo,plazo
			ORDER BY periodo_plazo,plazo
			
		
		
			
			LET cCampo1 = "CAT Promocional "||' '|| cPeriodo_plazo||' '|| iPlazo;
			LET cCampo2 = " - ";
			LET cCampo3 = dCAt||" %";
			
				
			LET cConsulta = TRIM(NVL(cCampo1,''))||'|'|| TRIM(NVL(cCampo2,''))||'|'||TRIM(NVL(cCampo3,''));
				---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		
			SYSTEM cEncabezado;		
			
			
			LET cCampo1 ='';
			LET cCampo2 ='';
			LET cCampo3 ='';

		END FOREACH	
		FOREACH WITH HOLD
			SELECT periodo_plazo,plazo, SUM(linea *cat) / SUM(linea)
				INTO cPeriodo_plazo ,iPlazo, dCAt	
			FROM "informix".sd_datoscatpromo_pdn
			WHERE  cat > 0
			GROUP BY periodo_plazo,plazo
			ORDER BY periodo_plazo,plazo	
		
			
			LET cCampo1 = "CAT promedio del Préstamo Directo Nómina esquema "||' '|| cPeriodo_plazo;
			LET cCampo2 = " - ";
			LET cCampo3 = dCAt||" %";
							
			LET cConsulta = TRIM(NVL(cCampo1,''))||'|'|| TRIM(NVL(cCampo2,''))||'|'||TRIM(NVL(cCampo3,''));
				---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		
			SYSTEM cEncabezado;		
			
			
			LET cCampo1 ='';
			LET cCampo2 ='';
			LET cCampo3 ='';

		END FOREACH	

	
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   		
			
		 
	DROP TABLE sd_datoscatpromo_pdn;
	
	RETURN NVL(cCodRet,'');
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para calcular el cat promocional del Producto Directo Nómina',
'FECHA: 08/febrero/2017',
'BD: bdicred',
'AUTOR: Jesus Manuel Aguilar Heredia';

CREATE PROCEDURE "informix".sp_validarinfocrediticia_ofi
(
pEmpresa		CHAR(3), 
pNumCte			VARCHAR(20),
pNumTarjeta		VARCHAR(20)
)

RETURNING 
CHAR(6) AS COD_RET,
CHAR(80) AS MENSAJE_RET,
CHAR(60) AS DESC_STATUS;
		  
--DEFINICIÃN DE VARIABLES--		  
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);

DEFINE cDescripcion			CHAR(60);
DEFINE cNumTarjeta			CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE cStatusInc			CHAR(2);
DEFINE dtFecha1				DATE;
DEFINE dtFechaHoy			DATE;
DEFINE v_empresa			CHAR(1);
DEFINE v_garantizada		CHAR(1);
DEFINE v_credito			CHAR(1);
DEFINE v_valida				CHAR(1);
DEFINE cMtoVen              DECIMAL(18,2);

--INICIALIZACIÃN DE VARIABLES--
LET iSqlErr               	= 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= 'PROCESO EXITOSO';
LET cCodRet               	= '000000';

LET cDescripcion			= '';
LET cNumTarjeta				= '';
LET cNumCredito				= '';
LET cStatusCred				= '';
LET cStatusInc				= '';
LET dtFecha1				= DATE(1);
LET dtFechaHoy				= DATE(1);
LET v_empresa				= '';
LET v_garantizada			= '';
LET v_credito				= '';
LET v_valida				= '';
LET cMtoVen                = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;
		  
	--SET DEBUG FILE TO '/home/sysifx/has/sp_validarinfocrediticia_ofi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;

	IF NVL(pEmpresa,'') = '' OR (NVL(pNumCte,'') = '' AND NVL(pNumTarjeta,'') = '') THEN 
		LET cCodRet = '000001';
		LET cErrorInfo = 'FALTA UNO O MAS PARÃMETROS';
		RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
	ELSE
		--IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
		SELECT FIRST 1 '1' INTO v_empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
		
		IF (v_empresa IS NULL) OR (v_empresa = '') THEN
			LET cCodRet = '000002';
			LET cErrorInfo = 'LA EMPRESA NO ES VÃLIDA';
			RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		ELSE
			-- NO VIENE LA TARJETA PERO SI TRAE EL NUMERO DE CLIENTE EN LOS PARAMETROS RECIBIDOS
			IF NVL(pNumTarjeta,'') = '' THEN -- HACER QUE LA CONSULTA REGRESE EL CREDITO QUE ESTA VIGENTE YA QUE EL CLIENTE PUEDE TENER MAS DE 1
				FOREACH WITH HOLD
					SELECT a.num_credito, a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					INTO cNumCredito, cStatusCred,cMtoVen
					FROM bdicred:"informix".sd_maecred a
					INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
					WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
					ORDER BY a.fecha_apertura DESC
				END FOREACH
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '000003';
					LET cErrorInfo = 'NO SE ENCUENTRA EL CLIENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			
				SELECT num_tarjeta
				INTO cNumTarjeta
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_credito = cNumCredito AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumTarjeta,'') = '' THEN
					LET cCodRet = '000004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			-- TRAE EL NUMERO DE TARJETA EN LOS PARAMETROS RECIBIDOS
			ELSE
				SELECT num_credito, numcte
				INTO cNumCredito, pNumCte
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pNumTarjeta AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '000004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON DE CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
				
				SELECT a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
				INTO cStatusCred, cMtoVen
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
				WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
				AND a.num_credito = cNumCredito ;
				
			END IF
			
			--validaciÃ³n de TDC Garantizada			
			--IF EXISTS (SELECT * FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S") THEN
			
			SELECT FIRST 1 '1' INTO v_garantizada FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S";
			
			IF (v_garantizada = '1') THEN
				-- Cliente con Tarjeta de CrÃ©dito Garantizada.
				LET cCodRet = '000011';
				LET cErrorInfo = 'Cliente con Tarjeta de CrÃ©dito Garantizada.';
				RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
			END IF;					
			
			--Lazalde VALIDAR QUE LA TARJETA DE CREDITO VISA NO ESTE BLOQUEADA				
				--VALIDAR DE QUE EL NUMERO DE CREDITO EXISTA EN EL LISTADO DE TARJETAS BLOQUEADAS
			/*	IF EXISTS(
					SELECT num_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito
					)
						THEN*/
				SELECT FIRST 1 '1' INTO v_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito;
					
				IF (v_credito = '1') THEN
							LET cCodRet = '000012';
							LET cErrorInfo = 'Cliente tiene "Bloqueada" su Tarjeta de CrÃ©dito Visa';
							RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
			
			  IF (cStatusCred NOT IN ('AA','E1') or cMtoVen > 0) THEN   --IFRS MACF
				IF cStatusCred IN ('BT','BA','CV','FC','E1','E2','E3')  THEN  --IFRS MACF
					SELECT descripcion
					INTO cDescripcion
					FROM bdicred:"informix".sd_tipocartera
					WHERE status_cred = cStatusCred;
					LET cCodRet = '000005';
					LET cErrorInfo = 'CLIENTE TIENE ' || trim(cDescripcion) || ' SU TARJETA DE CRÃDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				ELSE
					LET cCodRet = '000006';
					LET cErrorInfo = 'CLIENTE CON CRÃDITO NO VIGENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			ELSE
				-- OBTIENE LA FECHA DOS MESES ANTES
				SELECT monthadd(fecha_hoy, -3), fecha_hoy
				INTO dtFecha1, dtFechaHoy
				FROM bdicred:"informix".sd_fechas
				WHERE empresa = pEmpresa;
			
			/*	IF EXISTS(SELECT empresa FROM bdicred:"informix".sd_bitacora_aumlincred 
						WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY) )  THEN*/
				SELECT FIRST 1 '1' INTO v_valida FROM bdicred:"informix".sd_bitacora_aumlincred 
				WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY);
				
				IF (v_valida = '1') THEN
					-- Solicitud de incremento ya hecha en el mismo dia
					LET cCodRet = '000010';
					LET cErrorInfo = 'CLIENTE YA REALIZÃ LA SOLICITUD DE INCREMENTO ESTE MISMO DÃA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF

				SELECT FIRST 1 NVL(a.status,'')
				INTO cStatusInc
				FROM bdicred:"informix".sd_bitacora_aumlincred a
				WHERE a.numcte = pNumCte           
				AND a.fecha_insert = (SELECT MAX(b.fecha_insert)
									   FROM bdicred:"informix".sd_bitacora_aumlincred b
									  WHERE b.status = b.status
										AND b.numcte = pNumCte
										AND b.empresa = a.empresa
										AND b.fecha_insert BETWEEN dtFecha1 AND dtFechaHoy)
				AND a.empresa = pEmpresa;
				   
				IF cStatusInc IS NULL THEN
					LET cStatusInc = '';
				END IF;
			   
				IF cStatusInc IN ('IN','AT') THEN
				   -- Cliente tiene en tramite un Incremento en la lÃ­nea de CrÃ©dito
					LET cCodRet = '000007';
					LET cErrorInfo = 'CLIENTE TIENE EN TRAMITE UN INCREMENTO EN LA LÃNEA DE CRÃDITO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc = 'RT' THEN
				   -- Cliente con Solicitud de Incremento de LÃ­nea 'Rechazada'
					LET cCodRet = '000008';
					LET cErrorInfo = 'CLIENTE CON SOLICITUD DE INCREMENTO DE LÃNEA RECHAZADA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc IN ('PC','AC','BC','CC','EC') THEN
				   -- Cliente tiene una Solicitud de Incremento de LÃ­nea en Proceso
					LET cCodRet = '000009';
					LET cErrorInfo = 'CLIENTE TIENE UNA SOLICITUD DE INCREMENTO DE LÃNEA EN PROCESO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			END IF
			
		END IF
	END IF

	RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para confirmaciÃ³n de la informaciÃ³n del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/10/2011',
'BD    : BDICRED',
'MODIFICO: Mohamed Carreon',
'DESCRIPCION: Se modifico para cumplir con las reglas de programacion',
'FECHA: 11/NOV/2011',
'MODIFICO: Armando Morales',
'DESCRIPCION: Se modificÃ³ para que consulte el credito mas reciente que tiene el cliente ya que puede tener mas de 1',
'FECHA: 12/06/2012',
'Modificacion: Se corrige para agregar validaciÃ³n de las solicitudes en PC',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 17/Septiembre/2012',
'BD    : bdicred',
'VERSION:20120917.1011',
'FECHA: 12/06/2012',
'Modificacion: Se borra cÃ³digo comentado,se agregan informix y bd a las tablas que no tenÃ­an, Se implementan reglas','de informix',
'AUTOR : JosuÃ© Remberto Zazueta Acosta',
'FECHA : 02/Octubre/2012',
'BD    : bdicred',
'Modificacion: Validar si la tarjeta de crÃ©dito visa esta bloqueada',
'AUTOR : Juan Daniel Lazalde',
'FECHA : 14/Febrero/2014',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_validarinfocrediticia_ofi_web
(
pEmpresa		CHAR(3), 
pNumCte			VARCHAR(20),
pNumTarjeta		VARCHAR(20)
)

RETURNING 
CHAR(5) AS COD_RET,
CHAR(80) AS MENSAJE_RET,
CHAR(60) AS DESC_STATUS;
		  
--DEFINICIÃÂN DE VARIABLES--		  
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(5);

DEFINE cDescripcion			CHAR(60);
DEFINE cNumTarjeta			CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE cStatusInc			CHAR(2);
DEFINE dtFecha1				DATE;
DEFINE dtFechaHoy			DATE;
DEFINE v_empresa			CHAR(1);
DEFINE v_garantizada		CHAR(1);
DEFINE v_credito			CHAR(1);
DEFINE v_valida				CHAR(1);
DEFINE cMtoVen              DECIMAL(18,2);

--INICIALIZACIÃÂN DE VARIABLES--
LET iSqlErr               	= 0;
LET iIsamErr              	= 0;
LET cErrorInfo            	= 'PROCESO EXITOSO';
LET cCodRet               	= '00000';

LET cDescripcion			= '';
LET cNumTarjeta				= '';
LET cNumCredito				= '';
LET cStatusCred				= '';
LET cStatusInc				= '';
LET dtFecha1				= DATE(1);
LET dtFechaHoy				= DATE(1);
LET v_empresa				= '';
LET v_garantizada			= '';
LET v_credito				= '';
LET v_valida				= '';
LET cMtoVen                = 0;

-- INICIO DEL PROCEDIMIENTO
BEGIN 
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;
		  
	--SET DEBUG FILE TO '/home/sysifx/has/sp_validarinfocrediticia_ofi.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') = '' OR (NVL(pNumCte,'') = '' AND NVL(pNumTarjeta,'') = '') THEN 
		LET cCodRet = '00001';
		LET cErrorInfo = 'FALTA UNO O MAS PARÃÂMETROS';
		RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
	ELSE
		--IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
		SELECT FIRST 1 '1' INTO v_empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
		
		IF (v_empresa IS NULL) OR (v_empresa = '') THEN
			LET cCodRet = '00002';
			LET cErrorInfo = 'LA EMPRESA NO ES VÃÂLIDA';
			RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
		ELSE
			-- NO VIENE LA TARJETA PERO SI TRAE EL NUMERO DE CLIENTE EN LOS PARAMETROS RECIBIDOS
			IF NVL(pNumTarjeta,'') = '' THEN -- HACER QUE LA CONSULTA REGRESE EL CREDITO QUE ESTA VIGENTE YA QUE EL CLIENTE PUEDE TENER MAS DE 1
				FOREACH WITH HOLD
									  
									
					SELECT a.num_credito, a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					INTO cNumCredito, cStatusCred,cMtoVen
					FROM bdicred:"informix".sd_maecred a
					INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
					WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
					ORDER BY a.fecha_apertura DESC
				END FOREACH
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '00003';
					LET cErrorInfo = 'NO SE ENCUENTRA EL CLIENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			
				SELECT num_tarjeta
				INTO cNumTarjeta
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_credito = cNumCredito AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumTarjeta,'') = '' THEN
					LET cCodRet = '00004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON CRÃÂDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			-- TRAE EL NUMERO DE TARJETA EN LOS PARAMETROS RECIBIDOS
			ELSE
				SELECT num_credito, numcte
				INTO cNumCredito, pNumCte
				FROM bdicred:"informix".sd_tarjeta 
				WHERE num_tarjeta = pNumTarjeta AND empresa = pEmpresa AND tipo_tarjeta = 'T' AND status_tar = 'A';
				
				IF NVL(cNumCredito,'') = '' THEN
					LET cCodRet = '00004';
					LET cErrorInfo = 'CLIENTE NO CUENTA CON DE CRÃÂDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
				
				SELECT a.status_cred, NVl(b.monto_vencido + b.mto_venc_trasp,0)
					
									  
												 
									 
	
													
				INTO cStatusCred, cMtoVen
				FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:"informix".sd_maesdos b on a.num_credito = b.num_credito
				WHERE a.empresa = pEmpresa AND a.numcte = pNumCte
				AND a.num_credito = cNumCredito ;
				
			END IF
			
			--validaciÃÂ³n de TDC Garantizada			
			--IF EXISTS (SELECT * FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S") THEN
			
			SELECT FIRST 1 '1' INTO v_garantizada FROM bdicred:"informix".sd_tarjeta_garantizada WHERE empresa = pEmpresa and num_credito = cNumCredito AND garantizada = "S";
			
			IF (v_garantizada = '1') THEN
				-- Cliente con Tarjeta de CrÃÂ©dito Garantizada.
				LET cCodRet = '00011';
				LET cErrorInfo = 'Cliente con Tarjeta de CrÃÂ©dito Garantizada.';
				RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
			END IF;					
			
			--Lazalde VALIDAR QUE LA TARJETA DE CREDITO VISA NO ESTE BLOQUEADA				
				--VALIDAR DE QUE EL NUMERO DE CREDITO EXISTA EN EL LISTADO DE TARJETAS BLOQUEADAS
			/*	IF EXISTS(
					SELECT num_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito
					)
						THEN*/
				SELECT FIRST 1 '1' INTO v_credito FROM "informix".sd_maecred 
					WHERE ((id_unidad_prod IS NOT NULL) OR (cod_caract <> "" OR cod_caract IS NOT NULL) or (cod_caract_2 <> "" OR cod_caract_2 IS NOT NULL))
					and num_credito = cNumCredito;
					
				IF (v_credito = '1') THEN
							LET cCodRet = '00012';
							LET cErrorInfo = 'Cliente tiene "Bloqueada" su Tarjeta de CrÃÂ©dito Visa';
							RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
			
			  IF (cStatusCred NOT IN ('AA','E1') or cMtoVen > 0) THEN   --IFRS MACF
												   
				IF cStatusCred IN ('BT','BA','CV','FC','E1','E2','E3')  THEN  --IFRS MACF
					SELECT descripcion
					INTO cDescripcion
					FROM bdicred:"informix".sd_tipocartera
					WHERE status_cred = cStatusCred;
					LET cCodRet = '00005';
					LET cErrorInfo = 'CLIENTE TIENE ' || trim(cDescripcion) || ' SU TARJETA DE CREDITO VISA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				ELSE
					LET cCodRet = '00006';
					LET cErrorInfo = 'CLIENTE CON CREDITO NO VIGENTE';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			ELSE
				-- OBTIENE LA FECHA DOS MESES ANTES
				SELECT monthadd(fecha_hoy, -3), fecha_hoy
				INTO dtFecha1, dtFechaHoy
				FROM bdicred:"informix".sd_fechas
				WHERE empresa = pEmpresa;
			
			/*	IF EXISTS(SELECT empresa FROM bdicred:"informix".sd_bitacora_aumlincred 
						WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY) )  THEN*/
				SELECT FIRST 1 '1' INTO v_valida FROM bdicred:"informix".sd_bitacora_aumlincred 
				WHERE numcte = pNumCte AND (fecha_insert = dtFechaHoy OR fecha_insert = TODAY);
				
				IF (v_valida = '1') THEN
					-- Solicitud de incremento ya hecha en el mismo dia
					LET cCodRet = '00010';
					LET cErrorInfo = 'CLIENTE YA REALIZÃÂ LA SOLICITUD DE INCREMENTO ESTE MISMO DÃÂA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF

				SELECT FIRST 1 NVL(a.status,'')
				INTO cStatusInc
				FROM bdicred:"informix".sd_bitacora_aumlincred a
				WHERE a.numcte = pNumCte           
				AND a.fecha_insert = (SELECT MAX(b.fecha_insert)
									   FROM bdicred:"informix".sd_bitacora_aumlincred b
									  WHERE b.status = b.status
										AND b.numcte = pNumCte
										AND b.empresa = a.empresa
										AND b.fecha_insert BETWEEN dtFecha1 AND dtFechaHoy)
				AND a.empresa = pEmpresa;
				   
				IF cStatusInc IS NULL THEN
					LET cStatusInc = '';
				END IF;
			   
				IF cStatusInc IN ('IN','AT') THEN
				   -- Cliente tiene en tramite un Incremento en la lÃÂ­nea de CrÃÂ©dito
					LET cCodRet = '00007';
					LET cErrorInfo = 'CLIENTE TIENE EN TRAMITE UN INCREMENTO EN LA LÃÂNEA DE CRÃÂDITO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc = 'RT' THEN
				   -- Cliente con Solicitud de Incremento de LÃÂ­nea 'Rechazada'
					LET cCodRet = '00008';
					LET cErrorInfo = 'CLIENTE CON SOLICITUD DE INCREMENTO DE LÃÂNEA RECHAZADA';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF;
				
				IF cStatusInc IN ('PC','AC','BC','CC','EC') THEN
				   -- Cliente tiene una Solicitud de Incremento de LÃÂ­nea en Proceso
					LET cCodRet = '00009';
					LET cErrorInfo = 'CLIENTE TIENE UNA SOLICITUD DE INCREMENTO DE LÃÂNEA EN PROCESO';
					RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
				END IF
			END IF
			
		END IF
	END IF

	RETURN cCodRet,  NVL(cErrorInfo,''), NVL(cDescripcion,'');
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para confirmaciÃÂ³n de la informaciÃÂ³n del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/10/2011',
'BD    : BDICRED',
'MODIFICO: Mohamed Carreon',
'DESCRIPCION: Se modifico para cumplir con las reglas de programacion',
'FECHA: 11/NOV/2011',
'MODIFICO: Armando Morales',
'DESCRIPCION: Se modificÃÂ³ para que consulte el credito mas reciente que tiene el cliente ya que puede tener mas de 1',
'FECHA: 12/06/2012',
'Modificacion: Se corrige para agregar validaciÃÂ³n de las solicitudes en PC',
'AUTOR : JesÃÂºs Manuel Aguilar Heredia',
'FECHA : 17/Septiembre/2012',
'BD    : bdicred',
'VERSION:20120917.1011',
'FECHA: 12/06/2012',
'Modificacion: Se borra cÃÂ³digo comentado,se agregan informix y bd a las tablas que no tenÃÂ­an, Se implementan reglas','de informix',
'AUTOR : JosuÃÂ© Remberto Zazueta Acosta',
'FECHA : 02/Octubre/2012',
'BD    : bdicred',
'Modificacion: Validar si la tarjeta de crÃÂ©dito visa esta bloqueada',
'AUTOR : Juan Daniel Lazalde',
'FECHA : 14/Febrero/2014',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_chi_pld_layout_sic(v_id_proceso CHAR(1))
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Creado por: 			Gutberto Gomez Guadarrama
	-- Fecha de creacion: 	25/05/2021
	-- Peticion:			RQM 10-1404 (RQI 28 268)
	-- Modificado por: 		N/A
	-- Fecha modificación:	N/A
	-- Modificación:		N/A
	-- BD: 					bdicred
	-- ID Rational:			50746
	-------------------------------------------------------------------------------------
	-- Peticion:			RQM 10 1404 - Hipotecario Infonavit
	-- Modificado por: 		Miguel Alejandro Sánchez Mojica
	-- Fecha modificación:	16/12/2021
	-- Modificación:		Manejo de errores en sección de exceptions
	-- BD: 					bdicred
	-- ID Rational:			54604
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	error_info              CHAR(40);
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);
    DEFINE     	cod_ret_aux             CHAR(6);
	DEFINE	   	mensaje_ret_aux			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE 		v_fechacaptura          DATE;
	DEFINE 		v_fechaintegracion      DATE;
	DEFINE 		v_naturaleza            CHAR(1);
	DEFINE 		v_importe               MONEY(18,2);
	DEFINE 		v_mensaje               CHAR(50);
	DEFINE 		v_status	            CHAR(8);
	DEFINE 		v_integra               INTEGER;
	DEFINE 		v_numtotal              SMALLINT;
	DEFINE	   	vCounter				INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRuta_in			    CHAR(100);
	DEFINE 		cRuta_out			    CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cArchivoLay			    CHAR(100);
	DEFINE 		cArchivoRep			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
	DEFINE 		cNombreArchivo2		    CHAR(100);
	
	DEFINE		v_ap_paterno			VARCHAR(50);
	DEFINE		v_ap_materno			VARCHAR(50);
	DEFINE		v_nombres				VARCHAR(80);
	DEFINE		v_fecha_nac				VARCHAR(10);
	DEFINE		v_rfc					VARCHAR(13);
	DEFINE		v_num_credito			VARCHAR(20);
	DEFINE		v_ind_listas_negras		VARCHAR(1);
	DEFINE		v_count_exist			INTEGER;
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
    LET 	   	cod_ret_aux 			= '00000'; 
	LET 	   	mensaje_ret_aux 		= '';
	LET			v_count_exist			= 0;
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET			v_fechacaptura			= today;
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta_in	 			= "/resplogifx/hipotecario_infonavit/pld/";
	LET 		cRuta_out	 			= "/RESPALDOSNEW/hipotecario_infonavit/pld/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_temp_chi_pld_layout_sic.sql";
	LET 		cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cArchivoLay				= "chi_pld_layout_sic_";
	LET 		cArchivoRep				= "chi_pld_layout_sic_listas_negras_";
	LET			cNombreArchivo			= "";
	LET			cNombreArchivo2			= "";
	LET			vCounter				= 0;
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A CARGAR, TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS Y LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
				DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/pld/sp_chi_pld_layout_sic'||v_id_proceso||'.out';
		--TRACE ON;                                                   
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

-- ****************************************************************************
-- *                      SE OBTIENE FECHA DE PROCESO                         *
-- ****************************************************************************	
	SELECT LPAD(YEAR(fecha_hoy), 4, '0') INTO cYear FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(MONTH(fecha_hoy), 2, '0') INTO cMes FROM bdicred:sd_fechas WHERE empresa = '001';
	SELECT LPAD(DAY(fecha_hoy), 2, '0') INTO cDia FROM bdicred:sd_fechas WHERE empresa = '001';	

-- ****************************************************************************
-- *                          PASE A HISTORICO                                *
-- ****************************************************************************	
IF v_id_proceso = 0 THEN
			INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_hist 
			SELECT * FROM bdicred:"informix".sd_chi_pld_layout_sic;

-- ****************************************************************************
-- *                     ELIMINAR REGISTROS ACTUALES                          *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic;
		
-- ****************************************************************************
-- *                        ELIMINAR TABLA DE PASO                            *
-- ****************************************************************************	
			
			DELETE FROM bdicred:"informix".sd_chi_pld_layout_sic_paso;
		
	
-- ****************************************************************************
-- *               IMPORTACIóN DE ARCHIVO A TABLA DE PASO                     *
-- ****************************************************************************	
			
			--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC|NUMERO CREDITO
			LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
			LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRuta_in) || TRIM(cNombreArchivo) || 
				' INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_paso;' || "" || '">'||TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM TRIM(cSQL);

			LET cSQL='chmod 777 '|| TRIM(cRuta_in)|| TRIM(cNomSQL);
			SYSTEM cSQL;

			LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			
			LET cSQL = 'rm ' || TRIM(cRuta_in) || TRIM(cNomSQL);
			SYSTEM cSQL;
			

-- ****************************************************************************
-- *                    PASE A TABLA DE PROCESO ACTUAL                        *
-- ****************************************************************************	
				
			FOREACH WITH HOLD
				SELECT  
					hito_num_credito,
					hito_nombres,
					hito_fecha_nacimiento,
					hito_rfc
					--
					INTO 
					v_num_credito,
					v_nombres,
					v_fecha_nac,
					v_rfc
				FROM bdicred:"informix".sd_chi_pld_layout_sic_paso
				
				SELECT COUNT (*) INTO v_count_exist
				FROM bdicred:"informix".sd_chi_pld_layout_sic WHERE hito_num_credito = v_num_credito;
				
				IF v_count_exist = 0 THEN
				
					INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic VALUES
					(
						v_num_credito,
						v_nombres,
						v_fecha_nac,
						v_rfc,
						'',--pld_numcte_bcpl
						'',--pld_uid
						'',--pld_categoria
						'',--pld_sub_categoria
						'',--pld_posicion
						'',--pld_lugar_nacimiento
						'',--pld_ciudadania
						'',--pld_companias
						'',--pld_ind_validado
						'',--pld_ind_listas_negras
						CURRENT::datetime year to second,--fecha_carga
						CURRENT::datetime year to second--fecha_modifica
					);
					ELSE
						INSERT INTO bdicred:"informix".sd_chi_pld_layout_sic_err VALUES
						(
							v_num_credito,
							v_nombres,
							v_fecha_nac,
							v_rfc,
							'',--pld_numcte_bcpl
							'',--pld_uid
							'',--pld_categoria
							'',--pld_sub_categoria
							'',--pld_posicion
							'',--pld_lugar_nacimiento
							'',--pld_ciudadania
							'',--pld_companias
							'',--pld_ind_validado
							'',--pld_ind_listas_negras
							CURRENT::datetime year to second,--fecha_carga
							CURRENT::datetime year to second--fecha_modifica
						);
					END IF;
					
			END FOREACH;
			
-- ****************************************************************************
-- *                       GENERACIÓN DE REPORTE                              *
-- ****************************************************************************	
			ELSE

					--- layout de archivo: APELLIDO PATERNO|APELLIDO MATERNO|NOMBRE(S)|FECHA DE NACIMIENTO(DDMMAAAA)|RFC
					LET cNombreArchivo = TRIM(cArchivoRep) || cYear || cMes || cDia || '.unl ';
					let cSQL = '';
					let cSQL=  'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' 
					|| TRIM(cRuta_out) || TRIM(cNombreArchivo) || 
					' SELECT TRIM(hito_num_credito), hito_nombres, hito_fecha_nacimiento, hito_rfc, pld_ind_listas_negras FROM bdicred:"informix".sd_chi_pld_layout_sic /*WHERE ind_listas_negras = "0"*/;">'
					||TRIM(cRuta_out)|| TRIM(cNomSQL);
					system cSQL;
							
					let cSQL='chmod 777 '|| TRIM(cRuta_out)|| TRIM(cNomSQL);
					System cSQL;
							
					let cSQL = '';
					let cSQL= '/ifxsif01/bin/dbaccess bdicred ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					system cSQL;					
					
					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNomSQL);
					
					LET cNombreArchivo2 = TRIM(cArchivoRep) || cYear || cMes || cDia || '.txt ';
					
					system cSQL;
					let cSQL ='';
					let cSQL = "sed 's/|$//g' "|| TRIM(cRuta_out) || TRIM(cNombreArchivo) ||" >> "|| TRIM(cRuta_out) || TRIM(cNombreArchivo2);
					system cSQL;

					let cSQL = cSQL;
					let cSQL ='rm ' || TRIM(cRuta_out) || TRIM(cNombreArchivo);
					system cSQL;
					
					
			
		END IF
		RETURN cod_ret;	
    END	
END PROCEDURE;