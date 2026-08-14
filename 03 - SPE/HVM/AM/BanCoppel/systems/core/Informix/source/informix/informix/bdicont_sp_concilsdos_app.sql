CREATE PROCEDURE "informix".sp_concilsdos_app(pempresa CHAR(3),pfecha DATE, psistema CHAR(2))
RETURNING VARCHAR(5),    --retorno
		  CHAR(50),      -- producto No. + Descripción
		  CHAR(14),      -- nivel_cont
	      VARCHAR(25),   --concept_oper
		  DECIMAL(18,2), --saldo_contable
		  DECIMAL(18,2), --saldo_operativo
		  DECIMAL(18,2)  --diferencia Saldos

	DEFINE cVarDataErr  VARCHAR(64);
	DEFINE iSqlErr      INTEGER;
	DEFINE iSamErr      INTEGER;
	DEFINE vCodRet      CHAR(5);

	DEFINE vfecha_cont  DATE;
	DEFINE vproducto    CHAR(50);
    DEFINE vnivel_cont  CHAR(14);
    DEFINE vconcept_op  VARCHAR(25);
	DEFINE vsaldocont   DECIMAL(18,2);
	DEFINE vsaldooper   DECIMAL(18,2);
	DEFINE vsaldiff     DECIMAL(18,2);

	--Manejo del error
	    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
		   IF iSqlErr <> 0 THEN
	          LET vCodRet = iSqlErr;
		      RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff;
		   END IF;
		END EXCEPTION;

   --set debug file to "/tmp/sp_sel_sdohistorico.out";
    --trace on;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vCodRet = "000";

	LET vproducto = "";
	LET vnivel_cont = ""; 
	LET vconcept_op = "";

	LET vsaldocont = 0.0;  
	LET vsaldooper  = 0.0;  
	LET vsaldiff = 0.0;

	SELECT fecha_hoy 
      INTO vfecha_cont
      FROM bdicont:co_fechas;

	IF vfecha_cont <= pfecha THEN
		LET vcodret = "101";
		LET cVarDataErr='Fecha de Consulta es Mayor o Igual a la Fecha de Contabilidad';
		RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff;
	END IF

	IF psistema = "01" THEN -- Captacion
		IF YEAR(pfecha)  = YEAR(vfecha_cont)  AND  MONTH(pfecha) = MONTH(vfecha_cont) THEN
			FOREACH 
				SELECT a.producto || ' ' ||  b.descripcion 
					  ,b.cta_contable AS nivel_cont
				      ,b.tipo AS concept_oper
					  ,SUM(c.saldo_fin_de_dia) AS saldo_cont    
					  ,a.capital_actual AS saldo_oper
					  ,SUM(c.saldo_fin_de_dia) - a.capital_actual AS diferencia
				 INTO vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff
				 FROM bdicheq:sc_concilsdo_difacum a, bdicheq:sc_ctascontchq b, bdicont:co_sdodias c
				WHERE a.producto = b.producto
				  AND a.fecha = pfecha
				  AND b.tipo = 'CAPITAL'
				  AND c.empresa = pempresa
				  AND c.mes_dia = a.fecha
				  AND c.ccmayor    = substr(b.cta_contable,1,4)
				  AND c.ccsub      = substr(b.cta_contable,5,2)
				  AND c.ccsubsub   = substr(b.cta_contable,7,2)
				  AND c.ccssubsub  = substr(b.cta_contable,9,2)
				  AND c.ccsssubsub = substr(b.cta_contable,11,2)
			    GROUP BY 1,2,3,5
				ORDER BY 1 ASC	      

			    RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff WITH RESUME;
			END FOREACH; 

			FOREACH 
				SELECT a.producto || ' ' ||  b.descripcion 
					  ,b.cta_contable AS nivel_cont
				      ,b.tipo AS concept_oper
					  ,SUM(c.saldo_fin_de_dia) AS saldo_cont    
					  ,a.interes_actual AS saldo_oper
					  ,SUM(c.saldo_fin_de_dia) - a.interes_actual AS diferencia
				 INTO vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff
				 FROM bdicheq:sc_concilsdo_difacum a, bdicheq:sc_ctascontchq b, bdicont:co_sdodias c
				WHERE a.producto = b.producto
				  AND a.fecha = pfecha
				  AND b.tipo = 'INTERES'
				  AND c.empresa = pempresa
				  AND c.mes_dia = a.fecha
				  AND c.ccmayor    = substr(b.cta_contable,1,4)
				  AND c.ccsub      = substr(b.cta_contable,5,2)
				  AND c.ccsubsub   = substr(b.cta_contable,7,2)
				  AND c.ccssubsub  = substr(b.cta_contable,9,2)
				  AND c.ccsssubsub = substr(b.cta_contable,11,2)
			    GROUP BY 1,2,3,5
				ORDER BY 1 ASC	      

			    RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff WITH RESUME;
			END FOREACH; 

	    ELSE
	        FOREACH 
				SELECT a.producto || ' ' ||  b.descripcion 
					  ,b.cta_contable AS nivel_cont
				      ,b.tipo AS concept_oper
					  ,SUM(c.saldo_fin_de_dia) AS saldo_cont    
					  ,a.capital_actual AS saldo_oper
					  ,SUM(c.saldo_fin_de_dia) - a.capital_actual AS diferencia
				 INTO vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff
				 FROM bdicheq:sc_concilsdo_difacum a, bdicheq:sc_ctascontchq b, bdicont:co_histsdodias c
				WHERE a.producto = b.producto
				  AND a.fecha = pfecha
				  AND b.tipo = 'CAPITAL'
				  AND c.empresa = pempresa
				  AND c.mes_dia = a.fecha
				  AND c.ccmayor    = substr(b.cta_contable,1,4)
				  AND c.ccsub      = substr(b.cta_contable,5,2)
				  AND c.ccsubsub   = substr(b.cta_contable,7,2)
				  AND c.ccssubsub  = substr(b.cta_contable,9,2)
				  AND c.ccsssubsub = substr(b.cta_contable,11,2)
			    GROUP BY 1,2,3,5
				ORDER BY 1 ASC	      

			    RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff WITH RESUME;
			END FOREACH; 

	        FOREACH 
				SELECT a.producto || ' ' ||  b.descripcion 
					  ,b.cta_contable AS nivel_cont
				      ,b.tipo AS concept_oper
					  ,SUM(c.saldo_fin_de_dia) AS saldo_cont    
					  ,a.interes_actual AS saldo_oper
					  ,SUM(c.saldo_fin_de_dia) - a.interes_actual AS diferencia
				 INTO vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff
				 FROM bdicheq:sc_concilsdo_difacum a, bdicheq:sc_ctascontchq b, bdicont:co_histsdodias c
				WHERE a.producto = b.producto
				  AND a.fecha = pfecha
				  AND b.tipo = 'INTERES'
				  AND c.empresa = pempresa
				  AND c.mes_dia = a.fecha
				  AND c.ccmayor    = substr(b.cta_contable,1,4)
				  AND c.ccsub      = substr(b.cta_contable,5,2)
				  AND c.ccsubsub   = substr(b.cta_contable,7,2)
				  AND c.ccssubsub  = substr(b.cta_contable,9,2)
				  AND c.ccsssubsub = substr(b.cta_contable,11,2)
			    GROUP BY 1,2,3,5
				ORDER BY 1 ASC	      

			    RETURN vCodRet, vproducto, vnivel_cont, vconcept_op, vsaldocont, vsaldooper, vsaldiff WITH RESUME;
			END FOREACH; 

	    END IF;
	END IF;
END PROCEDURE;