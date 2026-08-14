CREATE PROCEDURE "informix".sp_arqueocedulacontable()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE cCodRet      CHAR(5);
DEFINE iSqlError    INTEGER;
DEFINE cVsql         CHAR(500);
DEFINE cRutaCarga   CHAR(100);
DEFINE cRutaQuery   CHAR(100);
DEFINE cLinCaptura  CHAR(20);
	
LET cCodRet  	 = '00000';
LET iSqlError  	 = 0;
LET cVsql 		 = '';
LET cRutaCarga   = '';
LET cRutaQuery   = '';
LET cRutaQuery   = 'ArqueoBancoppel.txt';
LET cLinCaptura  = '';



--SET DEBUG FILE TO "/respaldosbd/obed/sp_arqueocedulacontable.out";
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlError
		IF iSqlError <> 0 THEN
			LET cCodRet = iSqlError;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	SELECT valor 
	INTO cRutaCarga
	FROM bdisuc:"informix".ss_param_cajagen
	WHERE codigo = '0090';
	
	LET cVsql = 'echo "LOAD FROM ''' || TRIM(cRutaCarga) || TRIM(cRutaQuery) || ''' DELIMITER ' || '''	''' || ' insert into ss_arqueo_panamericano (plaza,saldo_anterior,suc_concentracion,arqueo_sobrante,arqueo_faltante,dot_devuelta,dot_entregada,compra,venta,remanente_atm,dotacion,fecha)" > '|| TRIM(cRutaCarga) || 'cargdat.sql';
	SYSTEM cVsql;

    LET cVsql = '';
 	LET cVsql = 'dbaccess bdisuc ' || TRIM(cRutaCarga) || 'cargdat.sql';
    SYSTEM cVsql;
	 
 RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: Se crea Procedimiento Almacenado para Importar archivo de Arqueo Pan Americano.',
'AUTOR : Obed Vega',
'FECHA : 10/Julio/2013',
'VERSIÓN: 1.0',
'BD: bdisuc';

create procedure "informix".sp_consultacedula (d_fecha date, caja char(34))

RETURNING char(30), char(4), money, money, money, money,
money, money, money, money, money,money, money,
money, money, money, money, money, money,
money, money, money, money, money, money,money, money,
money, money, money, money, money, money, money, money, char(300),char(10),char(10);


define v_caja char(4);
define vplaza char(30);
define vcentro_costo char(4);
define vsaldo_cont_ante  money;
define  vsaldo_ante_sif  money;
define vconcent_atm  money;
define vconcent_suc  money;
define vcorreccion_sob  money;
define vcompra_tesoreria  money;
define vtotal_entradas  money;
define vdot_atm  money;
define vdot_suc  money;
define vcorreccion_falt  money;
define vdeposito_tesoreria  money;
define vtotal_salidas  money;
define  vdif_entra_sale  money;
define  vsaldo_final_control  money;
define  vsaldo_ayer_movhoy  money;
define vsaldo_final_conta  money;
define  vdif_ayer_hoy  money;
define vsaldo_anterior  money;
define  vconcentraciones  money;
define vsobrante  money;
define  vdotacion_devuelta  money;
define  vremanent_atm  money;
define  vcompra   money;
define varq_total_entra  money;
define vfaltante  money;
define varq_dot_suc  money; 
define varq_dot_atm   money;
define v_ventas  money;
define varq_total_salida  money;
define  vsaldo_final_etv   money;
define vdif_etv  money;
define vdif_dia_ant  money;
define vdif_dia_hoy money;
define vcomentarios char(300);
define vvfecha_modificacion char(10);
define vvfecha_archivo char(10);

let v_caja = SUBSTR(caja,1,4);
let vplaza ='';
let vcentro_costo ='';
let vsaldo_cont_ante = 0;
let vsaldo_ante_sif = 0;
let vconcent_atm = 0;
let vconcent_suc = 0;
let vcorreccion_sob = 0;
let vcompra_tesoreria = 0;
let vtotal_entradas = 0;
let vdot_atm = 0;
let vdot_suc = 0;
let vcorreccion_falt = 0;
let vdeposito_tesoreria = 0;
let vtotal_salidas = 0;
let vdif_entra_sale = 0;
let vsaldo_final_control = 0;
let vsaldo_ayer_movhoy = 0;
let vsaldo_final_conta = 0;
let vdif_ayer_hoy = 0;
let vsaldo_anterior = 0;
let vconcentraciones = 0;
let vsobrante = 0; 
let vdotacion_devuelta = 0; 
let vremanent_atm = 0;
let vcompra = 0;
let varq_total_entra = 0;
let vfaltante = 0;
let varq_dot_suc = 0; 
let varq_dot_atm = 0;
let v_ventas = 0;
let varq_total_salida = 0;
let vsaldo_final_etv = 0;
let vdif_etv = 0;
let vdif_dia_ant = 0; 
let vdif_dia_hoy = 0; 
let vcomentarios= '';
let vvfecha_modificacion='';
let vvfecha_archivo='';

if v_caja='Todo' then
	foreach
		select {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
		plaza, centro_costo, saldo_cont_ante, saldo_ante_sif, concent_atm, concent_suc,
		correccion_sob, compra_tesoreria, total_entradas, dot_atm, dot_suc, correccion_falt, deposito_tesoreria,
		total_salidas, dif_entra_sale, saldo_final_control, saldo_ayer_movhoy, saldo_final_conta, dif_ayer_hoy,
		saldo_anterior, concentraciones, sobrante, dotacion_devuelta, remanent_atm, compra, arq_total_entra, faltante,
		arq_dot_suc, arq_dot_atm, ventas, arq_total_salida, saldo_final_etv, dif_etv, dif_dia_ant, dif_dia_hoy, comentarios,vfecha_modificacion,vfecha_archivo 
		into vplaza, vcentro_costo, vsaldo_cont_ante, vsaldo_ante_sif, vconcent_atm, vconcent_suc,
		vcorreccion_sob, vcompra_tesoreria, vtotal_entradas, vdot_atm, vdot_suc,vcorreccion_falt, vdeposito_tesoreria,
		vtotal_salidas, vdif_entra_sale, vsaldo_final_control, vsaldo_ayer_movhoy, vsaldo_final_conta, vdif_ayer_hoy,
		vsaldo_anterior, vconcentraciones, vsobrante, vdotacion_devuelta, vremanent_atm, vcompra, varq_total_entra, vfaltante,
		varq_dot_suc, varq_dot_atm, v_ventas, varq_total_salida, vsaldo_final_etv, vdif_etv, vdif_dia_ant, vdif_dia_hoy, vcomentarios,vvfecha_modificacion,vvfecha_archivo
		FROM ss_reportecedula where fecha = d_fecha

		RETURN vplaza, vcentro_costo, vsaldo_cont_ante, vsaldo_ante_sif, vconcent_atm, vconcent_suc,
		vcorreccion_sob, vcompra_tesoreria, vtotal_entradas, vdot_atm, vdot_suc,vcorreccion_falt, vdeposito_tesoreria,
		vtotal_salidas, vdif_entra_sale, vsaldo_final_control, vsaldo_ayer_movhoy, vsaldo_final_conta, vdif_ayer_hoy,
		vsaldo_anterior, vconcentraciones, vsobrante, vdotacion_devuelta, vremanent_atm, vcompra, varq_total_entra, vfaltante,
		varq_dot_suc, varq_dot_atm, v_ventas, varq_total_salida, vsaldo_final_etv, vdif_etv, vdif_dia_ant, vdif_dia_hoy, vcomentarios,vvfecha_modificacion,vvfecha_archivo  WITH RESUME;  

	end foreach;
else 
	foreach
		select {+INDEX(bdisuc:"informix".ss_reportecedula idx01_reportecedula)}
		plaza, centro_costo, saldo_cont_ante, saldo_ante_sif, concent_atm, concent_suc,
		correccion_sob, compra_tesoreria, total_entradas, dot_atm, dot_suc, correccion_falt, deposito_tesoreria,
		total_salidas, dif_entra_sale, saldo_final_control, saldo_ayer_movhoy, saldo_final_conta, dif_ayer_hoy,
		saldo_anterior, concentraciones, sobrante, dotacion_devuelta, remanent_atm, compra, arq_total_entra, faltante,
		arq_dot_suc, arq_dot_atm, ventas, arq_total_salida, saldo_final_etv, dif_etv, dif_dia_ant, dif_dia_hoy, comentarios,vfecha_modificacion,vfecha_archivo 
		into vplaza, vcentro_costo, vsaldo_cont_ante, vsaldo_ante_sif, vconcent_atm, vconcent_suc,
		vcorreccion_sob, vcompra_tesoreria, vtotal_entradas, vdot_atm, vdot_suc,vcorreccion_falt, vdeposito_tesoreria,
		vtotal_salidas, vdif_entra_sale, vsaldo_final_control, vsaldo_ayer_movhoy, vsaldo_final_conta, vdif_ayer_hoy,
		vsaldo_anterior, vconcentraciones, vsobrante, vdotacion_devuelta, vremanent_atm, vcompra, varq_total_entra, vfaltante,
		varq_dot_suc, varq_dot_atm, v_ventas, varq_total_salida, vsaldo_final_etv, vdif_etv, vdif_dia_ant, vdif_dia_hoy, vcomentarios,vvfecha_modificacion,vvfecha_archivo
		FROM ss_reportecedula where fecha = d_fecha and centro_costo =v_caja

		RETURN vplaza, vcentro_costo, vsaldo_cont_ante, vsaldo_ante_sif, vconcent_atm, vconcent_suc,
		vcorreccion_sob, vcompra_tesoreria, vtotal_entradas, vdot_atm, vdot_suc,vcorreccion_falt, vdeposito_tesoreria,
		vtotal_salidas, vdif_entra_sale, vsaldo_final_control, vsaldo_ayer_movhoy, vsaldo_final_conta, vdif_ayer_hoy,
		vsaldo_anterior, vconcentraciones, vsobrante, vdotacion_devuelta, vremanent_atm, vcompra, varq_total_entra, vfaltante,
		varq_dot_suc, varq_dot_atm, v_ventas, varq_total_salida, vsaldo_final_etv, vdif_etv, vdif_dia_ant, vdif_dia_hoy, vcomentarios,vvfecha_modificacion,vvfecha_archivo  WITH RESUME; 

	end foreach;
end if; 

end procedure;