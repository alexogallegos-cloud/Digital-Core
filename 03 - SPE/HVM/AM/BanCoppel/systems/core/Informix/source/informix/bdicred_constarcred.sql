Create procedure "informix".constarcred(pempresa char(3),
                                        pnumtarjeta  char(20))
                                                         
 Returning	char(5),char(3),char(20),char(20),char(20),date,char(1),char(1),char(14),char(30),date;

 define vcodret		char(5);
 define vsqlerr         integer;
 define vempresa	char(3);
 define vnum_cred       char(20);
 define vnum_tar        char(20);
 define vnumcte         char(20);
 define vexpiracion     date;
 define vtipo_tar       char(1);
 define vstatus_tar     char(1);
 define vlimite_aut     char (14);
 define vnombre         char(30);
 define vfecha_nac      date;
 define vstatus_cred    char(2);

 let vcodret     = "";
 let vsqlerr     = 0;
 let vempresa    =  "";
 let vnum_cred   =  "";
 let vnum_tar    =  "";
 let vnumcte     =  "";
 let vexpiracion =  "";
 let vtipo_tar   =  "";
 let vstatus_tar =  "";
 let vlimite_aut =  "";
 let vnombre     =  "";
 let vfecha_nac  =  "";
 let vstatus_cred = "";

 Begin

	On exception set vsqlerr
		if vsqlerr<>0 then
			let vcodret = vsqlerr;
			return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
		end if;
	end exception;


	--set debug file to  '/pisa/pisabanco/pisa_ftes/credito/constarcred.out';
	--trace on;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	if pnumtarjeta is null or pnumtarjeta= "" then
	   let vcodret = '101';
           return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
	end if;

		/*
        select num_tarjeta
        into   vnum_tar
        from   "informix".sd_tarjeta
        where  empresa = pempresa and num_tarjeta = pnumtarjeta;
		*/
    --RQM 10 1473 Se contempla que no reimpriman portada TDCs Canceladas
	SELECT cred.status_cred
        INTO   vstatus_cred
        FROM   bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maecred cred
	WHERE  tar.empresa=pempresa 
	AND tar.num_credito = cred.num_credito
	AND tar.num_tarjeta=pnumtarjeta;
    IF vstatus_cred NOT IN ('FF','FI') THEN
            --JMAH Se modifica para obtener el monto_solicitado de la tabla de solicitudes.
            --limite_aut
        SELECT tar.empresa, tar.num_credito, tar.num_tarjeta, tar.numcte, tar.expiracion, tar.tipo_tarjeta, tar.status_tar,sol.monto_solicitado , tar.nombre --limite_aut
            INTO   vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre 
            FROM   bdicred:"informix".sd_tarjeta tar, bdisolic:"informix".ss_solicitudes sol
        WHERE  tar.empresa=pempresa 
        AND tar.num_credito = sol.num_solicitud
        AND tar.num_tarjeta=pnumtarjeta;

        -- INC 27 178 contemplar productos TDC Oro y TDC Platinum
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            SELECT tar.empresa, tar.num_credito, tar.num_tarjeta, tar.numcte, tar.expiracion, tar.tipo_tarjeta, tar.status_tar,msdo.monto_otorgado , tar.nombre --limite_aut
                INTO   vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre 
                FROM   bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maesdos msdo
            WHERE  tar.empresa=pempresa 
            AND tar.num_credito = msdo.num_credito
            AND tar.num_tarjeta=pnumtarjeta;        
        END IF;  

            SELECT fecha_nac INTO vfecha_nac 
            FROM bdinteg:"informix".si_ctepf
            WHERE numcte = vnumcte;

    END IF;   
        return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;

 end
 end procedure;