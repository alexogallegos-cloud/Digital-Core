CREATE PROCEDURE "informix".cierrechqpba(pempresa CHAR(3))
       RETURNING CHAR(5);


   DEFINE GLOBAL vgusuario     CHAR(8)   DEFAULT " ";
   DEFINE GLOBAL vgprox_fecha  DATE      DEFAULT " ";
   DEFINE GLOBAL vgfecha_hoy   DATE      DEFAULT " ";
   DEFINE GLOBAL vgpri_hab_mes DATE      DEFAULT " ";
   DEFINE GLOBAL vgpri_dia_mes DATE      DEFAULT " ";
   DEFINE GLOBAL vgult_hab_mes DATE      DEFAULT " ";
   DEFINE GLOBAL vgult_dia_mes DATE      DEFAULT " ";
   DEFINE GLOBAL vgtrans_pag_int CHAR(4) DEFAULT " ";
   DEFINE GLOBAL vgtransisr CHAR(4)      DEFAULT " ";
   DEFINE GLOBAL vgtranprov CHAR(4)      DEFAULT " ";
   DEFINE GLOBAL vgtranabotrasp CHAR(4)  DEFAULT " ";
   DEFINE GLOBAL vgtranrevprov  CHAR(4)  DEFAULT " ";
   DEFINE GLOBAL vgProdCreciente CHAR(4) DEFAULT " ";


   DEFINE vcuenta  CHAR(20);
   DEFINE vfcuenta CHAR(20);
   DEFINE vstatus_cta CHAR(1);

   DEFINE vtotsuc,
          vcontproc,
          vdiaspri,
          vdias             INTEGER;
   DEFINE vcodret           CHAR(5);
   DEFINE vsqlerr           INTEGER;
   DEFINE vcontprocie       CHAR(1);
   DEFINE vexiste           CHAR(1);
   DEFINE vcierre_ejercicio SMALLINT;
   DEFINE vproddiv          CHAR(4);
   DEFINE vfecinidiv        DATETIME YEAR TO MONTH;
   DEFINE vfecfindiv        DATETIME YEAR TO MONTH;
   DEFINE vstmt             CHAR(800);
   DEFINE vfolio_suc        CHAR(16);
   DEFINE vcontador         INTEGER;
   DEFINE vregproc          INTEGER;
   DEFINE vporcentajerror   INTEGER;
   DEFINE vcontvalcie       INTEGER;
   DEFINE vregistros        INTEGER;
   DEFINE vexiste2          INTEGER;
   DEFINE vexistefin        INTEGER;
   DEFINE vsistema          CHAR(2);
   DEFINE vproceso          CHAR(10);
   DEFINE FechaProc         DATE;
   DEFINE vProducto         CHAR(4);
   DEFINE vSdoActual        DECIMAL(14,2);
   DEFINE isam_err          SMALLINT;
   DEFINE error_info        CHAR(40);

   DEFINE vmes,vdia         CHAR(2);
   DEFINE vanio             CHAR(4);
   DEFINE vBandNva          SMALLINT;
   DEFINE vaniomes          CHAR(6);


BEGIN

   ON EXCEPTION SET vsqlerr, isam_err, error_info
      IF vsqlerr <> 0 THEN
         SET DEBUG FILE TO "cierrechq.err";
         TRACE ON;
         LET vcodret = vsqlerr;
         UPDATE bdinteg:sx_contproc
	    SET  hora_fin = current hour to fraction,
	 	 ejecutivo = vgusuario,
	 	 status_proc = "C",
	 	 codret      = vcodret
	  WHERE  empresa = pempresa
	    AND  proceso = vproceso
	    AND  fecha   = vgfecha_hoy
            AND  sistema = vsistema;

          RETURN vcodret;
      END IF;
   END EXCEPTION;

