CREATE PROCEDURE "informix".proyecta(pempresa        char(3),
                                     valortotal      money(14,2),
                                     pagopropuesto   money(14,2),
                                     producto        char(04),
                                     num_sol         char(20),
                                     apli_plan       char(1),
                                     usuario         char(20))

        RETURNING char(5),money(14,2),integer,money(14,2),money(14,2),money(14,2),date,decimal(9,6),char(6),decimal(9,6),money(14,2);

   DEFINE cod_ret            char(5);
   DEFINE vcod_tasa_base     char(8);
   DEFINE vtipoplazo         char(1);
   DEFINE vtipodia           char(1);
   DEFINE proyeccio1         char(20);
   DEFINE v_dia              char(2);
   DEFINE v_mes              char(2);
   DEFINE v_anio             char(4);
   DEFINE vfactor_sobretasa  char(1);
   DEFINE wtp_calculo        char(2);
   DEFINE wcod_tipcred       char(2);
   DEFINE vcat               char(6);
   DEFINE vCodTasaMora       char(8);
   DEFINE vFactor            char(1);
   DEFINE wfecha_venc        date;
   DEFINE wfecha_alta        date;
   DEFINE vfecha             date;
   DEFINE vfecha_hoy         date;
   DEFINE vfecha_hoyAnt      date;
   DEFINE wfecha_cambio      date;
   DEFINE wfecha_cambi1      date;
   DEFINE vfecha_primer      date;
   DEFINE v_fecha_vencim     date;
   DEFINE wtasa_interes      decimal(9,6);
   DEFINE vSobreTasa         decimal(9,6);
   DEFINE vtasa_periodo      decimal(10,6);
   DEFINE vtasa_diario       decimal(10,6);
   DEFINE v_tasa_interes     decimal(9,6);
   DEFINE wfactor            decimal(10,6);

   DEFINE wmonto_iva         decimal(14,2);
   DEFINE wadicional         decimal(14,2);
   DEFINE wadicionals        decimal(14,2);
   DEFINE wcomisions         decimal(14,2);
   DEFINE wtasaprop          decimal(9,6);
   DEFINE vTasaMora          decimal(9,6);
   DEFINE vmontopago         decimal(14,2);
   DEFINE sqlerr             integer;
   DEFINE proyeccion         integer;
   DEFINE wmesespro          integer;
   DEFINE cuotafantasma      integer;
   DEFINE nomeses1           integer;
   DEFINE nomeses2           integer;
   DEFINE vAnio              integer;
   DEFINE vDia               integer;
   DEFINE vMes               integer;
   DEFINE vper               integer;
   DEFINE vdia1              integer;
   DEFINE cicloseguro        smallint;
   DEFINE v_dias_cal_int     CHAR(10);
   DEFINE wplazo_fin         smallint;
   DEFINE wplazo_linea       smallint;
   DEFINE vmaxmeses          smallint;
   DEFINE wplazo_v           smallint;
   DEFINE wplazo_1           smallint;
   DEFINE v_dias             smallint;
   DEFINE cicloadicionales   smallint;
   DEFINE ciclo              smallint;
   DEFINE pagopropuestocal   money(14,2);
   DEFINE capital            money(14,2);
   DEFINE capital1           money(14,2);
   DEFINE valorfinal         money(14,2);
   DEFINE valorfinalAnt      money(14,2);
   DEFINE interes            money(14,2);
   DEFINE iva                money(14,2);
   DEFINE vmonto_int_par     money(14,2);
   DEFINE vinteres_total     money(14,2);
   DEFINE wmonto_linea       money(14,2);
    DEFINE vCapital          money(14,2);
   DEFINE vInteres           money(14,2);
   DEFINE vIva               money(14,2);
   DEFINE vIvaMas            money(14,2);
   DEFINE vMesPro            money(14,2);
   DEFINE vValorFin          money(14,2);
   DEFINE vabono_fijo        money(14,2);
   DEFINE vProyecInt         money(14,2);
   DEFINE vValorPre          MONEY(14,2);
   DEFINE BanderaCas         CHAR(1);
   DEFINE bEsNumero          BOOLEAN;

 --  DEFINE cMontoMaxPlazoMax  MONEY(18,2);
 --  DEFINE cFechaMaxPlazoMax  MONEY(18,2);


   LET nomeses1 = 0;
   LET wtasaprop = 0;
   LET wmesespro = 0;

   LET cod_ret          = "000";
   LET wtasa_interes    = 0;
   LET wplazo_v         = 0;
   LET vfecha_hoy       = "";
   LET v_fecha_vencim   = "";
   LET v_dias_cal_int   = '0';
   LET vmonto_int_par   = 0;
   LET sqlerr           = 0;
   LET capital          = 0;
   LET capital1         = 0;
   LET interes          = 0;
   LET iva              = 0;
   LET valorfinal       = 0;
   LET vfecha           = "";
   LET proyeccion       = 0;
   LET v_tasa_interes   = 0;
   LET vAnio            = 0;
   LET vMes             = 0;
   LET vDia             = 0;
   LET vcat             = '';
   LET vTasaMora        = 0;
   LET vCodTasaMora     = '';
   LET vFactor          = '';
   LET vSobreTasa       = 0;
   LET vProyecInt       = 0;
   LET valorfinalAnt    = 0;
   LET BanderaCas       = '0';
   LET bEsNumero        = 't';
   
 --  LET cMontoMaxPlazoMax= 0;

BEGIN
ON EXCEPTION
      SET sqlerr
      LET cod_ret = sqlerr;
      return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
END EXCEPTION;

--    SET DEBUG FILE TO "/tmp/proyecta.out";
--    TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
    -- FMV 12-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
    EXECUTE PROCEDURE bdinteg:val_num (num_sol) INTO bEsNumero;
     
    IF bEsNumero = 'f' THEN
      LET cod_ret = '242';  --EL NUMERO DE SOLICITUD NO EXISTE
          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
    END IF;


    if pagopropuesto < 10 then
      LET cod_ret = '002';
      return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
    end if;

    SELECT valor
    INTO vcat
    FROM "informix".sd_param
    WHERE empresa = pempresa
      AND cod_param='321';  --FMV 6-DIC-11: Se cambia codigo para Cat con iva solo Reestructura

-- SE OBTIENE EL I.V.A
    SELECT valor
    INTO vIva
    FROM "informix".sd_param
    WHERE empresa = pempresa 
      AND cod_param='12';

-- SE LE INCREMENTA 1 AL I.V.A
   LET vIvaMas = vIva + 1;

    SELECT cod_tasa_mora,fact_sobret_mora,sobretasa_mora
    INTO   vCodTasaMora, vFactor, vSobreTasa
    FROM   bdicred:"informix".sd_definicion  --FMV 1-AGO-12 Se cambia a la tabla sd_definicion no afecta, Rees no usa mora
    WHERE  num_producto = producto;

    SELECT valor  
     INTO vTasaMora 
     FROM bdinteg:"informix".si_fechavalor
    WHERE empresa = pempresa   
      AND tasa = vCodTasaMora  
      AND fecha = (SELECT MAX(fecha)
                    FROM bdinteg:"informix".si_fechavalor
                   WHERE tasa = vCodTasaMora);

     IF   vFactor = '+' then
        LET vTasaMora = vTasaMora + vSobreTasa;
     ELIF vFactor = '-' then
        LET vTasaMora = vTasaMora - vSobreTasa;
     ELIF vFactor = '*' then
        LET vTasaMora = vTasaMora * vSobreTasa;
     ELIF vFactor = '/' then
        LET vTasaMora = vTasaMora / vSobreTasa;
     ELSE
        LET vTasaMora = vTasaMora;
     END IF;

   IF  apli_plan = 'S' THEN
       LET usuario = usuario;
       DELETE from bdicred:"informix".sd_proyecta    --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       where empresa = pempresa 
         and num_solicitud = usuario;
       if valortotal = 0  or pagopropuesto = 0 or trim(producto) = "" then
          LET cod_ret = "110";
          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
       end if

       select cod_tasa_base,factor_sobretasa,sobretasa,plazo_max_cred,periodo_plazo
         into vcod_tasa_base,vfactor_sobretasa,vsobretasa,vmaxmeses,vtipoplazo
         from bdicred:"informix".sd_definicion 
       where num_producto = producto;

       SELECT valor  
         INTO wtasa_interes 
         FROM bdinteg:"informix".si_fechavalor
        WHERE tasa = vcod_tasa_base  
          AND fecha = (SELECT MAX(fecha)
                         FROM bdinteg:"informix".si_fechavalor
                        WHERE tasa = vcod_tasa_base);
       LET v_tasa_interes = wtasa_interes * vsobretasa;
       IF vfactor_sobretasa = '+' then
          LET v_tasa_interes = wtasa_interes + vsobretasa;
       ELIF vfactor_sobretasa = '-' then
            LET v_tasa_interes = wtasa_interes - vsobretasa;
       ELIF vfactor_sobretasa = '*' then
            LET v_tasa_interes = wtasa_interes * vsobretasa;
       ELIF vfactor_sobretasa = '/' then
            LET v_tasa_interes = wtasa_interes / vsobretasa;
       END IF;

      SELECT valor 
        INTO v_dias_cal_int
        FROM bdicred:"informix".sd_param       ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa = pempresa   
         AND cod_param = "24";

      select max(num_solicitud) {+index (sd_proyecta idx_sdproyecta)}
        into proyeccion
        from bdicred:"informix".sd_proyecta     ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       where empresa =  pempresa
         and num_solicitud = usuario;

      if proyeccion is null then
         LET proyeccion = 1;
      else
         LET proyeccion = proyeccion;
      end if
      LET proyeccion = proyeccion + 1;

      SELECT fecha_hoy,pri_dia_mes
        INTO vfecha_hoy,vfecha_primer
        FROM bdicred:"informix".sd_fechas
       WHERE empresa = pempresa;

      if day(vfecha_hoy) > 2 and day(vfecha_hoy) < 17 then
         LET vfecha_primer = Mdy(month(vfecha_hoy),02,year(vfecha_hoy));
         LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
      else
         LET vfecha_primer = Mdy(month(vfecha_hoy),17,year(vfecha_hoy)) ;
         IF day(vfecha_hoy) > 2 THEN
            LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
         END IF;
      end if
      LET wplazo_linea = vmaxmeses;
      LET vtipodia = "N";
      LET v_fecha_vencim = vfecha_primer + (wplazo_linea - 1) units month;
      LET wplazo_fin =1;
      LET wplazo_v = 0;
      if vtipoplazo = "C" then
         LET wplazo_fin = 4;
      else
         if vtipoplazo = "A" then
            LET wplazo_fin = 12;
         else
            if vtipoplazo = "S" then
               LET wplazo_fin = 6;
            end if
         end if
      end if
      LET wmonto_linea = valortotal;
      LET vtasa_periodo = (v_tasa_interes/12)/100;
      LET ciclo = 0;
      LET vinteres_total =0 ;
      LET wfecha_alta = vfecha_primer ;
      LET wcomisions = 0;
      LET wadicionals = 0;
      LET cuotafantasma = 0;
      LET wplazo_1 = vmaxmeses;
      LET nomeses2 = 0;
      if pagopropuesto > 0 then
         LET nomeses1 = vmaxmeses;
         LET wplazo_1 = vmaxmeses;
      end if
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
   LET vtasa_diario = round((v_tasa_interes/v_dias_cal_int)/100,8);

  -- LET vtasa_diario = vtasa_diario * (1 + .15);

   LET vdia1 = (wfecha_alta - vfecha_hoy);
   LET vabono_fijo = pagopropuesto;
   LET vtasa_periodo = vtasa_periodo * vIvaMas;
   LET wmonto_linea = wmonto_linea;
   LET ciclo = 0;
   LET wadicional = wmonto_linea;
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vValorPre = 0;

   LET vdia1 = vdia1;


   while ciclo < wplazo_linea
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_cambi1 - wfecha_cambio + 1;
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       ELSE
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       END IF;

   --    LET vmonto_int_par = round(wadicional * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wadicional * vtasa_diario, 2);
       LET vmonto_int_par = round(vmonto_int_par * vdia1, 2);
       LET wmonto_iva = round(vmonto_int_par  * vIva ,2);
    --   LET vmonto_int_par = vmonto_int_par - wmonto_iva ;
       LET capital = pagopropuesto - vmonto_int_par - wmonto_iva ;

       IF capital < 0 THEN -- No Cubre el Interes   
          LET valorfinalAnt=valorfinal;  
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses+3));
            IF pagopropuesto < ROUND(wmonto_linea*vtasa_periodo,2) THEN
               LET valorfinal=valorfinal+valorfinalAnt;
            END IF;    
          LET wadicional = wmonto_linea - valorfinal;
           IF wadicional<0 THEN
              LET cod_ret = '002';
              return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET capital = 0;
          LET BanderaCas='2';
