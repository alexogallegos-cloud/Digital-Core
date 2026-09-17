CREATE PROCEDURE "informix".sp_proyecta_prestamos(pEmpresa          CHAR(3),
                                                valortotal          MONEY(14,2),
                                                pagopropuesto       MONEY(14,2),
                                                producto            CHAR(04),
                                                num_sol             CHAR(20),
                                                apli_plan           CHAR(1),
                                                usuario             CHAR(20),
                                                sPeriodoDeGracia    SMALLINT)

        RETURNING CHAR(5), MONEY(14,2), INTEGER, MONEY(14,2), MONEY(14,2), MONEY(14,2), DATE, DECIMAL(9,6), CHAR(6),DECIMAL(9,6), MONEY(14,2);

   DEFINE cod_ret            CHAR(6);
   DEFINE vcod_tasa_base     CHAR(8);
   DEFINE vtipoplazo         CHAR(1);
   DEFINE vtipodia           CHAR(1);
   DEFINE proyeccio1         CHAR(20);
   DEFINE v_dia              CHAR(2);
   DEFINE v_mes              CHAR(2);
   DEFINE v_anio             CHAR(4);
   DEFINE vfactor_sobretasa  CHAR(1);
   DEFINE wtp_calculo        CHAR(2);
   DEFINE wcod_tipcred       CHAR(2);
   DEFINE vcat               CHAR(6);
   DEFINE vCodTasaMora       CHAR(8);
   DEFINE vFactor            CHAR(1);
   DEFINE wfecha_venc        DATE;
   DEFINE wfecha_alta        DATE;
   DEFINE vfecha             DATE;
   DEFINE vfecha_hoy         DATE;
   DEFINE vfecha_hoyAnt      DATE;
   DEFINE wfecha_cambio      DATE;
   DEFINE wfecha_cambi1      DATE;
   DEFINE vfecha_primer      DATE;
   DEFINE v_fecha_vencim     DATE;
   DEFINE wtasa_interes      DECIMAL(9,6);
   DEFINE vSobreTasa         DECIMAL(9,6);
   DEFINE vtasa_periodo      DECIMAL(10,6);
   DEFINE vtasa_diario       DECIMAL(10,6);
   DEFINE v_tasa_interes     DECIMAL(9,6);
   DEFINE wfactor            DECIMAL(10,6);

   DEFINE wmonto_iva         DECIMAL(14,2);
   DEFINE wadicional         DECIMAL(14,2);
   DEFINE wadicionals        DECIMAL(14,2);
   DEFINE wcomisions         DECIMAL(14,2);
   DEFINE wtasaprop          DECIMAL(9,6);
   DEFINE vTasaMora          DECIMAL(9,6);
   DEFINE vmontopago         DECIMAL(14,2);
   DEFINE sqlerr             INTEGER;
   DEFINE proyeccion         INTEGER;
   DEFINE wmesespro          INTEGER;
   DEFINE cuotafantasma      INTEGER;
   DEFINE nomeses1           INTEGER;
   DEFINE nomeses2           INTEGER;
   DEFINE vAnio              INTEGER;
   DEFINE vDia               INTEGER;
   DEFINE vMes               INTEGER;
   DEFINE vper               INTEGER;
   DEFINE vdia1              INTEGER;
   DEFINE cicloseguro        SMALLINT;
   DEFINE v_dias_cal_int     CHAR(10);
   DEFINE wplazo_fin         SMALLINT;
   DEFINE wplazo_linea       SMALLINT;
   DEFINE vmaxmeses          SMALLINT;
   DEFINE wplazo_v           SMALLINT;
   DEFINE wplazo_1           SMALLINT;
   DEFINE v_dias             SMALLINT;
   DEFINE cicloadicionales   SMALLINT;
   DEFINE ciclo              SMALLINT;
   DEFINE pagopropuestocal   MONEY(14,2);
   DEFINE capital            MONEY(14,2);
   DEFINE capital1           MONEY(14,2);
   DEFINE valorfinal         MONEY(14,2);
   DEFINE valorfinalAnt      MONEY(14,2);
   DEFINE interes            MONEY(14,2);
   DEFINE iva                MONEY(14,2);
   DEFINE vmonto_int_par     MONEY(14,2);
   DEFINE vinteres_total     MONEY(14,2);
   DEFINE wmonto_linea       MONEY(14,2);
   DEFINE vCapital    	     MONEY(14,2);
   DEFINE vInteres           MONEY(14,2);
   DEFINE vIva               MONEY(14,2);
   DEFINE vIvaMas            MONEY(14,2);
   DEFINE vMesPro            MONEY(14,2);
   DEFINE vValorFin          MONEY(14,2);
   DEFINE vabono_fijo        MONEY(14,2);
   DEFINE vProyecInt         MONEY(14,2);
   DEFINE vValorPre          MONEY(14,2);
   DEFINE BanderaCas         CHAR(1);
   DEFINE bEsNumero          BOOLEAN;

   LET nomeses1 		= 0;
   LET wtasaprop 		= 0;
   LET wmesespro 		= 0;
   LET cod_ret          = "000000";
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
   

