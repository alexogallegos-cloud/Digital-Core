CREATE PROCEDURE "informix".arr_edocta2(eEmpresa    CHAR(3),
			     eCuenta     CHAR(20),
			     eIni  DATE,
			     eFin  DATE,
			     eAnioMes CHAR(6),
			     eDiaSdoPos  DECIMAL(14,2))

RETURNING CHAR(5);

DEFINE GLOBAL vgtrans_pag_int CHAR(4) DEFAULT " ";


DEFINE vsdo_mes_ant   DECIMAL(14,2);
DEFINE vDiasAcum      SMALLINT;
DEFINE vtotdepositos  DECIMAL(14,2);
DEFINE vtotretiros    DECIMAL(14,2);
DEFINE vtotint        DECIMAL(14,2);
DEFINE vtotcomcobrada DECIMAL(14,2);
DEFINE vtotivacobrado DECIMAL(14,2);
DEFINE vtotisrcobrado DECIMAL(14,2);
DEFINE vCuenta        CHAR(20);
DEFINE CodRet	      CHAR(5);
DEFINE sql_err        INTEGER;
DEFINE vTasaAplicada  DECIMAL(9,6);
DEFINE vaxel          CHAR(10);
DEFINE Mes            SMALLINT;
DEFINE vdia           CHAR(2);
DEFINE vmes           CHAR(2);
DEFINE vanio          CHAR(4);
DEFINE vcuenta_clabe  CHAR(20);
DEFINE vsucursal      CHAR(4);
DEFINE vproducto      CHAR(4);
DEFINE vnum_cte	      CHAR(20);
DEFINE vstatus_cta    CHAR(1);
DEFINE vmotivo        CHAR(2);
DEFINE vfec_cancelac  DATE;
DEFINE vsdo_retenido  DECIMAL(14,2);
DEFINE vsdo_cong      DECIMAL(14,2);
DEFINE vsdo_actual    DECIMAL(14,2);
DEFINE venvio_direcc  CHAR(1);
DEFINE vdirecc_envio  SMALLINT;
DEFINE vacum_sdo_pos  DECIMAL(14,2);
DEFINE vdia_sdo_pos   SMALLINT;
DEFINE vacum_sdo_int  DECIMAL(14,2);
DEFINE vdias_acum_int SMALLINT;
DEFINE vret_mes_ant   DECIMAL(14,2);
DEFINE vcong_mes_ant  DECIMAL(14,2);
DEFINE vlim_sbg_ccc   DECIMAL(14,2);
DEFINE vimp_sbg_ccc   DECIMAL(14,2);
DEFINE vimp_chq_sbg   DECIMAL(14,2);
DEFINE vsaldo_sbc     DECIMAL(14,2);
DEFINE vint_acum      DECIMAL(14,2);
DEFINE visr_acum,
       vtotcombonif,
       vtotivabonif   DECIMAL(14,2);
DEFINE vmaxsecuencia  SMALLINT;
DEFINE vnum_tarjeta   CHAR(20);
DEFINE FechaHoy,
       FechaAnt,
       ProxFecha,
       PriDiaMes,
       PriHabMes,
       UltDiaMes,
       UltHabMes,
       vultdiamesant  DATE;
DEFINE vmesax         SMALLINT;
DEFINE vprimercobro   DATE;
DEFINE vaniomes       CHAR(6);
DEFINE vtasa_bruta    DECIMAL(9,6);





   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