--      SET DEBUG FILE TO "cierrechq.out";
--      TRACE ON;


   LET vgusuario = USER;
   LET vcodret = "000";
   LET vsistema = "01";
   LET vproceso = "cierrechq";


   SELECT fecha_hoy,pri_dia_mes,pri_hab_mes,ult_dia_mes,
          ult_hab_mes,prox_fecha
     INTO vgfecha_hoy,vgpri_dia_mes,vgpri_hab_mes,vgult_dia_mes,
          vgult_hab_mes,vgprox_fecha
     FROM sc_fechas
    WHERE empresa = pempresa;


   SELECT valor INTO vgtrans_pag_int
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranpagint";

   SELECT valor INTO vgtransisr
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranisr";

   SELECT valor INTO vgtranprov
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranprov";

   SELECT valor INTO vgtranrevprov
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranrevprov";

   SELECT valor INTO vgtranabotrasp
     FROM sc_param
    WHERE empresa = pempresa
      AND codparam = "tranabotrasp";

   SELECT valor INTO vcierre_ejercicio
     FROM sc_param
     WHERE empresa = pempresa
       AND codparam = "cierre_ejercicio";

   -- Valida se halla realizado respaldo
   SELECT 1 INTO vexiste FROM sc_contproc
      WHERE empresa = pempresa AND proceso = "respacie"
	AND fecha = vgfecha_hoy;

   IF vexiste is null THEN
      LET vcodret = "965";
         UPDATE bdinteg:sx_contproc
      	    SET hora_fin = current hour to fraction,
      	 	ejecutivo = vgusuario,
      	 	status_proc = "C",
      	 	codret      = vcodret
      	 WHERE  empresa = pempresa
      	   AND  proceso = vproceso
      	   AND  fecha   = vgfecha_hoy
           AND  sistema = vsistema;

      RETURN vcodret;

   END IF

   SELECT count(*)
     INTO vexiste2
     FROM bdinteg:sx_contproc
    WHERE empresa = pempresa
      AND proceso = vproceso
      AND fecha   = vgfecha_hoy
      AND sistema = vsistema;

   IF vexiste2 = 0 THEN
      INSERT INTO bdinteg:sx_contproc
       VALUES (pempresa,vproceso,vgfecha_hoy,vsistema,"I",vgusuario,
               current hour to fraction,null,null);
   else

      SELECT count(*)
        INTO vexistefin
        FROM bdinteg:sx_contproc
       WHERE empresa = pempresa
         AND proceso = vproceso
         AND fecha   = vgfecha_hoy
         AND sistema = vsistema
         AND status_proc = "F";

      IF vexistefin = 0 THEN

         UPDATE bdinteg:sx_contproc
            SET hora_ini = current hour to fraction,
                ejecutivo = vgusuario,
                status_proc = "I",
                codret      = vcodret
         WHERE  empresa = pempresa
           AND  proceso = vproceso
           AND  fecha   = vgfecha_hoy
           AND  sistema = vsistema;

      ELSE

         LET vcodret = "966";

         UPDATE bdinteg:sx_contproc
	    SET hora_fin = current hour to fraction,
	 	ejecutivo = vgusuario,
	 	status_proc = "C",
	        codret      = vcodret
	 WHERE  empresa = pempresa
	   AND  proceso = vproceso
	   AND  fecha   = vgfecha_hoy
           AND  sistema = vsistema;
      --   RETURN vcodret;

      END IF


END IF;

