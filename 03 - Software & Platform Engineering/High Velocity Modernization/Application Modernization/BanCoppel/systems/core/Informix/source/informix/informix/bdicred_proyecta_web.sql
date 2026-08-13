CREATE PROCEDURE "informix".proyecta_web(pempresa        char(3),
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

   LET nomeses1 = 0;
   LET wtasaprop = 0;
   LET wmesespro = 0;

   LET cod_ret          = "00000";
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
      return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
END EXCEPTION;

--    SET DEBUG FILE TO "/tmp/proyecta.out";
--    TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
    -- FMV 12-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
    EXECUTE PROCEDURE bdinteg:val_num (num_sol) INTO bEsNumero;
     
    IF bEsNumero = 'f' THEN
      LET cod_ret = '00242';  --EL NUMERO DE SOLICITUD NO EXISTE
          return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
    END IF;


    if pagopropuesto < 10 then
      LET cod_ret = '00002';
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
          LET cod_ret = "00110";
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
              LET cod_ret = '00002';
              return cod_ret,valorfinal,wmesespro,capital,interes,iva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt;
           END IF;
          LET wfecha_cambi1=vfecha_primer;
          LET wfecha_cambio = vfecha_hoy;
          LET ciclo   = 0;
          LET capital = 0;
          LET BanderaCas='2';
--          LET cod_ret = "00002";
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
   LET valorfinal = valorfinal;
   LET wmonto_linea = wmonto_linea-valorfinal;
   LET wplazo_linea = vmaxmeses;
   LET ciclo = 0;
   LET vabono_fijo = pagopropuesto;
   LET BanderaCas='1';
   while ciclo < wplazo_linea and wmonto_linea <> 0
       LET ciclo = ciclo + 1;
       IF ciclo = 1 THEN
          LET vdia1 = wfecha_alta - vfecha_hoy;
       ELSE
          LET vdia1 = wfecha_alta - vfecha_hoy;
       END IF;

       LET vmonto_int_par = round(wmonto_linea * vtasa_diario ,2);
       LET vmonto_int_par = round(vmonto_int_par *  vdia1,2);
       LET wmonto_iva = round(vmonto_int_par * vIva,2);


       IF vmonto_int_par < 0 THEN
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
  select count(1), sum(capital_cuota), min(fecha_cuota)  {+index (sd_proyecta idx_sdproyecta)}
    into wplazo_v, capital,vfecha_hoy
    from "informix".sd_proyecta
   where empresa = pempresa       --FMV 1-AGO-12: OPTIMIZAR FILTRO POR INDICE UNICO
     and num_solicitud = usuario;

  LET wmesespro = wplazo_v;
  LET valorfinal = valortotal - capital;
  LET nomeses2 = 1;
  LET capital1 = capital;

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

CREATE PROCEDURE "informix".sp_bloqueocuenta_web (
																pEmpresa 	CHAR(3),
																pNumCuenta 	CHAR(20),
																cCveBloqueo	INTEGER,
																pCveCausa 	CHAR(2),
																pEjecutivo 	CHAR(8),
																pTipo		INTEGER
															  )
RETURNING
	CHAR(5) AS CODIGO,
	CHAR(80) AS MENSAJECOD;

--Definicion de variables
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(5);
DEFINE cMensajeRet   CHAR(80);
DEFINE vFecha        DATE;
DEFINE vCveExistente INTEGER;
DEFINE vCodSP        CHAR(6);
DEFINE vStatusCred   CHAR(2);
DEFINE pClaveBloqueo INTEGER;
DEFINE iCveAnte      INTEGER;
DEFINE cCausa        CHAR(2);

--Set debug file to '/informix/christ/sp_bloqueocuenta.out';
--trace on;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet= iSqlErr;
		  LET cMensajeRet= cErrorInfo;
		  RETURN
			   cCodRet,
			   cMensajeRet;
	   END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--Inicializar Variables--
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = '';
LET cCodRet        = '00000';
LET cMensajeRet    = '';

LET vFecha         = date(1);
LET vCveExistente  = 0;
LET vCodSP         = '';
LET vStatusCred    = '';
LET pClaveBloqueo  = 0;
LET iCveAnte       = 0;
LET cCausa		   = '';


	IF pEmpresa IS NULL OR pNumCuenta IS NULL OR cCveBloqueo IS NULL OR pCveCausa IS NULL OR pEjecutivo IS NULL OR pTipo IS NULL THEN
		LET cCodRet = '00001';    --Faltan Valores
		LET cMensajeRet = 'Faltan valores para ejecutar el procedimiento.';
	ELSE
		IF( SELECT count(empresa) FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) = 0 THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'La empresa no valida';
		ELSE
			IF(SELECT count(clave) FROM bdicred:"informix".sd_bloqueoscuenta WHERE clave = cCveBloqueo) = 0 THEN
				LET cCodRet = '00003';
				LET cMensajeRet = 'La clave del bloqueo no es valida';
			ELSE
				IF(SELECT count(cod_causa) FROM bdicred:"informix".sd_causa_bloqueo WHERE empresa = pEmpresa and cod_causa = pCveCausa) = 0 THEN
					LET cCodRet = '00004';
					LET cMensajeRet = 'La clave de la causa del bloqueo no es valida';
				ELSE
					IF(SELECT count(ejecutivo) FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo) = 0 THEN
						LET cCodRet = '00005';
						LET cMensajeRet = 'La clave de la causa del bloqueo no es valida';
					ELSE
						IF pTipo NOT IN (1,2) THEN
							LET cCodRet = '00006';
							LET cMensajeRet = 'El tipo de bloqueo no es valido';
						ELSE
							EXECUTE PROCEDURE bdicred:"informix".sp_validacredito (pEmpresa, pNumCuenta)
							INTO vCodSP;
							IF vCodSP::INTEGER <> 0 THEN
								LET cCodRet = '00007';    --No existe el credito en la base de datos
								LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' no existe.';
							ELSE
								SELECT NVL(id_unidad_prod, 0), status_Cred, cod_caract_2
								  INTO vCveExistente, vStatusCred, cCausa
								  FROM "informix".sd_maecred
								 WHERE empresa = pEmpresa
								   AND num_credito = pNumCuenta;

								IF (vCveExistente = 0 AND cCausa IS NOT NULL) OR (vCveExistente > 0 AND cCausa IS NULL) THEN
									LET cCodRet = '00008';
									LET cMensajeRet = 'Credito bloqueado manualmente favor de verificar';
								ELSE
									IF vCveExistente > 0 AND cCausa IS NOT NULL THEN
									   LET cCodRet = '00009';
									   LET cMensajeRet = 'El credito ya se encuentra bloqueado';
									ELSE
										IF vCveExistente >= 0 THEN
											IF vStatusCred='FC' THEN
												LET cCodRet = '00012';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' esta cancelada.';
											ELIF vStatusCred ='CV' THEN
												LET cCodRet = '00010';
												LET cMensajeRet = 'La cuenta ' || pNumCuenta || ' esta en cartera vendida.';
											ELSE
												SELECT fecha_hoy
												INTO vFecha
												FROM bdicred:"informix".sd_fechas
												WHERE empresa = pEmpresa;

												INSERT INTO bdicred:"informix".sd_bitacorabloqueocta
												(cuenta, cve_bloqueo,cve_causa,cve_bloqueAnterior,cve_causa_anterior, ejecutivo, fecha, tipo_bloqueo, tipo_movimiento)
												VALUES (pNumCuenta, cCveBloqueo,pCveCausa, NULL, NULL, pEjecutivo, vFecha, pTipo, 'B');

												UPDATE bdicred:"informix".sd_maecred
												SET id_unidad_prod = cCveBloqueo, Cod_caract_2 = pCveCausa
												WHERE empresa = pEmpresa
												AND num_credito = pNumCuenta;

												LET cMensajeRet = 'La cuenta ' ||  Trim(pNumCuenta) || ' se ha bloqueado.';

												IF vCveExistente > 0 THEN
												   LET cCodRet = '00011';  --El bloque se actualizo
												   LET cMensajeRet = 'Se actualizo el bloqueo de la cuenta ' || pNumCuenta;
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF
					END IF
				END IF
			END IF
		END IF
	END IF;

	RETURN cCodRet,cMensajeRet;

END;

END PROCEDURE

DOCUMENT
'Autor: Abraham Ayala Aguilar',
'Descripcion: Bloquea una cuenta e inserta un registro en la tabla sd_bitacorabloqueocta. Bloqueo Cuentas',
'Fecha: 08/01/2009',
'Cambio: se quito la restriccion de cuando ya estaba bloqueada la cuenta y se actualiza  cCveBloqueo   pClaveBloqueo',
'Modifico: Roque Enrique Solis ',
'Cambio: Se cambio el parametro clave del parametro por la descripcion del parametro',
		'Se agrego el parametro del bloqueo anterior para que se inserte el la bitacora',
		'Se agrego el campo para conocer la causa del bloque',
'Modifico: Roque Enrique Solis',
'Cambio: Se agrega de tipo bloqueo (manual o masivo), ademÃÂ¡s se cambias las clave del bloqueo por su descripcion',
		'tipo_bloqueo  1 = Manual, 2 = Masivo',
'Modifico: Mohamed Carreon, Abigail Vasavilbazo CaÃÂ±edo',
'Version: 20120104.1048';

CREATE PROCEDURE "informix".sp_cantidadadicionales_web(pNumeroCuenta CHAR(13), pNumeroClienteAdic CHAR(20))
	-- DATOS A REGRESAR

	RETURNING
	CHAR(5),	-- Codigo de retorno
	CHAR(3);
	-- Declaracion de variables

	DEFINE vCodRet		CHAR(5);
	DEFINE vCanReg		CHAR(3);

	-- Se Inicializan las Variables

	LET vCodRet  = "00000";
	LET vCanReg = "000";

	BEGIN

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 -- Se verifica que exista el numero de cuenta
		 
		 LET pNumeroCuenta = TRIM(pNumeroCuenta);
		 LET pNumeroClienteAdic = TRIM(pNumeroClienteAdic);
		 
		IF(SELECT count(num_credito) from bdicred:sd_tarjeta WHERE empresa = '001' AND num_credito = pNumeroCuenta) > 0 THEN

			SELECT COUNT(num_credito)
				INTO vCanReg
				FROM bdicred:sd_tarjeta
				WHERE empresa = '001' AND num_credito = pNumeroCuenta AND tipo_tarjeta='A' AND status_tar = 'A';

			IF vCanReg IS NULL OR vCanReg = 0 THEN

				LET vCanReg ="001";
				LET vCodRet = "00000";

			ELSE

				IF (vCanReg = 1) THEN

					LET vCanReg ="002";
					LET vCodRet = "00000";
				ELSE
					LET vCanReg ="003";
					LET vCodRet = "00000";
				END IF;
			END IF;

			IF(SELECT count(num_credito) from bdicred:sd_tarjeta WHERE empresa = '001' AND num_credito = pNumeroCuenta AND tipo_tarjeta='A' AND status_tar = 'A'  AND TRIM(numcte) = pNumeroClienteAdic) > 0 THEN
				LET vCodRet = "00110";
			END IF;

		ELSE  --Cuenta No existe

			LET vCodRet = "00100";
			LET vCanReg ="";
		END IF;
		RETURN vCodRet , vCanReg;
	END;

END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 16/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_conscreditocte(pNumEmpresa CHAR(3), pNumTarjeta CHAR(20))

    RETURNING CHAR(5), CHAR(20), CHAR(20);

    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
	DEFINE cNumCredito CHAR(20);
	DEFINE cNumCliente CHAR(20);

    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr = 0;
    LET cCodRet = '00000';
	LET cNumCredito = '';
	LET cNumCliente = '';

    --SET DEBUG FILE TO "/tmp/sp_conscreditocte.out";
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET sSqlErr
			IF sSqlErr <> 0 THEN
				LET cCodRet = sSqlErr;
				RETURN cCodRet, cNumCredito, cNumCliente;
			END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT num_credito, numcte
		INTO cNumCredito, cNumCliente
		FROM "informix".sd_tarjeta
		WHERE empresa = pNumEmpresa AND num_tarjeta = pNumTarjeta;

		IF NVL(cNumCredito, '') = '' OR NVL(cNumCliente , '') = '' THEN
			LET cCodRet = '00001';
		END IF

		RETURN cCodRet, cNumCredito, cNumCliente;
    END;
END PROCEDURE
DOCUMENT
"Consulta de Credito y Cliente por Numero de Tarjeta",
"AUTOR: Iris Arias Zazueta",
"FECHA: 05/01/2017",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_consulta_datos_general_web(pEmpresa      CHAR(3), 
                                                      pNumCte       CHAR(20),
                                                      pNumCredito   CHAR(20),
                                                      pNumTarjeta   CHAR(20),
                                                      pApellidosPat CHAR(26),
                                                      pApellidosMat CHAR(26),
													  pNumProd      CHAR(4))
RETURNING CHAR(5)   AS codigo_retorno,
          CHAR(80)  AS mensaje_retorno,
          CHAR(20)  AS numero_credito,
          CHAR(20)  AS numero_cliente,
          CHAR(40)  AS nombre_producto,
          CHAR(20)  AS numero_tarjeta,
          CHAR(150) AS nombre_cliente;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE cNumCredito   CHAR(20);
DEFINE cNumCte       CHAR(20);
DEFINE cNomProducto  CHAR(40);
DEFINE cNumTarjeta   CHAR(20);
DEFINE cNomCte       CHAR(150);
DEFINE cCodprod        CHAR(2);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '';
LET cMensajeRet   = '';

LET cNumCredito   = '';
LET cNumCte       = '';
LET cNomProducto  = '';
LET cNumTarjeta   = '';
LET cNomCte       = '';
LET cCodprod      = '';

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
    END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_consulta_datos_general';
--TRACE ON;

--Fecha: 25/06/2009
-- Modificacion: Se separo el query principal 
-- Autor: Roque Solis C.

-- Fecha. 05/10/2009
-- Modificacion: Se duplicaron querys para consultar los datos para prestamos personales
-- Autor: Roque Solis C.

LET cCodRet= '00000';
LET cMensajeRet= 'Se realizÃ³ la consulta correctamente.';

IF pNumProd = '' THEN
   LET pNumProd = NULL;
END IF;

IF NVL(pNumCte,'') = '' THEN
  LET pNumCte = NULL; 
END IF;

IF NVL(pNumCredito,'') = '' THEN
  LET pNumCredito = NULL;
END IF;

IF NVL(pNumTarjeta,'') = '' THEN
  LET pNumTarjeta = NULL;
ELSE 
    SELECT num_credito
      INTO pNumCredito
      FROM "informix".sd_tarjeta
     WHERE empresa     = pEmpresa
       AND num_tarjeta = pNumTarjeta;
END IF;

IF NVL(pApellidosPat,'') = '' THEN
  LET pApellidosPat = NULL;
END IF;

IF NVL(pApellidosMat,'') = '' THEN
  LET pApellidosMat = NULL;
END IF;

IF pNumCte IS NULL AND pNumCredito IS NULL AND pNumTarjeta IS NULL AND pApellidosPat IS NULL AND pApellidosMat IS NULL THEN
   LET cCodRet= '00001';
   LET cMensajeRet= 'No hay informaciÃ³n para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
END IF;

    IF pNumCredito IS NOT NULL THEN
    
	   -- consulta por numero de credito para creditos normales
      -- FOREACH


                SELECT num_credito,b.cod_prod
                  INTO cNumCredito,cCodprod
                  FROM bdicred:sd_maecred a,
                       bdicred:sd_tipprod b
                 WHERE a.num_credito = pNumCredito
                   AND a.empresa=pEmpresa
                   AND a.empresa=b.empresa 
                   AND a.num_producto=b.abrevia_prod;

                    IF cNumCredito IS NULL OR cCodprod IS NULL THEN
                        SELECT num_credito,b.cod_prod
                          INTO cNumCredito,cCodprod
                          FROM bdicred:sd_maecredcrd a,
                               bdicred:sd_tipprod b
                         WHERE a.num_credito = pNumCredito
                           AND a.empresa=pEmpresa
                           AND a.empresa=b.empresa 
                           AND a.num_producto=b.abrevia_prod;
                        IF cNumCredito IS NULL OR cCodprod IS NULL THEN
                           LET cCodRet     = '00001';
                           LET cMensajeRet = 'EL PRODUCTO NO EXISTE FAVOR DE CONFIRMAR';
                           RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
                        END IF;
                    END IF;

       IF cCodprod ='T' THEN
	   
		 IF SUBSTR(cNumCredito,1,2) = "78" THEN 
			SELECT a.num_credito,
					   a.numcte,
					   '',
					   c.nombre_prod,
					   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
				  INTO cNumCredito,
					   cNumCte,
					   cNumTarjeta,
					   cNomProducto, 
					   cNomCte
				  FROM "informix".sd_maecred a,
					   bdinteg:"informix".si_cliente b, 
					   "informix".sd_definicion c
					 
				 WHERE c.num_producto = a.num_producto
				   AND c.empresa = a.empresa
				   AND b.empresa = a.empresa
				   AND c.num_producto = a.num_producto
				   AND b.numcte = a.numcte
				   AND b.apell_paterno=  b.apell_paterno 
				   AND b.apell_materno=  b.apell_materno 				   
				   AND a.empresa = pEmpresa
				   AND a.num_credito= pNumCredito;  
				   
				   IF cNumCredito IS NOT NULL THEN
					   LET nrows=nrows+1;
					   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
				   END IF;
		   --END FOREACH;
			ELSE
			   SELECT a.num_credito,
					   a.numcte,
					   d.num_tarjeta,
					   c.nombre_prod,
					   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
				  INTO cNumCredito,
					   cNumCte,
					   cNumTarjeta,
					   cNomProducto, 
					   cNomCte
				  FROM "informix".sd_maecred a,
					   bdinteg:"informix".si_cliente b, 
					   "informix".sd_definicion c, 
					   "informix".sd_tarjeta d
				 WHERE c.num_producto = a.num_producto
				   AND c.empresa = a.empresa
				   AND b.empresa = a.empresa
				   AND d.empresa = a.empresa
				   AND c.num_producto = a.num_producto
				   AND b.numcte = a.numcte
				   AND b.apell_paterno=  b.apell_paterno 
				   AND b.apell_materno=  b.apell_materno 
				   AND d.num_credito = a.num_credito
				   AND d.tipo_tarjeta = 'T'
				   and d.secuencia = (SELECT MAX(secuencia) 
										FROM bdicred:sd_tarjeta 
									   WHERE a.empresa = empresa 
										 AND a.num_credito = num_credito 
										 AND tipo_tarjeta = 'T')
				   AND a.empresa = pEmpresa
				   AND a.num_credito= pNumCredito;  
				   
				   IF cNumCredito IS NOT NULL THEN
					   LET nrows=nrows+1;
					   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
				   END IF;
		   --END FOREACH;
		   END IF;
       END IF;

       IF cCodprod IN ('P','R') THEN
	          --consulta de por numero de credito para prestamos personales
		      --FOREACH
	           SELECT a.num_credito,
	                   a.numcte,
	                   c.nombre_prod,
	                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	              INTO cNumCredito,
	                   cNumCte,
	                   cNomProducto, 
	                   cNomCte
	              FROM "informix".sd_maecredcrd a,
	                   bdinteg:"informix".si_cliente b, 
	                   "informix".sd_definicion c
	             WHERE c.num_producto = a.num_producto
	               AND c.empresa = a.empresa
	               AND b.empresa = a.empresa
	               AND c.num_producto = a.num_producto
	               AND b.numcte = a.numcte
	               AND b.apell_paterno=  b.apell_paterno 
	               AND b.apell_materno=  b.apell_materno 
	               AND a.empresa = pEmpresa
	               AND a.num_credito = pNumCredito  
				   AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END);
	               
	               IF cNumCredito IS NOT NULL THEN
	    	           LET nrows=nrows+1;
	                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
	               END IF;
	          --END FOREACH; 
       END IF;
	   
    ELIF pNumCte IS NOT NULL THEN
         --consulta por numero de cliente para creditos normales
         FOREACH
              SELECT num_credito
                INTO pNumCredito
                FROM "informix".sd_maecred
               WHERE numcte = pNumCte
                 AND empresa = pEmpresa 
                 AND num_producto = (CASE WHEN pNumProd IS NULL THEN num_producto ELSE pNumProd END)		 				 
              
	              --FOREACH
	              
	                 SELECT a.num_credito,
	                       a.numcte,
	                       d.num_tarjeta,
	                       c.nombre_prod,
	                       TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	                  INTO cNumCredito,
	                       cNumCte,
	                       cNumTarjeta,
	                       cNomProducto, 
	                       cNomCte
	                  FROM "informix".sd_maecred a,
	                       bdinteg:"informix".si_cliente b, 
	                       "informix".sd_definicion c, 
	                       "informix".sd_tarjeta d
	                 WHERE c.num_producto = a.num_producto
	                   AND c.empresa = a.empresa
	                   AND b.empresa = a.empresa
	                   AND d.empresa = a.empresa
	                   AND b.numcte = a.numcte
	                   AND b.apell_paterno=  b.apell_paterno 
	                   AND b.apell_materno=  b.apell_materno 
	                   AND d.num_credito = a.num_credito
	                   AND d.tipo_tarjeta = 'T'
	                   AND d.secuencia = (SELECT MAX(secuencia) 
					                        FROM bdicred:sd_tarjeta 
										   WHERE a.empresa = empresa 
										     AND a.num_credito = num_credito 
											 AND tipo_tarjeta = 'T')
	                   AND d.empresa = a.empresa
	                   AND a.empresa = pEmpresa
	                   AND a.num_credito = pNumCredito;
                        					   
	                   
	                   IF cNumCredito IS NOT NULL THEN
	        	           LET nrows=nrows+1;
	                       RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	                   END IF;
	                      
	                  --END FOREACH;                  
	              
	        END FOREACH;
			
			LET cNumTarjeta='';
			    --consulta por numero de credito para prestamos personales
			    FOREACH
	              SELECT num_credito
	                INTO pNumCredito
	                FROM "informix".sd_maecredcrd
	               WHERE numcte=pNumCte
	                 AND empresa=pEmpresa
                     AND num_producto = (CASE WHEN pNumProd IS NULL THEN num_producto ELSE pNumProd END)		 
	              
	              --FOREACH
	              
	                 SELECT a.num_credito,
	                       a.numcte,
	                       c.nombre_prod,
	                       TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	                  INTO cNumCredito,
	                       cNumCte,
	                       cNomProducto, 
	                       cNomCte
	                  FROM "informix".sd_maecredcrd a,
	                       bdinteg:"informix".si_cliente b, 
	                       "informix".sd_definicion c 
	                 WHERE c.num_producto = a.num_producto
	                   AND c.empresa = a.empresa
	                   AND b.empresa = a.empresa
	                   AND b.numcte = a.numcte
	                   AND b.apell_paterno=  b.apell_paterno 
	                   AND b.apell_materno=  b.apell_materno 
	                   AND a.empresa = pEmpresa
	                   AND a.num_credito= pNumCredito;  
	                   
	                   IF cNumCredito IS NOT NULL THEN
	        	           LET nrows=nrows+1;
	                       RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	                   END IF;
	                      
	                  --END FOREACH;                  
	              
	              END FOREACH;
         
    ELIF pApellidosPat IS NOT NULL OR pApellidosMat IS NOT NULL THEN 
         --consulta por nombre para credito normales
       FOREACH 
         SELECT a.num_credito
           INTO pNumCredito
           FROM bdicred:sd_maecred a, bdinteg:"informix".si_cliente b
          WHERE b.apell_paterno = pApellidosPat 
            AND b.apell_materno = (CASE WHEN pApellidosMat IS NULL THEN b.apell_materno ELSE pApellidosMat END)
            AND a.empresa= b.empresa
            AND b.numcte = a.numcte
            AND a.empresa= pEmpresa
			AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END)
        
           --FOREACH
               
               SELECT a.num_credito,
                   a.numcte,
                   d.num_tarjeta,
                   c.nombre_prod,
                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
              INTO cNumCredito,
                   cNumCte,
                   cNumTarjeta,
                   cNomProducto, 
                   cNomCte
              FROM "informix".sd_maecred a,
                   bdinteg:"informix".si_cliente b, 
                   "informix".sd_definicion c, 
                   "informix".sd_tarjeta d
             WHERE c.num_producto = a.num_producto
               AND c.empresa = a.empresa
               AND b.empresa = a.empresa
               AND d.empresa = a.empresa
               AND b.numcte = a.numcte
               AND b.apell_paterno=  b.apell_paterno 
               AND b.apell_materno=  b.apell_materno 
               AND d.num_credito = a.num_credito
               AND d.tipo_tarjeta = 'T'
               AND d.secuencia = (SELECT MAX(secuencia) 
			                        FROM bdicred:sd_tarjeta 
								   WHERE a.empresa = empresa 
								     AND a.num_credito = num_credito 
									 AND tipo_tarjeta = 'T')
               AND d.empresa = a.empresa
               AND a.empresa = pEmpresa
               AND a.num_credito= pNumCredito;  
               
               IF cNumCredito IS NOT NULL THEN
    	           LET nrows=nrows+1;
                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
               END IF;
           --END FOREACH;           
       END FOREACH;
	   
	      --CONSULTA POR NOMBRE PARA PRESTAMOS PERSONALES
		  LET cNumTarjeta='';
	      FOREACH 
	         SELECT a.num_credito
	           INTO pNumCredito
	           FROM bdicred:sd_maecredcrd a, bdinteg:"informix".si_cliente b
	          WHERE b.apell_paterno = pApellidosPat 
	            AND b.apell_materno = (CASE WHEN pApellidosMat IS NULL THEN b.apell_materno ELSE pApellidosMat END)
	            AND a.empresa= b.empresa
	            AND b.numcte = a.numcte
	            AND a.empresa= pEmpresa
				AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END)
	        
	           --FOREACH
	               
	               SELECT a.num_credito,
	                   a.numcte,
	                   c.nombre_prod,
	                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	              INTO cNumCredito,
	                   cNumCte,
	                   cNomProducto, 
	                   cNomCte
	              FROM "informix".sd_maecredcrd a,
	                   bdinteg:"informix".si_cliente b, 
	                   "informix".sd_definicion c 
	             WHERE c.num_producto = a.num_producto
	               AND c.empresa = a.empresa
	               AND b.empresa = a.empresa
	               AND b.numcte = a.numcte
	               AND b.apell_paterno=  b.apell_paterno 
	               AND b.apell_materno=  b.apell_materno 
	               AND a.empresa = pEmpresa
	               AND a.num_credito= pNumCredito;  
	               
	               IF cNumCredito IS NOT NULL THEN
	    	           LET nrows=nrows+1;
	                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	               END IF;
	           END FOREACH;           
	       --END FOREACH;
    END IF
  
