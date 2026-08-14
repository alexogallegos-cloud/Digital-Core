CREATE PROCEDURE "informix".sp_actualizastatususuario_app(pEmpresa char(3), pIdUsuario INTEGER, pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
returning char(5);
   
   --Modificó: Alejandro Vazquez
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Solicito: APPS
   --Fecha: 28-05-2015
 
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE vStatus integer;
   DEFINE vNumcte char(20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET vStatus = "0";
   LET vNumcte ="";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


    IF pIdUsuario <> 0 THEN
			SELECT bpi.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
				WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
				
        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = vNumcte )  THEN
		
			SELECT id_status INTO vStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and numcte = vNumcte;
							
				INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (vNumcte, vStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = vNumcte;

				LET cod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN
		
			SELECT id_status, numcte INTO vStatus,vNumcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and usuario = pUsuario;
			
				 INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (vNumcte, vStatus, pStatus, pIp, current, pSuc, pUsuCambio);	
					
				 UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cod_ret = '000';  -- Usuario bloqueado
			

        ELSE

            LET cod_ret = '002';  -- No existe el Usuario

        END IF ;

    END IF ;

    RETURN cod_ret;

END

END PROCEDURE ;