CREATE PROCEDURE "informix".construyehis(eEmpresa CHAR(3))

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
DEFINE vaxel          CHAR(10);
DEFINE Mes            SMALLINT;
DEFINE vPromedio      DECIMAL(14,2);
DEFINE yearmaenoc     CHAR (4);
DEFINE mesmaenoc      CHAR (2);
DEFINE diamaenoc      INTEGER;
DEFINE mesmovhis      CHAR (2);
DEFINE diamovhis      INTEGER;
DEFINE mimes          CHAR (3);
DEFINE unmes            CHAR (2);
DEFINE fechalt        CHAR (12);
DEFINE fechval        CHAR (12);
DEFINE fechor         CHAR (12);
DEFINE numserial      CHAR(50);
DEFINE vaxl           SMALLINT;



   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err
--      SET DEBUG FILE TO "contrehis.out" || vCuenta;
--      TRACE ON;
      LET vCuenta = vCuenta;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

-- SET DEBUG FILE TO "contrehis.out";
-- TRACE ON;

   -- **************************************************************************
LET CodRet = "000";

   FOREACH
	  SELECT aniomes, cuenta, fechaini, fechafin
	    INTO vAnio, vCuenta, vIni, vFIn
	    FROM sc_maehis
--	   WHERE cuenta = "10000220081"
	   ORDER BY 1,2

	 select year(fecha_alta), month(fecha_alta),day(fecha_alta)
	 into yearmaenoc,mesmaenoc,diamaenoc
	 from sc_maenoc
	 where cuenta = vCuenta;

         foreach
	 	select fech_alt,fech_val,fech_hor,num_serial,month(fech_alt),day(fech_alt)
	 	into fechalt,fechval,fechor,numserial, mesmovhis,diamovhis
	 	from sc_movhis
	 	where cuenta = vCuenta

	 	let mimes = ' ';
	 		if mesmovhis - mesmaenoc <= 0
	 		  then let mimes = 0;
	 	        elif diamovhis > diamaenoc
	      	          then
	      	              let    mimes =  mesmovhis - mesmaenoc;
	      	         else
	       	              let  mimes = (mesmovhis - mesmaenoc) -1;
	       	         end if;
	 	let unmes = mimes + mesmaenoc;

			update sc_movhis
			       set aniomes = yearmaenoc||lpad(unmes,3,"0")
			where cuenta = vCuenta
			      and fech_alt = fechalt
			      and fech_val = fechval
			      and fech_hor = fechor
			      and num_serial = numserial;

	end foreach




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
	SELECT COUNT(*) INTO vaxl FROM sc_maehis
         where empresa = eEmpresa
           and cuenta = vCuenta
	   AND fechafin = vIni;
	IF vaxl > 0 THEN
		LET vIni = vIni + 1;
	END IF

        select sum(monto_tot), tasa_aplicada
          into vtotint, vTasaAplicada
          from sc_movhis mv
         where mv.empresa = eEmpresa
           and cuenta = vCuenta
           and fech_alt between vIni and vFin
           and cancelad <> "S"
           and transacc = "3276"
	  group by 2;
        if vtotint is null then
           let vtotint = 0;
        end if

	IF vaxl > 0 THEN
		LET vIni = vIni - 1;
	END IF


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
	LET vaxel =  year(vIni)||lpad(month(vIni),2,"0")-1;
	LET Mes  = MONTH(vIni) -1;
        SELECT sdo_actual INTO vsdo_mes_ant
          FROM sc_maehis
         WHERE cuenta = vCuenta
           AND aniomes =  year(vIni)||lpad(Mes,2,"0");

        IF vsdo_mes_ant IS NULL THEN
                LET vsdo_mes_ant = 0;
        END IF

	LET vDiasAcum = (vFin - vIni) +1;
	IF vTasaAplicada IS NULL OR vTasaAplicada = 0 THEN
		LET vTasaAplicada = 4;
	END IF

	IF vtotint > 0 THEN
	  LET vPromedio = ((vtotint * 36000) /vTasaAplicada);
	ELSE
	  LET vPromedio = 0;
	END IF


	-- Atualiza MAEHIS
        UPDATE sc_maehis
           SET sdo_mes_ant = vsdo_mes_ant,
	       dia_sdo_pos = vDiasAcum,
	       acum_sdo_pos = vPromedio,
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