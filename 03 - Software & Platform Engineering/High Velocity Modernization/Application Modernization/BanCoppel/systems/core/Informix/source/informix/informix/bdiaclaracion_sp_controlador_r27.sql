CREATE PROCEDURE "informix".sp_controlador_r27() Returning char(7);

/*DEFINICIÃÂN DE VARIABLES*/
--Variables de retorno
DEFINE vcodret				          char(7);	
DEFINE vsqlerr				          integer;
DEFINE pFechaCap_Ini                  varchar(20);
DEFINE pFechaCap_Fin                  varchar(20);
DEFINE resultado_FECHA_INCIO          VARCHAR(20);
DEFINE VALOR_RETORNO                  VARCHAR(20);
let vcodret = "";
let vsqlerr = 0;
let VALOR_RETORNO= "";
--SET DEBUG FILE TO "/resplogifx/traces/IAP/controladaor27";
--TRACE ON;
 
begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if;
		end exception;
		
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

let resultado_FECHA_INCIO = month(today);
if resultado_FECHA_INCIO = '1' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+89),(today),(today+89) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;


if resultado_FECHA_INCIO = '4' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+90),(today),(today+90),0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
-----Si no retorna codigo exitoso
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;
-----------------------

if resultado_FECHA_INCIO = '7' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+91),(today),(today+91) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;

------------------------------
if resultado_FECHA_INCIO = '10' THEN
---Selecciona las fechas a mandar como parametros al SP
select fecha_inicio, fecha_fin
into pFechaCap_Ini,pFechaCap_Fin
from acl_control_r27 where exito=0;
---------------------------------------------------------
--Se envian parametros a SP
call bdiaclaracion:"informix".sp_acl_regulatorio27(TO_DATE(pFechaCap_Ini,'%Y-%m-%d'),TO_DATE(pFechaCap_Fin,'%Y-%m-%d'))
RETURNING VALOR_RETORNO;
--------------------------------------------------------------------------
--Se valida codigo de retorno para revisar si fue exitoso, si fue exitoso inserta la fecha para la siguiente ejecucion en tabla de control
if VALOR_RETORNO = '00000' THEN
-- Inserta a tabla de control 
INSERT INTO bdiaclaracion:"informix".acl_control_r27(fecha_ejecucion, fecha_inicio, fecha_fin, exito, fecha_exito)
VALUES ((today+91),(today),(today+91) , 0,'');
--Update para verificar que fue exitoso
UPDATE "informix".acl_control_r27 SET exito = 1, fecha_exito = CURRENT WHERE fecha_fin = pFechaCap_Fin;
ELSE let VALOR_RETORNO = '00001';
END IF;
end IF;
-----------------------


-----------------

----Valida que el codigo de retorno sea exitoso para Control-M
if VALOR_RETORNO = '00000' THEN 
let vcodret = '00000';
ELSE let vcodret= '00001';
END IF;

return vcodret;
end;
end procedure
;