IF nrows= 0 THEN
   LET cCodRet= '00002';
   LET cMensajeRet= 'No hay datos con la informaciÃ³n indicada';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para realizar una consulta general',
'para obtener la informaciÃ³n basica del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 17/06/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultaplazos_web(pNumPromocion SMALLINT)
	RETURNING CHAR(5) AS CodRetorno, INTEGER AS Plazo, INTEGER AS RegAct, INTEGER AS Tasa;	--DSB20140610

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE iPlazo  INTEGER;
DEFINE iCanReg INTEGER;
DEFINE iTasa	INTEGER;		--DSB20140610

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET iPlazo = 0;
LET iCanReg = 1;
LET iTasa	= 0;				--DSB20140610

--SET DEBUG FILE TO '/tmp/sp_consultaplazos.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iPlazo, iCanReg, iTasa;	--DSB20140610
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	FOREACH
		SELECT plazo, tasa						--DSB20140610
		INTO iPlazo, iTasa
		FROM bdicred:"informix".sd_tasa_plazo
		WHERE num_promo = pNumPromocion ORDER BY plazo
		RETURN cCodRet, iPlazo, iCanReg, iTasa WITH RESUME;		--DSB20140610
	END FOREACH;
	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Regresa los plazos para las promociones activas',
'AUTOR : Adrian Lara I',
'FECHA : 02/02/2012',
'BD: bdicred',
'SISTEMA : 6',
'-- Folio.........: 1452 - CrediSoluciones',
'-- Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'-- Fecha.........: 10/06/2014 - DSB20140610',
'-- ModificaciÃ³n..: Se modifica para que retorne la tasa de interes y se muestre en la dll de Credisoluciones',
'-- Sustento......: Analisis incidencias credisoluciones.doc',
'-- Solicita......: Faviola Martinez',
'-- BD............: Bdicred';