--          LET cod_ret = "002";
--          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
       END IF;
       LET capital = capital;
       LET vmonto_int_par = vmonto_int_par;
       LET wmonto_iva = wmonto_iva;
       LET pagopropuesto = pagopropuesto;

       IF vmonto_int_par < 0 THEN     --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
       --IF vmonto_int_par = 0 THEN   
          EXIT WHILE;
       END IF;

       if capital > wadicional then
          LET capital = wadicional;
       end if
       IF ciclo <> 0 THEN 
           LET wfecha_cambio = wfecha_cambi1;
           LET wfecha_cambi1 = wfecha_cambi1 + 1 UNITS MONTH;
           LET wadicional = wadicional - capital;
       END IF;

       IF valorfinal>0 AND ciclo>= vmaxmeses and ((BanderaCas= '1' ) or pagopropuesto > ROUND(wmonto_linea*vtasa_periodo,2)) THEN --and wadicional<=0
          EXIT WHILE;
       END IF;

       IF wadicional > 0 and ciclo = vmaxmeses THEN
          LET valorfinalAnt=valorfinal; 
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses));
            IF pagopropuesto < ROUND(wmonto_linea*vtasa_periodo,2) and BanderaCas='2' THEN
               LET valorfinal=valorfinal+valorfinalAnt;
            END IF;    
          LET wadicional = wmonto_linea - valorfinal;
          LET capital = 0;
           IF wadicional<0 THEN
              EXIT WHILE; 
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET BanderaCas= '1';
       END IF;



       if wadicional <= 0 then
          LET wadicional = 0;
          EXIT WHILE; 
       end if;
   end while

   IF apli_plan = "N" THEN
      IF ciclo = wplazo_linea THEN
         LET valorfinal = valortotal - vValorPre;
         -- Aqui Ajusto lo Calculado MEL
         LET wmonto_linea = wmonto_linea - valorfinal;
      ELSE
         LET vValorPre = 0;
      END IF;
   END IF;

 
   LET valortotal = valortotal;
   LET vfecha_hoyAnt = vfecha_hoy;
  -- LET valorfinal = valortotal - wmonto_linea;
   LET valorfinal = valorfinal;
   LET wmonto_linea = wmonto_linea-valorfinal;
   LET wplazo_linea = vmaxmeses;
   LET ciclo = 0;
   LET vabono_fijo = pagopropuesto;
   LET BanderaCas='1';
   while ciclo < wplazo_linea and wmonto_linea <> 0
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_alta - vfecha_hoy + 1;
          LET vdia1 = wfecha_alta - vfecha_hoy;
       ELSE
          LET vdia1 = wfecha_alta - vfecha_hoy;
       END IF;
       --LET + = round(wmonto_linea * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wmonto_linea * vtasa_diario ,2);
       LET vmonto_int_par = round(vmonto_int_par *  vdia1,2);
       LET wmonto_iva = round(vmonto_int_par * vIva,2);

       --LET vmonto_int_par = vmonto_int_par - wmonto_iva ;

       IF vmonto_int_par < 0 THEN
       --IF vmonto_int_par = 0 THEN --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       LET capital = pagopropuesto - vmonto_int_par - wmonto_iva ;
       if capital > wmonto_linea then
          LET capital = wmonto_linea;
       end if
       LET vmontopago = capital + vmonto_int_par + wmonto_iva;
       insert into "informix".sd_proyecta (empresa,num_solicitud,fecha_cuota,capital_cuota,
                                                    interes_cuota,iva_cuota,plazo,enganche,tasa_interes)
                values(pempresa,trim(usuario),wfecha_alta,capital,vmonto_int_par,wmonto_iva,ciclo,
                       valorfinal, v_tasa_interes);
      LET vfecha_hoy = wfecha_alta;
      LET wfecha_alta = wfecha_alta + 1 UNITS MONTH;
      LET wmonto_linea = wmonto_linea - capital;

  

      if wmonto_linea <= 0 then
          LET wmonto_linea = 0;
      end if;
  end while
  select count(*), sum(capital_cuota), min(fecha_cuota)  {+index (sd_proyecta idx_sdproyecta)}
    into wplazo_v, capital,vfecha_hoy
    from "informix".sd_proyecta
   where empresa = pempresa       --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
     and num_solicitud = usuario;
  LET wmesespro = wplazo_v;

--  select sum(capital_cuota) {+index (sd_proyecta idx_sdproyecta)}
--   into capital
--  from sd_proyecta
--  where empresa = pempresa   --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
--    and num_solicitud = usuario;
  LET valorfinal = valortotal - capital;

  LET nomeses2 = 1;
  LET capital1 = capital;

--  SELECT min(fecha_cuota)  {+index (sd_proyecta idx_sdproyecta)}
--    INTO vfecha_hoy
--   from sd_proyecta
--  where empresa = pempresa   --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
--    and num_solicitud = usuario;

    foreach
      select 
          fecha_cuota,capital_cuota ,interes_cuota,iva_cuota,plazo,plazo,tasa_interes
          into vfecha,vCapital,vInteres, vIva,vMesPro,vValorFin, v_tasa_interes
          from "informix".sd_proyecta
          where empresa = pempresa        --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
            and num_solicitud = trim(usuario)
          order by fecha_cuota
          if nomeses2 < wmesespro then
                 LET nomeses2 = nomeses2 +1;
          end if
                 return cod_ret,valorfinal,wmesespro,vCapital,vInteres,vIva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt with resume;
    end foreach;
 ELSE
      UPDATE "informix".sd_proyecta
         SET num_solicitud = num_sol
       WHERE empresa = pempresa
         AND num_solicitud = usuario;
      return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt with resume ;
 END IF;

END
END PROCEDURE
DOCUMENT
"Realiza la generacion de planes de pago",
"AUTOR : Procesamiento Interactivo ",
"BD.   : bdicred"
;

CREATE PROCEDURE "informix".sp_proyecta_creditos(pMonto_Autorizado  DECIMAL(18,6),  -- MONTO DEL CREDITO
											       pPlazo 			 INTEGER, 	     --PLAZO EN MESES PARA PAGAR
                                                   pCapacidad_Pres	 DECIMAL(18,6),  -- CAPACIDAD DE PAGO DEL CLIENTE
                                                   pProducto 		 CHAR(4), 	     -- CODIGO DE pProducto
                                                   pSucursal 		 CHAR(4),	     -- CODIGO DE SUCURSAL
                                                   pTipoRetorno 	 SMALLINT,	     -- DETERMINA COMO SE VAN A RETORNAR LOS DATOS:
                                                                                                --	0  RESUMEN
                                                                                                --	1   DETALLE
                                                                                                --	2  REIMPRESION DE CARATULA
                                                                                                --	3  CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                                                                --	4  RESUMEN CON DIFERENTE FECHA DE INICIO DE PROYECCION
                                                   pSolicitudes 	 SMALLINT,	     -- PARA PAGINACION
                                                 --  pNumCred			 CHAR(20),	     -- NUMERO DE CREDITO
                                                   pFecha			 DATE,		     -- FECHA PARA INICIAR LA PROYECCION
												   pFrecuencia       INTEGER,         --Frecuencia de pago
																						--0.- Mensual(prestamo)
																						--1.- Mensual credinomina
																						--2.- Quincenal credinomina
												   pDiaPago       INTEGER
                                                   )

RETURNING   CHAR(6)         AS Codigo, 		  -- CODIGO DE RETORNO
            INTEGER         AS Periodo,       -- PERIODO ACTUAL
            DATE            AS FechaCouta,	  -- FECHA DEL PAGO
            DECIMAL(18,2)   AS SaldoInicial,  -- SALDO INICIAL
            DECIMAL(18,2)   AS Mensualidad,	  -- MENSUALIDAD
            DECIMAL(18,2)   AS Intereses,	  -- INTERESES
            DECIMAL(18,2)   AS IvaInteres,	  -- IVA DE INTERESES
            DECIMAL(18,2)   AS Capital,		  -- CAPITAL
            DECIMAL(18,2)   AS SaldoFinal,	  -- SALDO FINAL
            SMALLINT        AS DiasPeriodo,	  -- DIAS DEL PERIODO
            DATE            AS FechaAper,	  -- FECHA DE APERTURA
			CHAR(3)         AS NumMesesPago;	  -- FECHA DE APERTURA

