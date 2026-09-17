CREATE PROCEDURE "informix".sp_procesa_fechaenvio ()

RETURNING CHAR(5);

DEFINE vsCodRet CHAR(5);
DEFINE vSqlErr	INTEGER;
DEFINE vNum_guia CHAR(30);
DEFINE vCte_destino CHAR(9);
DEFINE vToken CHAR(9);
DEFINE vSucursal CHAR(4);
DEFINE vTipo CHAR(1);
DEFINE vSolicitud CHAR(10);
DEFINE vDia Smallint;
DEFINE vCondicion CHAR(100);


BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
			
	            RETURN vsCodRet;
	      END IF;
		END EXCEPTION;
		
    LET vDia=WEEKDAY(current);

		
	IF (vDia==1) THEN	
		FOREACH
		
			SELECT gui.num_guia, gui.cte_destino, substr(gui.factura, 1,9), substr(gui.factura, 11,4), sol.tipo, sol.solicitud
			INTO vNum_guia,vCte_destino,vToken,vSucursal,vTipo,vSolicitud
			FROM tkn_guias gui inner join bpi_tokensolicitud sol on sol.numcte=gui.cte_destino and substr(gui.factura, 1,9)=sol.ns_token and substr(gui.factura, 11,4)=sol.sucursal
			WHERE gui.f_registro::date between (today - 3) AND (today - 1)  and sol.id_status=110 and gui.num_guia is not null
		
			
			UPDATE bdibpi:"informix".tkn_envios SET f_envio=current, id_status=120 WHERE solicitud=TRIM(vSolicitud) AND num_guia=TRIM(vNum_guia);
			
			IF (vTipo=='1' OR vTipo=='2') THEN
				-- PERSONA FISICA
				UPDATE bdinteg:"informix".si_bpitoken SET id_status_token=120, f_status=current WHERE num_cliente=TRIM(vCte_destino) AND ns_token=vToken;
			ELIF (vTipo=='3' OR vTipo=='4') THEN
			    -- PERSONA MORAL
				UPDATE bdinteg:"informix".si_bpitokenpm SET id_status_token=120, f_status=current WHERE num_cliente=TRIM(vCte_destino) AND ns_token=vToken;
			END IF;
			
			UPDATE bdibpi:"informix".tkn_nseries SET id_status=120,canal='04', f_status=current WHERE ns_token=trim(vToken);
		
			UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 120 WHERE solicitud = vSolicitud and ns_token=vToken;
		
			INSERT INTO bdibpi:"informix".tkn_status_token VALUES(vToken, 120,110,CURRENT,'informix','04');
		
			INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(vSolicitud,110,120,CURRENT);
			
		END FOREACH;
	ELSE
		FOREACH
		
			SELECT gui.num_guia, gui.cte_destino, substr(gui.factura, 1,9), substr(gui.factura, 11,4), sol.tipo, sol.solicitud
			INTO vNum_guia,vCte_destino,vToken,vSucursal,vTipo,vSolicitud
			FROM tkn_guias gui inner join bpi_tokensolicitud sol on sol.numcte=gui.cte_destino and substr(gui.factura, 1,9)=sol.ns_token and substr(gui.factura, 11,4)=sol.sucursal
			WHERE gui.f_registro::date = (today-1) and sol.id_status=110 and gui.num_guia is not null
			
			UPDATE bdibpi:"informix".tkn_envios SET f_envio=current, id_status=120 WHERE solicitud=TRIM(vSolicitud) AND num_guia=TRIM(vNum_guia);
			
			IF (vTipo=='1' OR vTipo=='2') THEN
				-- PERSONA FISICA
				UPDATE bdinteg:"informix".si_bpitoken SET id_status_token=120, f_status=current WHERE num_cliente=TRIM(vCte_destino) AND ns_token=vToken;
			ELIF (vTipo=='3' OR vTipo=='4') THEN
			    -- PERSONA MORAL
				UPDATE bdinteg:"informix".si_bpitokenpm SET id_status_token=120, f_status=current WHERE num_cliente=TRIM(vCte_destino) AND ns_token=vToken;
			END IF;
			
			UPDATE bdibpi:"informix".tkn_nseries SET id_status=120,canal='04', f_status=current WHERE ns_token=trim(vToken);
		
			UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 120 WHERE solicitud = vSolicitud and ns_token=vToken;
		
			INSERT INTO bdibpi:"informix".tkn_status_token VALUES(vToken, 120,110,CURRENT,'informix','04');
		
			INSERT INTO bdibpi:"informix".tkn_stasolicitud VALUES(vSolicitud,110,120,CURRENT);
			
		END FOREACH;

    END IF;	
	LET vsCodRet = '00000';
	
	RETURN vsCodRet;
	
END
END PROCEDURE;