--SET EXPLAIN ON;

   -- Valida no se halla realizado cierre

   SELECT 1 INTO vexiste FROM sc_contproc
    WHERE empresa = pempresa
      AND proceso = "cierre"
      AND fecha = vgfecha_hoy;
   IF vexiste  = "1" THEN
      LET vcodret = "966";
      RETURN vcodret;
   END IF

  --- Guarda historial de valcierre y limpia la tabla

   SELECT count(*)
     INTO vcontvalcie
     FROM sc_valcierre
    WHERE empresa = pempresa;


    IF vcontvalcie <> 0 THEN
          INSERT INTO sc_valcierre_his
          SELECT a.*,b.fecha_ant FROM sc_valcierre a, sc_fechas b
           WHERE a.empresa = pempresa;

          DELETE FROM sc_valcierre
           WHERE empresa = pempresa;

    END IF



   -- Valida se halla efectuado el Pase Contable en Sucursales

   SELECT count(*) INTO vtotsuc
     FROM bdinteg:si_sucursales su
    WHERE empresa = pempresa
      AND tpo_sucursal = "01"
      AND not exists (SELECT fecha FROM bdinteg:si_feriadsuc fs
                       WHERE fs.empresa = pempresa
			 AND fecha = vgfecha_hoy
			 AND su.sucursal = fs.sucursal);

   SELECT count(*) INTO vcontproc
     FROM bdisuc:ss_contproc
    WHERE proceso = "pase"
      AND fecha = vgfecha_hoy;

   -- Reversa movimiento de desglose de documentos cuANDo no hay movdia

  foreach
         SELECT cuenta,folio_suc INTO vcuenta,vfolio_suc
           FROM sc_docret
          WHERE siglas = "SC"
	    AND fecha_alta = vgfecha_hoy
	    AND cancelado <> "S"
          GROUP BY 1,2

      SELECT 1 INTO vexiste
        FROM sc_movdia
       WHERE cuenta = vcuenta
	 AND folio_suc = vfolio_suc
         AND cancelad <> "S";

      IF vexiste is null THEN
         UPDATE sc_docret
            SET cancelado = "S"
          WHERE cuenta = vcuenta
	    AND folio_suc = vfolio_suc
 	    AND fecha_alta = vgfecha_hoy;

      END IF
   END FOREACH ;



   IF vgfecha_hoy = vgult_hab_mes THEN
      LET vdias = vgult_dia_mes - vgfecha_hoy + 1;
      IF vgprox_fecha > vgult_dia_mes THEN
	LET vdias = vdias + ((vgprox_fecha-1) - vgult_dia_mes);
      END IF
   ELSE
      LET vdias = vgprox_fecha - vgfecha_hoy;
   END IF



   SELECT control
     INTO vcontprocie
     FROM sc_folsuc
    WHERE empresa = pempresa
      AND control = "2";
   IF vcontprocie is null THEN
      INSERT INTO sc_folsuc values(pempresa,"2","1");
      LET vcontprocie = "1";
   END IF

   IF vcontprocie = "1" THEN
      UPDATE sc_folsuc SET control = "2" WHERE empresa = pempresa;
   END IF

-- Obtiene registros a procesar
 SELECT count(*)
   INTO  vregproc
   FROM sc_maechq
  WHERE empresa = pempresa
    AND status_cta not in("0","2","8","9")
    AND (fecha_proceso is null
         OR fecha_proceso = " "
         OR fecha_proceso = vgfecha_hoy);

-- Obtiene parametro de porcentajes de error por proceso

SELECT ROUND(valor)
  INTO vporcentajerror
  FROM sc_param
 WHERE empresa  = pempresa
   AND codparam = "porcentajerror";

-- Producto Inversion Creciente
SELECT valor INTO vgProdCreciente
  FROM sc_param
 WHERE empresa = pempresa
   AND codparam = "PRODCREC";

-- ************************************************************
-- *      FOREACH PRINCIPAL DEL CIERRE DE CAPTACION           *
-- ************************************************************
FOREACH principal WITH HOLD FOR

  SELECT cuenta, fecha_proceso, producto, sdo_actual
    INTO  vfcuenta, FechaProc, vProducto, vSdoActual
    FROM sc_maechq
   WHERE empresa = pempresa
     AND status_cta not in("0","2","8","9")
     AND (fecha_proceso is null
          OR fecha_proceso = " "
          OR fecha_proceso = vgfecha_hoy)
