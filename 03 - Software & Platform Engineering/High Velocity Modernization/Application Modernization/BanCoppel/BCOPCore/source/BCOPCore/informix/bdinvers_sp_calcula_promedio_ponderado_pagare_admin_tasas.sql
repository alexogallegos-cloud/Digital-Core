CREATE PROCEDURE  "informix".sp_calcula_promedio_ponderado_pagare_admin_tasas (eEmpresa CHAR(3), nroCliente CHAR(20),nMes SMALLINT)
       RETURNING CHAR(5), MONEY, SMALLINT;

 --------------------------------------------------------------------------------------------
-- Peticion: RQM 10 1637 Administrador Tasas (DEF-Administrador de tasa complemento de pagarÃ© )
-- Autor: Julian Reyna
-- Fecha: 27/02/2025
-- Descripcion: Funcion encargada de calcular el saldo nuevo para ofertarle nuevas tasas promocionales.
-- BD: ofi

DEFINE vcodret 		  			CHAR(5);
DEFINE vsdo_ponderado_pagare  	MONEY;
DEFINE sql_err 					INTEGER;
DEFINE vfecha_hoy				DATE;
DEFINE vsaldo_promedio_mes 		MONEY;
DEFINE vmeses			 		SMALLINT;
DEFINE vfecha_venc				DATE;
DEFINE vfecha_alta				DATE;
DEFINE vfecha_alta_int			DATE;
DEFINE vfecha_venc_int			DATE;
DEFINE vfecha_while 			DATE;
DEFINE vultimo_dia				DATE;
DEFINE vmes_venc 				DATE;
DEFINE vmes_inicio 				DATE;
DEFINE vdias_transc				SMALLINT;
DEFINE vdias_mes 				SMALLINT;
DEFINE vfecha_limite 			DATE;
DEFINE vmes						SMALLINT;
DEFINE vanno					SMALLINT;
DEFINE vfecha_hoy_mes			DATE;


-- Inicializa variables
LET vcodret = 	"000";
LET vsaldo_promedio_mes = 0;
LET vdias_transc = 0;

BEGIN    
    ON EXCEPTION SET SQL_ERR
		LET vcodret = sql_err;
		RETURN vcodret, vsaldo_promedio_mes, vdias_transc;
    END EXCEPTION;
		
    --SET debug FILE TO "/home/syscybcore/spjulian/sp_calcula_promedio_ponderado_pagare_admin_tasas.out";
	--trace ON;

	SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

    SELECT {+INDEX(sc_fechas idx_fechas1)}
        fecha_hoy
		INTO vfecha_hoy
		FROM bdicheq:sc_fechas
			WHERE empresa = eEmpresa;
		
	SELECT valor::SMALLINT
		INTO vmeses
		FROM bdicheq:sc_param
		WHERE empresa = eEmpresa AND codparam = 'admintasasmeses';	
		
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio_pagare;

	LET vfecha_limite = ADD_MONTHS(vfecha_hoy, -vmeses);
	
	SELECT capital, cuenta , fecha_alta, fecha_venc
		FROM bdinvers:sv_maeinv mae
	WHERE mae.num_cte = nroCliente
		AND empresa = eEmpresa 
		AND vfecha_limite <= fecha_venc
		AND status_cta = '1'
	INTO TEMP temp_admintasas_sdopromedio_pagare WITH NO LOG;	

	FOREACH
		SELECT capital,fecha_alta,fecha_venc 
			INTO vsdo_ponderado_pagare,vfecha_alta, vfecha_venc
			FROM temp_admintasas_sdopromedio_pagare		

		IF MONTH(vfecha_alta) = nMes THEN
			LET vfecha_alta_int = vfecha_alta;
		ELSE 
			IF vfecha_alta < mdy(nMes, 1, YEAR(vfecha_alta)) THEN
				LET vfecha_alta_int = mdy(nMes, 1, YEAR(vfecha_alta));
		
				IF vfecha_venc <  vfecha_alta_int THEN
					RETURN  vcodret, vsaldo_promedio_mes,vdias_transc;
				END IF;
			ELSE
				IF mdy(nMes, 1, YEAR(vfecha_hoy)) <  vfecha_hoy THEN
					LET vfecha_alta_int = mdy(nMes, 1, YEAR(vfecha_hoy));
					IF mdy(nMes, 1, YEAR(vfecha_hoy)) >  vfecha_alta THEN
						RETURN  vcodret, vsaldo_promedio_mes,vdias_transc;
					ELSE
						RETURN  vcodret, vsaldo_promedio_mes,vdias_transc;
					END IF;
				ELSE
					RETURN  vcodret, vsaldo_promedio_mes,vdias_transc;
				END IF;
			END IF;
		END IF;	
		
		LET vmes = MONTH(vfecha_hoy);
		LET vanno = YEAR(vfecha_hoy);
		
		IF MONTH(vfecha_venc) = nMes THEN
			IF vfecha_hoy < vfecha_venc THEN 
				LET vfecha_venc_int = vfecha_hoy;
			ELSE
				LET vfecha_venc_int = vfecha_venc;
			END IF;			
		ELSE 
			IF vmes = 12 THEN
				LET vfecha_hoy_mes = mdy(1,1,vanno + 1);
			ELSE
				LET vfecha_hoy_mes = mdy(MONTH(vfecha_hoy),1,vanno + 1);
			END IF;
			
			IF vfecha_hoy < vfecha_hoy_mes THEN 
				LET vfecha_venc_int = vfecha_hoy;
			ELSE
				IF vmes = 12 THEN
					LET vfecha_venc_int = mdy(1, 1, YEAR(vfecha_hoy)+1) - 1 UNITS DAY;
				ELSE
					LET vfecha_venc_int = mdy(nMes + 1, 1, YEAR(vfecha_hoy)) - 1 UNITS DAY;
				END IF;
			END IF;	
		END IF;	
		
		LET vmes = MONTH(vfecha_alta_int);
		LET vanno = YEAR(vfecha_alta_int);
		
		IF vmes = 12 THEN
			LET vultimo_dia = mdy(1, 1, vanno + 1) - 1 UNITS DAY;
		ELSE
			LET vultimo_dia = mdy(vmes + 1, 1, vanno) - 1 UNITS DAY;
		END IF;
		
		IF  vfecha_venc_int <  vultimo_dia THEN
			LET vmes_venc = vfecha_venc_int;
			ELSE
				LET vmes_venc = vultimo_dia;
		END IF;
		
		LET vmes_inicio = vfecha_alta_int;
	
		LET vdias_transc = (DAY(vmes_venc) - DAY(vmes_inicio) + 1);
		LET vdias_mes =  DAY(vultimo_dia);
		
		LET vsaldo_promedio_mes = vsaldo_promedio_mes + (vsdo_ponderado_pagare * vdias_transc) / vdias_mes;
					
	END FOREACH;
	
	DROP TABLE IF EXISTS temp_admintasas_sdopromedio_pagare;
			
	RETURN  vcodret, vsaldo_promedio_mes,vdias_transc;
END;
END PROCEDURE;