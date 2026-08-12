CREATE PROCEDURE "informix".movimientos_edocta (pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE, pNumRegistros SMALLINT)
	RETURNING CHAR(5), 
				DATE , 
			 CHAR(20), 
			 SMALLINT,
			 SMALLINT, 
			  CHAR(9), 
			CHAR(255),
			 CHAR(16),
			 CHAR(16);
		 
	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	DEFINE cod_ret             		CHAR(5);
	DEFINE sql_err             		INTEGER;
	DEFINE v_cod_ret_otro			CHAR(5);

	DEFINE v_corta_linea_detalle 	INTEGER;
	DEFINE v_corta_linea_detalle2 	INTEGER;
	DEFINE v_corta_linea_mensaje 	INTEGER;


	DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
	DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc

	DEFINE v_periodo_tc_ini   		DATE;			--periodo_tc_ini
	DEFINE v_periodo_tc_fin   		DATE;			--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	DEFINE v_dia           		CHAR(2);
	DEFINE v_mes           		CHAR(2);
	DEFINE v_ano	       		CHAR(4);
	DEFINE v_referencia    		CHAR(296);
	DEFINE v_referencia23  		CHAR(279);
	DEFINE v_rfc_comer     		CHAR(276);
	DEFINE v_transacc      		CHAR(4);
	DEFINE v_monto         		DECIMAL(18,2);

	DEFINE v_concepto      		VARCHAR(255);
	DEFINE v_naturaleza    		CHAR(1);
	DEFINE v_letra         		CHAR(15);
	DEFINE v_fecha_mov     		CHAR(12);

	DEFINE v_compra	       		DECIMAL(18,2);
	DEFINE v_abono	       		DECIMAL(18,2);

	DEFINE v_maximo        		INTEGER;
	DEFINE v_contador      		SMALLINT;

	DEFINE v_Registros    		SMALLINT;
	DEFINE vfechacentral 		DATE;

	DEFINE iexists				INTEGER;	-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	DEFINE cfecAper				DATE;		-- FECHA DE APERTURA DEL CREDITO
	DEFINE cDiaCorte			CHAR(2);	-- DIA DE CORTE DEL CREDITO
	DEFINE cFecInicio			CHAR(10);	-- FECHA DE INICIO DEL PERIODO DE CONSULTA	

	--*******************************************************
	--*******************************************************
	--*******************************************************

	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	LET cod_ret = "000";
	LET v_cod_ret_otro = "000";

	LET sql_err = "";
	LET v_corta_linea_detalle 	= 30;
	LET v_corta_linea_detalle2 	= 0;
	LET v_corta_linea_mensaje 	= 100;

	LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
	LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc

	LET v_periodo_tc_ini   		= " ";	--periodo_tc_ini
	LET v_periodo_tc_fin   		= " ";	--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	LET vfechacentral  = NULL;
	LET v_dia          = "";
	LET v_mes          = "";
	LET v_ano	   	   = "";
	LET v_referencia   = "";
	LET v_referencia23 = "";
	LET v_rfc_comer    = "";
	LET v_transacc     = "";
	LET v_monto        = 0;


	LET v_concepto     = "";
	LET v_naturaleza   = "";
	LET v_letra        = "";
	LET v_fecha_mov    = "";

	LET v_compra       = "";
	LET v_abono        = "";

	LET v_maximo       = 0;
	LET v_contador     = 0;


	LET v_Registros    = 0;

	LET iexists		   = 1;		-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	LET cfecAper	   = '';	-- FECHA DE APERTURA DEL CREDITO
	LET cDiaCorte	   = '';	-- DIA DE CORTE DEL CREDITO
	LET cFecInicio	   = '';	-- FECHA DE INICIO DEL PERIODO DE CONSULTA


	-- SET DEBUG FILE TO "/tmp/cab/movimientos_edocta.out";
	-- TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
		RETURN cod_ret, vfechacentral,	pnum_credito, v_maximo, v_contador,	v_fecha_mov, v_concepto, v_compra, v_abono;
	END EXCEPTION ;

	-------------------------------------------------------------
	--PERIODO ANTERIOR	
	-------------------------------------------------------------	

   -- LET cod_ret = "741";
   -- RETURN cod_ret, vfechacentral,	pnum_credito, v_maximo, v_contador,	v_fecha_mov, v_concepto, v_compra, v_abono;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
	-- se obtiene la fecha hoy
	SELECT fecha_hoy 
	  INTO vfechacentral 
	  FROM bdicred:"informix".sd_fechas
	 WHERE empresa = '001';
	
	-- se obtiene el dia de corte
	SELECT dia_corte
	  INTO cDiaCorte
	  FROM bdicred:"informix".sd_maecredanexo
	 WHERE empresa = '001' 
	   AND num_credito = pnum_credito;
	   
	-- se le suma un dia al dia de corte
	LET cDiaCorte = cDiaCorte::INTEGER + 1;
	 
	-- se valida si el dia de la fecha hoy es mayor al dia de corte
	IF DAY(vfechacentral) > cDiaCorte THEN
	
		-- se une el mes de la fecha de hoy + el nuevo dia de corte + el año de la fecha de hoy
		LET v_periodo_tc_ini = LPAD(MONTH(vfechacentral), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(vfechacentral);
	
	-- se valida si el dia de la fecha de hoy es menor o igual al dia de corte
	ELIF DAY(vfechacentral) <= cDiaCorte THEN
	
		-- se le resta un mes a la fecha de hoy
		EXECUTE PROCEDURE bdicred:"informix".monthadd(vfechacentral, -1)
					 INTO cFecInicio;
		
		-- se une el mes de la fecha de hoy menos 1 mes + el nuevo dia de corte + el año de la fecha de hoy menos 1 mes
		LET v_periodo_tc_ini = LPAD(MONTH(cFecInicio), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(cFecInicio);
	
	END IF;	
			
	-- se asigna la fecha de final de consulta igual a la fecha de hoy
	LET v_periodo_tc_fin = vfechacentral;
	
   	--##############################################################
	--##	GENERACION DETALLE	 EDO CUENTA				          ##
   	--##############################################################
   	   
		--------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	
	FOREACH WITH HOLD 
		SELECT DAY(a.fecha_mov), MONTH(a.fecha_mov), YEAR(a.fecha_mov), REPLACE(a.referencia,"'",""), a.referencia23, a.rfc_comer, a.transacc_suc, a.monto,
			   TRIM(c.descripcion), b.naturaleza, 
			   DECODE(MONTH(a.fecha_mov), "1", "ENE", "2", "FEB", "3", "MAR", "4", "ABR", "5", "MAY", "6", "JUN", "7", "JUL", "8", "AGO", "9", "SEP", "10", "OCT", "11", "NOV", "12", "DIC")
		  INTO v_dia, v_mes, v_ano, v_referencia, v_referencia23, v_rfc_comer, v_transacc, v_monto, 
			   v_concepto, v_naturaleza,
			   v_letra
		  FROM bdicred:"informix".sd_movhis a
    INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
		 WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND b.sistema = "06"  ---Se agrega el campo sistema 
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
 	 UNION ALL
		SELECT DAY(a.fecha_mov), MONTH(a.fecha_mov), YEAR(a.fecha_mov), REPLACE(a.referencia,"'",""), a.referencia23, a.rfc_comer, a.transacc_suc, a.monto,
			    TRIM(c.descripcion), b.naturaleza,
			   DECODE( MONTH(a.fecha_mov), "1", "ENE", "2", "FEB", "3", "MAR", "4", "ABR", "5", "MAY", "6", "JUN", "7", "JUL", "8", "AGO", "9", "SEP", "10", "OCT", "11", "NOV", "12", "DIC")
		  FROM bdicred:"informix".sd_movdia a
	INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	     WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND b.sistema = "06"  ---Se agrega el campo sistema 
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
	  ORDER BY 3,2,1
	
		IF v_monto = 0 THEN
			CONTINUE FOREACH;
		END IF;
		
		--------------------------------------------------------
		--		GENERO LA DESCRIPCION DEL MOVIMIENTO
		--------------------------------------------------------
		
		IF v_referencia IS NULL THEN
			LET v_concepto = NVL(TRIM(v_concepto),'');
		ELSE
			IF v_referencia[1,8] = "intercar" THEN
				LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 16)) || "  " || NVL(TRIM(v_rfc_comer),'') || "  " || NVL(TRIM(v_referencia23),'');
				IF v_concepto[1,8] = "intercar" THEN
					LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 16));
				END IF;
			ELIF (TRIM(SUBSTRING(v_referencia FROM 18)) = 'a') or (TRIM(SUBSTRING(v_referencia FROM 18)) = 'DISVENT') OR (TRIM(SUBSTRING(v_referencia FROM 18)) = '') THEN
				LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,16]);
				
			ELSE
				LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 18)) || "  " || NVL(TRIM(v_rfc_comer),'') || "  " || NVL(TRIM(v_referencia23),'');
			END IF;
		END IF;

		--------------------------------------------------------
		--		ARMO LA FECHA DE MOVIMIENTO CON LETRA
		--------------------------------------------------------

		IF v_mes IS NOT NULL THEN
			LET v_fecha_mov = TRIM(v_dia)  || "-" || TRIM(v_letra)|| "-" || v_ano[3]||v_ano[4];
		END IF;
		
		--------------------------------------------------------
		--		TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		--------------------------------------------------------

		IF v_naturaleza IS NOT NULL THEN
			IF v_naturaleza = "A" THEN
				LET v_abono  = v_monto;
			ELSE
				LET v_compra = v_monto;
			END IF;
		ELSE
			LET v_compra = v_monto;
		END IF;

		--------------------------------------------------------
		--		TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		--------------------------------------------------------
		
		LET v_maximo = v_maximo + 1 ;
		LET v_contador = 0;

		--------------------------------------------------------
		--		DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		--------------------------------------------------------

		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".corta_linea(v_concepto, v_corta_linea_detalle) 
						 INTO v_concepto, v_corta_linea_detalle2
			
			LET v_contador = v_contador + 1;
			LET v_Registros = v_Registros + 1;
			
			IF v_Registros <= pNumRegistros THEN
				CONTINUE FOREACH;
			END IF;

			IF v_contador = 1 THEN
				RETURN cod_ret, pfechahoy, NVL(pnum_credito, ""), NVL(v_maximo, 0), NVL(v_contador, 0), NVL(v_fecha_mov, ""), NVL(v_concepto, ""),
					   NVL(v_compra, ""), NVL(v_abono, "") WITH RESUME;
			ELSE
				RETURN cod_ret, pfechahoy, NVL(pnum_credito, ""), NVL(v_maximo, 0), NVL(v_contador, 0), "", NVL(v_concepto, ""),
					   "", "" WITH RESUME;
			END IF;
		END FOREACH;

		--------------------------------------------------------
		--		INICIALIZA LAS VARIABLES
		--------------------------------------------------------

		LET v_fecha_mov    = "";
		LET v_concepto     = "";
		LET v_compra       = "";
		LET v_abono        = "";

	END FOREACH;
