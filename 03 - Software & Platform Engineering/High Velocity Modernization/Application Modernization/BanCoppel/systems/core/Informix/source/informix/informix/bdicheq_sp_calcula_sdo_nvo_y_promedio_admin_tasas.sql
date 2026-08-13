CREATE PROCEDURE  "informix".sp_calcula_sdo_nvo_y_promedio_admin_tasas (eEmpresa CHAR(3), nroCliente CHAR(20), idpromocion INT)
       RETURNING CHAR(5), MONEY , MONEY, MONEY;

 --------------------------------------------------------------------------------------------
-- Peticion: RQM 10 1637 Administrador Tasas (DEF-Administrador de tasa complemento de pagarÃ© )
-- Autor: Julian Reyna
-- Fecha: 27/02/2025
-- Descripcion: Funcion encargada de calcular el saldo nuevo para ofertarle nuevas tasas promocionales.
-- BD: ofi

DEFINE vcodret 		  			CHAR(5);
DEFINE vcodret_pagare  			CHAR(5);
DEFINE vsdo_ponderado_maehis  	MONEY;
DEFINE vsdo_ponderado_maenoc  	MONEY;
DEFINE vsdo_ponderado_maenoctot MONEY;
DEFINE vsdo_ponderado_pagare	MONEY;
DEFINE vdia_sdo					SMALLINT;
DEFINE vdia_sdo_total			SMALLINT;
DEFINE vsaldoadmintasas 		MONEY (14,2);
DEFINE numclienteadmin 			CHAR (20);
DEFINE ncuenta 		    		CHAR (20);
DEFINE sql_err 					INTEGER;
DEFINE vfecha_hoy				DATE;
DEFINE vsaldo_promedio_total 	MONEY;
DEFINE vsaldo_suma				MONEY;
DEFINE vsdo_total_nuevo			MONEY;
DEFINE vsdo_total				MONEY;
DEFINE vmeses			 		SMALLINT;
DEFINE vaniomes					CHAR(6);
DEFINE vmes 					SMALLINT;
DEFINE vdias					SMALLINT;
DEFINE vsuma_saldos				MONEY;
DEFINE vsdo_ponderado_maenoc_sum MONEY;
DEFINE vsdo_ponderado_pagare_sum MONEY;
DEFINE vsdo_ponderado_pagare_for MONEY;
DEFINE vsdo_total_pagare		MONEY;
DEFINE vfecha_venc				DATE;
DEFINE vfecha_alta				DATE;
DEFINE vdia_hoy					SMALLINT;
DEFINE vfecha_alta_int			DATE;
DEFINE vdias_transc				SMALLINT;
DEFINE vdias_pagare				SMALLINT;

-- Inicializa variables
LET vcodret = 	"000";
LET vsaldoadmintasas = 00.00;
LET vsdo_ponderado_maehis = 0;
LET vsaldo_promedio_total = 0;
LET vsaldo_suma = 0;
LET vsdo_total_nuevo = 0;
LET vsdo_total = 0;
LET vdia_sdo_total = 0;
LET vsdo_ponderado_maenoc = 0;
LET vsuma_saldos = 0;
LET vsdo_ponderado_maenoc_sum = 0;
LET vsdo_ponderado_pagare_sum = 0;

BEGIN    
    ON EXCEPTION SET SQL_ERR
		LET vcodret = sql_err;
		RETURN vcodret, vsdo_total_nuevo, vsaldo_promedio_total, vsdo_total;
    END EXCEPTION;
		    
    --SET debug FILE TO "/home/syscybcore/spjulian/sp_calcula_sdo_nvo_y_promedio_admin_tasas.out";
	--trace ON;

	SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
        fecha_hoy
		INTO vfecha_hoy
		FROM sc_fechas
			WHERE empresa = eEmpresa;
		
	SELECT valor::SMALLINT
		INTO vmeses
		FROM bdicheq:sc_param
		WHERE empresa = eEmpresa AND codparam = 'admintasasmeses';	
	