--  CONTROL DE CAMBIOS
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agregaron como parametros de entrada el pProducto y la sucursal,
--             el iva se toma de la sucursal, la fecha se toma de la tabla
--	       bdicred:sd_fechas, la tasa anual se toma de la tabla bdicred:sd_definicion,
--             se agrego validacion para detectar cuando el parametro
--	      de entrada pPlazo venga vacio se le asigne por default el valor 36.
--Fecha: 2009/09/15
--Version: 20090909.1800
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agregaron las formulas para obtener los valores de Plazo,
--              Monto otorgado y mensualidades.
--Fecha: 2009/09/18
--Version: 20090918.1303
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se hicieron adecuaciones a las formulas para que los resultados
--             fueran mas exactos.
--Fecha: 2009/09/21
--Version: 20090921.1508
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego parametro para definir el numero de registros que se van
--             a retornar, si se manda 1 regresa n registros y si se manda 0
--	       regresa solo un registro.
--Fecha: 2009/09/22
--Version: 20090922.0956
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego parametro de entrada para paginar los resultados.
--Fecha: 2009/09/29
--Version: 20090929.1209
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se referencia el procedimiento monthadd a la base de datos bdicred.
--Fecha: 2009/10/06
--Version: 20091006.1840
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego validacion para evitar que se de una mensualidad menor a
--              los intereses que se generan de forma mensual.
--              Se agregaron validaciones para ver si el monto y el plazo se encuentren
--              dentro de los rangos permitidos
--	        Se agrego validacion para que solo se manden 2 de 3 de los parametros
--              de plazo, mensualidad y monto otorgado
--	        Se agrego ajuste del monto de la mensualidad para el ultimo pago
--              en caso de que no sea exacta para que quede en 0 el prestamo
--Fecha: 2009/10/08'
--Version: 20091008.1238
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se cambio la forma de obtener la fecha de couta y los dias por periodo
--Fecha: 2009/10/21
--Version: 20091021.1800
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jose Luis Pulido Zepeda
--Descripcion: Se agrego nuevo parametro de entrada que se tomaria como la fecha
--             de inicio de la proyeccion en dado caso que el parametro
--             que define el tipo de retorno sea igual a 3
--Fecha: 2009/10/27
--Version: 20091027.1326
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se cambio que al obtener el iva del maestro de crédito no se dividiera entre 100
--             ya que se definio que te almacenaria ya con el calculo correspondiente
--             Se valida si el pTipoRetorno es diferente de 0 realice la comparación de rangos
--             de montos maximos y minimos permitidos en caso contrario no se realice la comparación
--             ya se que se realizará desde la calificación del crédito (califica_scoring2).
--Fecha: 2009/11/01
--Version: 20091101.1013
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para que se contemplen diferentes escenarios de comparación de parámetros
--             para el pTipoRetorno 2 (Reimpresion de la proyección)
--Fecha: 2009/11/10
--Version: 20091110.1309
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para validar que los parámetros de plazo y monto autorizado recibido
--              se encuentra dentro de rango permitido y que para el escenario donde se reciba el
--              monto y la mensualidad, se ejecute el sp_obtiene_aproximación enviadole en el parámetro de
--              plazo el plazo máximo establecido para el pProducto de crédito a proyectar, con la finalidad
--              de que esta validación se elimine dentro del sp que realiza la proyección con valor fijo.
--Fecha: 2009/12/01
--Versión: 20091201.1148
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para paginar los registros correctamente.
--Fecha: 2009/12/01
--Version: 20091201.1153
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifca para que al validar el retorno del sp_obtiene_aproximación,
--              se asgine un valor controlado o en su defecto retornar el código
--              que se reciba  del sp de aproximación.
--Fecha: 2009/12/10
--Versión: 20091210.1107
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica las variables para calculos de tasas money(14,2) a decimal(9,6).
--Fecha: 2010/01/27
--Version: 20100127.0830
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Viridiana Osobampo Aguilar
--Descripcion: Se modifica para que el la mensualidad de la cuota no sobrepase al monto indicado
--	 	 en el parámetro de entrada en la ejecución del spl
--Fecha: 2010/02/05
--Version: 20100205.1358
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modifica para cambiar los mensajes:
--             * Se modifica el retorno "000015" que mostraria el mensaje
--             "El cálculo del monto no se puede realizar con los parámetros actuales" por el
--             retorno "000004" para que muestre el mensaje "El monto autorizado esta fuera del rango permitido".
--             * Se modifica el retorno "000014" por el retorno "000005" era el mismo mensaje solo se reemplazo
--             para eliminar el mensaje similar.
--Fecha: 2010/02/09
--Version: 20100209.0912
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Hector Manuel Bojorquez Ruelas,Jesús Manuel Aguilar Heredia
--Descripcion: Se modifica para que se pueda utilizar en el pProducto Credinomina, para lo cual se le agrego un parametro de entrada mas para identificar la forma de pago del prestamo.
--Fecha: 2011/05/04
--Version: 20110405.1010
---------------------------------------------------------------------------------------------------------------
--MODIFICO: Jesús Manuel Aguilar Heredia
--Descripcion: Se modifica para que  se contemple el dia de pago en la proyeccion, y no se manejen dias 15 y 30.
--Fecha: 2011/08/10
--Version: 20110810.1010
---------------------------------------------------------------------------------------------------------------
-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet     		CHAR(6); 			-- CODIGO DE RETORNO DE ERROR
DEFINE mPeriodo			INTEGER;			-- PERIODO DE PAGO
DEFINE dFechaCouta		DATE;				-- FECHA
DEFINE mSdoInicial		DECIMAL(18,6);		-- SALDO INICIAL
DEFINE mMensualidad		DECIMAL(18,6);		-- MENSUALIDAD
DEFINE mIntereses		DECIMAL(18,6);		-- INTERESES
DEFINE mIvaInt			DECIMAL(18,6);		-- IVA DE INTERESES
DEFINE mCapital			DECIMAL(18,6);		-- CAPITAL
DEFINE mSdoFinal		DECIMAL(18,6);		-- SALDO FINAL
DEFINE sDiasPeriodo		SMALLINT;			-- DIAS DEL PERIODO
DEFINE mMontoMin		DECIMAL(18,6);		-- MONTO MINIMO
DEFINE mMontoMax		DECIMAL(18,6);		-- MONTO MAXIMO
DEFINE sPlazoMin		SMALLINT;			-- PLAZO MINIMO
DEFINE sPlazoMax		SMALLINT;			-- PLAZO MAXIMO
DEFINE dFechaAper		DATE;				-- FECHA DE APERTURA

-- VARIABLES AUXILIARES
DEFINE Contador 		INTEGER; 			-- PARA CONTROLAR LAS INTERACIONES DEL CICLO
DEFINE mTasaInt 		DECIMAL(18,6);		-- TASA DE INTERES
DEFINE mIVA				DECIMAL(18,6);    	-- IVA
DEFINE mTasa			DECIMAL(18,6);		-- TASA ANUAL
DEFINE dFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas
DEFINE sPlazo			SMALLINT;			-- PLAZO
DEFINE mTasaMensual		DECIMAL(18,6);      -- TASA MENSUAL
DEFINE mTasaIVA			DECIMAL(18,6);		-- TASA ANUAL CON IVA
DEFINE mTasaMensualIVA	DECIMAL(18,6);		-- TASA MENSUAL CON IVA
DEFINE dFechaInicial	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dtDiaprimero 	DATE;				-- FECHA QUE SE TOMA COMO INICIO PARA CALCULAR LAS DEMAS FECHAS
DEFINE dFechaAnt		DATE;				-- FECHA ANTERIOR DE COUTA
DEFINE dFechaFinMes		DATE;				-- FECHA ANTERIOR DE COUTA

-- VARIABLES PARA CAPTURAR LOS VALORES DE PLAZO, PAGO MENSUAL Y MONTO APROBADO
DEFINE mMontoAut 		DECIMAL(18,6); 		-- MONTO DEL CREDITO
DEFINE mPlazo  	 		DECIMAL(18,6);		--PLAZO EN MESES PARA PAGAR
DEFINE mCapacidadPres	DECIMAL(18,6); 		-- CAPACIDAD DE PAGO DEL CLIENTE

DEFINE cEmpresa         CHAR(3);
DEFINE dLimites         DECIMAL(18,6);
DEFINE dDiferencia      DECIMAL(18,6);
DEFINE mMensualidadAux  DECIMAL(18,6);
DEFINE mMontoAutAux		DECIMAL(18,6);

DEFINE iTpoPago        INTEGER;
DEFINE cTipo            CHAR(15);
DEFINE iDiaPago      	INTEGER;
DEFINE mPlazoAux      	DECIMAL(18,6);
DEFINE sContinua      	INTEGER;
---6011
DEFINE cod_ret            char(5);
DEFINE vcod_tasa_base     char(8);
DEFINE vtipoplazo         char(1);
DEFINE vtipodia           char(1);
DEFINE proyeccio1         char(20);
DEFINE v_dia              char(2);
DEFINE v_mes              char(2);
DEFINE v_anio             char(4);
DEFINE vfactor_sobretasa  char(1);
DEFINE wtp_calculo        char(2);
DEFINE wcod_tipcred       char(2);
DEFINE vcat               char(6);
DEFINE vCodTasaMora       char(8);
DEFINE vFactor            char(1);
DEFINE wfecha_venc        date;
DEFINE wfecha_alta        date;
DEFINE vfecha             date;
DEFINE vfecha_hoy         date;
DEFINE vfecha_hoyAnt      date;
DEFINE wfecha_cambio      date;
DEFINE wfecha_cambi1      date;
DEFINE vfecha_primer      date;
DEFINE v_fecha_vencim     date;
DEFINE wtasa_interes      decimal(9,6);
DEFINE vSobreTasa         decimal(9,6);
DEFINE vtasa_periodo      decimal(10,6);
DEFINE vtasa_diario       decimal(10,6);
DEFINE v_tasa_interes     decimal(9,6);
DEFINE wfactor            decimal(10,6);

DEFINE wmonto_iva         decimal(14,2);
DEFINE wadicional         decimal(14,2);
DEFINE wadicionals        decimal(14,2);
DEFINE wcomisions         decimal(14,2);
DEFINE wtasaprop          decimal(9,6);
DEFINE vTasaMora          decimal(9,6);
DEFINE vmontopago         decimal(14,2);
DEFINE sqlerr             integer;
DEFINE proyeccion         integer;
DEFINE wmesespro          integer;
DEFINE cuotafantasma      integer;
DEFINE nomeses1           integer;
DEFINE nomeses2           integer;
DEFINE vAnio              integer;
DEFINE vDia               integer;
DEFINE vMes               integer;
DEFINE vper               integer;
DEFINE vdia1              integer;
DEFINE cicloseguro        smallint;
DEFINE v_dias_cal_int     CHAR(10);
DEFINE wplazo_fin         smallint;
DEFINE wplazo_linea       smallint;
DEFINE vmaxmeses          smallint;
DEFINE wplazo_v           smallint;
DEFINE wplazo_1           smallint;
DEFINE v_dias             smallint;
DEFINE cicloadicionales   smallint;
DEFINE ciclo              smallint;
DEFINE pagopropuestocal   money(14,2);
DEFINE capital            money(14,2);
DEFINE capital1           money(14,2);
DEFINE valorfinal         money(14,2);
DEFINE valorfinalAnt      money(14,2);
DEFINE interes            money(14,2);
DEFINE iva                money(14,2);
DEFINE vmonto_int_par     money(14,2);
DEFINE vinteres_total     money(14,2);
DEFINE wmonto_linea       money(14,2);
DEFINE vCapital          money(14,2);
DEFINE vInteres           money(14,2);
DEFINE vIva               money(14,2);
DEFINE vIvaMas            money(14,2);
DEFINE vMesPro            money(14,2);
DEFINE vValorFin          money(14,2);
DEFINE vabono_fijo        money(14,2);
DEFINE vProyecInt         money(14,2);
DEFINE vValorPre          MONEY(14,2);
DEFINE BanderaCas         CHAR(1);
 --  DEFINE cMontoMaxPlazoMax  MONEY(18,2);
 --  DEFINE cFechaMaxPlazoMax  MONEY(18,2);


