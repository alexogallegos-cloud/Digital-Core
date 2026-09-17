create procedure "informix".sp_sw_ro_buscacte_ctatar(pBusqueda smallint, pNumCtaTar char(20))
	returning 
		char(5) as codret,
		char(1) as tipopersona,
		char(26) as apPaterno, 
		char(26) as apMaterno, 
		char(26) as nombre1, 
		char(26) as nombre2, 
		char(60) as razonSocial,
		char(2) as tipo_cuenta
		
	define cSubCta char(1);
	define cNumCliente char(20);
	define cCodRet char(5);
	define cTipoPersona char(1);
	define cApPaterno char(26);
	define cApMaterno char(26);
	define cNombre1 char(26);
	define cNombre2 char(26);
	define cRazonSocial char(26);
	define cTipoCuenta char(2);
	define iSqlErr int;
	define iRegEncontrados int;
	
	let cCodRet = '00000';
	let cTipoPersona = '';
	let cApPaterno = '';
	let cApMaterno = '';
	let cNombre1 = '';
	let cNombre2 = '';
	let cRazonSocial = '';
	let cTipoCuenta = '';
	let iSqlErr = 0;
	let iRegEncontrados = 0;
	
	let cSubCta = '0';
	let cNumCliente = '';
	
	begin
	
		on exception set iSqlErr
			let cCodRet = iSqlErr;
			return cCodRet, '', '', '', '', '', '', '';
		end exception;
	
		let cSubCta = substr(trim(pNumCtaTar),1,1);
		
		if pBusqueda = 1 then  -- Busqueda por numero de cuenta
			if length(trim(pNumCtaTar)) > 11 then
				foreach
					select limit 1 numcte into cNumCliente
					from bdicred:sd_maecred
					where num_credito = pNumCtaTar and empresa = '001'
					union
					select numcte
                    from bdicred:sd_maecredcrd
                    where num_credito = pNumCtaTar and empresa = '001'
					
					let cTipoCuenta = '06';
				end foreach;
			else
				if cSubCta='3' then
                    select limit 1 num_cte into cNumCliente 
                    from bdinvers:sv_maeinv
                    where cuenta = pNumCtaTar and empresa = '001';
					
					let cTipoCuenta = '03';
				elif cSubCta='8' then
                    select numcte_tf into cNumCliente
                    FROM bditransfer:tf_maecte
                    where cuenta_tf = pNumCtaTar and empresa = '001';
					
					let cTipoCuenta = '01';
                else
                    select num_cte into cNumCliente
                    FROM bdicheq:sc_maechq
                    where cuenta = pNumCtaTar and empresa = '001';
					
					let cTipoCuenta = '01';
                end if;
			end if;
		else 
			select nvl(numcte,0) into cNumCliente
                from bdicred:sd_tarjeta
                where num_tarjeta  = pNumCtaTar and empresa = '001' ;
				                
                IF cNumCliente = '0' or cNumCliente is null then
                    select nvl(numcte,0) into cNumCliente
                    from bdicheq:sc_tarjeta
                    where num_tarjeta  = pNumCtaTar AND empresa = '001' ;
					
					let cTipoCuenta = '01';
				else
					let cTipoCuenta = '06';
                end if;
		end if;
		
		if cNumCliente is null or cNumCliente = '' then
			return cCodRet, null, '', '', '', '', '', '';
		end if;

		foreach
			select substring(tpo_persona from 2) as tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, razon_social
				into cTipoPersona, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial
				from bdinteg:si_cliente where numcte = cNumCliente
			UNION
			SELECT '01' AS tpo_persona, apell_paterno, apell_materno, nombre1, nombre2, ''
			FROM bditransfer:tf_maecte 
			WHERE numcte_tf = cNumCliente

			let iRegEncontrados = iRegEncontrados + 1;
			return cCodRet, cTipoPersona, cApPaterno, cApMaterno, cNombre1, cNombre2, cRazonSocial, cTipoCuenta with resume;
				
		end foreach;
		
		if iRegEncontrados = 0 then
			return cCodRet, null, '', '', '', '', '', cTipoCuenta;
		end if;
		
	end;
end procedure;