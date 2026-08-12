CREATE PROCEDURE "informix".sp_actualizastatususuario_bpi(pEmpresa char(3), pIdUsuario integer, pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
   returning char(5);
      
   --Modificó: Javier A. Chávez T.
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Solicito: Mauricio León
   --Fecha: 05-03-09
  
   --Modificó: Elmer López Valenzuela.
   --Actividad: se cambia parametro de numero de cliente por id de usuario
   --Solicito: Alejandro Vazquez
   --Fecha: 15-01-16   

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cCod_ret char(5);
   DEFINE iSql_err integer;
   DEFINE iStatus integer;
   DEFINE cNumcte char(9);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cCod_ret = "000";
   LET iStatus = "0";
   LET cNumcte = "";

BEGIN

   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            let cCod_ret = iSql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;
   
    --SET DEBUG FILE TO '/tmp/sp_actualizastatususuario_bpi.out';
    --TRACE ON;
		
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

    IF pIdUsuario <> 0 THEN
	  
	  SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
					
	ELSE
		LET cCod_ret = '003';
	END IF;

    IF cNumcte <> "" THEN

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumcte ) THEN
		
			SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and numcte = cNumcte;
							
				INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = cNumcte;

				LET cCod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cCod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN
		
			SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and usuario = pUsuario;
			
				 INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);	
					
				 UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cCod_ret = '000';  -- Usuario bloqueado
			

        ELSE

            LET cCod_ret = '002';  -- No existe el Usuario

        END IF ;

    END IF ;

    RETURN cCod_ret;

END

END PROCEDURE ;