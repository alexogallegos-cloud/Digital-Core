CREATE PROCEDURE "informix".sp_obtieneincrementolin(pnum_solicitud CHAR(12), pTpoSolicitud char(1)) 
	RETURNING 
	CHAR(6)	AS codret,
	CHAR(2) AS pporc_mod_lin, 
	CHAR(6) AS ptipo_modifica;
	

	---DECLARACION DE VARIABLES
	DEFINE cCodRet 				CHAR(6); 
	DEFINE ptipogrupo 			CHAR(2); 
	DEFINE phit 				CHAR(6); 	
	DEFINE VSQL  				CHAR(6000); 
	DEFINE iSqlErr 				INTEGER; 	
	DEFINE dPaso  				SMALLINT;	
	DEFINE error_info			CHAR(80);
	DEFINE isam_err				INTEGER;
	DEFINE pempresa				CHAR(3);
	DEFINE pproceso				CHAR(30);
	DEFINE pMensaje				CHAR(80);
	DEFINE cCod_RetIB			CHAR(6);
	DEFINE seccion1 			CHAR(6);
	DEFINE seccion2 			CHAR(6);
	DEFINE pporc_mod_lin	   	decimal(5,2);
	DEFINE pporc_mod_lin1   	decimal(5,2);
	DEFINE pporc_mod_lin2   	decimal(5,2);
	DEFINE pporc_mod_lin_dec   	decimal(5,2);
	DEFINE vtipo_modifica 	   	CHAR(1);
	DEFINE vtipo_modifica1 	   	CHAR(1);
	DEFINE vtipo_modifica2 	   	CHAR(1);


	
	
	--SET DEBUG FILE TO "/informix/gpe/sp_obtieneincrementolin.out";
	--TRACE ON;

	---INICIALIZACION DE VARIABLES
	LET cCodRet  = '000000'; 
	LET ptipogrupo = ''; 
	LET phit = ''; 
	LET VSQL = ''; 
	LET iSqlErr = 0; 
	LET dPaso = 0;
	LET pMensaje = 'PROCESO EXITOSO';
	LET pproceso = '2120';
	LET pempresa = '001';
	LET cCod_RetIB	= "000000";
	LET seccion1 ='';
	LET seccion2 ='';
	LET pporc_mod_lin	= 0;
	LET pporc_mod_lin1	= 0;
	LET pporc_mod_lin2	= 0;
	LET pporc_mod_lin_dec = 0;
	LET vtipo_modifica 	= '';
	

	BEGIN

	ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
		RETURN cCodRet,'','';
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	call bdisolic:"informix".sp_obtienegrupo (pnum_solicitud)RETURNING cCodRet,ptipogrupo,phit;
	
	select evaluacion
	into seccion1
	from bdisolic:ss_resumen_scoring
	where empresa = pempresa
	and num_solicitud = pnum_solicitud
	and seccion = 1;
	
	select evaluacion
	into seccion2
	from bdisolic:ss_resumen_scoring
	where empresa = pempresa
	and num_solicitud = pnum_solicitud
	and seccion = 2;
	
	select first 1 porc_mod_lin,tipo_modifica
	into pporc_mod_lin1,vtipo_modifica1
	from bdisolic:ss_param_porc_lincred
	where tp_solicitud = pTpoSolicitud
	and grupo = ptipogrupo
	and respuesta_sic = DECODE(phit,"X","X","0","0","2","1","3","1","4","1","1")
       and ( seccion2 between pro_scormin and pro_scormax  ) 
       and tipo_modifica ='I';

	select first 1 porc_mod_lin,tipo_modifica
	into pporc_mod_lin2,vtipo_modifica2
	from bdisolic:ss_param_porc_lincred
	where tp_solicitud = pTpoSolicitud
	and grupo = ptipogrupo
	and respuesta_sic = DECODE(phit,"X","X","0","0","2","1","3","1","4","1","1")
       and ( ( seccion1 between bc_scoremin and bc_scoremax and ( respuesta_sic <> 'X' and  seccion1  <>-1) )) 
       and tipo_modifica ='I';

	if nvl(pporc_mod_lin1,0) >= nvl(pporc_mod_lin2,0) then
	  let pporc_mod_lin = nvl(pporc_mod_lin1,0);
	  let vtipo_modifica = vtipo_modifica1;
    else 
      let pporc_mod_lin = nvl(pporc_mod_lin2,0); 
	  let vtipo_modifica = vtipo_modifica2;
	end if;
	if pporc_mod_lin1 is null and pporc_mod_lin2 is null then
      let pporc_mod_lin = 0;
	  let vtipo_modifica = null;	
	end if;
----not null ---si aplica para los 2 no se aplica cambio
	if (ptipogrupo ='3') then
		if phit = '0' then if seccion1 > 0 then  let seccion1 = 0; end if; end if;
              if phit = 'X' then if seccion1 >= 0 then  let seccion1 = -1; end if; end if;
 
		select porc_mod_lin,tipo_modifica
		  into pporc_mod_lin_dec,vtipo_modifica
		  from bdisolic:ss_param_porc_lincred
		where tp_solicitud = pTpoSolicitud
		  and grupo = ptipogrupo
		  and respuesta_sic = DECODE(phit,"X","X","0","0","2","1","3","1","4","1","1")
       	  and ( ( seccion1 between bc_scoremin and bc_scoremax  )
       	  and ( seccion2 between pro_scormin and pro_scormax ) ) 
and tipo_modifica ='D';
	end if;
	--En caso de que la solicitud aplique incremento y decremento no hay modificación de línea
	if nvl(pporc_mod_lin,0) >0 and nvl(pporc_mod_lin_dec,0) >0 then
	  let pporc_mod_lin = 1;
	  let vtipo_modifica =  'N';	
	  RETURN cCodRet,pporc_mod_lin, vtipo_modifica;
	elif nvl(pporc_mod_lin,0) =0 and nvl(pporc_mod_lin_dec,0) >0 then
	  let pporc_mod_lin = pporc_mod_lin_dec;
       elif nvl(pporc_mod_lin,0) >0 and nvl(pporc_mod_lin_dec,0) =0 then
	  --let pporc_mod_lin = pporc_mod_lin_dec;          
	  let vtipo_modifica =  'I';
	end if;
	 
	---En caso de que no existan los parametros para determinar si es incremento o decremento
	if ( select count(*) from bdisolic:ss_resumen_scoring 
	      where num_solicitud = pnum_solicitud
		    and ptipogrupo in (select grupo from bdisolic:ss_param_porc_lincred	)
	        and phit in (select respuesta_sic from bdisolic:ss_param_porc_lincred)) = 0 then
			let pporc_mod_lin = 1;
			let vtipo_modifica = 'N';
            RETURN cCodRet,pporc_mod_lin, vtipo_modifica;
        end if;

	RETURN cCodRet,pporc_mod_lin, vtipo_modifica;

END
END PROCEDURE