LET nomeses1 = 0;
LET wtasaprop = 0;
LET wmesespro = 0;

LET cod_ret          = "000";
LET wtasa_interes    = 0;
LET wplazo_v         = 0;
LET vfecha_hoy       = "";
LET v_fecha_vencim   = "";
LET v_dias_cal_int   = '0';
LET vmonto_int_par   = 0;
LET sqlerr           = 0;
LET capital          = 0;
LET capital1         = 0;
LET interes          = 0;
LET iva              = 0;
LET valorfinal       = 0;
LET vfecha           = "";
LET proyeccion       = 0;
LET v_tasa_interes   = 0;
LET vAnio            = 0;
LET vMes             = 0;
LET vDia             = 0;
LET vcat             = '';
LET vTasaMora        = 0;
LET vCodTasaMora     = '';
LET vFactor          = '';
LET vSobreTasa       = 0;
LET vProyecInt       = 0;
LET valorfinalAnt    = 0;
LET BanderaCas       = '0';
--  LET cMontoMaxPlazoMax= 0;

--6011
LET iSqlErr 		= 0;
LET cCodRet 		= "000000";
LET dFechaCouta		= DATE(1);
LET mPeriodo		= 0;
LET mSdoInicial		= 0;
LET mMensualidad	= 0;
LET mIntereses		= 0;
LET mIvaInt			= 0;
LET mCapital		= 0;
LET mSdoFinal		= 0;
LET sDiasPeriodo	= 0;
LET dFechaAper		= DATE(1);

LET Contador 		= 0;
LET mTasaInt    	= 0;
LET mIVA			= 0;
LET mTasa			= 0;
LET dFechaActual	= DATE(1);
LET mTasaMensual	= 0;
LET mTasaIVA 		= 0;
LET dFechaInicial	= DATE(1);
LET dtDiaprimero   = DATE(1);
LET dFechaAnt		= DATE(1);
LET dFechaFinMes	= DATE(1);

LET mMontoAut 		= pMonto_Autorizado;
LET mPlazo  	 	= pPlazo;
LET mCapacidadPres	= pCapacidad_Pres;
LET mMontoMin		= 0;
LET mMontoMax		= 0;
LET sPlazoMin    	= 0;
LET sPlazoMax		= 0;

LET cEmpresa        = '001';
LET dLimites        = 0.05;
LET dDiferencia     = 0.20;
LET mMensualidadAux = 0;
LET mMontoAutAux		= 0;

LET iTpoPago       = 0;
LET cTipo             = '';
LET iDiaPago       = 0;
LET mPlazoAux       = 0;
LET sContinua       = 0;


BEGIN

	ON EXCEPTION  SET iSqlErr
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END  EXCEPTION

--  SET DEBUG FILE TO "/tmp/sp_Proyecta_creditos.out";
--  TRACE ON;
	--SET DEBUG FILE TO "/informix/jesus/sp_Proyecta_Prestamo.out";
	--TRACE ON;
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- ***********************************************************************
	-- 000001 	VALORES DE ENTRADA INCORRECTOS
	-- 000002	SOLO SE PERMITE RECIBIR 2 DE LOS 3 PARAMETROS SIGUIENTES pMonto_Autorizado, pPlazo, pCapacidad_Pres
	-- 000003	LA CANTIDAD DEL PAGO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES
	-- 000004	EL MONTO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000005	EL PLAZO DEL PRESTAMO SE ENCUENTRA FUERA DEL RANGO PERMITIDO
	-- 000006	EL NUMERO DE CREDITO NO EXISTE
	-- 000007	FALTA LA NUEVA FECHA DE INICIO DE LA PROYECCION
	-- 000008	EL PARAMETRO DE FECHA NO ES NECESARIO
	-- 000009	EL CALCULO DEL MONTO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000010	EL CALCULO DE LA CAPACIDAD NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000011	EL CALCULO DE EL PLAZO NO SE PUEDE REALIZAR CON LOS PARAMETROS ACTUALES
	-- 000012   NO ES POSIBLE REALIZAR UNA PROYECCIÓN CON LAS CONDICIONES INDICADAS. (Este código de retorno llega desde el sp_obtiene_aproximacion_creditos)
	-- 000013   LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO OBTENIDOS SON INCORRECTOS
	-- 000014   EL PARAMETRO DE FRCUENCIA DE PAGO RECIBIDO NO ES VALIDO
	-- 000015 Ocurrio un Error al obtener la fecha de pago del crédito para credinomina.
 -- ***********************************************************************
 -- ******************** ERRORES CONTROLADOS **************************
 -- *********************************** ************************************

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		--Se valida si la frecuencia recibida es correcta

IF pProducto = '6011' THEN



	IF pCapacidad_Pres < 10 THEN
      LET cCodret = '000003';
      RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
    END IF;

-- SE OBTIENE EL I.V.A
    SELECT valor
    INTO vIva
    FROM "informix".sd_param
    WHERE empresa = '001'
      AND cod_param='12';

-- SE LE INCREMENTA 1 AL I.V.A
   LET vIvaMas = vIva + 1;

    SELECT cod_tasa_mora,fact_sobret_mora,sobretasa_mora
    INTO   vCodTasaMora, vFactor, vSobreTasa
    FROM   bdicred:"informix".sd_definicion  --FMV 1-AGO-12 Se cambia a la tabla sd_definicion no afecta, Rees no usa mora
    WHERE  num_producto = pProducto;

    SELECT valor  INTO vTasaMora FROM bdinteg:"informix".si_fechavalor
    WHERE empresa = '001'
      AND tasa = vCodTasaMora
      AND fecha = (SELECT MAX(fecha)
                    FROM bdinteg:"informix".si_fechavalor
                   WHERE tasa = vCodTasaMora);

     IF   vFactor = '+' then
        LET vTasaMora = vTasaMora + vSobreTasa;
     ELIF vFactor = '-' then
        LET vTasaMora = vTasaMora - vSobreTasa;
     ELIF vFactor = '*' then
        LET vTasaMora = vTasaMora * vSobreTasa;
     ELIF vFactor = '/' then
        LET vTasaMora = vTasaMora / vSobreTasa;
     ELSE
        LET vTasaMora = vTasaMora;
     END IF;

       IF pMonto_Autorizado = 0  or pCapacidad_Pres = 0 or trim(pProducto) = "" THEN
          LET cCodret = "110";
          RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux ;
       END IF

       select cod_tasa_base,factor_sobretasa,sobretasa,plazo_max_cred,periodo_plazo
       into vcod_tasa_base,vfactor_sobretasa,vsobretasa,vmaxmeses,vtipoplazo
       from bdicred:"informix".sd_definicion where num_producto = pProducto;
       SELECT valor  INTO wtasa_interes FROM bdinteg:"informix".si_fechavalor
        WHERE tasa = vcod_tasa_base
          AND fecha = (SELECT MAX(fecha)
                         FROM bdinteg:"informix".si_fechavalor
                        WHERE tasa = vcod_tasa_base);
       LET v_tasa_interes = wtasa_interes * vsobretasa;
       IF vfactor_sobretasa = '+' then
          LET v_tasa_interes = wtasa_interes + vsobretasa;
       ELIF vfactor_sobretasa = '-' then
            LET v_tasa_interes = wtasa_interes - vsobretasa;
       ELIF vfactor_sobretasa = '*' then
            LET v_tasa_interes = wtasa_interes * vsobretasa;
       ELIF vfactor_sobretasa = '/' then
            LET v_tasa_interes = wtasa_interes / vsobretasa;
       END IF;

     SELECT valor
        INTO v_dias_cal_int
        FROM bdicred:"informix".sd_param       ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa = '001'
         AND cod_param = "24";




      LET proyeccion = proyeccion + 1;

      SELECT fecha_hoy,pri_dia_mes
        INTO vfecha_hoy,vfecha_primer
        FROM bdicred:"informix".sd_fechas
       WHERE empresa = '001';

      if day(vfecha_hoy) > 2 and day(vfecha_hoy) < 17 then
         LET vfecha_primer = Mdy(month(vfecha_hoy),02,year(vfecha_hoy));
         LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
      else
         LET vfecha_primer = Mdy(month(vfecha_hoy),17,year(vfecha_hoy)) ;
         IF day(vfecha_hoy) > 2 THEN
            LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
         END IF;
      end if
      LET wplazo_linea = vmaxmeses;
      LET vtipodia = "N";
      LET v_fecha_vencim = vfecha_primer + (wplazo_linea - 1) units month;
      LET wplazo_fin =1;
      LET wplazo_v = 0;
      if vtipoplazo = "C" then
         LET wplazo_fin = 4;
      else
         if vtipoplazo = "A" then
            LET wplazo_fin = 12;
         else
            if vtipoplazo = "S" then
               LET wplazo_fin = 6;
            end if
         end if
      end if
      LET wmonto_linea = pMonto_Autorizado;
      LET vtasa_periodo = (v_tasa_interes/12)/100;
      LET ciclo = 0;
      LET vinteres_total =0 ;
      LET wfecha_alta = vfecha_primer ;
      LET wcomisions = 0;
      LET wadicionals = 0;
      LET cuotafantasma = 0;
      LET wplazo_1 = vmaxmeses;
      LET nomeses2 = 0;
      if pCapacidad_Pres > 0 then
         LET nomeses1 = vmaxmeses;
         LET wplazo_1 = vmaxmeses;
      end if
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
   LET vtasa_diario = round((v_tasa_interes/v_dias_cal_int)/100,8);

  -- LET vtasa_diario = vtasa_diario * (1 + .15);

   LET vdia1 = (wfecha_alta - vfecha_hoy);
   LET vabono_fijo = pCapacidad_Pres;
   LET vtasa_periodo = vtasa_periodo * vIvaMas;
   LET wmonto_linea = wmonto_linea;
   LET ciclo = 0;
   LET wadicional = wmonto_linea;
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vValorPre = 0;

   LET vdia1 = vdia1;

  while ciclo < wplazo_linea
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_cambi1 - wfecha_cambio + 1;
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       ELSE
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       END IF;

   --    LET vmonto_int_par = round(wadicional * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wadicional * vtasa_diario, 2);
       LET vmonto_int_par = round(vmonto_int_par * vdia1, 2);
       LET wmonto_iva = round(vmonto_int_par  * vIva ,2);
    --   LET vmonto_int_par = vmonto_int_par - wmonto_iva ;
       LET capital = pCapacidad_Pres - vmonto_int_par - wmonto_iva ;

       IF capital < 0 THEN -- No Cubre el Interes
          LET valorfinalAnt=valorfinal;
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses+3));
            IF pCapacidad_Pres < ROUND(wmonto_linea*vtasa_periodo,2) THEN
               LET valorfinal=valorfinal+valorfinalAnt;
            END IF;
          LET wadicional = wmonto_linea - valorfinal;
           IF wadicional<0 THEN
              LET cod_ret = '002';
             RETURN cCodRet, ciclo, wfecha_alta, wmonto_linea, vmontopago, vmonto_int_par, wmonto_iva, capital, wmonto_linea, vdia1, wfecha_alta, ciclo;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET capital = 0;
          LET BanderaCas='2';
