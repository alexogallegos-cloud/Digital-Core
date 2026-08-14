CREATE PROCEDURE "informix".sp_registra_correotel ()

RETURNING  char(5) as vsCodret;


DEFINE vsnumcte CHAR(20);
DEFINE vstelefono CHAR(13);
DEFINE vscorreo CHAR(100);
DEFINE vsCodret CHAR(5);
DEFINE vsCodret1 CHAR(3);
DEFINE vsCodret2 CHAR(3);
DEFINE viSqlError INTEGER;
DEFINE isam_error INTEGER;
define visam_error integer;


LET vsnumcte = ' ';
LET vstelefono = ' ';
LET vscorreo = ' ';
LET vsCodret = ' ';
LET vsCodret1 = ' ';
LET vsCodret2 = ' ';
LET isam_error = 0;
LET viSqlError = 0;
let visam_error = 0;

--	SET DEBUG FILE TO "/informix/rene/MNSJ/sp_registra_correotel.OUT";
--	TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlError,isam_error
		IF (viSqlError != 0) THEN
			LET vsCodret = viSqlError;
			LET visam_error = isam_error;
			RETURN vsCodret;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH
	
		select limit 500 pf.numcte,tel.telefono1,pf.email
		INTO vsnumcte,vstelefono,vscorreo
		from bdinteg:si_ctepf as pf
		inner join bdinteg:si_direcciones_actual as tel
		on pf.numcte = tel.numcte
		where pf.email <> '' and tel.telefono1 <> ' '
		
			
				EXECUTE FUNCTION bdinteg:"informix".sp_registra_telefonos("001", vsnumcte,  vstelefono, 3, '', 1, 2, "93825994")
				INTO vsCodret1;
					IF vsCodret1 <> '000' THEN
						let vsCodret = '00'||vsCodret1;
					end if;
		

			EXECUTE FUNCTION bdinteg:"informix".sp_registra_correos("001",vsnumcte,vscorreo, 1, 2, "93825994")
			INTO vsCodret2;
				IF vsCodret2 <> '000' THEN
					let vsCodret = '00'||vsCodret2;
				end if;
	

	END FOREACH;
	
	IF vsCodret1 ='000' or vsCodret2 = '000' THEN
		let vsCodret1 = '00000';
	end IF;
	
	RETURN vsCodret;
	
END;
END PROCEDURE;