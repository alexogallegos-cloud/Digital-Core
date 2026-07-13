CREATE PROCEDURE "informix".sp_cargametasmis()
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta ;


DEFINE viSQLerr           INTEGER;
DEFINE NomArchivo			char(21); 
DEFINE vsSQL			char(300); 
DEFINE vsMensaje_Respuesta			char(250); 
define movimiento char(200);
define rvcodret		char(8);
define cont integer;


let vsMensaje_Respuesta='';

let vsSQL='';
let rvcodret='000';

let cont=0;
 BEGIN

	ON EXCEPTION SET viSQLerr
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		LET rvcodret = '00107';
		RETURN rvcodret, ('[' || rvcodret ||  '] ERROR NO CONTROLADO (' || viSQLerr || ')  ' || TRIM(vsMensaje_Respuesta) );
		
	END EXCEPTION;

	if (select count(*) from bdmis:mi_movimientosmetas) > 0 then
	
		FOREACH 
			select  replace(trim(SUBSTR(cambio,21,500) ),'*',"'" ) ||  ';'
			into movimiento
			from  bdmis:mi_movimientosmetas

			LET vsSQL = 'echo "'||  movimiento || '">>load_archivo_234.sql';

			SYSTEM vsSQL;
			
		end foreach;
	  
		let vsSQL = '';
			let vsSQL= 'dbaccess bdmis load_archivo_234.sql';
		system vsSQL;
		
		let vsSQL ='';
			let vsSQL ='rm  load_archivo_234.sql';
		system vsSQL;
		
		
		insert into bdmis:mi_bitacora_metas (empleado,nombre,fecha,hora,cambio)
		select empleado,nombre,fecha,hora,cambio
		from bdmis:mi_movimientosmetas;
		
		let vsSQL ='PROCESO EXITOSO';
		truncate table bdmis:mi_movimientosmetas;
	else
		let vsSQL='No hay movimientos para fin de mes';
	
	end if;
		return rvcodret,vsSQL;
END;
END PROCEDURE;