--     AND cuenta = "10000921470 "

  IF vproducto =  vgProdCreciente AND FechaProc IS NULL THEN
      IF vSdoActual = 0 THEN
         UPDATE sc_maechq
            SET status_cta = "2",
                fecha_proceso = vgfecha_hoy
          WHERE empresa = pempresa
            AND cuenta = vfcuenta;
          LET vcodret ="000";
	  CONTINUE FOREACH;
      ELSE
          CALL creciente_proy_cierre(pempresa, vfcuenta, vProducto,
                                     vSdoActual)
          RETURNING vcodret;
	  IF vcodret <> "000" THEN
		CONTINUE FOREACH;
	  END IF
      END IF
  END IF

  CALL cierrechq_reg (pempresa,vdias,vfcuenta)
  RETURNING vcodret;


  IF vcodret <> "000" THEN

  -- Conteo de Errores generados por el cierre

     SELECT count(*)
       INTO vcontvalcie
       FROM sc_valcierre
      WHERE empresa = pempresa;


     LET vregistros = round(vregproc * vporcentajerror / 100);


     IF vcontvalcie <= vregistros THEN
        CONTINUE FOREACH;
     ELSE


        LET vcodret = "997";

        UPDATE bdinteg:sx_contproc
           SET hora_fin = current hour to fraction,
	       ejecutivo = vgusuario,
	       status_proc = "C",
	       codret      = vcodret
	WHERE  empresa = pempresa
	  AND  proceso = vproceso
	  AND  fecha   = vgfecha_hoy
          AND  sistema = vsistema;

        RETURN vcodret;

     END IF;

  END IF;


END FOREACH;

  --- End del forech cuentas de maecheq
-- ***************************************************************
-- Realiza pase de Movs de Ctas Crencientes Canceladas en el Dia *
-- ***************************************************************
FOREACH SELECT a.cuenta, sdo_actual, fecha_alta
	  INTO vfcuenta, vSdoActual, FechaProc
	  FROM sc_maechq a, sc_maenoc b
	 WHERE a.empresa = pempresa
	   AND a.status_cta = "2"
	   AND (a.fecha_proceso = vgfecha_hoy
	    OR  a.fecha_proceso IS NULL)
	   AND b.empresa = a.empresa
	   AND b.cuenta = a.cuenta

        SELECT MAX(aniomes) INTO vaniomes
          FROM sc_maehis
	 WHERE empresa = pempresa
           AND cuenta = vfcuenta;

        IF vaniomes IS NULL THEN
           LET vaniomes =  YEAR(FechaProc) || LPAD(month(FechaProc),2,0);
        ELSE
           LET vdia = DAY(FechaProc);  --- 1 AXEL;
           LET vmes = MONTH(vgfecha_hoy);
           LET vanio = YEAR(vgfecha_hoy);
           IF FechaProc = vgfecha_hoy THEN
              LET vdia = 0;
           END IF
           IF vdia > DAY(vgult_dia_mes) OR vdia < 1 THEN
              LET FechaProc = vgult_dia_mes;
           ELSE
              LET FechaProc = LPAD(TRIM(vmes),2,"0")||"/"||
                              LPAD(TRIM(vdia),2,"0")||"/"||vanio;
           END IF
        END IF

        IF FechaProc <> vgfecha_hoy THEN
           LET vBandNva = SUBSTR(vaniomes,5);
           IF vBandNva = 12 THEN
                LET vBandNva = 1;
           ELSE
                LET vBandNva = vBandNva + 1;
           END IF
           LET vaniomes = SUBSTR(vaniomes,1,4) || LPAD(vBandNva,2,0);
        END IF

        INSERT INTO sc_movhis
        SELECT vaniomes, a.*
          FROM sc_movdia a, sc_fechas b
         WHERE a.empresa = pempresa
           AND a.empresa = b.empresa
           AND cuenta  = vfcuenta;

        DELETE FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta = vfcuenta;

END FOREACH


-- ***********************************************
-- Aplica Movimientos Procedentes de Inversiones *
-- ***********************************************
 CALL movinver(pempresa)
 RETURNING  vcodret;
 IF vcodret <> "000" THEN
    INSERT INTO sc_valcierre VALUES
        (pempresa, "MOVINVER", vcodret);
    RETURN vcodret;
 END IF



--- Registra fin de cierre s


   UPDATE bdinteg:sx_contproc
      SET hora_fin = current hour to fraction,
          status_proc = "F",
          codret      = vcodret
    WHERE empresa = pempresa
      AND proceso = vproceso
      AND fecha   = vgfecha_hoy
      AND sistema = vsistema;

      UPDATE sc_contproc
         SET fecha = vgfecha_hoy
       WHERE empresa = pempresa
         AND proceso = "cierre";


   RETURN vcodret;

