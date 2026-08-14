CREATE PROCEDURE "informix".sp_activausuario_bei(pEmpresa char(3), pNumCte char(20), pUsuario char(50), pPass char(50), pStatus integer,pIp char (15), pSuc char (4), pUsuCambio char (8))
   returning char(5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Activa el usuario y registra el cambio de status
	-- Fecha: 22/07/2011

	DEFINE sql_err integer ;
	DEFINE cCod_ret char(5);
	DEFINE iCont smallint ;
	DEFINE iStatus integer;

	LET cCod_ret  = '00000';
	LET iCont = 0;
	LET iStatus = 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
   
   IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa AND num_cliente = pNumCte ) THEN

		SELECT id_status INTO iStatus FROM bdinteg:"informix".si_bpiusuariospm WHERE empresa = pEmpresa and num_cliente = pNumCte;

		INSERT INTO bdinteg:"informix".si_cambiostctepm (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (pNumCte,iStatus,pStatus,pIp,current,pSuc,pUsuCambio);

        UPDATE bdinteg:"informix".si_bpiusuariospm SET usuario = pUsuario, pass = TRIM(pPass), f_pass = current, id_status = pStatus  WHERE num_cliente = pNumCte;

        LET cCod_ret = '000';  -- Usuario activado
   ELSE
        LET cCod_ret = '002';  -- No existe el Cliente
   END IF ;
   RETURN cCod_ret;
END
END PROCEDURE;