------------------Saldo promedio ponderado	
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio;
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio_res;
	
	SELECT  
		mae.cuenta, 
		his.aniomes, 
		his.acum_sdo_pos,
		his.dia_sdo_pos,
		ROW_NUMBER() OVER (PARTITION BY mae.cuenta ORDER BY his.fechafin DESC) AS n 
	FROM bdicheq:sc_maechq mae
	JOIN bdicheq:sc_maehis his
		ON mae.cuenta = his.cuenta
	WHERE mae.num_cte = nroCliente
		AND mae.empresa = eEmpresa 
		AND mae.status_cta NOT IN("2","6","7")	
	INTO TEMP temp_admintasas_sdopromedio WITH NO LOG;	
		
	SELECT aniomes, acum_sdo_pos, dia_sdo_pos
		FROM temp_admintasas_sdopromedio
		WHERE n <= vmeses
	INTO TEMP temp_admintasas_sdopromedio_res WITH NO LOG;	

	FOREACH
		SELECT acum_sdo_pos, dia_sdo_pos, aniomes 
			INTO vsdo_ponderado_maehis, vdia_sdo, vaniomes
			FROM temp_admintasas_sdopromedio_res
		
			LET vsdo_ponderado_maehis = (vsdo_ponderado_maehis / vdia_sdo) * vdia_sdo;
			
			LET vsuma_saldos = (vsuma_saldos + vsdo_ponderado_maehis);
			LET vdia_sdo_total = vdia_sdo_total + vdia_sdo;
	END FOREACH;	

	FOREACH
		SELECT DISTINCT aniomes
			INTO vaniomes
		FROM temp_admintasas_sdopromedio
			WHERE n <= vmeses
		
		LET vmes = CAST(SUBSTR(vaniomes, LENGTH(vaniomes)-1,2) AS SMALLINT);
		
		EXECUTE PROCEDURE bdinvers:sp_calcula_promedio_ponderado_pagare_admin_tasas(eEmpresa, nroCliente, vmes) INTO vcodret_pagare, vsdo_ponderado_pagare, vdias_pagare;

		IF vsdo_ponderado_pagare > 0 THEN
			LET vdia_sdo_total = vdia_sdo_total + vdias_pagare;
			LET vsdo_ponderado_pagare_for = vsdo_ponderado_pagare * vdias_pagare;
			LET vsaldo_suma = vsdo_ponderado_pagare_for + vsaldo_suma;
		END IF;
	END FOREACH;	

	LET vsaldo_suma = vsuma_saldos + vsaldo_suma;
-------------------saldo ponderado de dias trascurriddos despues del corte
	DROP TABLE IF EXISTS temp_admintasas_sdopromedioaldia;

		SELECT 
			noc.acum_sdo_pos AS Saldo , noc.dia_sdo_pos AS dias 
		FROM bdicheq:sc_maechq mae
			JOIN bdicheq:sc_maenoc noc
			ON mae.cuenta = noc.cuenta
		WHERE mae.num_cte = nroCliente
			AND mae.empresa = eEmpresa 
			AND mae.status_cta NOT IN("2","6","7")
				GROUP BY  dia_sdo_pos, acum_sdo_pos			
		INTO TEMP temp_admintasas_sdopromedioaldia WITH NO LOG;	
	
	FOREACH
		SELECT 	Saldo, Dias
			INTO vsdo_ponderado_maenoc, vdia_sdo
		FROM temp_admintasas_sdopromedioaldia
			
		IF vdia_sdo <> 0 AND  vsdo_ponderado_maenoc <> 0 THEN
			LET vsdo_ponderado_maenoc_sum = vsdo_ponderado_maenoc_sum + (vsdo_ponderado_maenoc / vdia_sdo) * vdia_sdo;
			LET vdia_sdo_total =  vdia_sdo_total + vdia_sdo;
		END IF;
	END FOREACH;		
		
---------------------------------------------------------------
	LET vmes = MONTH(vfecha_hoy);

	EXECUTE PROCEDURE bdinvers:sp_calcula_promedio_ponderado_pagare_admin_tasas(eEmpresa, nroCliente, vmes) INTO vcodret_pagare, vsdo_ponderado_pagare, vdias_pagare;
	
	FOREACH
		SELECT fecha_alta, fecha_venc
			INTO vfecha_alta, vfecha_venc
			FROM bdinvers:sv_maeinv mae
		WHERE mae.num_cte = nroCliente
			AND empresa = eEmpresa 
			AND status_cta = '1'
	
		IF MONTH(vfecha_alta) = vmes  THEN 
				
			LET vfecha_alta_int = mdy(vmes, DAY(vfecha_alta), YEAR(vfecha_hoy));
		ELSE
			LET vfecha_alta_int = mdy(vmes, 1, YEAR(vfecha_hoy));
		END IF;
	
		LET vdias_transc = (DAY(vfecha_hoy) - DAY(vfecha_alta_int) + 1);
	
	END FOREACH;
	
	IF vsdo_ponderado_pagare > 0 THEN
		LET vsdo_ponderado_pagare_sum = vsdo_ponderado_pagare * vdias_transc;
		LET vdia_sdo_total =  vdia_sdo_total + vdias_transc;
	END IF;
	
	LET vsuma_saldos = vsdo_ponderado_pagare_sum + vsdo_ponderado_maenoc_sum;
	LET vsaldo_suma = vsaldo_suma + vsuma_saldos;


