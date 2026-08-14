CREATE PROCEDURE "informix".sp_mantstatusctetoken_web(pNumCliente VARCHAR(9))
	RETURNING char (5); 

	DEFINE sql_err integer;
    DEFINE cod_ret char (5);
	DEFINE vns_token varchar(10);
	DEFINE vNumCliente varchar (9);

	--SET DEBUG FILE TO "/home/informix/raldana/RQI03444/informix/bdibpi/spl/sp_mantstatusctetoken.out";
	--TRACE ON;
	
--Inicializa variables
LET sql_err = '';
LET cod_ret = '00000';
LET vns_token = 0;
LET vNumCliente = '';

BEGIN
   ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret;
   END EXCEPTION;
   
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;
			
		SELECT  {+ INDEX (bpi_usuario inx_ncst)} usr.numcliente 	
		INTO vNumCliente
		FROM bdibpi:"informix".bpi_usuario usr 
			left outer join bdibpi:"informix".bpi_resp_seguridad rsp on usr.id_usuario = rsp.id_usuario AND id_pregunta = 1010 
			inner join bdinteg:"informix".si_bpiusuarios bpi on bpi.numcte = usr.numcliente 
			inner join bdinteg:"informix".si_bpitoken tkn on tkn.num_cliente = bpi.numcte AND tkn.ns_token <> '' AND tkn.id_status_token IN ('150')
			inner join bdibpi:"informix".tkn_nseries tkser on tkn.ns_token = tkser.ns_token AND tkser.id_status IN ('150')
			inner join bdinteg:"informix".si_cliente cte on cte.numcte = bpi.numcte AND cte.tpo_persona='01' AND cte.status_cte='AL'
			inner join bdibpi:"informix".bpi_tokensolicitud tknsol on  tknsol.numcte = usr.numcliente AND tknsol.id_status = '130' AND tkn.ns_token = tknsol.ns_token 
		WHERE bpi.id_status = 30
		  AND usr.st_portal = 'activo'
		  AND usr.numcliente =  pnumcliente
		GROUP BY 1
		HAVING COUNT(id_pregunta) = 0;
		
		IF (vNumCliente	 <> '' OR vNumCliente IS NOT NULL) THEN
								  
			UPDATE bdinteg:"informix".si_bpitoken SET id_status_token = '130' where num_cliente = pnumcliente AND id_status_token = '150';
			select {+ INDEX (bpi_tokensolicitud idx_statustoken)} ns_token INTO vns_token from bdibpi:bpi_tokensolicitud where numcte = pnumcliente;
			UPDATE bdibpi:"informix".tkn_nseries  SET id_status = '130' where ns_token = vns_token AND id_status = '150';
			LET cod_ret = '00000'; -- EL STATUS DEL TOKEN SE ACTUALIZO

		ELSE 
			LET cod_ret = '00001'; -- EL STATUS DEL TOKEN NO TIENE LAS CARACTERISTICAS PARA SER ACTUALZADO A 130
			
		END IF;
		
	  RETURN cod_ret WITH RESUME;
	END;
END PROCEDURE;