--          LET cod_ret = "002";
--          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
       END IF;
       LET capital = capital;
       LET vmonto_int_par = vmonto_int_par;
       LET wmonto_iva = wmonto_iva;
       LET pCapacidad_Pres = pCapacidad_Pres;

       --IF vmonto_int_par = 0 THEN
       IF vmonto_int_par < 0 THEN   --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       if capital > wadicional then
          LET capital = wadicional;
       end if
       IF ciclo <> 0 THEN
           LET wfecha_cambio = wfecha_cambi1;
           LET wfecha_cambi1 = wfecha_cambi1 + 1 UNITS MONTH;
           LET wadicional = wadicional - capital;
       END IF;

       IF valorfinal>0 AND ciclo>=vmaxmeses and ((BanderaCas= '1' ) or pCapacidad_Pres > ROUND(wmonto_linea*vtasa_periodo,2)) THEN --and wadicional<=0
          EXIT WHILE;
       END IF;

       IF wadicional > 0 and ciclo = vmaxmeses THEN
          LET valorfinalAnt=valorfinal;
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses));
            IF pCapacidad_Pres < ROUND(wmonto_linea*vtasa_periodo,2) and BanderaCas='2' THEN
               LET valorfinal=valorfinal+valorfinalAnt;
            END IF;
          LET wadicional = wmonto_linea - valorfinal;
          LET capital = 0;
           IF wadicional<0 THEN
              EXIT WHILE;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET BanderaCas= '1';
       END IF;



       if wadicional <= 0 then
          LET wadicional = 0;
          EXIT WHILE;
       end if;
   end while


   LET pMonto_Autorizado = pMonto_Autorizado;
   LET vfecha_hoyAnt = vfecha_hoy;
  -- LET valorfinal = pMonto_Autorizado - wmonto_linea;
   LET valorfinal = valorfinal;
   LET wmonto_linea = wmonto_linea-valorfinal;
   LET wplazo_linea = vmaxmeses;
   LET ciclo = 0;
   LET vabono_fijo = pCapacidad_Pres;
   LET BanderaCas='1';
   LET valorfinal = pMonto_Autorizado -wmonto_linea;
   while ciclo < wplazo_linea and wmonto_linea <> 0
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          --LET vdia1 = wfecha_alta - vfecha_hoy + 1;
          LET vdia1 = wfecha_alta - vfecha_hoy;
       ELSE
          LET vdia1 = wfecha_alta - vfecha_hoy;
       END IF;
       --LET vmonto_int_par = round(wmonto_linea * vtasa_diario * vdia1,2);

       LET vmonto_int_par = round(wmonto_linea * vtasa_diario ,2);
       LET vmonto_int_par = round(vmonto_int_par *  vdia1,2);
       LET wmonto_iva = round(vmonto_int_par * vIva,2);

       --LET vmonto_int_par = vmonto_int_par - wmonto_iva ;
       IF vmonto_int_par < 0 THEN
       --IF vmonto_int_par = 0 THEN     --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       LET capital = pCapacidad_Pres - vmonto_int_par - wmonto_iva ;
       if capital > wmonto_linea then
          LET capital = wmonto_linea;
       end if
        LET vmontopago = capital + vmonto_int_par + wmonto_iva;

		LET  Contador = Contador+1;
		IF Contador > pSolicitudes THEN
	           RETURN cCodRet, ciclo, wfecha_alta, valorfinal, vmontopago, vmonto_int_par, wmonto_iva, capital, wmonto_linea, vdia1, wfecha_alta, ciclo WITH RESUME;
     	END IF;

      LET vfecha_hoy = wfecha_alta;
      LET wfecha_alta = wfecha_alta + 1 UNITS MONTH;
	let wmonto_linea = wmonto_linea - capital;


      if wmonto_linea <= 0 then
          LET wmonto_linea = 0;
      end if;
  end while
ELSE

	SELECT tipo_pago
	INTO cTipo
	FROM  bdicred:sd_cattipopago
	WHERE valor = pFrecuencia;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000014';
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;
	-- SE OBTIENEN LOS PARAMETROS PARA VALIDAR EL MONTO Y EL PLAZO DEL CREDITO

	SELECT monto_min_cred, monto_max_cred, plazo_min_cred, plazo_max_cred
	  INTO mMontoMin, mMontoMax, sPlazoMin, sPlazoMax
	  FROM bdicred:"informix".sd_definicion
     WHERE num_producto = pProducto
       AND empresa      = cEmpresa;

       IF NVL(mMontoMin,0) = 0 OR NVL(mMontoMax,0) = 0 OR NVL(sPlazoMin,0)= 0 OR NVL(sPlazoMax,0) = 0 THEN
           LET cCodRet = '000013';
           RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
       END IF;

	-- SE VERIFICA QUE LOS VALORES DE ENTRADA SEAN CORRECTOS
    IF pTipoRetorno <> '2' THEN
        IF (NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0) OR NVL(pProducto,"") = "" OR NVL(pSucursal,"") = "" THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mCapacidadPres,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mPlazo,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mCapacidadPres,0) = 0 AND NVL(mMontoAut,0) = 0 THEN
            LET  cCodRet  = "000001";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0) THEN
            LET  cCodRet  = "000002";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF (NVL(mPlazo,0) > 0 AND NVL(mPlazo,0) < CASE WHEN pFrecuencia = 2 THEN sPlazoMin * 2 ELSE sPlazoMin END) OR (NVL(mPlazo,0) > CASE WHEN pFrecuencia = 2 THEN sPlazoMax * 2 ELSE sPlazoMax END) THEN
            LET cCodRet = "000005";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        ELIF NVL(mMontoAut,0) >0 AND (NVL(mMontoAut,0) < mMontoMin OR NVL(mMontoAut,0) > mMontoMax) THEN
            LET cCodRet = "000004";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    ELSE
        IF (NVL(mPlazo,0) <> 0 AND NVL(mCapacidadPres,0) <> 0 AND NVL(mMontoAut,0) <> 0)  THEN
             LET  cCodRet  = "000001";
             RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	IF (pTipoRetorno = 0 AND NVL(pFecha,"") <> "") OR (pTipoRetorno = 1 AND NVL(pFecha,"") <> "") THEN
		LET  cCodRet  = "000008";
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	END IF;

	LET pSucursal =pSucursal;
		-- SE OBTIENE EL IVA DE LA SUCURSAL
		SELECT iva
		  INTO mIVA
		  FROM bdinteg:"informix".si_sucursales
		 WHERE sucursal = pSucursal
		   AND empresa = "001";

		IF mIVA = 0 THEN
			LET mIVA = 0.16;
		END IF

		-- SE OBTIENE LA TASA ANUAL
		SELECT c.valor
		INTO mTasa
		FROM bdicred:"informix".sd_definicion a
		INNER JOIN bdinteg:"informix".si_fechavalor c ON (c.tasa = a.cod_tasa_base
														AND c.fecha = (SELECT MAX(r.fecha)
																	FROM bdinteg:"informix".si_fechavalor r
																	WHERE r.tasa = a.cod_tasa_base
																	AND r.fecha = r.fecha
																	AND r.empresa = a.empresa)
														AND c.empresa = a.empresa)
		WHERE a.num_producto = pProducto
		AND a.empresa      = cEmpresa;

	LET mPlazo = mPlazo;
	LET pFrecuencia = pFrecuencia;
	LET sPlazoMax = sPlazoMax;

	IF NVL(mPlazo,0) = 0 THEN
		LET mPlazo = case when pFrecuencia = 2 then sPlazoMax * 2 else sPlazoMax end;
	END IF;

	IF pProducto = '6400' AND  pFrecuencia = 1  THEN ---Frecuencia Mensual
		LET iTpoPago = 1;
		LET mPlazo = mPlazo * 1;
		LET sDiasPeriodo = 30;
	ELIF pProducto = '6400' AND  pFrecuencia = 2 THEN	---Frecuencia Quincenal
		LET iTpoPago = 2;
--		LET mPlazo = mPlazo * 2;
		LET sDiasPeriodo = 15;
	ELSE ---Frecuencia Mensual
		LET iTpoPago = 0;
		LET mPlazo = mPlazo * 1;
		LET sDiasPeriodo = 30;
	END IF;

		-- SE OBTIENE LA TASA ANUAL CON IVA
		LET mTasaIVA = (mTasa * (1 + mIVA))/100;  ---
		LET mTasaInt = mTasa/100;                 ---

		-- SE CALCULA LA TASA DE INTERES MENSUAL
		LET mTasaMensual = mTasaInt/mPlazo;
		LET mTasaMensualIVA = mTasaIVA/mPlazo;


	IF mCapacidadPres > 0 AND mMontoAut > 0 THEN
		-- SI ESTA FORMULA REGRESA UN VALOR NEGATIVO SIGNIFICA QUE EL MONTO MENSUAL NO ES SUFICIENTE PARA PAGAR LOS INTERESES QUE SE GENERAN
		IF (((mMontoAut*(mTasaMensualIVA)/mCapacidadPres)-1)/-1) < 0 THEN
			LET cCodRet = "000003";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	-- SI EL PARAMETRO QUE DEFINE EL RETORNO TIENE EL VALOR DE 2 SE OBTIENE LA FECHA DE APERTURA DEL CREDITO PARA REIMPRESION
	IF pTipoRetorno = 2 THEN
		LET dFechaActual = dFechaAper;
	ELIF pTipoRetorno = 3 OR pTipoRetorno = 4 THEN -- DIFERENTE FECHA PARA INICIO DE PROYECCION
		IF NVL(pFecha,"") = "" THEN
			LET  cCodRet  = "000007";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		ELSE
			LET dFechaActual = pFecha;
		END IF;
	ELSE
		-- SE OBTIENE LA FECHA
		SELECT fecha_hoy
          INTO dFechaActual
          FROM bdicred:"informix".sd_fechas;
	END IF;

	LET dFechaCouta = dFechaActual;