CREATE PROCEDURE "informix".sp_elimina_adicionales_pendientes_web (pEmpresa char(3),pClienteAdicional char(20),pCredito char(20))
	--DATOS A REGRESAR
	RETURNING 
	CHAR(6) AS cCodRet;
	
--============= DEFINIR VARIABLES =============
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE sClienteTitular CHAR(20);
	
--============= INICIALIZAR VARIABLES ===========
	LET cCodRet = '00000';
	LET sClienteTitular = '';
--==================================================
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			LET cCodRet = iSqlErr;
			RETURN  cCodRet;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		-- SET DEBUG FILE TO "/respaldosbd/Bryan/sp_elimina_adicionales_pendientes.out";
		-- TRACE ON;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pClienteAdicional,'') = '' OR NVL(pCredito,'') = '' THEN
			LET cCodRet = '00001';
		ELSE
			--Validar que exista el adicional en la tabla de sd_adicionalespendientes
			SELECT LIMIT 1 numctetitular 
			INTO sClienteTitular
			FROM bdicred:"informix".sd_adicionalespendientes
			WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
			AND credito = pCredito;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--Registro no existe
				LET cCodRet = '00002';
			ELSE
				-- Existe y se elimina el registro
				DELETE FROM bdicred:"informix".sd_adicionalespendientes
				WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
				AND credito = pCredito;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					-- Si existe el registro pero no se elimino 
					LET cCodRet = '00003';
				END IF;
			END IF
		END IF;

		RETURN  cCodRet;