-- SET DEBUG FILE TO "/tmp/arr_edocta2.out";
-- TRACE ON;
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet = "000";

   SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes,
          ult_dia_mes, ult_hab_mes
     INTO FechaHoy, FechaAnt, ProxFecha, PriDiaMes, PriHabMes,
          UltDiaMes, UltHabMes
     FROM sc_fechas
    WHERE empresa = eEmpresa;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


        --Pasa a Maestro historico de saldos (maehis)
        SELECT cuenta_clabe,sucursal,    mc.producto,  mc.num_cte,
               status_cta,  motivo,      fec_cancelac,sdo_retenido, sdo_cong,
               sdo_actual,  envio_direcc,direcc_envio,sdo_mes_ant,
               acum_sdo_pos,dia_sdo_pos, acum_sdo_int,dias_acum_int,
               ret_mes_ant, cong_mes_ant,lim_sbg_ccc, imp_sbg_ccc,
               imp_chq_sbg, saldo_sbc,   int_acum,    isr_acum
          INTO vcuenta_clabe, vsucursal,    vproducto,   vnum_cte,
               vstatus_cta,  vmotivo,     vfec_cancelac,vsdo_retenido,vsdo_cong,
               vsdo_actual,  venvio_direcc,vdirecc_envio,vsdo_mes_ant,
               vacum_sdo_pos,vdia_sdo_pos, vacum_sdo_int,vdias_acum_int,
               vret_mes_ant, vcong_mes_ant,vlim_sbg_ccc, vimp_sbg_ccc,
               vimp_chq_sbg, vsaldo_sbc,   vint_acum,    visr_acum
          FROM sc_maechq mc, sc_maenoc mn, sc_producto pr
         WHERE mc.empresa = eEmpresa
           AND mc.cuenta = eCuenta
           AND mc.empresa = mn.empresa
           AND mc.cuenta = mn.cuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        SELECT max(secuencia) INTO vmaxsecuencia
           FROM sc_tarjeta
           WHERE empresa = eEmpresa
             AND cuenta = eCuenta
             AND tipo_tarjeta = "T";

        SELECT num_tarjeta INTO vnum_tarjeta
           FROM sc_tarjeta
           WHERE empresa = eEmpresa
             AND cuenta = eCuenta
             AND secuencia = vmaxsecuencia;

        IF vnum_tarjeta IS NULL THEN
           LET vnum_tarjeta = "";
        END IF

        SET ISOLATION TO DIRTY READ;

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc AND mv.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tr.numero <> "3276"),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc AND md.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tr.numero <> "3276"),0)
          INTO vtotdepositos
          FROM dual;

        IF vtotdepositos IS NULL THEN
           LET vtotdepositos = 0;
        END IF

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa
                   AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc
                   AND tr.tipo_tran IN ("00","30")
                   AND mv.cancelad <> "S"
                   AND tr.naturaleza = "C"),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa
                   AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc
                   AND tr.tipo_tran IN ("00","30")
                   AND md.cancelad <> "S"
                   AND tr.naturaleza = "C"),0)
          INTO vtotretiros
          FROM dual;

        IF vtotretiros IS NULL THEN
           LET vtotretiros = 0;
        END IF

        SELECT monto_tot,tasa_aplicada
          INTO vtotint,vtasa_bruta
          FROM sc_movdia mv
          WHERE mv.empresa = eEmpresa
            AND cuenta = eCuenta
            AND fech_alt BETWEEN eIni AND eFin
            AND cancelad <> "S"
            AND transacc = "3276";
        IF vtotint IS NULL THEN
           LET vtotint = 0;
        END IF

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc AND mv.cancelad <> "S"
                   AND tr.naturaleza = "C"
                   AND tipo_tran in("01","31")),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc AND md.cancelad <> "S"
                   AND tr.naturaleza = "C"
                   AND tipo_tran in("01","31")),0)
          INTO vtotcomcobrada
          FROM dual;

        IF vtotcomcobrada IS NULL THEN
           LET vtotcomcobrada = 0;
        END IF

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc AND mv.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tipo_tran in("01","05","09")),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc AND md.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tipo_tran in("01","05","09")),0)
          INTO vtotcombonif
          FROM dual;

        IF vtotcombonif IS NULL THEN
           LET vtotcombonif = 0;
        END IF
        LET vtotcomcobrada = vtotcomcobrada - vtotcombonif;

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc AND mv.cancelad <> "S"
                   AND tr.naturaleza = "C"
                   AND tipo_tran in("02","32")),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc AND md.cancelad <> "S"
                   AND tr.naturaleza = "C"
                   AND tipo_tran in("02","32")),0)
          INTO vtotivacobrado
          FROM dual;

        IF vtotivacobrado IS NULL THEN
           LET vtotivacobrado = 0;
        END IF

        SELECT NVL((SELECT sum(mv.monto_tot)
                  FROM sc_movhis mv, bdinteg:si_transacc tr
                 WHERE mv.empresa = eEmpresa AND cuenta = eCuenta
                   AND mv.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = mv.transacc AND mv.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tipo_tran in("02","04","06","08")),0) +
               NVL((SELECT sum(md.monto_tot)
                  FROM sc_movdia md, bdinteg:si_transacc tr
                 WHERE md.empresa = eEmpresa AND md.cuenta = eCuenta
                   AND md.fech_alt BETWEEN eIni AND eFin
                   AND tr.numero = md.transacc AND md.cancelad <> "S"
                   AND tr.naturaleza = "A"
                   AND tipo_tran in("02","04","06","08")),0)
          INTO vtotivabonIF
          FROM dual;

        LET vtotivacobrado = vtotivacobrado - vtotivabonIF;

        SELECT sum(monto_tot)
          INTO vtotisrcobrado
          FROM sc_movdia mv
         WHERE mv.empresa = eEmpresa
           AND cuenta = eCuenta
           AND fech_alt BETWEEN eIni AND eFin
           AND cancelad <> "S"
           AND transacc = "3277";
        IF vtotisrcobrado IS NULL THEN
           LET vtotisrcobrado = 0;
        END IF

        IF vtotretiros < 0 THEN
                LET vtotretiros = 0;
        END IF

        -- Extrae Saldo Mes Anterior
	SELECT MAX(aniomes)
	  INTO vaniomes
          FROM sc_maehis
	 WHERE empresa = eEmpresa
           AND cuenta = eCuenta
	   AND aniomes < "200712";

	IF NOT vaniomes IS NULL THEN
          SELECT sdo_actual INTO vsdo_mes_ant
            FROM sc_maehis
	   WHERE empresa = eEmpresa
             AND cuenta = eCuenta
             AND aniomes = vaniomes;
        ELSE
          SELECT sdo_actual INTO vsdo_mes_ant
            FROM sc_maehis
	   WHERE empresa = eEmpresa
             AND cuenta = eCuenta
             AND aniomes IS NULL;
	END IF	

        IF vsdo_mes_ant IS NULL THEN
                LET vsdo_mes_ant = 0;
        END IF

	LET vsdo_actual = (vsdo_mes_ant + vtotdepositos + vtotint) - vtotretiros;
      
        IF NOT EXISTS (SELECT aniomes 
                        FROM sc_maehis 
                       WHERE empresa = '001' 
                         AND aniomes = eAnioMes 
                         AND cuenta = eCuenta) THEN
           INSERT INTO sc_maehis
              VALUES(eEmpresa,eAnioMes,eCuenta,eIni,eFin,
                  vcuenta_clabe,vnum_tarjeta,vsucursal,vproducto,vnum_cte,
                  vstatus_cta,vmotivo,vfec_cancelac,vsdo_retenido,
                  vsdo_cong,vsdo_actual,venvio_direcc,vdirecc_envio,
                  vsdo_mes_ant,0,0,vacum_sdo_int,
                  vdias_acum_int,vtasa_bruta,vret_mes_ant,vcong_mes_ant,
                  vlim_sbg_ccc,vimp_sbg_ccc,vimp_chq_sbg,vsaldo_sbc,vint_acum,
                  visr_acum,vtotdepositos,vtotretiros,vtotint,
                  vtotcomcobrada,vtotivacobrado,vtotisrcobrado);
        END IF
     RETURN CodRet;

END PROCEDURE
;