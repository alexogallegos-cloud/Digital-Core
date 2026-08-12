CREATE PROCEDURE "informix".sp_descarga_movhisedocta_credisoluciones(pempresa CHAR(3),pperiodo DATE)
--EXECUTE PROCEDURE "informix".sp_descarga_movhisedocta_credisoluciones('001',MDY('05','20','2023'));
RETURNING CHAR(5);

DEFINE v_ruta      	VARCHAR(255);
DEFINE v_ruta_cfd  	VARCHAR(255);
DEFINE cod_ret     	CHAR(5);
DEFINE sql_err     	INTEGER;
DEFINE v_sql        CHAR(6200);
DEFINE v_sql1       CHAR(1550);
DEFINE v_sql2       CHAR(1550);
DEFINE v_sql3       CHAR(1300);
DEFINE v_sql4       CHAR(800);
DEFINE v_sql5       CHAR(1000);
DEFINE v_sql6       CHAR(10000);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_periodo_tc_ini   		  DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   		  DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   	  DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		  INTEGER;		--dias_periodo_tc
DEFINE v_cod_ret_otro			  CHAR(5);
DEFINE vNumCredito		CHAR(20);
DEFINE vsecuencia		SMALLINT;
DEFINE Vnum_solpres		CHAR(20);

DEFINE vDiaHoyM	CHAR(02);
DEFINE vDiaHoy  CHAR(02);
DEFINE vMesHoy  CHAR(02);
DEFINE vAnioHoy CHAR(04);

-- MSI
DEFINE vTotalCredSol	INTEGER;
DEFINE vTotalCredMSI	INTEGER;
DEFINE vNumCte			CHAR(20);
DEFINE vNumCred			CHAR(20);
DEFINE vNumTarjeta		CHAR(20);
DEFINE vNumCredMSI		CHAR(20);
DEFINE vCodRet    		CHAR(6);
DEFINE vMsjRet			CHAR(80);
DEFINE vFechaCompra		DATE;
DEFINE vConcepto		CHAR(40);
DEFINE vFolioCompra		CHAR(16);
DEFINE vPagMin			DECIMAL(18,2);
DEFINE vNumPago			CHAR(02);
DEFINE vPlazo			CHAR(02);
DEFINE vSaldoAPagar		DECIMAL(18,2);
DEFINE vSaldoDeudor		DECIMAL(18,2);

DEFINE TotVersMsi	INTEGER;
DEFINE TotBuyMsi 	INTEGER;
DEFINE TotCredMsi	INTEGER;


LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET v_sql6      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_periodo_tc_ini   		  	= " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  	= " ";	--periodo_tc_fin
LET v_periodo_anterior   		= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		 	 = 0;	--dias_periodo_tc
LET v_cod_ret_otro 	= "000";
LET vNumCredito 	= '';
LET vsecuencia		= 0;
LET Vnum_solpres 	= '';

LET vDiaHoy 	= '';
LET vMesHoy 	= '';
LET vAnioHoy	= '';

-- MSI
LET vTotalCredSol	= 0;
LET vTotalCredMSI	= 0;
LET vNumCte			= '';
LET vNumCred		= '';
LET vNumTarjeta		= '';
LET vNumCredMSI		= '';
LET vCodRet         = '00000';
LET vMsjRet			= 'Consulta pago minimo correcta.';
LET vFechaCompra	= date(1);
LET vConcepto		= '';
LET vFolioCompra	= '';
LET vPagMin			= 0;
LET vNumPago		= '';
LET vPlazo			= '';
LET vSaldoAPagar	= 0;
LET vSaldoDeudor	= 0;
LET vDiaHoyM		= '';

LET TotVersMsi = 0;
LET TotBuyMsi  = 0;
LET TotCredMsi = 0;