END
END PROCEDURE

DOCUMENT 
'Folio: 226',
'Autor: 93034687 - Bryan Limon',
'Fecha: 15/11/2017',
'ModificaciÃ³n: Crear procedimiento el cÃºal consulte si existe el registro en la tabla sd_adicionalespendientes y eliminarlo',
'Sustento: basado en el requerimiento 10 810 Solicitud de Tarjetas Adicionales Tarjeta de CrÃ©dito',
'Solicita: Abrham Narvaez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_eliminaadicional_web(pNumeroCuenta char(26), pNumeroCliente char(26),pTipo smallint)
        
	-- DATOS A REGRESAR
        RETURNING
        char(5);        -- Codigo de retorno

        -- Declaracion de variables
        DEFINE vCodRet          char(5);
        DEFINE vsecuencia       smallint;
        DEFINE vnumcte          char(26);
        DEFINE vContador        smallint;
        DEFINE vtipo            smallint;
        DEFINE vNumerocuenta    char(26);

        -- Se Inicializan las Variables
        LET vCodRet  = "00000";
        LET vsecuencia=0;
        LET vnumcte = "";
        LET vContador = 1;

        --SET DEBUG FILE TO '/tmp/SPEliminaAdicional2.OUT';
        --TRACE ON;

	BEGIN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
        IF ptipo=1 THEN -- aDICIONAL DE credito

	 -- Se verifica que exista el nÃÂºmero de cuenta
		IF(SELECT count(numcte)
			FROM bdicred:sd_tarjeta
			WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicred:sd_tarjeta
							WHERE numcte = pNumeroCliente AND tipo_tarjeta='A' AND num_credito = pNumeroCuenta)) > 0 THEN
			SELECT MAX(secuencia)
					INTO Vsecuencia
					FROM bdicred:sd_tarjeta
					WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta  AND tipo_tarjeta='A' AND status_tar='A';

			UPDATE bdicred:sd_tarjeta
					SET status_tar = 'C'
			WHERE numcte = pNumeroCliente
					AND  num_credito = pNumeroCuenta
					AND secuencia = vsecuencia;

			LET vCodRet = "00000";
			RETURN vCodRet ;

        ELSE  --Cliente NO EXISTE

                        LET vCodRet="00259";
                        RETURN vCodRet ;

        END IF;
