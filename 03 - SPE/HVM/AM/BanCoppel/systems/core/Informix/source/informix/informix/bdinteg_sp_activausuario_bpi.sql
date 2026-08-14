CREATE PROCEDURE "informix".sp_activausuario_bpi(pEmpresa char(3), pNumCte char(20), pUsuario char(50), pPass char(50), pStatus integer,pIp char (15), pSuc char (4), pUsuCambio char (8))
   returning char(5);

   --ModificÃ³ Javier A. ChÃ¡vez T.
   --Actividad activa el usuario y registra el cambio de status
   --Solicito Mauricio LeÃ³n
   --Fecha 05-03-09


-- 
-- Define variables
-- 
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iCont smallint ;
	DEFINE vStatus integer;
	DEFINE v_f_pri_ingreso  DATETIME YEAR to SECOND;

-- 
-- Inicializa variables
-- 
   LET cod_ret  = 000;
   LET iCont = 0;
   LET vStatus = 0;


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

		SELECT id_status,f_pri_ingreso INTO vStatus,v_f_pri_ingreso FROM bdinteg:
		si_bpiusuarios WHERE empresa = pEmpresa and numcte = pNumCte;

		INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (pNumCte,vStatus,pStatus,pIp,current,pSuc,pUsuCambio);

        UPDATE bdinteg:si_bpiusuarios SET usuario = pUsuario, pass = TRIM(pPass), f_pass = current, id_status = pStatus  WHERE numcte = pNumCte;
		IF (pStatus == 30 AND v_f_pri_ingreso is null) THEN
			UPDATE 	bdinteg:si_bpiusuarios SET f_pri_ingreso = current WHERE numcte = pNumCte;
		END IF 	
		
        LET cod_ret = '000';  -- Usuario activado

   ELSE

        LET cod_ret = '002';  -- No existe el Cliente

   END IF ;

   RETURN cod_ret;

END

END PROCEDURE;