BEGIN
ON EXCEPTION
      SET sqlerr
      LET cod_ret = sqlerr;
      RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
END EXCEPTION;

    --SET DEBUG FILE TO "/RESPALDOSNEW/ulises/RT_PP/sp_proyecta_prestamos.trc";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
    -- FMV 12-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
    EXECUTE PROCEDURE bdinteg:val_num (num_sol) INTO bEsNumero;
     
    IF bEsNumero = 'f' THEN
      LET cod_ret = '00242';  --EL NUMERO DE SOLICITUD NO EXISTE
          RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
    END IF;


    IF pagopropuesto < 10 THEN
      LET cod_ret = '00002';
      RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
    END IF;

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

     IF   vFactor = '+' THEN
        LET vTasaMora = vTasaMora + vSobreTasa;
     ELIF vFactor = '-' THEN
        LET vTasaMora = vTasaMora - vSobreTasa;
     ELIF vFactor = '*' THEN
        LET vTasaMora = vTasaMora * vSobreTasa;
     ELIF vFactor = '/' THEN
        LET vTasaMora = vTasaMora / vSobreTasa;
     ELSE
        LET vTasaMora = vTasaMora;
     END IF;

   IF  apli_plan = 'S' THEN
       LET usuario = usuario;
       DELETE FROM bdicred:"informix".sd_proyecta    --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa = pempresa 
         AND num_solicitud = usuario;

       IF valortotal = 0  or pagopropuesto = 0 or trim(producto) = "" THEN
          LET cod_ret = "000110";
          RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
       END IF;

       SELECT cod_tasa_base,factor_sobretasa,sobretasa,plazo_max_cred,periodo_plazo
         INTO vcod_tasa_base,vfactor_sobretasa,vsobretasa,vmaxmeses,vtipoplazo
         FROM bdicred:"informix".sd_definicion 
       WHERE num_producto = producto;

       SELECT valor  
         INTO wtasa_interes 
         FROM bdinteg:"informix".si_fechavalor
        WHERE tasa = vcod_tasa_base  
          AND fecha = (SELECT MAX(fecha)
                         FROM bdinteg:"informix".si_fechavalor
                        WHERE tasa = vcod_tasa_base);

       LET v_tasa_interes = wtasa_interes * vsobretasa;
       IF vfactor_sobretasa = '+' THEN
          LET v_tasa_interes = wtasa_interes + vsobretasa;
       ELIF vfactor_sobretasa = '-' THEN
            LET v_tasa_interes = wtasa_interes - vsobretasa;
       ELIF vfactor_sobretasa = '*' THEN
            LET v_tasa_interes = wtasa_interes * vsobretasa;
       ELIF vfactor_sobretasa = '/' THEN
            LET v_tasa_interes = wtasa_interes / vsobretasa;
       END IF;

      SELECT valor 
        INTO v_dias_cal_int
        FROM bdicred:"informix".sd_param       ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa = pempresa   
         AND cod_param = "24";

      SELECT max(num_solicitud) {+index (sd_proyecta idx_sdproyecta)}
        INTO proyeccion
        FROM bdicred:"informix".sd_proyecta     ----FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
       WHERE empresa =  pempresa
         AND num_solicitud = usuario;

      IF proyeccion is null THEN
         LET proyeccion = 1;
      ELSE
         LET proyeccion = proyeccion;
      end IF;
      LET proyeccion = proyeccion + 1;

      SELECT fecha_hoy, pri_dia_mes
        INTO vfecha_hoy,vfecha_primer
        FROM bdicred:"informix".sd_fechas
       WHERE empresa = pempresa;

      IF day(vfecha_hoy) > 2 AND day(vfecha_hoy) < 17 THEN
         LET vfecha_primer = Mdy(MONTH(vfecha_hoy),02,year(vfecha_hoy));
         LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
      ELSE
         LET vfecha_primer = Mdy(MONTH(vfecha_hoy),17,year(vfecha_hoy)) ;
         IF day(vfecha_hoy) > 2 THEN
            LET vfecha_primer = vfecha_primer + 1 UNITS MONTH;
         END IF;
      end IF;

      LET wplazo_linea = vmaxmeses;
      LET vtipodia = "N";
      LET v_fecha_vencim = vfecha_primer + (wplazo_linea - 1) units MONTH;
      LET wplazo_fin =1;
      LET wplazo_v = 0;

      IF vtipoplazo = "C" THEN
         LET wplazo_fin = 4;
      ELSE
         IF vtipoplazo = "A" THEN
            LET wplazo_fin = 12;
         ELSE
            IF vtipoplazo = "S" THEN
               LET wplazo_fin = 6;
            end IF;
         end IF;
      end IF;

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

      IF pagopropuesto > 0 THEN
         LET nomeses1 = vmaxmeses;
         LET wplazo_1 = vmaxmeses;
      end IF;
      
   LET wfecha_cambio = vfecha_hoy;
   LET wfecha_cambi1 = vfecha_primer;
   LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
   LET vtasa_diario = ROUND((v_tasa_interes/v_dias_cal_int)/100,8);

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


   WHILE ciclo < wplazo_linea
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       ELSE
          LET vdia1 = (wfecha_cambi1 - wfecha_cambio);
       END IF;

       LET vmonto_int_par = ROUND(wadicional * vtasa_diario, 2);
       LET vmonto_int_par = ROUND(vmonto_int_par * vdia1, 2);
       LET wmonto_iva = ROUND(vmonto_int_par  * vIva ,2);
       LET capital = pagopropuesto - vmonto_int_par - wmonto_iva ;

       IF capital < 0 THEN -- No Cubre el Interes   
          LET valorfinalAnt=valorfinal;  
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses+3));
            IF pagopropuesto < ROUND(wmonto_linea*vtasa_periodo,2) THEN
               LET valorfinal=valorfinal+valorfinalAnt;
            END IF;    
          LET wadicional = wmonto_linea - valorfinal;
           IF wadicional<0 THEN
              LET cod_ret = '00002';
              RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET capital = 0;
          LET BanderaCas='2';
       END IF;
       LET capital = capital;
       LET vmonto_int_par = vmonto_int_par;
       LET wmonto_iva = wmonto_iva;
       LET pagopropuesto = pagopropuesto;

       IF vmonto_int_par < 0 THEN     --FMV 26-AGO-14: Tasa de interes cero en la contratacion de Reestructuras.
          EXIT WHILE;
       END IF;

       IF capital > wadicional THEN
          LET capital = wadicional;
       end IF;
	   
       IF ciclo <> 0 THEN 
           LET wfecha_cambio = wfecha_cambi1;
           LET wfecha_cambi1 = wfecha_cambi1 + 1 UNITS MONTH;
           LET wadicional = wadicional - capital;
       END IF;

       IF valorfinal>0 AND ciclo>= vmaxmeses AND ((BanderaCas= '1' ) or pagopropuesto > ROUND(wmonto_linea*vtasa_periodo,2)) THEN
          EXIT WHILE;
       END IF;

       IF wadicional > 0 AND ciclo = vmaxmeses THEN
          LET valorfinalAnt=valorfinal; 
          LET valorfinal= wadicional/(POW(1+vtasa_periodo,vmaxmeses));
            IF pagopropuesto < ROUND(wmonto_linea*vtasa_periodo,2) AND BanderaCas='2' THEN
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

       IF wadicional <= 0 THEN
          LET wadicional = 0;
          EXIT WHILE; 
       END IF;
   END WHILE

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
   LET valorfinal = valorfinal;
   LET wmonto_linea = wmonto_linea-valorfinal;
   LET wplazo_linea = vmaxmeses;
   LET ciclo = 0;
   LET vabono_fijo = pagopropuesto;
   LET BanderaCas='1';
   
    WHILE ciclo < (sPeriodoDeGracia) AND wmonto_linea <> 0
        LET ciclo = ciclo + 1;

        INSERT INTO "informix".sd_proyecta (empresa,num_solicitud,fecha_cuota,capital_cuota,
                                            interes_cuota,iva_cuota,plazo,enganche,tasa_interes)
        VALUES (pempresa, TRIM(usuario), wfecha_alta, '0', '0', '0',ciclo,
                valorfinal, v_tasa_interes);

        LET vfecha_hoy = wfecha_alta;
        LET wfecha_alta = wfecha_alta + 1 UNITS MONTH;
    END WHILE

   WHILE ciclo < (wplazo_linea) AND wmonto_linea <> 0
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          LET vdia1 = wfecha_alta - vfecha_hoy;
       ELSE
          LET vdia1 = wfecha_alta - vfecha_hoy;
       END IF;

       LET vmonto_int_par = ROUND(wmonto_linea * vtasa_diario ,2);
       LET vmonto_int_par = ROUND(vmonto_int_par *  vdia1,2);
       LET wmonto_iva = ROUND(vmonto_int_par * vIva,2);

       IF vmonto_int_par < 0 THEN
          EXIT WHILE;
       END IF;

       LET capital = pagopropuesto - vmonto_int_par - wmonto_iva ;
	   
       IF capital > wmonto_linea THEN
          LET capital = wmonto_linea;
       END IF;
	   
       LET vmontopago = capital + vmonto_int_par + wmonto_iva;
       INSERT INTO "informix".sd_proyecta (empresa,num_solicitud,fecha_cuota,capital_cuota,
                                                    interes_cuota,iva_cuota,plazo,enganche,tasa_interes)
                VALUES(pempresa,TRIM(usuario),wfecha_alta,capital,vmonto_int_par,wmonto_iva,ciclo,
                       valorfinal, v_tasa_interes);

      LET vfecha_hoy = wfecha_alta;
      LET wfecha_alta = wfecha_alta + 1 UNITS MONTH;
      LET wmonto_linea = wmonto_linea - capital;

  

      IF wmonto_linea <= 0 THEN
          LET wmonto_linea = 0;
      END IF;
  end WHILE

  SELECT COUNT(*), SUM(capital_cuota), MIN(fecha_cuota)  {+INDEX (sd_proyecta idx_sdproyecta)}
    INTO wplazo_v, capital,vfecha_hoy
    FROM "informix".sd_proyecta
   WHERE empresa = pempresa       --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
     AND num_solicitud = usuario;

  LET wmesespro = wplazo_v;
  LET valorfinal = valortotal - capital;

  LET nomeses2 = 1;
  LET capital1 = capital;

    foreach
      SELECT 
          fecha_cuota,capital_cuota ,interes_cuota,iva_cuota,plazo,plazo,tasa_interes
          INTO vfecha,vCapital,vInteres, vIva,vMesPro,vValorFin, v_tasa_interes
          FROM "informix".sd_proyecta
          WHERE empresa = pempresa        --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
            AND num_solicitud = trim(usuario)
          ORDER BY fecha_cuota
          IF nomeses2 < wmesespro THEN
                 LET nomeses2 = nomeses2 +1;
          END IF;
                 RETURN cod_ret,valorfinal,wmesespro,vCapital,vInteres,vIva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt WITH resume;
    END FOREACH;
 ELSE
      UPDATE "informix".sd_proyecta
         SET num_solicitud = num_sol
       WHERE empresa = pempresa
         AND num_solicitud = usuario;
      RETURN cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt WITH resume ;
 END IF;