set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 
-- Autor: 
-- Nodificacion: Informacion Base de Credisoluciones para la generacion de los Estados de Cuenta
-- Separando los querys.
 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
				DROP TABLE IF EXISTS tmp_universcredmsi;
				DROP TABLE IF EXISTS tmpCredBuyInfoMSI;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";
   
   --SET DEBUG FILE TO "/informix/Rebeca/sp_descarga_movhisedocta.out";
   --SET DEBUG FILE TO "/informix/ulises/RQI/2023-06-20_RQI_21_308/sps/sp_descarga_movhisedocta_credisol.out";
   --TRACE ON;
   
   SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '039';
   
   --let v_ruta = '/informix/Ulises/RQI/25_200/infoedocta/'; --v_ruta || 'cobranza/';
   EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
   
   LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
   LET v_periodo_tc_fin = pperiodo;	
   LET vDiaHoyM = 20;
   LET vDiaHoy = DAY(pperiodo)+1;
   LET vMesHoy = LPAD(MONTH(pperiodo::DATE), 2, '0');
   LET vAnioHoy = YEAR(pperiodo);
   
   
   
   -- Elimina informacion de tabla credsol para promocion de credisoluciones
   SELECT COUNT(*) INTO vTotalCredSol FROM cred_sol;

	IF NVL(vTotalCredSol,0) > 0 THEN
		TRUNCATE TABLE "informix".cred_sol;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cred_sol;
	END IF;
	
	-- Elimina informacion de tabla credmsi para promocion de meses sin intereses
	SELECT COUNT(*) INTO vTotalCredMSI FROM "informix".cred_msi;
	
	IF NVL(vTotalCredMSI,0) > 0 THEN
		TRUNCATE TABLE "informix".cred_msi;
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".cred_msi;
	END IF;

		------------------------ Credisoluciones ------------------------------------------------
		LET v_sql1 = ' echo " set isolation to dirty read; '||
		             ' INSERT INTO cred_sol '||
					 ' (fecha_emision, num_credito,num_promo,num_sol_prestamo,folio_suc,plazo,diasmes,fecha, '||
					 ' tasa,sdo_capital,prox_fecha_pago,concepto,capital_mto_cuota,numero_cuotas,secuencia,nlinea,fecha_oper,monto_ori, '||
					 ' int_periodo,iva_int_periodo,num_tar_ori,tipo_tarjeta) ';
		LET v_sql2 = ' SELECT '''||to_char(pperiodo,'%m-%d-%Y')||''', cr.num_credito,promoCred.num_promo, '||
					 ' promoCred.num_sol_prestamo,promoCred.folio_suc,crd.plazo,DAY(promoCred.fecha) diames, '||
					 ' promoCred.fecha, crd.tasa_interes, msdocrd.sdo_cap_insoluto,DATE(1) prox_fecha_pago, '||  
					 ' (CASE WHEN promoCred.num_promo = 1 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 2 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
                     ' WHEN promoCred.num_promo = 3 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
                     ' WHEN promoCred.num_promo = 4 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 5 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 6 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 7 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 8 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo '||
					 ' WHEN promoCred.num_promo = 9 THEN ''PAGOS FIJOS FOLIO: '' || promoCred.num_sol_prestamo END) concepto, '||
					 ' amorcrd.capital_mto_cuota, amorcrd.num_pago, 1, 1, crd.fecha_apertura, msdocrd.monto_otorgado, '||
					 ' amorcrd.interes_pagado,amorcrd.iva_pagado, sdtar.num_tarjeta, sdtar.tipo_tarjeta ';
        LET v_sql3 = ' FROM bdicred:sd_maecred cr '||
					' INNER JOIN "informix".sd_promocion_credito promoCred ON cr.num_credito = promoCred.num_credito '||
					' INNER JOIN BDICRED:SD_MAECREDCRD crd ON crd.num_credito = promoCred.num_sol_prestamo '||
					' INNER JOIN sd_amortiza_creditocrd amorcrd ON crd.num_credito = amorcrd.num_credito ' ||
					' INNER JOIN sd_maesdoscrd msdocrd ON msdocrd.num_credito = promoCred.num_sol_prestamo '||
					' LEFT OUTER JOIN sd_tarjeta sdtar ON cr.num_credito = sdtar.num_credito  AND promoCred.num_tarjeta = sdtar.num_tarjeta AND promoCred.num_cte = sdtar.numcte AND sdtar.empresa = ''001'' '||
					' WHERE cr.status_cred in (''E1'',''E2'',''E3'') '||
					' AND crd.num_producto = ''6900'' '||
					' AND crd.status_cred = ''E1'' '||
					' AND amorcrd.fecha_cuota > ''' ||to_char(v_periodo_anterior,'%m-%d-%Y')||''' AND amorcrd.fecha_cuota <= ''' ||to_char(pperiodo,'%m-%d-%Y')||''' '||
					' AND amorcrd.capital_status = ''5'' ';
		LET v_sql4 = '; " >'|| v_ruta||'queryCRESOL.sql';
								
			
        LET v_sql = Trim(v_sql1) || ' ' || Trim(v_sql2) || ' ' ||Trim(v_sql3)|| ' ' ||Trim(v_sql4);
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryCRESOL.sql";
        system v_sql;
		
		Foreach 
		   select num_credito 
		     into vNumCredito
			from cred_sol
			group by num_credito
			
			let VSecuencia = 1;	
			
			Foreach 
			  select num_sol_prestamo
		        into Vnum_solpres
			   from cred_sol
			   where num_credito = vNumCredito
			   
			  update cred_sol 
			    set secuencia = VSecuencia
			  where fecha_emision = pperiodo
			    and num_credito = vNumCredito
                and num_sol_prestamo =	Vnum_solpres;
				
			  let VSecuencia = VSecuencia +1;	
			end foreach;	
		end foreach;  		
		
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaCredisolucion.unl '||
		             ' SELECT *  FROM cred_sol " > '||v_ruta ||'queryCredisolucion.sql';
		
		-- SE EJECUTA ARCHIVO DE QUERY PARA OBTENER LA INFORMACION
		LET v_sql = Trim(v_sql1);
		SYSTEM v_sql;
		
		LET v_sql = "dbaccess bdicred "||v_ruta||"queryCredisolucion.sql";
		SYSTEM v_sql;


		-- SE COPIA EL ARCHIVO DE DESCARGA A UNO NUEVO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCredisolucion.unl'||" >"||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;

		-- SE BORRA EL ARCHIVO DE DESCARGA
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion.unl';
		SYSTEM v_sql;

		-- SE COPIA LA INFORMACION DEL ARCHIVO DE DESCARGA AL NUEVO ARCHIVO DE CREDISOLUCION
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCredisolucion1.unl'||" > " ||v_ruta||'Edocta_Credisolucion'||'.unl';
		SYSTEM v_sql;

		-- BORRA ARCHIVO DE DESCARGA
        LET v_sql = '';   
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;  

		-- SE BORRA ARCHIVO QUERY
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCredisolucion.sql';
		SYSTEM v_sql;  
			
		--'JMAH INI CAT
		LET v_sql6 = ' echo "UNLOAD TO '||v_ruta||'descargacredsolsdoint1.unl'  ||		
		' select a.num_credito ,a.num_sol_prestamo,nvl((c.capvig21 ),0) +  '||
		' nvl((c.capvig22 ),0) +  '||
		' nvl((c.capvig23 ),0) + '||
		' nvl((c.capvig24 ),0) + '||
		' nvl((c.capvig25 ),0) + '||
		' nvl((c.capvig26 ),0) + '||
		' nvl((c.capvig27 ),0) + '||
		' nvl((c.capvig28 ),0) + '||
		' nvl((c.capvig29 ),0) + '||
		' nvl((c.capvig30 ),0) + '||
		' nvl((c.capvig31 ),0) + '||
		' (b.capvig1) + '||
		' (b.capvig2 ) + '||
		' (b.capvig3 ) + '||
		' (b.capvig4 ) + '||
		' (b.capvig5 ) + '||
		' (b.capvig6 ) + '||
		' (b.capvig7 ) + '||
		' (b.capvig8 ) + '||
		' (b.capvig9 ) + '||
		' (b.capvig10 ) +  '||
		' (b.capvig11 ) + '||
		' (b.capvig12 ) + '||
		' (b.capvig13 ) + '||
		' (b.capvig14 ) + '||
		' (b.capvig15 ) + '||
		' (b.capvig16 ) + '||
		' (b.capvig17 ) + '||
		' (b.capvig18 ) + '||
		'  nvl((b.capvig19 ),0)  + '||
		' nvl((b.capvig20 ),0)  , '||
		' round((b.capvig1 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig2 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig3 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig4 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig5 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig6 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig7 ) * tasa_interes / 36000,2) + '||
		'  round((b.capvig8  ) * tasa_interes / 36000,2) + '||
		' round((b.capvig9 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig10 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig11 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig12 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig13 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig14 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig15 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig16 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig17 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig18 ) * tasa_interes / 36000,2) + '||
		' round((b.capvig19 ) * tasa_interes / 36000,2)   + '||
		' round((b.capvig20 ) * tasa_interes / 36000,2)   + '||
		' nvl(round((c.capvig21 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig22 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig23 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig24 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig25 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig26 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig27 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig28 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig29 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig30 ) * tasa_interes / 36000,2),0) + '||
		' nvl(round((c.capvig31 ) * tasa_interes / 36000,2),0)  '||
		' from cred_sol   a '||
		' join bdicred:sd_sdodiariocrd b on (a.num_sol_prestamo = b.num_credito and b.fecha = '''|| to_char(pperiodo,'%m-01-%Y') || ''')'|| 
		' join bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito)  '||
		' left outer join bdicred:sd_sdodiariocrd c on (a.num_sol_prestamo = c.num_credito and c.fecha = monthadd(b.fecha,-1)) " > '||v_ruta ||'querycredsolsdoint.sql';

		system v_sql6;
		LET v_sql6 = "dbaccess bdicred "||v_ruta||"querycredsolsdoint.sql";
		system v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/|$//g' "||v_ruta||'descargacredsolsdoint1.unl'||" >"||v_ruta||'descargacredsolsdoint.unl';
		SYSTEM v_sql6;

 		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargacredsolsdoint1.unl';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargacredsolsdoint.unl'||" > " ||v_ruta||'Edocta_credsolsdoint'||'.unl';
		SYSTEM v_sql6;

 		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargacredsolsdoint.unl ';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'querycredsolsdoint.sql';
		SYSTEM v_sql6; 		
		--'JMAH FIN CAT
	  
	  ------------------------ Meses sin interes ------------------------------------------------
				-- Obtiene informacion de creditos (Vigentes) con pagos facturados durante la vigencia de la compra a MSI
	LET v_sql1 =   ' echo " set isolation to dirty read; '||
		           ' INSERT INTO cred_msi '||
					' (fecha_emision, folio_movto, numcte, num_credito, num_tarjeta, num_sol_prestamo, num_promo, fecha_compra, comercio, '||
					' descripcion, numero_cuotas, plazo, saldo_total_compra, msipagomin, saldo_total_deudor, diasmes, status, secuencia, tasa_int_aplicable, tipo_tarjeta) ';
	LET v_sql2 =    ' SELECT distinct mdy("'||vMesHoy||'","'||vDiaHoyM||'","'||vAnioHoy||'"),promoCred.folio_suc,cr.numcte, '||
					' cr.num_credito,promoCred.num_tarjeta,promoCred.num_sol_prestamo,promoCred.num_promo,promoCred.fecha_compra_msi, '||
					' promoCred.detalle_compra_msi,promoCred.comercio_msi,amorcrd.num_pago,crd.plazo,msdocrd.monto_otorgado, '||
					' amorcrd.capital_mto_cuota,msdocrd.sdo_cap_insoluto,DAY(promoCred.fecha) diames,promoCred.status,1,crd.tasa_interes,sdtar.tipo_tarjeta '||
					' FROM bdicred:sd_maecred cr '||
					' INNER JOIN "informix".sd_promocion_credito promoCred ON cr.num_credito = promoCred.num_credito '||
					' INNER JOIN BDICRED:SD_MAECREDCRD crd ON crd.num_credito = promoCred.num_sol_prestamo '||
					' INNER JOIN sd_amortiza_creditocrd amorcrd ON crd.num_credito = amorcrd.num_credito '||
					' INNER JOIN sd_maesdoscrd msdocrd ON msdocrd.num_credito = promoCred.num_sol_prestamo '||
					' LEFT OUTER JOIN sd_tarjeta sdtar ON cr.num_credito = sdtar.num_credito  AND promoCred.num_tarjeta = sdtar.num_tarjeta AND promoCred.num_cte = sdtar.numcte AND sdtar.empresa = ''001'' ';
	LET v_sql3 =	' WHERE cr.status_cred in (''E1'',''E2'',''E3'') '||
					' AND crd.num_producto = ''8900'' '||
					' AND crd.status_cred = ''E1'' '||
					' AND amorcrd.fecha_cuota > ''' ||to_char(v_periodo_anterior,'%m-%d-%Y')||''' AND amorcrd.fecha_cuota <= ''' ||to_char(pperiodo,'%m-%d-%Y')||''' '||
					' AND amorcrd.capital_status = ''5'' '||
					' AND promoCred.banderact_msi = ''1'' ';
	LET v_sql4 = 	'; " >'||trim(v_ruta)||'queryMSI.sql';
				   
			 
	LET v_sql = Trim(v_sql1) || ' ' || Trim(v_sql2) || ' ' || Trim(v_sql3) || ' ' || Trim(v_sql4);
    system v_sql;
	
	LET v_sql = '';
    LET v_sql = 'dbaccess bdicred ' ||trim(v_ruta)|| 'queryMSI.sql';
    system v_sql;

	LET cNumCred		= '';
	LET vsecuencia		= 0;
	LET vNumTarjeta		= '';
	LET vNumCredMSI		= '';
	
	Foreach 
		select num_credito 
		into vNumCred
		from cred_msi
		group by num_credito
			
		let VSecuencia = 1;	
			
		Foreach 
			select num_sol_prestamo
			into vNumCredMSI
			from cred_msi
			where num_credito = vNumCred

			update cred_msi 
			set secuencia = VSecuencia
			where fecha_emision = pperiodo
			and num_credito = vNumCred
			and num_sol_prestamo =	vNumCredMSI;

			let VSecuencia = VSecuencia +1;	
		end foreach;	
	end foreach;
	
	LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaMSI.unl' ||
		         ' SELECT *  FROM cred_msi ORDER BY num_credito,secuencia " > '||v_ruta ||'queryCredMSI.sql';
	
	-- SE EJECUTA ARCHIVO DE QUERY PARA OBTENER LA INFORMACION
		LET v_sql = Trim(v_sql1);
		SYSTEM v_sql;
		
		LET v_sql = "dbaccess bdicred "||v_ruta||"queryCredMSI.sql";
		SYSTEM v_sql;


		-- SE COPIA EL ARCHIVO DE DESCARGA A UNO NUEVO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaMSI.unl'||" >"||v_ruta||'descargaMSI1.unl';
		SYSTEM v_sql;

		-- SE BORRA EL PRIMER ARCHIVO DE DESCARGA
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaMSI.unl';
		SYSTEM v_sql;

		-- SE COPIA LA INFORMACION DEL ARCHIVO DE DESCARGA AL NUEVO ARCHIVO DE CREDISOLUCION
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaMSI1.unl'||" > " ||v_ruta||'Edocta_MovsMSI'||'.unl';
		SYSTEM v_sql;
		
		-- SE BORRA EL SEGUNDO ARCHIVO DE LIMPIEZA
        LET v_sql = '';   
		LET v_sql = "rm "||v_ruta||'descargaMSI1.unl';
		SYSTEM v_sql;  

		-- SE BORRA ARCHIVO QUERY
        LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCRESOL.sql';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryMSI.sql';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCredMSI.sql';
		SYSTEM v_sql;
		
		DROP TABLE IF EXISTS tmp_universcredmsi;
		DROP TABLE IF EXISTS tmpCredBuyInfoMSI;
	  

  END;
  RETURN cod_ret;

END PROCEDURE;