-----------------Calculo del saldo proomedio ponderado
	
	IF vdia_sdo_total = 0 THEN
		LET vdia_sdo_total = 1;
	END IF;
	LET vsaldo_promedio_total = vsaldo_suma  / vdia_sdo_total;
		
----------------Saldo al dia del cliente
	
	SELECT SUM(capital)
		INTO vsdo_total_pagare
		FROM bdinvers:sv_maeinv mae
	WHERE mae.num_cte = nroCliente
		AND empresa = eEmpresa 
		AND status_cta = '1';
	
	IF vsdo_total_pagare IS NULL THEN
		LET vsdo_total_pagare = 0;
	END IF;
	
	SELECT 
		SUM(mae.sdo_actual)
		INTO vsdo_total
	FROM bdicheq:sc_maechq mae
	WHERE mae.num_cte = nroCliente
		AND mae.empresa = eEmpresa 		
		AND mae.status_cta NOT IN("2","6","7");

	LET vsdo_total = vsdo_total_pagare + vsdo_total;
	LET vsdo_total_nuevo =   vsaldo_promedio_total - vsdo_total;

----------------------Update del saldo promedio	
	SELECT {+INDEX(bdicheq:sc_admintasas_sdo_promedio idx_admintasas_sdopromedio)}
		sdo_promedio, num_cliente 
		INTO vsaldoadmintasas,  numclienteadmin
		FROM bdicheq:sc_admintasas_sdo_promedio
			WHERE num_cliente = nroCliente AND id_promocion = idpromocion;
	
		IF (vsaldoadmintasas <> vsaldo_promedio_total OR vsaldoadmintasas IS NULL) AND (nroCliente <> numclienteadmin OR numclienteadmin IS NULL) THEN 
			INSERT INTO {+INDEX(bdicheq:sc_admintasas_sdo_promedio idx_admintasas_sdopromedio)} bdicheq:sc_admintasas_sdo_promedio (id_promocion, sdo_promedio, num_cliente, fecha) VALUES (idpromocion, vsaldo_promedio_total, nroCliente,CURRENT YEAR TO SECOND  );
		ELSE 
			UPDATE {+INDEX(bdicheq:sc_admintasas_sdo_promedio idx_admintasas_sdopromedio)} bdicheq:sc_admintasas_sdo_promedio SET  sdo_promedio = vsaldo_promedio_total, fecha = CURRENT YEAR TO SECOND   WHERE num_cliente = nroCliente AND id_promocion = idpromocion;
		END IF;


----------------------Update del saldo nuevo	
	SELECT {+INDEX(bdicheq:sc_admintasas_sdo_nuevo idx_admintasas_sdo_nuevo)}
			sdo_nuevo, num_cliente  
			INTO vsaldoadmintasas,  numclienteadmin
		FROM bdicheq:sc_admintasas_sdo_nuevo
			WHERE num_cliente = nroCliente AND id_promocion = idpromocion;
	
		IF (vsaldoadmintasas <> vsdo_total_nuevo OR vsaldoadmintasas IS NULL) AND (nroCliente <> numclienteadmin OR numclienteadmin IS NULL ) THEN
			INSERT INTO bdicheq:sc_admintasas_sdo_nuevo (id_promocion, sdo_nuevo, num_cliente, fechaCalculo) VALUES (idpromocion, vsdo_total_nuevo, nroCliente, CURRENT YEAR TO SECOND);
		ELSE
			UPDATE bdicheq:sc_admintasas_sdo_nuevo SET  sdo_nuevo = vsdo_total_nuevo, fechaCalculo = CURRENT YEAR TO SECOND WHERE num_cliente = nroCliente AND id_promocion = idpromocion;
		END IF;
		
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio;
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio_res;
	RETURN  vcodret, vsdo_total_nuevo, vsaldo_promedio_total, vsdo_total;
END;
END PROCEDURE;