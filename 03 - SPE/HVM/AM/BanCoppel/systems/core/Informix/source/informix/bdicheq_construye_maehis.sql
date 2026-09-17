CREATE PROCEDURE "informix".construye_maehis(eEmpresa CHAR(3))

RETURNING CHAR(5);



DEFINE vsdo_mes_ant   DECIMAL(14,2);
DEFINE vDiasAcum      SMALLINT; 
DEFINE vtotdepositos  DECIMAL(14,2);
DEFINE vtotretiros    DECIMAL(14,2);
DEFINE vtotint        DECIMAL(14,2);
DEFINE vtotcomcobrada DECIMAL(14,2);
DEFINE vtotivacobrado DECIMAL(14,2);
DEFINE vtotisrcobrado DECIMAL(14,2);
DEFINE vCuenta        CHAR(20);
DEFINE vAnio          CHAR(6);
DEFINE vIni	      DATE;
DEFINE vFin	      DATE;
DEFINE CodRet	      CHAR(5);
DEFINE sql_err        INTEGER;
DEFINE vTasaAplicada  DECIMAL(9,6);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

-- SET DEBUG FILE TO "contr_maehis.out";
-- TRACE ON;

   -- **************************************************************************
LET CodRet = "000";

   FOREACH
	  SELECT aniomes, cuenta, fechaini, fechafin
	    INTO vAnio, vCuenta, vIni, vFIn
	    FROM sc_maehis
	--   WHERE cuenta = "10000005059"
	   ORDER BY 1,2


	  -- Total de Depositos
        SELECT NVL((select sum(mv.monto_tot)
                      from sc_movhis mv, bdinteg:si_transacc tr
                     where mv.empresa = eEmpresa
                       and cuenta = vCuenta
                       and mv.fech_alt between vIni and vFin
                       and tr.numero = mv.transacc
                       and mv.cancelad <> "S"
                       and tr.naturaleza = "A"
		       and tr.numero <> "3276"),0) +
               NVL((select sum(md.monto_tot)
                      from sc_movdia md, bdinteg:si_transacc tr
                     where md.empresa = eEmpresa
                       and md.cuenta = vCuenta
                       and md.fech_alt between vIni and vFin
                       and tr.numero = md.transacc
                       and md.cancelad <> "S"
                       and tr.naturaleza = "A"
                       and tr.numero <> "3276"),0)
          INTO vtotdepositos
          FROM dual;

        if vtotdepositos is null then
           let vtotdepositos = 0;
        end if

	-- Total de Retiros
        SELECT NVL((select sum(mv.monto_tot)
                      from sc_movhis mv, bdinteg:si_transacc tr
                     where mv.empresa = eEmpresa
                       and cuenta = vCuenta
                       and mv.fech_alt between vIni and vFin
                       and tr.numero = mv.transacc
                       and tr.tipo_tran IN ("00","30")
                       and mv.cancelad <> "S"
                       and tr.naturaleza = "C"),0) +
               NVL((select sum(md.monto_tot)
                      from sc_movdia md, bdinteg:si_transacc tr
                     where md.empresa = eEmpresa
                       and md.cuenta = vCuenta
                       and md.fech_alt between vIni and vFin
                       and tr.numero = md.transacc
                       and tr.tipo_tran IN ("00","30")
                       and md.cancelad <> "S"
                       and tr.naturaleza = "C"),0)
          INTO vtotretiros
          FROM dual;

        if vtotretiros is null then
           let vtotretiros = 0;
        end if

	-- Intereses Pagados y Tasa Aplicada
        select monto_tot, tasa_aplicada
          into vtotint, vTasaAplicada
          from sc_movhis mv
         where mv.empresa = eEmpresa
           and cuenta = vCuenta
           and fech_alt between vIni and vFin
           and cancelad <> "S"
           and transacc = "3276";
        if vtotint is null then
           let vtotint = 0;
        end if

	-- Comisiones Cobradas
        SELECT NVL((select sum(mv.monto_tot)
                  from sc_movhis mv, bdinteg:si_transacc tr
                 where mv.empresa = eEmpresa and cuenta = vCuenta
                   and mv.fech_alt between vIni and vFin
                   and tr.numero = mv.transacc and mv.cancelad <> "S"
                   and tr.naturaleza = "C"
                   and tipo_tran in("01")),0) +
               NVL((select sum(md.monto_tot)
                  from sc_movdia md, bdinteg:si_transacc tr
                 where md.empresa = eEmpresa and md.cuenta = vCuenta
                   and md.fech_alt between vIni and vFin
                   and tr.numero = md.transacc and md.cancelad <> "S"
                   and tr.naturaleza = "C"
                   and tipo_tran in("01")),0)
          INTO vtotcomcobrada
          FROM dual;

        if vtotcomcobrada is null then
           let vtotcomcobrada = 0;
        end if


	-- Iva Cobrado
        SELECT NVL((select sum(mv.monto_tot)
                  from sc_movhis mv, bdinteg:si_transacc tr
                 where mv.empresa = eEmpresa and cuenta = vCuenta
                   and mv.fech_alt between vIni and vFin
                   and tr.numero = mv.transacc and mv.cancelad <> "S"
                   and tr.naturaleza = "C"
                   AND tipo_tran in("02")),0) +
               NVL((select sum(md.monto_tot)
                  from sc_movdia md, bdinteg:si_transacc tr
                 where md.empresa = eEmpresa and md.cuenta = vCuenta
                   and md.fech_alt between vIni and vFin
                   and tr.numero = md.transacc and md.cancelad <> "S"
                   and tr.naturaleza = "C"
                   and tipo_tran in("02")),0)
          INTO vtotivacobrado
          FROM dual;

        if vtotivacobrado is null then
           let vtotivacobrado = 0;
        end if


	-- ISR CObrado
        select sum(monto_tot) into vtotisrcobrado
           from sc_movdia mv
           where mv.empresa = eEmpresa and cuenta = vCuenta and
                 fech_alt between vIni and vFin and
                 cancelad <> "S" and transacc = "3277";
        if vtotisrcobrado is null then
           let vtotisrcobrado = 0;
        end if

	-- Saldo Mes Anterior
        SELECT sdo_actual INTO vsdo_mes_ant
          FROM sc_maehis
         WHERE cuenta = vCuenta
           AND aniomes =  year(vIni)||lpad(month(vIni),2,"0")-1;

        IF vsdo_mes_ant IS NULL THEN
                LET vsdo_mes_ant = 0;
        END IF

	-- Atualiza MAEHIS
        UPDATE sc_maehis
           SET sdo_mes_ant = vsdo_mes_ant, 
	       dia_sdo_pos = 30,
               totdepositos = vtotdepositos,
	       totretiros =vtotretiros,
	       totintpag = vtotint,
               totcomcobrada = vtotcomcobrada,
	       totivacobrado = vtotivacobrado,
	       totisrcobrado = vtotisrcobrado,
	       tasabruta = vTasaAplicada
	WHERE cuenta = vCuenta
	  AND aniomes = vAnio;

   END FOREACH



RETURN CodRet;


END PROCEDURE


;