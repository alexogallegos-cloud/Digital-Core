CREATE PROCEDURE "informix".sp_actbex(pOpcion CHAR(1), pcte CHAR(20), pcel CHAR(10), ptar CHAR(20), pcanal SMALLINT, 
                                      pgerente CHAR(8), pcajero CHAR(8), psucursal CHAR(4), pcuenta CHAR(20))
	RETURNING CHAR(5) as codret, CHAR(100) as desc_err, CHAR(9) as sNumcte;

DEFINE vcodret CHAR(5);
DEFINE iValAct SMALLINT;
DEFINE vsqlerr INTEGER;
DEFINE sNumcte CHAR(9);
DEFINE sTel char(10);
DEFINE sCodRetMail CHAR(5);



LET vcodret = '00000';
LET sCodRetMail = '00000';
LET iValAct = 0;
LET vsqlerr = 0;
LET sNumcte = '';
LET sTel='';


    BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'','';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

IF pOpcion=1 THEN
--OBTENIENDO NUMERO DE CLIENTE CON BASE EN EL TELEFONO
   if pcel is not null AND pcel  <>'' then 
     SELECT limit 1 numcte INTO sNumcte FROM bdinteg:si_telefonos
     WHERE telefono=pcel AND tipo_tel=2 and status_tel='A';
   
     IF NVL(sNumcte, '') ='' THEN
        LET vcodret='00003';
        RETURN vcodret,'EL TELEFONO NO ES VALIDO.','';
     END IF;
    END IF;

--OBTENIENDO NUMERO DE CLIENTE CON BASE EN EL NUMERO DE TARJETA
   if ptar is not null AND ptar  <>'' then 

       SELECT limit 1 numcliente INTO sNumcte 
       FROM intercard:tarjeta
       WHERE numtarjeta=ptar AND codstatustarjeta='ACT' and codstatusasignada='SIA';

       IF NVL(sNumcte, '') ='' THEN
           LET vcodret='00004';
           RETURN vcodret,'EL NUMERO DE TARJETA NO ES VALIDO.','';
	   END IF;
    END IF;

   IF pcte is not null AND pcte  <>'' then 
         LET   sNumcte=pcte;
         IF NVL(sNumcte, '') ='' THEN
           LET vcodret='00001';
           RETURN vcodret,'EL NUMERO DE CLIENTE NO ES VALIDO.', '';
		 END IF;
   End if;
   
   IF pcuenta is not null and pcuenta <> '' then
     SELECT limit 1 numcte INTO sNumcte	--verifica si es tarjeta de credito
	 FROM bdicred:"informix".sd_maecred
	 WHERE num_credito = pcuenta;
   
     IF NVL(sNumcte, '') ='' THEN
	 
	   SELECT limit 1 num_cte INTO sNumcte --verifica si es tarjeta de débito
	   FROM bdicheq:"informix".sc_maechq
	   WHERE cuenta = pcuenta;
     
	   IF NVL(sNumcte, '') ='' THEN
          LET vcodret='00001';
	      RETURN vcodret, 'LA CUENTA NO EXISTE','';
	       
	   END IF ;
	   
     END IF;
   END IF; 
  
   --SE REVISA SI EL CLIENTE CUENTA CON UN REGISTRO PARA ACTIVACION
        SELECT COUNT(*) INTO iValAct 
        FROM bdibpi:bpi_activacion_bex WHERE numcte=sNumcte AND status='3'; 

        IF iValAct=0 THEN
           LET vcodret='00001';
		   
		    --Valida si tiene la cuenta activa
    	   SELECT COUNT(*) INTO iValAct 
           FROM bdibpi:bpi_activacion_bex WHERE numcte=sNumcte AND status='1'; 
		   
		   IF iValAct>=1 THEN
	         LET vcodret='00001';
			 RETURN vcodret,'EL CLIENTE YA ESTA ACTIVADO',sNumcte;
		   ELSE
		   LET vcodret='00001'; 
           RETURN vcodret,'EL CLIENTE NO CUENTA CON APLICACION POR ACTIVAR','';
           END IF;
		ELSE
          
           LET vcodret='00002';  
           RETURN vcodret,'CLIENTE CON PRODUCTOS PARA ACTIVAR, FAVOR DE SOLICITAR HUELLA',sNumcte;
		  
        END IF;
  END IF;

   
   
       
        IF pOpcion=2 THEN --LA OPCION 1 ES SOLO PARA CONSULTA, LA OPCION 2 ES ACTIVACIÓN
        
          UPDATE bdibpi:bpi_activacion_bex SET status=1 , canal_act=pcanal, fech_act=current, sucursal=psucursal WHERE numcte=pcte and status=3;

          IF pcanal=1 THEN
            INSERT INTO bdinteg:bitacora_activacion_bex VALUES('001',pcte, pcanal, psucursal, pgerente, pcajero, current);
          END IF;
		  
		  
		  SELECT limit 1 telefono INTO sTel FROM bdibpi:bpi_activacion_bex WHERE numcte=pcte;
		  
		    --ENVIO DE CORREO
		   EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'PORTAL_BPI', 'APP_ACTMA','000000000', 'XXXXXXXXXXX','', '1', '', '', '', '', '', '', '', '', '', '', '', sTel, 1, 0, 0, 0, 0,current,current)
               INTO sCodRetMail;

          --ENVIO DE SMS
           EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'PORTAL_SMS', 'APP_ACTSM','000000000', 'XXXXXXXXXXX','', '1', '', '', '', '', '', '', '', '', '', '', '', sTel, 1, 0, 0, 0, 0,current,current)
               INTO sCodRetMail;			   
			   
          --ENVIO DE CORREO 
          --EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pRandom, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
          --     INTO sCodRetMail;
          --ENVIO DE SMS
          --EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pRandom, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
          --     INTO sCodRetSMS;
          LET vcodret='00000';
          RETURN vcodret,'LA ACTIVACION SE REALIZO DE MANERA CORRECTA','';
        END IF;

    END;
END PROCEDURE;