END
END PROCEDURE
DOCUMENT
"Realiza la generacion de planes de pago",
"AUTOR : Procesamiento Interactivo ",
"BD.   : bdicred",
'Folio: 686',
'RQM 09 546 Reestructura PrÃ©stamo Personal',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2020/10/06',
'DescripciÃ³n: Se genera un clon del sp proyecta para poder reestructurar los pÃ©stamos personales agregandoles periodo de gracia.',
'SolicitÃ³: Ricardo Sanchez';

CREATE PROCEDURE "informix".quita_condona_tdc(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoEfe               MONEY(14,2)
						   )
  --Valores a Regresar
      RETURNING CHAR(5)
			 
	DEFINE CodRet                	CHAR(5);
	DEFINE sql_err               	SMALLINT;
	DEFINE isam_err              	SMALLINT;
	DEFINE error_info            	CHAR(40);
	DEFINE nRows                 	SMALLINT;
	DEFINE Mensaje               	CHAR(80);
	DEFINE wBegin                	CHAR(1);
		
	
	DEFINE g_Remanente    			MONEY(14,2);
	DEFINE g_IntMoraCob   			MONEY(14,2);
	DEFINE g_IntVencCob   			MONEY(14,2);
	DEFINE g_CapVencCob   			MONEY(14,2);
	DEFINE g_IntVigCob    			MONEY(14,2);
	DEFINE g_CapVigCob    			MONEY(14,2);
	DEFINE g_Impuesto     			MONEY(14,2);
	DEFINE g_Comision     			MONEY(14,2);
	DEFINE g_Seguro       			MONEY(14,2);
			 
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general   
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE cStatus					CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2); 
	DEFINE csg_int_moratorios		MONEY(18,2); 
	DEFINE csg_iva_int_vdo			MONEY(18,2); 
	DEFINE csg_iva_int_moratorios	MONEY(18,2); 	
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE vQuitaEscVenc 			CHAR(1); 	 
	DEFINE v_MoraProvi              MONEY(18,2); 
	DEFINE v_MoraIva                MONEY(18,2); 
	DEFINE vIntVencido              MONEY(18,2); 
	DEFINE vIntMoratorio            MONEY(18,2); 
	DEFINE vDescuentoQuita          MONEY(18,2); 
	DEFINE vPorcQuita               MONEY(18,2); 
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);
	DEFINE csg_dMoraBase        DECIMAL(18,2);
	DEFINE csg_dMoraCopete      DECIMAL(18,2);
	DEFINE csg_dIvamoraBase     DECIMAL(18,2);
	DEFINE csg_dIvaMoraCopete   DECIMAL(18,2);
	DEFINE vMontoTransaccCapitalVdo DECIMAL(18,2);
	DEFINE vMontoTransaccCancelaLinea DECIMAL(18,2);
	DEFINE vaux1_cap_vdo_exig                DECIMAL(18,2);
	DEFINE vaux2_cap_vdo_no_exig             DECIMAL(18,2);
	DEFINE vaux3_sdo_cap_insol               DECIMAL(18,2);
	DEFINE CodRetqc              CHAR(5);
   
	DEFINE vMontoCondonado  	DECIMAL(18,2);
	DEFINE vMontoQuita     		DECIMAL(18,2);
	DEFINE vIndProceso     		CHAR(1);
	DEFINE v_SdoCapInsoluto   	MONEY(14,2);
	
	DEFINE monto_condona		DECIMAL(18,2);
	DEFINE monto_capital		DECIMAL(18,2);
	DEFINE quita_capital		DECIMAL(18,2);
	DEFINE numProducto			CHAR(4);
	DEFINE vDivisa				CHAR(2);
	DEFINE cancela				INT;
	DEFINE vtarjeta         	CHAR(20);
	DEFINE cproduto         	VARCHAR(3);
	DEFINE vFechaVigencia		DATE;
	DEFINE vfecha_hoy            DATE;
	DEFINE vmonto_quita_condona	DECIMAL(18,2);

