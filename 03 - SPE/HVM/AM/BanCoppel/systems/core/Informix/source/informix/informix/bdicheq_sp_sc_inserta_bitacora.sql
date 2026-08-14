CREATE PROCEDURE "informix".sp_sc_inserta_bitacora
(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20),pEjecutivo char(8), pHoraInicio datetime year to fraction)

RETURNING char(6);

DEFINE iError int;
DEFINE cCod_Ret char(6);

BEGIN
    ON EXCEPTION SET iError
      IF iError <> 0  THEN
         LET cCod_Ret = CAST(iError AS CHAR);
         RETURN cCod_Ret;
      END IF;
   END EXCEPTION;

   LET cCod_Ret = '0';

    IF pEmpresa = '' OR pNumeroCuenta = '' OR pNumeroCliente = '' OR pEjecutivo = '' THEN
        LET cCod_Ret = '110';
    END IF;


    IF TRIM(cCod_Ret)='0' THEN

        IF (SELECT COUNT(cuenta) FROM sc_maechq WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta AND num_cte = pNumeroCliente) > 0 THEN

            INSERT INTO sc_contbitacora(empresa,proceso,fecha,cuenta,cliente,ejecutivo,status_proc,hora_inicio,hora_fin,mensaje)
            VALUES(pEmpresa,'ACTUALIZAR FLAG',CURRENT,pNumeroCuenta,pNumeroCliente,pEjecutivo,'F',pHoraInicio,CURRENT,'OPERACION REALIZADA SATISFACTORIAMENTE');

        ELSE
            LET cCod_Ret = '141';
        END IF;

    END IF;

    RETURN cCod_Ret;

END

END PROCEDURE;