--JOM	LET mPlazoAux=mPlazo/pFrecuencia;
	LET mPlazoAux=mPlazo;
	IF pTipoRetorno <> 2 THEN
		-- SI TENEMOS EL PLAZO Y EL PAGO MENSUAL PERO NOS FALTA EL MONTO AUTORIZADO
		IF NVL(mPlazo,0) > 0 AND NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) = 0 THEN
			CALL "informix".sp_obtiene_aproximacion_creditos(0,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mMontoAut;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000009";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
		-- SI TENEMOS EL PLAZO Y EL MONTO AUTORIZADO PERO NOS FALTA EL PAGO MENSUAL
		ELIF NVL(mPlazo,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(mCapacidadPres,0) = 0 THEN
			CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazo,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mCapacidadPres;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000010";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELIF cCodRet = "000012" THEN
							LET mPlazoAux =mPlazo;
						WHILE  sContinua = 0
							LET mPlazoAux = mPlazoAux - pFrecuencia;
							CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazoAux,0,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mCapacidadPres;
							IF cCodRet <> "000000" THEN
								IF cCodRet < 0  THEN
									LET  cCodRet  = "000011";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								ELIF cCodRet = "000012" THEN
									LET sContinua =0;
								ELSE
									LET  cCodRet  = "000010";
									RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
								END IF;
							ELSE
								LET sContinua =1;
								LET mPlazo = mPlazoAux;
--JOM								LET mPlazoAux=mPlazo/pFrecuencia;
							END IF;

						END WHILE;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF

		-- SI TENEMOS EL MONTO AUTORIZADO Y EL PAGO MENSUAL PERO DESCONOCEMOS EL PLAZO
		ELIF NVL(mCapacidadPres,0) > 0 AND NVL(mMontoAut,0) > 0 AND NVL(pPlazo,0) = 0 THEN

			CALL "informix".sp_obtiene_aproximacion_creditos(mMontoAut,mPlazo,mCapacidadPres,mTasaInt,mTasaIVA,dFechaCouta,mIVA,dLimites,dDiferencia,iTpoPago,pDiaPago) RETURNING cCodRet, mPlazo;
			IF cCodRet <> "000000" THEN
					IF cCodRet < 0  THEN
						LET  cCodRet  = "000011";
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					ELSE
						RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
					END IF;
			END IF;
--JOM			LET mPlazoAux=mPlazo/pFrecuencia;
            LET mPlazoAux=mPlazo;
		END IF;
	END IF;

	-- SE VALIDA QUE EL MONTO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
    IF pTipoRetorno <> 0 THEN  -- Para el resumen no es necesario debido a que se realiza desde el procedimiento de calificación de la solicitud.
        IF mMontoAut < mMontoMin OR mMontoAut > mMontoMax THEN
            LET  cCodRet  = "000004";
            RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
        END IF;
    END IF;

	-- SE VALIDA QUE EL PLAZO DEL PRESTAMO SE ENCUENTRE DENTRO DEL RANGO PERMITIDO
	IF pFrecuencia = 0 THEN
		IF mPlazo < sPlazoMin OR mPlazo > sPlazoMax THEN
			LET  cCodRet  = "000005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	ELSE
		IF (mPlazo/pFrecuencia) < sPlazoMin OR (mPlazo/pFrecuencia) > sPlazoMax THEN
			LET  cCodRet  = "000005";
			RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
		END IF;
	END IF;

	LET mSdoInicial = mMontoAut;
	LET mMensualidad = ROUND(mCapacidadPres,0);

	-- SI EL TIPO DE RETORNO ES 0 REGRESAMOS SOLO UN REGISTRO
	IF pTipoRetorno = 0 OR pTipoRetorno = 4 THEN
		LET mPeriodo = mPlazo;
		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
	ELSE -- SI EL TIPO DE RETORNO ES 1 REGRESAMOS TODO EL DETALLE DEL COMPORTAMIENTO DEL PRESTAMO
		-- EL CICLO TENDRA EL NUMERO DE ITERACIONES IGUAL AL PLAZO DE PAGOS
		LET dFechaInicial = dFechaCouta;
		LET dFechaAnt = dFechaCouta;

		FOR Contador = 1 TO mPlazo STEP 1

			-- SE OBTIENE EL SALDO INICIAL DEL PERIODO, SI EL SALDO FINAL ES CERO QUIERE DECIR QUE ES EL PRIMER PERIODO Y EL SALDO INICIAL ES IGUAL AL MONTO APROBADO
			IF mSdoFinal > 0 THEN
				LET mSdoInicial = mSdoFinal;
			END IF;

			IF mSdoFinal <= 0 AND Contador > 1 THEN
				EXIT FOR;
			END IF;

			-- SE ASIGNA EL PERIODO
			LET mPeriodo = Contador;

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************
 			IF pProducto = '6400' THEN  --Periodo de pago  credinomina
					--se obtiene la fecha de la proxima cuota.
						EXECUTE PROCEDURE "informix".sp_obtienefechapago_creditos('001',dFechaCouta,pFrecuencia,pDiaPago)
							INTO cCodRet,dFechaCouta,iDiaPago;

							IF cCodRet::INTEGER <> 0  THEN
								LET cCodRet    = "000015";	--Ocurrio un Error al obtener la fecha de pago del crédito para credinomina.
								RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
							END IF;

					   IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
							LET dFechaCouta = dFechaCouta + 1;
						END IF;
						IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
							LET dFechaAnt = dFechaAnt + 1;
						END IF;
						LET sDiasPeriodo = dFechaCouta - dFechaAnt;	--se obtienen los dias del periodo
						LET dFechaAnt = dFechaCouta;
			ELSE   ---Periodo de pago Mensual prestamo

				CALL bdicred:"informix".monthadd(dFechaInicial,Contador) RETURNING dFechaCouta;
				CALL bdicred:"informix".monthadd(dFechaInicial,Contador-1) RETURNING dFechaAnt;

				IF (MONTH(dFechaCouta) = 1 AND DAY(dFechaCouta) = 1) OR (MONTH(dFechaCouta) = 12 AND DAY(dFechaCouta) = 25) THEN
					LET dFechaCouta = dFechaCouta + 1;
				END IF;

				IF (MONTH(dFechaAnt) = 1 AND DAY(dFechaAnt) = 1) OR (MONTH(dFechaAnt) = 12 AND DAY(dFechaAnt) = 25) THEN
					LET dFechaAnt = dFechaAnt + 1;
				END IF;

				LET sDiasPeriodo = dFechaCouta - dFechaAnt;
			END IF;

			-- ********************************************************************************************************************
			-- ************************** SE OBTIENE LA SIGUIENTE FECHA DE CUOTA Y LOS DIAS DEL PERIODO **********************
			--*********************************************************************************************************************

			-- SE OBTIENE LA FECHA POR PLAZO
			--LET dFechaCouta = bdicred:monthadd(dFechaCouta,Contador);

			--SE CALCULAN LOS INTERESES
			LET mIntereses = mSdoInicial * (mTasaInt/360) * sDiasPeriodo;

			-- SE CALCULA EL IVA DE LOS INTERESES
			LET mIvaInt = ROUND(mIntereses * mIVA,2);
			--LET mMontoAutAux = mMontoAut + mIntereses + mIvaInt;

			IF mMontoAut < mMensualidad THEN
				LET mMensualidad = mMontoAut + mIntereses + mIvaInt;
				LET mCapital = mMontoAut;
			ELSE
					LET mCapital = mMensualidad - (mIntereses + mIvaInt);
					LET mIntereses = mIntereses ;
					LET mIvaInt  = mIvaInt ;
					LET sDiasPeriodo= sDiasPeriodo;
			END IF;

			IF NVL(mCapital,0) < 0 AND Contador = 1  THEN
				LET cCodRet = '000012';
				RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux;
			END IF;

			-- SE CALCULA EL SALDO FINAL
			LET mSdoFinal = mSdoInicial - mCapital;
			LET mMontoAut = mSdoInicial - mCapital;

			-- SE UTILIZA PARA PODER PAGINAR
	        IF Contador <= pSolicitudes THEN
	            CONTINUE FOR;
	        END IF;

		RETURN cCodRet, mPeriodo, dFechaCouta, mSdoInicial, mMensualidad, mIntereses, mIvaInt, mCapital, mSdoFinal, sDiasPeriodo, dFechaAper, mPlazoAux WITH RESUME;
		END FOR;
	END IF;
END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: Simula el comportamiento de un prestamo durante el plazo seleccionado',
'Fecha: 2009/09/09',
'Version: 20090909.1750';

CREATE PROCEDURE "informix".sp_carteral_ppyr_pba()
RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--28-12-2011
--Proceso para la generación de archivo cartera total prestamo personal y reestructura

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechacorte date;
DEFINE Vult_dia_mes DATE;
--Structura
DEFINE Vcreditoexterno          char(20);
DEFINE Vproducto     		char(4);
DEFINE Vnum_credito         char(20);
DEFINE  Vnumcte				char(20);
DEFINE Vnum_tarjeta         char(20);
DEFINE Vnum_sucursal		char(4);
DEFINE  Vnom_suucursal		char(40);
DEFINE  Vingreso_mensual    money;
DEFINE  Vmonto_apertura      decimal(18,2); 
DEFINE  Vfecha_apertura      date;

DEFINE  Vplazo smallint;
DEFINE Vestatus char (2);
DEFINE  Vsaldo_insoluto	decimal(18,2);
DEFINE  Vcapital_vigente	decimal(18,2);
DEFINE Vcapital_transitorio	decimal(18,2);
DEFINE Vsaldo_vencido_exigible	decimal(18,2);
DEFINE Vsaldo_vencido_no_exigible	decimal(18,2);
DEFINE Vsaldo_actual decimal(18,2); 
DEFINE  Vsaldo_cierre decimal(18,2); 
DEFINE Vmes_vencido decimal(18,2); 
DEFINE Vtipo_mov cHAR (1);
DEFINE Vfecha_mov DATE;

DEFINE Vsexo char (1);
DEFINE Vfecha_nac date;
DEFINE Vnombre1 char(26);
DEFINE Vnombre2 char(26);
DEFINE Vapellido_p char(26);
DEFINE Vapellido_m char(26);
DEFINE Vmail char (60);
DEFINE Vdir_calle char(30);
DEFINE Vdir_numero char(20);
DEFINE Vdir_colonia char(32);
DEFINE Vcp char(5);

DEFINE Vdir_municipio char(60);
DEFINE Vnum_estado smallint;
DEFINE Vdir_estado char(30);
DEFINE Vnum_cd_coppel smallint;
DEFINE Vcd_coppel char(32);
DEFINE Vnum_cd_banco smallint;
DEFINE  Vcd_banco char(32);
DEFINE Vtel1 char(13);
DEFINE  Vtel2 char(13);
DEFINE Vtel3 char(13);
DEFINE Vext char(5);

DEFINE Vref_coppel char(20);
DEFINE Vficiencia decimal(5,2);
DEFINE Vmeses_historia smallint;
DEFINE Vhit char(6);
DEFINE Vsecc1 char (4);
DEFINE Vsecc2 decimal(5,2);
DEFINE sPaso integer;
DEFINE vlNumInsert SMALLINT;
DEFINE Vpri_dia_mes DATE;

	  --variables
DEFINE Vnumcreditortc       char(20);
DEFINE VcreditoConsulta       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumtarjetatdc       char(20);
--DEFINE Vnumcte        		char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vnumciudad			char(4);
DEFINE Vsaldoactual      	decimal(18,2);
DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE Vtasainteres			decimal(18,2);
DEFINE Vfechalimitedepago	date;
DEFINE Vfechaultmov			date;
DEFINE Vtipoultimomov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
--define sPaso				integer;
--define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
DEFINE cMotivo	char(5);

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_Ret2                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2060';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte = date(1);
LET Vult_dia_mes = DATE(1);
LET Vpri_dia_mes = DATE(1);

-----VARIABLES
LET Vcreditoexterno = '';
LET Vproducto     		='';
LET Vnum_credito         = '';
LET VcreditoConsulta         = '';
LET  Vnumcte				='';
LET Vnum_tarjeta         ='';
LET Vnum_sucursal		='';
LET  Vnom_suucursal		='';
LET  Vingreso_mensual    = 0;
LET  Vmonto_apertura      = 0;
LET  Vfecha_apertura     = date(1);

LET  Vplazo = 0;
LET Vestatus ='';
LET  Vsaldo_insoluto	= 0;
LET  Vcapital_vigente	= 0;
LET Vcapital_transitorio	= 0;
LET Vsaldo_vencido_exigible	= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual = 0;
LET  Vsaldo_cierre = 0;
LET Vmes_vencido = 0;
LET Vtipo_mov ='';
LET Vfecha_mov = DATE(1);

LET Vsexo ='';
LET Vfecha_nac = date(1);
LET Vnombre1 ='';
LET Vnombre2 ='';
LET Vapellido_p ='';
LET Vapellido_m ='';
LET Vmail ='';
LET Vdir_calle ='';
LET Vdir_numero ='';
LET Vdir_colonia ='';
LET Vcp = '';

LET Vdir_municipio ='';
LET Vnum_estado = 0;
LET Vdir_estado ='';
LET Vnum_cd_coppel= 0;
LET Vcd_coppel ='';
LET Vnum_cd_banco = 0;
LET  Vcd_banco ='';
LET Vtel1 ='';
LET  Vtel2 ='';
LET Vtel3 ='';
LET Vext ='';

LET Vref_coppel ='';
LET Vficiencia = 0;
LET Vmeses_historia = 0;
LET Vhit ='';
LET Vsecc1 = '';
LET Vsecc2 = 0;
LET  sPaso = 0;
LET vlNumInsert = 0;

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
LET	Vnumtarjetatdc			= '';
--LET	Vnumcte           	    = '';
LET	Vnumsucursal			= 0;
LET	Vnumciudad	            = '';
LET Vsaldoactual			= 0;
LET Vinteres                = 0;
LET Vsaldovencido           = 0;
LET Vinteresvencido         = 0;
LET Vabonobase              = 0;
LET Vabonosvencidos         = 0;
LET vinteres_moratorio		= 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET Vtasainteres   		    = 0;
LET Vfechalimitedepago      = DATE(1);
LET	Vfechaultmov            = DATE(1);
LET Vtipoultimomov          = '';
LET Vfechacorte             = DATE(1);
let cempresa 				= '001';
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo = '';
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret;
	END EXCEPTION;
--SET DEBUG FILE TO "CATERA_PPyR.out";
--TRACE ON;

--SET DEBUG FILE TO "/INFORMIXDUMP/CATERA_PPyR.out";
--TRACE ON;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_Ret;
	END IF;
	
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_Ret;
	END IF;
	
	-------------------------------GENERA TABLA-------------------------------------
		
	--DROP TABLE sd_cartera_total_PPyR;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_carteral_ppyr';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_carteral_ppyr;
            END IF;

					
    create table "informix".sd_carteral_ppyr
    ( 
	producto     		char(4),
    num_credito         char(20),
	numcte				char(20),
	num_tarjeta         char(20),
	num_sucursal		char(4),
	nom_suucursal		char(40),
	ingreso_mensual     money,
	monto_apertura      decimal(18,2), 
	fecha_apertura      date default '01/01/1900',
	 
	plazo smallint,
	estatus char (2),
	saldo_insoluto	decimal(18,2),
	capital_vigente	decimal(18,2),
	capital_transitorio	decimal(18,2),
	saldo_vencido_exigible	decimal(18,2),
	saldo_vencido_no_exigible	decimal(18,2),
	saldo_actual decimal(18,2), 
	saldo_cierre decimal(18,2), 
	--mes_vencido decimal(18,2), 
	mes_vencido integer,
	tipo_mov cHAR (1),
	fecha_mov DATE,
	 
	sexo char (1),
	fecha_nac date,
	nombre1 char(26),
	Nombre2 char(26),
	apellido_p char(26),
	apellido_m char(26),
	mail char (60),
	dir_calle char(30),
	dir_numero char(20),
	dir_colonia char(32),
	cp char(5),
	 
	dir_municipio char(60),
	num_estado smallint,
	dir_estado char(30),
	num_cd_coppel smallint,
	cd_coppel char(32),
	num_cd_banco smallint,
	cd_banco char(32),
	tel1 char(13),
	tel2 char(13),
	tel3 char(13),
	ext char(5),
	 
	ref_coppel char(20),
	eficiencia decimal(5,2),
	meses_historia smallint,
	hit char(6),
	secc1 decimal(5,2),
	secc2 decimal(5,2),
	motivo CHAR(5));
	
	
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_pagosydisposicionescrd_cartera';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_pagosydisposicionescrd_cartera;
            END IF;


    create table sd_pagosydisposicionescrd_cartera
    (
	num_producto	char(4),
    numcreditortc	char(20) default '0',
    numcreditotdc	char(20) default '0',
    numcuentartc	char(20) default '0',
	numtarjetatdc   char(20) default '0',
	numcte          char(20),
	numsucursal     char(4),
	numciudad		char(4),
    fechareestructura   date,
    saldoactual     decimal(18,2),
    interes       	decimal(18,2),
    saldovencido    decimal(18,2),
    interesvencido  decimal(18,2),
	interes_moratorio	decimal(18,2),
    abonobase           decimal(18,2),
    abonosvencidos      smallint,
    estadocredito       char(2),
    plazortc    		smallint,
    tasainteres    		decimal(18,2),
    fechalimitedepago 	date,
	fechaultmov 		date,
    tipoultimomov		char(2),
    fechacorte          date);
	
	select max(fecha)
	into pfechacorte
	from bdicred:sd_maecredcontcrd
	where num_producto in ( '6011','6300');
	
	select  empresa, num_credito, fecha_apertura, numcte , num_producto, credito_externo, sucursal, plazo, status_cred, tasa_interes, fecha
	from bdicred:sd_maecredcontcrd crd 
	where fecha =pfechacorte and empresa = '001'
	  and num_producto in ('6300','6011' ) and nvl(campo_trab3,'') <> 'BAJA'
	into temp CreditosCrd with no log;
	create index indx_creditos on CreditosCrd (num_credito );
			 update statistics medium for table CreditosCrd;
			 
	
	select  crd.num_credito ,fecha_mov, codigo_fun, codigo_ref, monto
			from bdicred:sd_movhiscrd mov , CreditosCrd crd
			where 
              crd.num_credito = mov.num_credito
             and crd.fecha_apertura>=mov.fecha_mov 
              and ((codigo_fun = '338' and codigo_ref = 21 )
            or (codigo_fun = '338' and codigo_ref = 22 )
            or (codigo_fun   in ('020','021','022','023','024','025','027','028','222','225') and  codigo_ref = 1 )
            or (codigo_fun  = '001' and codigo_ref  in (3,4) )
            or ( codigo_fun  in ('001','002')  and codigo_ref in (1,2,66) ) )
			and reversado = 'N'             
			 into temp MovtosCred with no log;
			 create index indx_mov on MovtosCred (num_credito );
			 update statistics medium for table MovtosCred;
			 
	
		select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.num_credito=scor.num_solicitud
		  and crd.num_producto ='6300'
		  union 
		  select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.credito_externo=scor.num_solicitud
		  and crd.num_producto ='6011'
		into temp scorfin with no log;
		create index indx_scor on scorfin (num_solicitud );
			 update statistics medium for table scorfin;
			 

		
	--------------------INSERTAR EN TABLA-----------------------------------
	
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;


	FOREACH 
		select a.num_producto,a.num_credito,NVL(a.credito_externo,'0'),a.numcte,a.sucursal,suc.nombre,b.monto_otorgado ,NVL(a.fecha_apertura,DATE(1))
			, a.plazo, a.status_cred,b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci, 
			round(b.mto_fin_ven_trasp),fecha_ult_pago,nvl(a.tasa_interes,0) ,NVL(c.prox_fecha_pago,'01/01/1900'),nvl(suc.ciudad,0),
			(CASE WHEN a.status_cred IN ('AA','BA') THEN (sdo_intereses + sdo_no_exig) ELSE 0 END) ,
            (CASE WHEN a.status_cred NOT IN ('AA','BA') THEN (sdo_intereses + sdo_no_exig + int_tra_no_exig) ELSE 0 END )
		into Vproducto ,  Vnum_credito,Vcreditoexterno  , Vnumcte,Vnum_sucursal,vnom_suucursal,vmonto_apertura,vfecha_apertura
			,vplazo,vestatus, vsaldo_insoluto,vcapital_vigente,vcapital_transitorio,vsaldo_vencido_exigible,vsaldo_vencido_no_exigible,
			vmes_vencido,Vfechaultmov,Vtasainteres,Vfechalimitedepago,Vnumciudad,
			Vinteres   ,Vinteresvencido
			
		from CreditosCrd a -- bdicred:sd_maecredcontcrd a
			inner join bdicred:sd_maesdoscontcrd b on (a.fecha = b.fecha and a.empresa = b.empresa and a.num_credito = b.num_credito)		
			left join bdinteg:si_sucursales suc on (suc.empresa = a.empresa and suc.sucursal = a.sucursal)					
			inner join bdicred:sd_maecredanexocrd  c on (c.num_credito = a.num_credito)
		 --where a.empresa ='001' and a.num_producto in ( '6011','6300')
		--and a.fecha = pfechacorte
		
		SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
		INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
		FROM  bdinteg:si_cliente cte 
		INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
		WHERE cte.numcte = Vnumcte;
		
		SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,cd.nombre as dir_mun,
		es.estado as num_estado,es.nombre as dir_estado,cd.ciudad_coppel as cd_coppel,cd.nombre ,
		zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
		INTO vdir_calle,vdir_numero,vdir_colonia,vcp
		,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
		FROM bdinteg:si_direcciones_actual dir  
		inner join bdinteg:si_catcalles ca on ( ca.numerocalle = dir.numerocalle)
		inner join bdinteg:si_catzonas zo on ( zo.numerociudad = dir.numerociudad   and zo.numerocolonia = dir.numerocolonia)
		inner join bdinteg:si_ciudades cd  on (cd.estado  = dir.estado  and  cd.ciudad = dir.ciudad)
		inner join bdinteg:si_estados es on (es.estado = dir.estado)
		WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;
		
		SELECT nvl(cta.num_cta,0) 
		INTO Vnum_tarjeta 
		FROM bdicred:sd_ctascarg cta
		WHERE empresa ='001' 
		AND cta.num_credito = Vnum_credito;
		
		LET Vnumcuentartc = Vnum_tarjeta;	
		
		IF (Vproducto = '6011') THEN 				
			SELECT nvl(tar.num_tarjeta,0)
				INTO Vnumtarjetatdc 
			FROM bdicred:sd_tarjeta tar 
			WHERE tar.empresa ='001'
			and tar.num_credito = Vcreditoexterno
			and tar.tipo_tarjeta ='T' 
			and tar.secuencia = (select max(tar2.secuencia)
								from bdicred:sd_tarjeta tar2
								where tar2.empresa = '001' 
								and tar2.num_credito = Vcreditoexterno
								and tar2.tipo_tarjeta ='T' );						
		END IF;
		
		SELECT LIMIT 1 nvl(sc01,'')
			INTO  Vsecc1
		FROM bdiburo:br_sc  br 
		WHERE  br.num_cliente = Vnumcte;			
		
		select limit 1 correo_elec
		INTO Vmail
		from bdinteg:si_correos
		where numcte = Vnumcte
		AND status_correo = 'A';
		
		select LIMIT 1 a.telefono, b.telefono ,d.telefono,d.extension
			into Vtel1 , Vtel2 ,Vtel3 ,Vext
		from bdinteg:si_telefonos_actual a
		left outer join bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
		left outer join bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
		where a.empresa = '001' and a.numcte = vnumcte 
		and a.tipo_tel = 1
		AND a.status_tel = 'A' 
		and a.cofetel = 'V' ;	
			
		--IF (Vproducto = '6300') then		
			LET VcreditoConsulta =Vnum_credito;
		--ELSE
			--LET VcreditoConsulta =Vcreditoexterno;  
		--END IF;
				
		SELECT limit 1 nvl(sum(valor),0) into Vsecc2
		FROM bdisolic:ss_detalle_scoring 
		where empresa = '001'
		and num_solicitud = VcreditoConsulta;

		select limit 1  nvl(ingreso_mensual,0) ,nvl(situacion_pago,0)  ,nvl(meses_historia,0),evalua_cc				
		into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from scorfin
		where num_solicitud = VcreditoConsulta;
		
		if (vestatus in ('AA')) then
			let Vsaldo_cierre =  Vcapital_vigente + vsaldo_vencido_exigible;	
		end if;
		if (vestatus in ('BA')) then
			let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;	
		end if;
		if (vestatus in  ('BT','VP')) then
			let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
		end if;
		if (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		END IF;
			
		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
		if exists(select num_credito 
			from MovtosCred 
			where  num_credito = Vnum_credito
			and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028','222','225')
			and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
			) then 	

			LET Vtipoultimomov = 'P';
			
			 IF  (Vproducto = '6011') THEN --para la segunda parte...
				/*select limit 1 nvl(monto,0) into vmontor1
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 21 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 21 );
				*/
			
				/*select limit 1 nvl(monto,0) into vmontor2
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 22 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 22 ); 
				*/
				
				--let Vinteres = vmontor1 + vmontor2;
				if   Vinteres is null then let Vinteres = 0; end if;			
			 
			 END IF;
			
		elif exists(select num_credito 
			from MovtosCred
			where 
			 num_credito = Vnum_credito
			and codigo_ref  in (3,4) and codigo_fun  = '001'
			and fecha_mov = (select max(fecha_mov)from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito)
			) then
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito;
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'L';
				LET Vfechaultmov = vfecha_apertura;
			ELSE
				LET Vtipoultimomov = 'A';
			END IF;		
			
		elif exists(select num_credito 
			from MovtosCred 
			where 
			 num_credito = Vnumcreditortc
			and codigo_ref in (1,2,66) and codigo_fun  in ('001','002') 
			and fecha_mov = (select max(fecha_mov)from MovtosCred where  num_credito = Vnumcreditortc and   codigo_ref in (1,2,66) and codigo_fun in ('001','002') )
			) then		
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where   num_credito = Vnumcreditortc and  codigo_ref in (1,2,66) and codigo_fun in ('001','002');
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'A';				
			ELSE
				LET Vtipoultimomov = 'D';
			END IF;								
		end if;
			
		LET vlNumInsert = vlNumInsert + 1;
		IF vlNumInsert = 5000 then 
		   LET vlNumInsert = 1;
		  -- update statistics medium for table bdicred:"informix".sd_carteral_ppyr;
		END IF;

		select NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
		into Vsaldovencido
		from sd_maesdoscrd 
		where empresa = '001'
		and num_credito = Vnum_credito;

		select nvl(capital_mto_cuota,0)
		into Vabonobase
		from bdicred:sd_amortiza_creditocrd 
		where num_credito = Vnum_credito
		and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnum_credito);

		if (Vabonobase = '') then 
			LET Vabonobase = 0; 
		end if;

		SELECT --nvl(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
			   nvl(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
		INTO --Vinteresvencido,
		  vinteres_moratorio
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = '001'
		AND num_credito = Vnum_credito
		AND capital_status IN ('2','7')
		AND fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);

		--obtener causa solicitud
			select limit 1 nvl(a.causa_solicitud,'') into cMotivo
			from bdisolic:ss_autorizacion a
			where a.empresa = cEmpresa
			and a.num_solicitud = vNum_Credito
			and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = vNum_Credito and status_solicitud = 'AT')
			and a.status_solicitud = 'AT';
			IF Vcreditoexterno not in ('0','') THEN
				select limit 1 nvl(a.causa_solicitud,'') into cMotivo
				from bdisolic:ss_autorizacion a
				where a.empresa = cEmpresa
				and a.num_solicitud = Vcreditoexterno
				and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = Vcreditoexterno and status_solicitud = 'AT')
				and a.status_solicitud = 'AT';
			END IF;	
		
		INSERT INTO sd_carteral_ppyr 
			(producto , num_credito ,numcte	,num_tarjeta ,num_sucursal	,nom_suucursal	,ingreso_mensual ,
			monto_apertura  ,fecha_apertura  ,plazo ,estatus ,
			saldo_insoluto	,capital_vigente,	capital_transitorio	,saldo_vencido_exigible	,saldo_vencido_no_exigible	,saldo_actual , 
			saldo_cierre ,mes_vencido ,tipo_mov ,fecha_mov,sexo ,fecha_nac ,nombre1 ,Nombre2 ,apellido_p ,
			apellido_m ,mail ,dir_calle ,dir_numero ,dir_colonia ,cp ,
			dir_municipio ,num_estado ,dir_estado ,num_cd_coppel ,cd_coppel ,num_cd_banco ,
			cd_banco ,tel1 ,tel2 ,tel3 ,ext ,ref_coppel ,eficiencia ,meses_historia ,hit ,secc1 ,secc2, motivo )
		VALUES
			(Vproducto , Vnum_credito , Vnumcte,	Vnum_tarjeta ,Vnum_sucursal	, Vnom_suucursal,Vingreso_mensual,
			Vmonto_apertura , Vfecha_apertura , Vplazo ,Vestatus,Vsaldo_insoluto,Vcapital_vigente,
			Vcapital_transitorio	,Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible,Vsaldo_actual ,
			Vsaldo_cierre ,Vmes_vencido ,Vtipoultimomov ,Vfechaultmov, Vsexo ,Vfecha_nac, Vnombre1 , Vnombre2 ,Vapellido_p ,
			Vapellido_m ,Vmail,Vdir_calle, Vdir_numero , Vdir_colonia , Vcp ,
			Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,
			Vcd_banco , Vtel1 ,Vtel2 ,Vtel3 ,Vext , Vref_coppel ,Vficiencia , Vmeses_historia ,Vhit ,Vsecc1 , Vsecc2, cMotivo );			
		
		IF Vnumtarjetatdc = '' THEN 
			LET Vnumtarjetatdc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		
		INSERT INTO sd_pagosydisposicionescrd_cartera  VALUES
		(Vproducto,Vnum_credito, Vcreditoexterno, Vnumcuentartc,	Vnumtarjetatdc ,Vnumcte ,Vnum_sucursal,Vnumciudad, 
		vfecha_apertura ,Vsaldo_insoluto  ,Vinteres   ,Vsaldovencido ,Vinteresvencido,vinteres_moratorio,
		Vabonobase ,vmes_vencido ,Vestatus , vplazo ,Vtasainteres , 	
		Vfechalimitedepago, Vfechaultmov ,Vtipoultimomov,pfechacorte );	
	
		
		LET	Vnumcreditortc			= '';LET Vcreditoexterno			= '';LET Vnumcuentartc			= '';
		LET	Vnumtarjetatdc			= '';LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0;
		LET	Vnumciudad	            = '';LET Vsaldoactual			= 0;LET Vinteres                = 0;
		LET Vsaldovencido           = 0;LET Vinteresvencido         = 0;LET Vabonobase              = 0;LET Vabonosvencidos         = 0;
		LET vinteres_moratorio		= 0;LET Vestadocredito          = 0;LET Vplazortc      			= 0;LET Vtasainteres   		    = 0;
		LET Vfechalimitedepago      = DATE(1);LET	Vfechaultmov            = DATE(1);LET Vtipoultimomov          = '';
		let Vprod					='';let vmontor1				= 0;let vmontor2				= 0;
					
			
		LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
		LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
		LET Vproducto     		='';     LET Vnum_credito         = '';	 LET  Vnumcte				='';
		LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_suucursal		='';	 LET  Vingreso_mensual    = 0;
		LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
		LET Vestatus ='';	  
		LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfecha_mov = DATE(1);
		LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
		LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
		LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
		LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
		LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
		LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;	LET cMotivo = '';
			   
    END FOREACH;	
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/Elizabeth/';
	--let cruta = '/informix/fmartinez_2/PruebasCartera1/';
	let cnombre = 'Cartera_Total';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicred:sd_carteral_ppyr ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 
	
	LET	Vnumcte           	    = '';
	LET  sPaso = 0;		

	--segundo archivo
	--CREAR  ARCHIVO
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) ||'Pagos1.unl' || ' DELIMITER ' || '''|'''  ||
	' select * from sd_pagosydisposicionescrd_cartera;'||
	' " > '|| TRIM(cruta) || 'Pagosydisposiciones2crd.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) || 'Pagos1.unl >' || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;

	let cSql = '';

	LET cSql = "rm " || TRIM(cruta) || 'Pagos1.unl ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	-- para Generar el archvio de Cifras.
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) || 'DirectorioCifrasControlRegistros.unl'|| ' DELIMITER ' || '''|'''  ||
	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte FROM bdicred:sd_pagosydisposicionescrd_cartera group by fechacorte ' ||
	' " > '|| TRIM(cruta) || 'DirectorioCifrasControlQuerys.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl > '|| TRIM(cruta) || trim(cNombreArchivo2);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;
	RETURN cCod_ret;
	
END;
END PROCEDURE;