END

END PROCEDURE
DOCUMENT
'DESCRIPCION: Programa inicial del cierre diario de las cuenta de       ',
'captacion',
'EJECUTADO O LLAMADO POR:',
'VB Ejecutor de procesos ',
'AUTOR : Antonio Ruiz Mtz.',
'FECHA : 29/Agosto/2007',
'VERSION: 1.00.0000',
'BD    : BDICHEQ';

create procedure "informix".pasecheqtmp(pempresa char(3),vfecha_hoy date)
       returning char(5);

define vcodret char(5);
--define vfecha_hoy date;
define vsqlerr integer;
define vsucopero      char(4);
define vproducto      char(4);
define vmoneda        char(2);
define vtransacc      char(4);
define vmonto_tot     money(14,2);
define vexento_isr    char(1);
define vsector        char(2);
define vvaloriza      char(1);
define vcancelad      char(1);
define vsuccta      char(4);
define wabreviatura   char(20);
define wdescripcion   char(30);
define vfechaproc     date;
define vporcentaje decimal(9,6);
define vtasa_bruta, vsobretasa decimal(9,6);
define vtpcambval  decimal(14,6);
define vmonto1, vmonto2 money(14,2);
define vdivisa_cambio char(2);
define vcodigo_mn char(2);
define vtransacc_t1,vtranprovint char(4);
define vcobraisr char(1);
define vexiste  integer;
define vexistefin integer;
define vproceso char(10);
define vsistema char(02);
define vestatusproc char(1);
define vusuario    char(10);
-- Inicializa variables
let vcodret       = "000";
let vsistema = "01";
let vproceso = "pasechq";
let vusuario = user;

--set debug file to "pasecheq.out";
--trace on;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;

-- Asigna la fecha de hoy
--select fecha_hoy into vfecha_hoy
--   from sc_fechas where empresa = pempresa;

truncate sc_contab;
truncate aux_auditerr;
truncate aux_contab;

-- Extrae tasa base para el calculo de tasa exenta y param de T+1
select valor into vdivisa_cambio
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "divisa cambio";

select valor into vcodigo_mn
   from bdinteg:si_param
   where empresa = pempresa and descripcion = "codigo mn";

select valor into vtransacc_t1
   from sc_param
   where empresa = pempresa and codparam = "tranlibsbc";

select valor into vtranprovint
   from sc_param
   where empresa = pempresa and codparam = "tranprov";

--Extrae tipo de cambio valorizado
select precio_venta into vtpcambval
   from bdinteg:si_tpcambio
   where empresa = pempresa and divisa = vdivisa_cambio and
         fecha_tpcambio = vfecha_hoy and
         clase_tpcambio = "O";
if vtpcambval is null then
   {select precio_venta into vtpcambval
      from bdinteg:si_histdiv
      where empresa = pempresa and divisa = vdivisa_cambio and
            fecha_tc = vfecha_hoy
            and clase_tpcambio = "O";
   if vtpcambval is null then}
      let vtpcambval = 1;
   --end if
end if

