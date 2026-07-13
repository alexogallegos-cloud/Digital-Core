CREATE PROCEDURE  "informix".sp_sw_ro_eliminaoficiofacul ( pUsuario char(8),pFuncionC char(10), pIdOficio int )
returning char(5) as codret

  define iSqlErr int;
	define cCodRet char(5);
	
	let iSqlErr = 0;
	let cCodRet = '00000';

begin

		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
	IF  pIdOficio = '' or	pFuncionC = '' or 	pUsuario = '' THEN
		let cCodRet = '00003';
		return cCodRet; 
	END IF;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	delete from sw_ro_oficio_facultados
	where id_oficio = pIdOficio;

	return cCodRet;
	
end;

END PROCEDURE;