---------------------------------------------------------------------------
        ELSE    --Buscar Datos de DICIONAL DE DEBITO
        let vnumcte = pnumerocliente;
        LET vnumerocuenta = pnumerocuenta;
        let vtipo = ptipo;

                IF(SELECT count(numcte)
                        FROM bdicheq:sc_firmantes
                        WHERE numcte = pNumeroCliente
                                AND cuenta = pNumeroCuenta) > 0 THEN

                        DELETE FROM bdicheq:sc_firmantes
                                WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta;

                        IF(SELECT count(secuencia)
                                  FROM bdicheq:sc_firmantes
                                  WHERE cuenta = pNumeroCuenta
                                  AND secuencia <>1) > 0 THEN

                                UPDATE bdicheq:sc_firmantes SET secuencia = 2
                                WHERE cuenta = pNumeroCuenta
                                AND secuencia <>1;

                        END IF;

                        IF(SELECT count(numcte)
                                FROM  bdicheq:sc_tarjeta
                                WHERE  numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A' AND status_tar = 'A') > 0 THEN

                                SELECT MAX(secuencia) INTO vSecuencia
                                        FROM bdicheq:sc_tarjeta
                                        WHERE cuenta = pnumerocuenta
                                                AND numcte = pNumeroCliente
                                                AND tipo_tarjeta='A'
                                                AND status_tar = 'A';

                                UPDATE bdicheq:sc_tarjeta
                                    SET status_tar = 'C'
                                    WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A'
                                        AND secuencia = vSecuencia;

                                LET vCodRet = "00000";
                                RETURN vCodRet ;

                        END IF;

                        LET vCodRet = "00000";
                        RETURN vCodRet ;

                ELSE  --Cliente cLIENTE nO EXISTE

                        LET Vcodret = "00259";
                        RETURN vCodRet ;

                END IF ;

        END IF;
END;
END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 15/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicheq,bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_actvig_camp_mx() 
RETURNING CHAR(6),CHAR(55);

DEFINE iSqlErr			INTEGER;
DEFINE cCodRet 			CHAR(6);
DEFINE cmensaje 		CHAR(55);
DEFINE cRuta 			CHAR (50);
DEFINE cnom_archivo		CHAR(30);
DEFINE cBitacoraCamp	CHAR (50);
DEFINE cBitacCampSms	CHAR (50);
DEFINE cCadena  		CHAR (500);
DEFINE siPromo 			varchar(5);
DEFINE dtIni_Vig 		DATE;
DEFINE dtFin_Vig 		DATE;
DEFINE dtIni_Vig_min 	DATE; 
DEFINE dtIni_Vig_max 	DATE;
DEFINE siPlazo 			varchar(5);
DEFINE siTasa 			decimal(10,2);
DEFINE wBegin           CHAR(1);
DEFINE cArchivo_dbld    CHAR(50);
DEFINE cArchivo_log     CHAR(50);
DEFINE cfec_arch		CHAR(8);
DEFINE dt_fec_carga 	DATE;
DEFINE sContador		SMALLINT;
DEFINE sContadorAux		SMALLINT;
DEFINE sContadorAux2	SMALLINT;
DEFINE sTasasSms		SMALLINT;
DEFINE iMonto_Ini		DECIMAL(10,2);
DEFINE iMonto_Fin 		DECIMAL(10,2);
DEFINE cMontos			CHAR(21);

LET iSqlErr 		= 0;
LET cCodRet 		= '000001';
LET cmensaje 		= 'Actualizacion de Vigencia Credisoluciones Ok';
LET cCadena 		= '';
LET cRuta 			= '';
LET cnom_archivo	= '';
LET cBitacoraCamp	= '';
LET cBitacCampSms   = '';
LET siPromo 		= 0;
LET dtIni_Vig 		= '';
LET dtFin_Vig 		= '';
LET siPlazo 		= 0;
LET siTasa 			= 0;
LET wBegin 			= '';
LET cfec_arch		= '';
LET sContador		= 0;
LET sContadorAux	= 0;
LET sContadorAux2	= 0;
LET sTasasSms		= 0;
LET cMontos			= '';
LET iMonto_Ini 		= 0;
LET iMonto_Fin		= 0;
LET cArchivo_dbld   = "f_actvig_prosp.com";
LET cArchivo_log    = "f_actvig_prosp.log";

BEGIN

	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		RETURN cCodRet,cmensaje;
	END EXCEPTION;
   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   

	SET DEBUG FILE TO '/tmp/sp_actvig_camp.out';
    TRACE ON;
	
	SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),fecha_hoy
	  INTO cfec_arch,dt_fec_carga
	  FROM bdicred:sd_fechas;
	
    LET cnom_archivo = "actvig_prospectos_"||cfec_arch||'.txt';
    LET cBitacoraCamp = "bitacora_actvig_prospectos_"||cfec_arch||'.txt';
	LET cBitacCampSms = "bitacora_actvig_prospectos_sms_"||cfec_arch||'.txt';
    LET cRuta = "/resplogifx/archivoscredito/";   

	--DROP TABLE IF EXISTS "informix".sd_actvig_camp;
    DROP TABLE IF EXISTS "informix".sd_actvig_camp;	
	CREATE TABLE sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21)
	);
		
   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cnom_archivo) ||' DELIMITER '|| "'" || '|' || "'" || ' 7; ' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
   system ' echo "INSERT INTO sd_actvig_camp;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
   system ' chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

	 --system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_actvig_prosp.sh';
	 --system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh'; 
	 --system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	 --system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';             
	 --system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';          
	 --system ' echo "update statistics medium for table sd_actvig_camp; ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	--system 'chmod 777 /usr/bin/sh ';
	system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	create index inx1_activ_camp on sd_actvig_camp(origen);
	 
	
	-- Valida que esten correctamente escritas las palabras: sucursal y sms
	LET sContador = 0;
	UPDATE bdicred:sd_actvig_camp SET origen = lower(origen);
	SELECT COUNT(camp) INTO sContador FROM bdicred:sd_actvig_camp WHERE origen != "sucursal" AND origen != "sms";
	IF sContador > 0 THEN
		LET cCodRet = '000003';
		LET cmensaje = 'Banderas de origen (sucursal o sms) son incorrectas.';
		RETURN cCodRet,cmensaje;
	END IF;
	
	-- Valida que los registros marcados como sms no superen los 4 por plazo.
	DROP TABLE IF EXISTS "informix".tmp_plazsms;
	SELECT camp, count(camp) total_p FROM bdicred:sd_actvig_camp WHERE origen = "sms" GROUP BY camp INTO temp tmp_plazsms WITH NO LOG;
	LET sContador = 0;
    SELECT MAX(total_p) INTO sContador FROM tmp_plazsms;

	IF sContador > 4 THEN	-- Maximo 4 plazos por campania.
		LET cCodRet = '000004';
		LET cmensaje = 'Numero de plazos para SMS No debe de ser mayor a 4.';
		RETURN cCodRet,cmensaje;
	END IF;

	-- Valida fechas.
	SELECT min (f_ini_vig), max(f_ini_vig) INTO dtIni_Vig_min, dtIni_Vig_max
	  FROM sd_actvig_camp WHERE origen = 'sucursal';
		
	IF ( dtIni_Vig_min <> dtIni_Vig_max ) THEN
		LET cCodRet = '000001';
		LET cmensaje = 'Diferentes inicios de vigencia';		
	ELIF  ((dtIni_Vig_min <> dt_fec_carga) OR (dtIni_Vig_max <> dt_fec_carga))THEN
		LET cCodRet = '000002';
		LET cmensaje = 'No coincide inicio de vigencia Vs fecha actual';	
	ELSE
		LET cCodRet = '000000';
	END IF;
	
	-- Indentifica si existen registros para SMS Y valida los montos asignados.
	SELECT COUNT(camp) INTO sTasasSms FROM bdicred:sd_actvig_camp WHERE origen = "sms";
	IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'sms'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una comda. Solo se permite el separador guion. 			
			IF sContador <= 0 OR sContadorAux > 0 OR sContadorAux2 > 0 THEN	
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
			-- Valida que solo pueda enviarse una estructura de '500-600' si tiene otro caracter se rechaza.
			IF bdinteg:val_num(SUBSTR(cMontos, 1, (sContador - 1))) = 'f' OR bdinteg:val_num(SUBSTR (cMontos, (sContador + 1), length(cMontos))) = 'f' THEN
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
		END FOREACH;
	END IF;

	IF cCodRet = '000000' THEN 

		-- Actualiza tasas para pagos fijos sucursales.
		FOREACH WITH HOLD
		   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa   --cast(tasa as decimal(18,2))
			 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa
			 FROM sd_actvig_camp WHERE origen = 'sucursal'

			BEGIN;
				UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
				UPDATE "informix".sd_tasa_plazo SET tasa = siTasa WHERE num_promo = siPromo and plazo = siPlazo;
			COMMIT;
		END FOREACH;
		
		-- Genera informacion de plazos y tasas para SMS
		IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
			BEGIN;
				TRUNCATE TABLE bdicred:sd_tasa_plazo_sms;
			COMMIT;
			
			LET cMontos = '';
			FOREACH WITH HOLD
			   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa,   montos   --cast(tasa as decimal(18,2))
				 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa, cMontos
				 FROM sd_actvig_camp WHERE origen = 'sms'
				 
				 
				LET sContador = CHARINDEX('-',cMontos);
				LET iMonto_Ini = SUBSTR(cMontos, 1, (sContador - 1));
				LET iMonto_Fin = SUBSTR (cMontos, (sContador + 1), length(cMontos));
			
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '6001'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
				COMMIT;

			END FOREACH;
		END IF;	
			  
		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacoraCamp)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sucursal''' ||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp1.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp1.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp1.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp1.sql';
		SYSTEM cCadena;

		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampSms)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_sms  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sms'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
	END IF;
	
	---	DROP TABLE sd_actvig_camp;

	RETURN cCodRet,cmensaje;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : Pamela Cardenas Balderas',
'FECHA : 30/MAYO/2018',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_calcula_interes_tdc(pEmpresa 				CHAR(3),
														pNumCredito 			CHAR(20),
														pFechaEmision 			DATE,
														pInicioSkip				INTEGER,
														pLimiteRegistros		INTEGER)
RETURNING	CHAR(5)   as codret,
			CHAR(30)  as cFechaCompleta,  
			CHAR(255) as cConcepto,
			CHAR(16)  as cCargo,
			CHAR(16)  as cAbono,
			CHAR(16)  as cSaldoPromedioDiario,
			CHAR(16)  as cSaldoSobCalculoInteres,
			CHAR(5)   as dInteresDiario

--------------------------------------------------------
-- DEFINICION DE VARIABLES 
--------------------------------------------------------
DEFINE sql_err   					SMALLINT;
DEFINE sCodRet   					CHAR(5);
DEFINE sCodRet2   					CHAR(5);
DEFINE sCodRet3   					CHAR(5);

DEFINE dFechaEmision 				DATE ;

DEFINE cSaldoPromedioDiario			CHAR(16);
DEFINE cConcepto 					CHAR(255);
DEFINE cCargo 						CHAR(16); --Compras
DEFINE cAbono 						CHAR(16);

DEFINE cSigFechaMov   				CHAR(9);
DEFINE cFechaMovAnt   				CHAR(9);
DEFINE cConceptoAnt   				CHAR(255);

DEFINE cSaldoPromedioDiarioInt		CHAR(16);
DEFINE cSaldoPromedioDiarioAux		CHAR(16);
DEFINE cUltimoSaldoDiario			CHAR(16);

DEFINE cEsIvaIntereses				CHAR(1);
DEFINE sMesAPoner					SMALLINT;
DEFINE sMesIngresado				SMALLINT;
DEFINE cSaldoDiario 				DECIMAL (14,2);

DEFINE cAnioCorto					CHAR(2);
DEFINE cMesAbreviado				CHAR(3);
DEFINE cDiaActual					CHAR(2);
DEFINE cMesNumero					CHAR(2);
DEFINE cAnioCompleto				CHAR(4);
DEFINE cMesCompleto					CHAR(10);
DEFINE cfechaAuxiliar				CHAR(8);
DEFINE cFechaCompleta				CHAR(30);

DEFINE cSaldoSobCalculoInteres		CHAR(16);
DEFINE cSaldoSobreCalculoInteresAnt	CHAR(16);
DEFINE cUltimoSaldoSobCalcInteres	CHAR(16);
DEFINE dInteresDiarioAux			DECIMAL(14,2);
DEFINE dInteresDiario				CHAR(5);
DEFINE iTamanioFecha				INTEGER;

DEFINE sContador                    SMALLINT;
DEFINE sDias						SMALLINT;
DEFINE sMovtos						SMALLINT;
DEFINE sInter						SMALLINT;
DEFINE cTasaInteres					DECIMAL(15,8);
DEFINE cDiaCorte					SMALLINT;
DEFINE cSaldoInicio					DECIMAL(18,2);
DEFINE cSaldoFin					DECIMAL(18,2);
DEFINE sContFecha					DATE;
DEFINE dFechaMov					DATE;
DEFINE sCargos						DECIMAL(18,2);
DEFINE sAbonos						DECIMAL(18,2);
DEFINE sDescripcion					CHAR(255);
DEFINE cSaldoPromedioDiario_t		DECIMAL(18,2);

--------------------------------------------------------
--	INICIALIZACION DE VARIABLES
--------------------------------------------------------
LET sql_err   					= 0;
LET sCodRet   					= "00000";
LET sCodRet2   					= "00000";
LET sCodRet3   					= "00000";

LET dFechaEmision 				= "";

LET cConcepto 					= "";
LET cCargo 						= "";
LET cAbono 						= "";

LET cSigFechaMov 				= "";
LET cFechaMovAnt  				= "";
LET cConceptoAnt  				= "";

LET cSaldoPromedioDiario 		= "";
LET cSaldoPromedioDiarioInt 	= "";
LET cSaldoPromedioDiarioAux		= "";
LET cUltimoSaldoDiario			= "";

LET cEsIvaIntereses 			= "0"; --Se inicializa en 0
LET sMesAPoner 					= 0;
LET sMesIngresado 				= 0;
LET cSaldoDiario 				= 0;

LET cAnioCorto					= "";
LET cMesAbreviado				= "";
LET cDiaActual					= "";
LET cMesNumero					= "";
LET cAnioCompleto				= "";
LET cMesCompleto				= "";
LET cFechaCompleta 				= "";

LET cSaldoSobCalculoInteres 	= "";
LET cSaldoSobreCalculoInteresAnt = "";
LET cUltimoSaldoSobCalcInteres  ="";
LET dInteresDiarioAux			= 0;
LET dInteresDiario				= "";
LET iTamanioFecha 				= 0;

LET sContador                   = 2;
LET sDias                       = 0;
LET sInter	                    = 0;
LET sMovtos						= 0;
LET cTasaInteres			 	= 0;
LET cDiaCorte					= 0;
LET cSaldoInicio				= 0;
LET cSaldoFin					= 0;
LET sContFecha					= DATE(1);
LET dFechaMov					= DATE(1);
LET sCargos						= 0;
LET sAbonos						= 0;
LET sDescripcion				= "";
LET cSaldoPromedioDiario_t		= 0;


BEGIN

	ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
	  DROP TABLE tmp_estado;
      RETURN sCodRet, 
		NVL(cFechaCompleta,""), NVL(cConcepto,""),NVL(cCargo,""),
		NVL(cAbono,""),NVL(cSaldoPromedioDiario,""),NVL(cSaldoSobCalculoInteres,""),NVL(dInteresDiario,0);
	END EXCEPTION ;
		
--SET DEBUG FILE TO "/informix/sp_calcula_interes_tdc_jom.out";
--TRACE ON;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
		
	select a.tasa_interes, dia_corte, nvl(c.sdo_cap_insoluto,0),  nvl(d.sdo_cap_insoluto,0)
	into cTasaInteres, cDiaCorte, cSaldoInicio, cSaldoFin	
	from bdicred:sd_maecred a
	join bdicred:sd_maecredanexo b on (a.num_credito = b.num_credito)
	left outer join bdicred:sd_maesdoshist c on (a.num_credito = c.num_credito and c.fecha = monthadd(mdy(month(pFechaEmision),dia_corte,year(pFechaEmision)),-1))
	left outer join bdicred:sd_maesdoshist d on (a.num_credito = d.num_credito and d.fecha = mdy(month(pFechaEmision),dia_corte,year(pFechaEmision)))
	where a.num_credito = pNumCredito;
		
	select secuencia, naturaleza, fecha_mov, case when naturaleza = 'C' then monto else 0 end cargo,case when naturaleza <> 'C' then monto else 0 end abono, 
			case when transacc = '8197' AND a.codigo_ref = 1 THEN TRIM(SUBSTRING(folio_suc FROM 6))||" Abono por remesa de BTS" 
				 else case when substr(referencia,1,1) = 'i' then nvl(TRIM(SUBSTRING(referencia FROM 18)),'')|| "  " ||NVL(TRIM(rfc_comer),'')|| "  " ||NVL(TRIM(referencia23),'')
                      else c.descripcion
                 end 
            end descripcion
	from bdicred:sd_movhis a
	left outer join bdicred:sd_transfun b on (a.empresa = b.empresa and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref)
	left outer join bdinteg:si_transacc c on (b.transacc = c.numero)
	where a.empresa = '001'
	  and fecha_mov between monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day and mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision))
	  and reversado = 'N'
	  and se_emite_edocta = 'S'
	  and a.num_credito = pNumCredito
	order by fecha_mov,secuencia			
	into temp tmp_estado with no log;
	
	create index inx_tmp_estado on tmp_estado(fecha_mov);
	update statistics medium for table tmp_estado;
	
	IF (pInicioSkip = 0) THEN	
		RETURN sCodRet, "", "USTED DEBIA",cSaldoInicio, 0,0,0,0 WITH RESUME;
	END IF;
	
	LET sDias = (date(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision))) - date(monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day))::integer;
	
	LET sContFecha = monthadd(mdy(month(pFechaEmision),cDiaCorte,year(pFechaEmision)),-1) + 1 units day;
	LET cSaldoPromedioDiario_t = cSaldoInicio;
	LET pLimiteRegistros = pInicioSkip + pLimiteRegistros;


	while sDias >= sInter
		select count(fecha_mov)
		  into sMovtos 
		  from tmp_estado
		where fecha_mov = sContFecha;

		LET cMesCompleto = 	DECODE (month(sContFecha),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre');
		LET cFechaCompleta = LPAD(day(sContFecha),2,'0')||' de '||trim(cMesCompleto)||' del '||LPAD(year(sContFecha),4,'0');
		
		if (sMovtos > 0) then	
			FOREACH WITH HOLD
				select fecha_mov, cargo, abono, descripcion
				  into dFechaMov, sCargos, sAbonos, sDescripcion
				from tmp_estado
				where fecha_mov = sContFecha 
				order by secuencia	
			
				LET cSaldoPromedioDiario_t = cSaldoPromedioDiario_t + sCargos - sAbonos;				
				
				LET sMovtos = sMovtos - 1;
				
				if (sMovtos = 0) then -- Envia ultimo registro
					IF (cSaldoPromedioDiario_t <= 0) THEN
						LET dInteresDiario = 0;
					ELSE
						LET dInteresDiario = round((cSaldoPromedioDiario_t * cTasaInteres / 100) / 360,2);
					END IF;
					if (sContador >= pInicioSkip) then
						RETURN sCodRet, cFechaCompleta, sDescripcion,sCargos, sAbonos,cSaldoPromedioDiario_t,cSaldoPromedioDiario_t,dInteresDiario WITH RESUME;
					end if;
				else
					if (sContador >= pInicioSkip) then
						RETURN sCodRet, cFechaCompleta, sDescripcion,sCargos, sAbonos,cSaldoPromedioDiario_t,"","" WITH RESUME;
					end if;						
				end if;
				LET sContador = sContador + 1;
				if (sContador > pLimiteRegistros) then
					EXIT FOREACH;
				end if;
			END FOREACH;
		else
			if (sContador >= pInicioSkip) then
				IF (cSaldoPromedioDiario_t <= 0) THEN
					LET dInteresDiario = 0;
				ELSE
					LET dInteresDiario = round((cSaldoPromedioDiario_t * cTasaInteres / 100) / 360,2);
				END IF;
				RETURN sCodRet, cFechaCompleta,"",0, 0,cSaldoPromedioDiario_t,cSaldoPromedioDiario_t,dInteresDiario WITH RESUME;
			end if;
			LET sContador = sContador + 1;
		end if;
		
		if (sContador > pLimiteRegistros) then
			LET sInter = sDias + 1;
		end if;
		
		LET sContFecha = sContFecha + 1 units day;
		LET	sInter = sInter +1;

		IF (sContador = pLimiteRegistros) THEN
			RETURN sCodRet, "", "",cSaldoFin, 0,0,0,0 WITH RESUME;
		END IF;		
		
	END WHILE;
	IF (sContador < pLimiteRegistros) THEN
		RETURN sCodRet, "", "USTED DEBE",cSaldoFin, 0,0,0,0 WITH RESUME;
		END IF;
	DROP TABLE tmp_estado;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza sp para calcular interes tdc.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_genrep_cteemp()
RETURNING CHAR(5) AS cod_ret;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE CodRet		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE isam_err		INTEGER;
DEFINE CMensaje    CHAR(80);
DEFINE vsql			CHAR(2000);
DEFINE v_DiaActual	INTEGER;
DEFINE v_MesActual	INTEGER;
DEFINE v_AnioActual	INTEGER;
DEFINE v_TotalEmpActivos INTEGER;
DEFINE v_FechaHoy	DATE;
--*****************************************************
--- Inicializar variables
--*****************************************************
LET CodRet		= '';
LET sql_err		= 0 ;
LET isam_err	= 0 ;
LET CMensaje	= '';

	
--SET DEBUG FILE TO "/aplicacion/ifxsif01/Control-M/sp_genrep_cteemp.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err,isam_err,CMensaje
		LET CodRet = sql_err;
		RETURN CodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
      
	--- Se obtiene la fecha actual del proceso
	SELECT 	DAY(fecha_hoy),		-- Dia actual
			MONTH(fecha_hoy),	-- Mes actual
			YEAR(fecha_hoy),	-- Año actual
			fecha_hoy			-- Fecha actual
	INTO	v_DiaActual,
			v_MesActual,
			v_AnioActual,
			v_FechaHoy 
	FROM	bdicred:"informix".sd_fechas
	WHERE	empresa = '001';

--- se valida si hay campañas activas en el mes actual
	SELECT COUNT(1)
	into v_TotalEmpActivos														-- Variable para contador de Campañas activas
	FROM bdinteg:"informix".si_rel_cte_empleado
	WHERE empresa = '001' AND status_emp = '1'; 

	--- Se valida si hay empleados activas
	IF	(v_TotalEmpActivos <> 0) THEN			
	
			/*
			-- Creacion de tabla que se va a usar temporalmente
			CREATE TABLE bdicred:"informix".sd_cte_empleado(                             
				numcte_banco	VARCHAR(10),   
				num_empleado	VARCHAR(10));

			select numcte_banco, num_empleado
			FROM bdinteg:"informix".si_rel_cte_empleado
			WHERE empresa = '001' AND status_emp = '1'
			INTO bdicred:"informix".sd_cte_empleado  WITH NO LOG;

			-- Generacion del reporte de empleados activos (RelEmpleadosTDCGC_AAAAMMDD.txt)
			let vsql = '';
			let vsql = 'echo "Empleado|Cliente">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||year(v_FechaHoy)||LPAD (MONTH(v_FechaHoy),2,"0")||day(v_FechaHoy)||'.txt';  
			system vsql;  
			*/
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Credito_GC/QA_BajaArchivo.unl select distinct(num_empleado) from bdinteg:"informix".si_rel_cte_empleado where empresa = "001" AND status_emp = "1";">/resplogifx/Credito_GC/QA_BajaScript.sql';      
			system vsql;
					
			let vsql='chmod a+rwx /resplogifx/Credito_GC/QA_BajaScript.sql';
			System vsql;
					
			let vsql = '';
			let vsql= 'dbaccess bdicred /resplogifx/Credito_GC/QA_BajaScript.sql';
			system vsql;
					
			let vsql = vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaScript.sql';
					
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Credito_GC/QA_BajaArchivo.unl >>/resplogifx/Credito_GC/RelEmpleadosTDCGC_"||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			
			system vsql;
			let vsql ='rm /resplogifx/Credito_GC/QA_BajaArchivo.unl';
			system vsql; 
					
			-- Se elimina tabla Temporal
			--DROP TABLE bdicred:"informix".sd_cte_empleado; 
			
		ELSE
			--Generacion de Reporte y Resumen de Campañas de Recompensa Inmediata sin información a reportar
			let vsql = '';
			let vsql = 'echo " <<< No hay información a reportar >>> ">/resplogifx/Credito_GC/RelEmpleadosTDCGC_'||LPAD(MONTH(v_FechaHoy),2,"0")||LPAD(day(v_FechaHoy),2,"0")||year(v_FechaHoy)||'.txt';
			system vsql;
	END IF;	
	
	LET CodRet = '00000'; --> Proceso concluyo exitosamente
	LET CMensaje = 'El archivo se genero correctamente';
	END;
	
	RETURN CodRet;

END PROCEDURE;