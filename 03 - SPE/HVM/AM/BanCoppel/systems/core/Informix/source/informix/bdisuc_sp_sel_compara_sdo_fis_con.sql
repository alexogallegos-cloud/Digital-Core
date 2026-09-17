CREATE PROCEDURE "informix".sp_sel_compara_sdo_fis_con(pempresa CHAR(3),pfecha DATE, ptpo_suc CHAR(1))
RETURNING VARCHAR(5), 
		  CHAR(4), 
	      VARCHAR(40),
		  CHAR(4), 
	      VARCHAR(40),
		  MONEY(14,2), 
		  MONEY(14,2),
		  MONEY(14,2)

	DEFINE cVarDataErr  VARCHAR(64);
	DEFINE iSqlErr      INTEGER;
	DEFINE iSamErr      INTEGER;
	DEFINE vCodRet      CHAR(5);
	DEFINE vfecha_cont  DATE;

	DEFINE vsucursal    VARCHAR(4);
	DEFINE vnombre      VARCHAR(40);
	DEFINE vcajagen     CHAR(4);
	DEFINE vdescajagen  VARCHAR(40);
	DEFINE vsaldosuc    MONEY(14,2);
	DEFINE vsaldocont   MONEY(14,2);
	DEFINE vsaldiff     MONEY(14,2);

	--Manejo del error
	    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
		   IF iSqlErr <> 0 THEN
	          LET vCodret = iSqlErr;
		      RETURN vCodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff ;
		   END IF;
		END EXCEPTION;

   --set debug file to "/tmp/sp_sel_sdohistorico.out";
    --trace on;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET vcodret = "000";
	LET vsucursal = "";
	LET vnombre = ""; 
	LET vcajagen = "";
	LET vdescajagen = "";
	LET vsaldosuc  = 0.0;  
	LET vsaldocont = 0.0;  
	LET vsaldiff = 0.0;

	SELECT fecha_hoy 
      INTO vfecha_cont
      FROM bdicont:co_fechas;

	IF vfecha_cont <= pfecha THEN
		LET vcodret = "101";
		LET cVarDataErr='Fecha de Consulta es Mayor o Igual a la Fecha de Contabilidad';
		RETURN vcodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff ;
	END IF

	IF ptpo_suc = "S" THEN
		IF YEAR(pfecha)  = YEAR(vfecha_cont)  AND  MONTH(pfecha) = MONTH(vfecha_cont) THEN
			FOREACH 
				SELECT u.sucursal, u.nombre, p.cod_proveedor, p.descripcion, 
					   s.saldo_total as saldo_fis, sum(c.saldo_fin_de_dia) as saldo_cont,  s.saldo_total - sum(c.saldo_fin_de_dia) as diferencia
				  INTO vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff
				  FROM bdinteg:si_sucursales u, bdisuc:ss_proveedores p, bdisuc:ss_saldossuc s, bdicont:co_sdodias c 
	             WHERE u.sucursal > '0'
			       AND u.empresa = pempresa
			       AND u.tpo_sucursal = 'S'
			       AND p.plaza = u.plaza_cajagen
			       AND s.empresa = u.empresa 
			       AND s.fecha = pfecha
			       AND s.sucursal = u.sucursal
			       AND c.empresa = s.empresa
			       AND c.ccmayor='1101' 
			       AND c.ccsub='01' 
			       AND c.ccsubsub ='00' 
			       AND c.ccssubsub='00'
			       AND c.ccsssubsub='00' 
			       AND c.sector='00' 
			       AND c.ciudad IS NOT NULL
			       AND c.sucursal = u.sucursal
			       AND c.moneda = '01' -- Moneda Nacional
			       AND c.mes_dia = s.fecha 
			     GROUP BY u.sucursal, u.nombre, p.cod_proveedor, p.descripcion, s.saldo_total
			     ORDER BY u.sucursal
	      
			    RETURN vcodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff WITH RESUME;

			END FOREACH; 
	    ELSE
	        FOREACH 
				SELECT u.sucursal, u.nombre, p.cod_proveedor, p.descripcion, s.saldo_total as saldo_fis, sum(c.saldo_fin_de_dia) as saldo_cont,  s.saldo_total - sum(c.saldo_fin_de_dia) as diferencia
				  INTO vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff
				  FROM bdinteg:si_sucursales u, bdisuc:ss_proveedores p, bdisuc:ss_saldossuc s, bdicont:co_histsdodias c 
				 WHERE u.sucursal > '0'
				   AND u.empresa = pempresa
	               AND u.tpo_sucursal = 'S'
	               AND p.plaza = u.plaza_cajagen
	               AND s.empresa = u.empresa 
	               AND s.fecha = pfecha
			       AND s.sucursal = u.sucursal
			       AND c.empresa = s.empresa
			       AND c.ccmayor='1101' 
			       AND c.ccsub='01' 
			       AND c.ccsubsub ='00' 
			       AND c.ccssubsub='00'
			       AND c.ccsssubsub='00' 
			       AND c.sector='00' 
			       AND c.ciudad IS NOT NULL
			       AND c.sucursal = u.sucursal
			       AND c.moneda ='01' -- Moneda Nacional
			       AND c.mes_dia = s.fecha 
	             GROUP BY u.sucursal, u.nombre, p.cod_proveedor, p.descripcion, s.saldo_total
	             ORDER BY u.sucursal

			    RETURN vcodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff WITH RESUME;
	         
	        END FOREACH; 
	    END IF;
	ELIF ptpo_suc = "G" THEN
		IF YEAR(pfecha)  = YEAR(vfecha_cont)  AND  MONTH(pfecha) = MONTH(vfecha_cont) THEN
			FOREACH
			    SELECT u.sucursal , u.nombre , u.sucursal , u.nombre, s.saldo_total as saldo_fis, sum(c.saldo_fin_de_dia) as saldo_cont,  s.saldo_total - sum(c.saldo_fin_de_dia) as diferencia
				  INTO vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff
				  FROM bdinteg:si_sucursales u, bdisuc:ss_cajageneral_hist s , bdicont:co_sdodias c 
				 WHERE u.sucursal = s.cod_proveedor
				   AND u.empresa = pempresa
	               AND u.tpo_sucursal IN ('N')
	               AND s.empresa = u.empresa 
			       AND s.cod_proveedor = u.sucursal
	               AND s.fecha = pfecha
			       AND c.empresa = s.empresa
			       AND c.ccmayor='1101' 
			       AND c.ccsub='01' 
			       AND c.ccsubsub ='00' 
			       AND c.ccssubsub='00'
			       AND c.ccsssubsub='00' 
			       AND c.sector='00' 
			       AND c.ciudad IS NOT NULL
			       AND c.sucursal = u.sucursal
			       AND c.moneda ='01' -- Moneda Nacional
			       AND c.mes_dia = s.fecha 
	             GROUP BY u.sucursal, u.nombre, u.sucursal, u.nombre, s.saldo_total
                 ORDER BY u.sucursal

			    RETURN vcodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff WITH RESUME;

	        END FOREACH; 
		ELSE
			FOREACH
			    SELECT u.sucursal , u.nombre , u.sucursal , u.nombre, s.saldo_total as saldo_fis, sum(c.saldo_fin_de_dia) as saldo_cont,  s.saldo_total - sum(c.saldo_fin_de_dia) as diferencia
				  INTO vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff
				  FROM bdinteg:si_sucursales u, bdisuc:ss_cajageneral_hist s , bdicont:co_histsdodias c 
				 WHERE u.sucursal = s.cod_proveedor
				   AND u.empresa = pempresa
	               AND u.tpo_sucursal IN ('N')
	               AND s.empresa = u.empresa 
			       AND s.cod_proveedor = u.sucursal
	               AND s.fecha = pfecha
			       AND c.empresa = s.empresa
			       AND c.ccmayor='1101' 
			       AND c.ccsub='01' 
			       AND c.ccsubsub ='00' 
			       AND c.ccssubsub='00'
			       AND c.ccsssubsub='00' 
			       AND c.sector='00' 
			       AND c.ciudad IS NOT NULL
			       AND c.sucursal = u.sucursal
			       AND c.moneda ='01' -- Moneda Nacional
			       AND c.mes_dia = s.fecha 
	             GROUP BY u.sucursal, u.nombre, u.sucursal, u.nombre, s.saldo_total
                 ORDER BY u.sucursal

			    RETURN vcodret, vsucursal, vnombre, vcajagen, vdescajagen, vsaldosuc, vsaldocont, vsaldiff WITH RESUME;

	        END FOREACH; 
		END IF;
	END IF;
END PROCEDURE;