--		SET DEBUG FILE TO "/RESPALDOSNEW/quita_condona_tdc.out";
--		TRACE ON;

	LET CodRet						= '000';
	LET g_Remanente    				= 0;
	LET g_IntMoraCob   				= 0;
	LET g_IntVencCob   				= 0;
	LET g_CapVencCob   				= 0;
	LET g_IntVigCob    				= 0;
	LET g_CapVigCob    				= 0;
	LET g_Impuesto     				= 0;
	LET g_Comision     				= 0;
	LET g_Seguro       				= 0;
		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET cStatus						= "";
	LET csg_fec_origen				= DATE(1);
	LET csg_fec_prox_pago			= DATE(1);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= DATE(1);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";
	LET csg_dMoraBase               = "";
	LET csg_dMoraCopete             = "";
	LET csg_dIvamoraBase            = "";
	LET csg_dIvaMoraCopete          = "";   
	
	LET vMontoCondonado  	= 0;
	LET vMontoQuita     		= 0;
	LET vIndProceso     		= '';
	LET v_SdoCapInsoluto   	= 0;
	LET monto_condona		= 0;
	LET monto_capital		= 0;
	LET quita_capital		= 0;
	LET numProducto			= 0;
	LET vDivisa				= 0;
	LET cancela				= 0;
	LET vtarjeta         	= '';
	LET cproduto         	= '';
	LET vFechaVigencia		= DATE (1);	
	LET vfecha_hoy   	= DATE (1);
	LET vmonto_quita_condona	= 0;
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;
	
	SELECT monto_condonado, mto_quita, indicador_proceso, fecha_negociacion
		INTO  vMontoCondonado, vMontoQuita,  vIndProceso, vFechaVigencia
	FROM  bdicred:sd_bitacora_quitacondonacion
		WHERE num_credito = p_NumCredito
		AND estatus_proceso = 'PR';
		
		
		IF vFechaVigencia IS NULL THEN LET vFechaVigencia = date(1); END IF;
		IF vMontoCondonado IS NULL OR vMontoCondonado = ''  THEN LET vMontoCondonado = 0; END IF;
		IF vMontoQuita IS NULL OR vMontoQuita = '' THEN LET vMontoQuita = 0; END IF;
		IF vIndProceso IS NULL OR vIndProceso = '' THEN LET vIndProceso = ''; END IF;

		LET vmonto_quita_condona = vMontoCondonado + vMontoQuita;
		
		IF vIndProceso <> '' THEN
			--Se valida si el credito entra en el programa de Condonacion y Quitas
			IF (p_MontoEfe >= vmonto_quita_condona )	 
				AND vfecha_hoy <= vFechaVigencia 	THEN

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
					INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
					csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
					csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
					csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
					csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
					csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
					csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
					csg_id_causa_esp_cred,csg_sit_esp_cred;
				
					--- valida si el pago sobrepasa el total a liquidar
				IF p_MontoEfe < csg_tot_liquidacion THEN
					IF csg_sdo_act_total_cap > 0 THEN
					
						UPDATE "informix".sd_bitacora_quitacondonacion
							SET saldo_tot_liquidar = csg_tot_liquidacion, copete_moratorio = NVL(csg_int_moratorios,0) + NVL(csg_iva_int_moratorios,0), 
							cap_vigente_cq = NVL(csg_cap_vig,0) + NVL(csg_cap_trans,0), cap_vencido_cq = NVL(csg_cap_vdo_exig,0) + NVL(csg_cap_vdo_no_exig,0), 
							int_vigente_cq =  csg_int_vig, int_vencido_cq = csg_int_vdo, int_moratorio = csg_int_moratorios, 
							iva_int_vigente_cq =  csg_iva_int_vig, iva_int_vencido_cq = csg_iva_int_vdo 			
						WHERE num_credito = p_NumCredito;
					
						LET monto_condona = csg_tot_liquidacion - p_MontoEfe;
						LET monto_capital = csg_tot_liquidacion - monto_condona;
														
						--- si el monto efectivo es mayor a capital no hay quita, solo se condonana moratorios y lo que alcance de vencidos.
						IF p_MontoEfe >= csg_sdo_act_total_cap THEN
						
							LET monto_condona = csg_tot_liquidacion - p_MontoEfe;
							IF monto_condona > 0 THEN	---- para casos de vigente no hay que condonar
								---- aplica pago de accesorios y capital que logre pagar
								CALL "informix".Principal(p_Empresa,p_NumCredito,p_TpPago,monto_condona,
										p_Usuario,p_Sucursal,p_Folio,'8638')	--- cambiar transacciÃ³n.. para condonaciones de quitas
										returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
											   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;	
							END IF;

							IF vIndProceso = 'Q' THEN
								LET cancela = 1;
							END IF;
						
						ELSE	
							--- se obtiene accesorios por diferencia, no alcanza el pago se condona al 100%
							LET monto_condona = csg_tot_liquidacion - csg_sdo_act_total_cap;
							IF monto_condona > 0 THEN	---- para casos de vigente no hay que condonar
								CALL "informix".Principal(p_Empresa,p_NumCredito,p_TpPago,monto_condona,
										p_Usuario,p_Sucursal,p_Folio,'8638')	--- cambiar transacciÃ³n.. para condonaciones de quitas
										returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
											   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;	
							END IF;	

							--- se obtiene la diferencia de capital que no cubre el pago.
							IF vIndProceso = 'Q' THEN
								LET quita_capital = csg_sdo_act_total_cap - p_MontoEfe;
								LET cancela = 1;
							END IF;
						
						END IF;
		
					END IF;
		
				END IF; 	--- csg_tot_liquidacion			
			ELSE
				LET CodRet = '001';
			END IF;
		END IF;

   RETURN CodRet;
END PROCEDURE;