CREATE PROCEDURE "informix".sp_actualizapass_bei(pEmpresa char(3), pNumCte char(20), pPass char(50), pIp char (15), pSucVirtual char (4), pUsuVirtual char(8))
   returning char(5);

   --Modificó: Manuel Ramos Figueroa
   --Actividad: activa el usuario y registra el cambio de status
   --Fecha: 26-07-2011

    DEFINE cCod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iStatus smallint ;

   LET cCod_ret  = "000";
   LET iStatus = 0;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
			END IF ;
		END EXCEPTION ;

		IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND num_cliente = pNumCte ) THEN
		
			SET LOCK MODE TO WAIT ;
			UPDATE bdinteg:"informix".si_bpiusuariospm SET pass3 = pass2, pass2 = pass1, pass1 = pass, f_pass3 = f_pass2,
							f_pass2 = f_pass1, f_pass1 = f_pass, pass = pPass, f_pass = current, f_actualizacion = current
							 WHERE  empresa = pEmpresa AND num_cliente = pNumCte;

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
							 
			SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND num_cliente = pNumCte;

			IF iStatus = 40 OR  iStatus = 90 THEN
				INSERT INTO bdinteg:"informix".si_cambiostctepm  (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (pNumCte,iStatus,30,pIp ,current, pSucVirtual, pUsuVirtual);
				UPDATE bdinteg:"informix".si_bpiusuariospm SET id_status = 30, f_status = current WHERE empresa = pEmpresa AND num_cliente = pNumCte;
			END IF ;
			
			INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio) VALUES (pNumCte,35,iStatus,pIp,current,pSucVirtual,pUsuVirtual);
		ELSE
			LET cCod_ret = '001';  -- No existe el Cliente
		END IF ;

		RETURN cCod_ret;
	END
END PROCEDURE ;