END;
END PROCEDURE
DOCUMENT
'AUTOR: ???',
'DESCRIPCION: Genera la consulta de movimientos de credito',
'FECHA: ???',
'MODIFICO: Clemente Angulo Ballardo',
'DESCRIPCION: Se modifica para que obtenga o calcule la fecha inicial del periodo de consulta',
'VERSION: 20100709.1156';

CREATE PROCEDURE "informix".sp_inserta_conciliador_cred_vs_conta(cFecha date, cCC char(14),vSdoConta Money(18,2),vsdoCargosConta Money(18,2), vsdoAbonosConta Money(18,2), vSdoFinDia Money(18,2), vsdoAbonos Money(18,2), vsdoCargos Money(18,2), vDescripcion char(50), cTipoProd integer)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--inserta en la tabla sd_conciliacredito, los cargos, abonos, saldo inicio y saldo final
--Realizó: Richar 
--Fecha: 07/07/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura
							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret;    

	DEFINE cCodRet 		CHAR(5);			
	DEFINE vDiferencia	MONEY(18,2);
	DEFINE vDiferenciaAbono	MONEY(18,2);
	DEFINE vDiferenciaCargo	MONEY(18,2);	
	DEFINE vProducto	CHAR(30);
	
	
	
			--SET DEBUG FILE TO "sp_inserta_conciliador_cred_vs_conta.out";
			--TRACE ON;
			  
	set isolation to dirty read;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	
	LET cCodRet = '00001';
	LET vDiferencia = 0;
	LET vDiferenciaAbono = 0;
	LET vDiferenciaCargo = 0;

					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;					  
				  
		if cTipoProd=1 then
			LET vProducto = 'Tarjeta de credito';
		elif cTipoProd=2 then
			LET vProducto = 'Credinomina';
		elif cTipoProd=3 then 
			LET vProducto = 'Prestamo Personal';
		elif cTipoProd=4 then 
			LET vProducto = 'Reestructura';
			
		End if;
		
					delete from bdicred:sd_conciliacredito where nivelcontable=cCC;
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
					  values(trim(vProducto),vDescripcion,cCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
					  
				if cTipoProd=3 and cCC ='77106102020132' then --and (cCC ='13110202020032' or cCC ='77106102020132')
					
					select NVL(sdoperativo-sdocontable,0)
					into vDiferencia
					from sd_conciliacredito
					where nivelcontable='13110202020032';
					
					--Restamos 
					update sd_conciliacredito set sdoperativo= (sdoperativo - vDiferencia) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdoperativo= (sdoperativo + vDiferencia) where nivelcontable='77106102020132';
					
					--sacamos diferencias
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='77106102020132';			
				End if;
	END;
		
	END PROCEDURE;