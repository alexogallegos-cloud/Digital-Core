CREATE PROCEDURE "informix".sp_valida_oper_atm(pidatm  CHAR(4), pempresa CHAR(3), ptipooper CHAR(20)) 

RETURNING 	CHAR(5) as codret;

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhayregistro		INTEGER;
DEFINE vNumTrasp 		INTEGER;	

LET vhayregistro	= 0;
LET vcodret    = "00000";

BEGIN

	ON EXCEPTION SET vsqlerr,visamerr
	   IF vsqlerr != 0 THEN
		  LET vcodret=vsqlerr;
		  RETURN vcodret;
	   END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 5;
	SET ISOLATION TO DIRTY READ;

	--SET debug file to "/tmp/Aaron/sp_valida_oper_atm.out";
	--trace on;

	--- Verifica recepcion correcta de datos
	IF pidatm = '0' or pidatm = '' or pempresa = '0' or pempresa = '' or ptipooper = '' then 
	   --Parametro de entrada faltante
	   LET vcodret = "00110";
	ELSE
		IF ptipooper = 'TRASPASO' THEN
			--Busca el registro solicitado
			SELECT count(*)
			INTO vhayregistro
			FROM bdisuc:ss_bitacora_cajeros_suc
			WHERE empresa  =  pempresa 
			AND fecha_insert = current::date
			AND tipo_movimiento = ptipooper
			AND SUBSTRING(observaciones FROM 1 FOR 4) = pidatm;
			
			-- Consulta el numero de traspaso al dia de un ATM a ventanilla y viceversa
			SELECT CAST(valor AS INTEGER) INTO vNumTrasp FROM bdisuc: ss_param_cajagen
			WHERE empresa = '001' AND codigo = '0073';
			
			IF vhayregistro >= vNumTrasp THEN
			   LET vcodret = "00002";
			END IF;
		ELSE
			--Busca el registro solicitado
			SELECT count(*)
			INTO vhayregistro
			FROM bdisuc:ss_bitacora_cajeros_suc
			WHERE empresa  =  pempresa 
			AND fecha_insert = current::date
			AND tipo_movimiento = ptipooper
			AND observaciones = pidatm;
			
			IF vhayregistro = 0 THEN
			   LET vcodret = "00001";
			END IF;
		END IF;
	END IF;
	RETURN vcodret;
	END;
END PROCEDURE
DOCUMENT
'BD: bdisuc',
'FOLIO:674',
'Llamado desde:CJ001001.exe',
'AUTOR:Aaron Lopez', 
'FECHA:2020-06-19',
'DESCRIPCIIÃN: Se crea sp para validar si ya se realizÃ³ el corte adm al ATM/Depositador',
'SOLICITA: Cristian Rojas';


create procedure "informix".tabla_dual ()
define existe int;

let existe = 0;
select count(*) into existe from systables
where tabname = "dual";

if (existe = 0)
then 
create table "informix".dual
  (
    dual char(1)
  )  ;

insert into dual values("X");
end if;

end procedure;