foreach
   select md.sucursal,md.producto,divisa,transacc,
          monto_tot,exento_isr, cl.sector,
          tr.valoriza,cancelad,tasa_bruta,
          ac.sobretasa, mc.sucursal,tr.descripcion abreviatura,mc.cobraisr
     into vsucopero,vproducto,vmoneda,vtransacc,vmonto_tot,
          vexento_isr,vsector,vvaloriza,vcancelad,vtasa_bruta,
          vsobretasa,vsuccta,wabreviatura,vcobraisr
     from sc_movhis md,sc_maechq mc,outer sc_auxcont ac,sc_producto pr,
	  bdinteg:si_transacc tr, bdinteg:si_cliente cl,
          bdinteg:si_tipper tp
     where md.empresa = pempresa and md.fech_alt = vfecha_hoy and
           mc.empresa = md.empresa and mc.cuenta = md.cuenta and
          ac.empresa = md.empresa and ac.cuenta = md.cuenta and
	  pr.empresa = md.empresa and pr.producto = md.producto and
          tr.empresa = md.empresa and tr.numero = md.transacc and
          cl.numcte = mc.num_cte and tp.tpo_persona = cl.tpo_persona and
	  md.cancelad <> "S" and
          transacc not in(vtransacc_t1,"0231","0232","3313","3314") and
	  tr.se_contabiliza = "S"
     union all
     select md.sucursal,ma.producto,divisa,transacc,monto_tot,"N",
	    cl.sector,tr.valoriza,cancelad,0,0,ma.sucursal,
            tr.descripcion abreviatura,ma.cobraisr
	from sc_movhis md,sc_maechq ma,sc_producto pr,
             bdinteg:si_cliente cl,bdinteg:si_transacc tr
        where md.empresa = pempresa and md.fech_alt = vfecha_hoy and
              ma.empresa = md.empresa and ma.cuenta = md.cuenta and
	      pr.empresa = md.empresa and pr.producto = md.producto and
	      numcte = num_cte and
              tr.empresa = md.empresa and tr.numero = md.transacc and
              transacc in(vtransacc_t1,"0231","0232","3313","3314") and
              tr.se_contabiliza = "S"
     order by 12,2,4

     let wdescripcion = wabreviatura;
     if vcobraisr <> "" then
        if vcobraisr = "S" then
           let vexento_isr = "N";
        else
           let vexento_isr = "S";
        end if
     end if


     -- Verifica si es Transaccion de provision de Interes
     if vtransacc = vtranprovint then
        if vmoneda = vcodigo_mn then
           call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                            vmoneda,vtransacc,vsector,vcancelad,
                            vsuccta,wdescripcion) returning vcodret;
	   continue foreach;
	end if
	if vmoneda != vcodigo_mn and vvaloriza = "S" then
	   call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
                            vmoneda,vtransacc,vsector,vcancelad,
		            vsuccta,wdescripcion) returning vcodret;
           let vmonto2 = vmonto_tot * vtpcambval;
	   call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
                            vcodigo_mn,vtransacc,vsector,vcancelad,
		            vsuccta, wdescripcion) returning vcodret;
           continue foreach;
        end if
     end if

     -- Verifica si es movimiento valorizado
     if vmoneda <> vcodigo_mn and vvaloriza = "S"  then
        let vmonto2 = vmonto_tot * vtpcambval;
	call extrae_cont(pempresa,3,vmonto2,vsucopero,vproducto,
             vcodigo_mn,vtransacc,vsector,vcancelad,
	     vsuccta,wdescripcion) returning vcodret;
     end if

     if vtransacc <> "0231" and vtransacc <> "0232" and
        vtransacc <> "3313" and vtransacc <> "3314" and
        vtransacc <> vtransacc_t1 then
        call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
             vmoneda,vtransacc,vsector,vcancelad,
	     vsuccta,wdescripcion)  returning vcodret;
     end if

     --- Contabiliza Camara,231,232,3246
     if vtransacc = "0231" or vtransacc = "0232" or
        vtransacc = "3313" or vtransacc = "3314" or
        vtransacc = vtransacc_t1 then
        call extrae_cont(pempresa,1,vmonto_tot,vsucopero,vproducto,
             vmoneda,vtransacc,vsector,vcancelad,
	     vsuccta,wdescripcion)  returning vcodret;
        if vtransacc = vtransacc_t1 then
           call extrae_cont(pempresa,2,vmonto_tot,vsucopero,vproducto,
                vmoneda,vtransacc,vsector,vcancelad,
		vsuccta,wdescripcion) returning vcodret;
        end if
     end if
  end foreach
  insert into sc_contab
      select empresa,secuencia,sucursal,succta,ccmayor,ccsub,ccsubsub,
	 ccssubsub,ccsssubsub,sector,auxiliar,tot_cargo,
	 tot_abono,moneda,descripcion from aux_contab;
  call auditor(pempresa) returning vcodret;
  if vcodret = "000" then
     call pasecont(pempresa,vfecha_hoy) returning vcodret;
     if vcodret <> "000" then
        return vcodret;
     end if
  end if

  return vcodret;
end
end procedure;