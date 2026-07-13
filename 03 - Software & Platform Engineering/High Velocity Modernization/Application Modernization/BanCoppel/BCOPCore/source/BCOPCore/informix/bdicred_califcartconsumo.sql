create procedure "informix".califcartconsumo(pempresa char(3))
       returning char(5);

define vcodret 			        char(5);
define vmensaje			        char(80);
define scod_ret     		    char(5);
define vsqlerr      		    integer;
define vContador 		        smallint;
define vTotalContador 		    smallint;
define vTotal 			        money;
define vGrado 			        char(2);
define vGrado_Aplicar 		    char(2);
define vCredito 		        char(20);
define vPeriodo 		        char(1);
define vNumPeriodo 		        smallint;
define vNum_Periodo 		    smallint;
define vPorcentajeReserva 	    money;
define vImporteReserva 		    money;
define vCalificacion 		    char(1);
define vProducto 		        char(4);
define vSucursal 		        char(4);
define vDivisa 			        char(2);
define vcapital_vig		        money;
define vinteres_vig		        money;

define pfecha 			        date;
define vtotal_dias		        smallint;
define vcapital_venc		    money;
define vinteres_venc		    money;
define vperiodicidad		    char(1);
define vnum_periodos		    smallint; 
define vcalificacion_riesgo	    char(1);
define vnum_producto		    char(4);
define vNvoPeriodo 		        smallint;
define vcuotasvenc 		        money;
define vult_hab_mes 		    date;
define vstatus_proc 		    char(1);
define vprox_fecha              date;
define vpri_hab_mes		        date;

define cEvaluaCC                Char(1);
define vImporteReservaBuroCC    Money(16,2);
define vtotal_capitalizado      Money(16,2);
define vmonto_capitalizado      Money(16,2);
define vStatusCred              char(02);
define vcodigo_ref              integer;
define vcontador_insert         integer;

BEGIN

ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "califcartconsumo.out";
--TRACE ON;
	
LET vcodret        = "000";
LET vtotal_dias    = 0;
LET vcuotasvenc    = 0;
LET vContador 	   = 0;
LET vTotalContador = 0;
LET vcapital_vig   = 0;
LET vinteres_vig   = 0;
LET vNvoPeriodo    = 0;
LET vmensaje 	   = "PROCESO TERMINADO SATISFACTORIAMENTE";
LET vpri_hab_mes   = "";
LET cEvaluaCC= "";
LET vImporteReservaBuroCC= 0;
LET vtotal_capitalizado= 0;
LET vmonto_capitalizado= 0;
LET vStatusCred='';
let vcodigo_ref = 0;
LET vcontador_insert = 0;

    --Obtiene la Fecha del Dia 
    SELECT fecha_hoy, ult_hab_mes, prox_fecha, pri_hab_mes
      INTO pfecha, vult_hab_mes, vprox_fecha, vpri_hab_mes
      FROM sd_fechas  
     WHERE empresa = pempresa;

   -- Valida que sea ultimo dia habil de mes
   -- if pfecha <> vult_hab_mes then
   --    let vcodret = "581";
   --    return vcodret;
   -- end if
   

   -- Valida que ya fue realizado el cierre del dia   
--   SELECT status_proc
--     INTO vstatus_proc
--     FROM sd_contproc
--    WHERE empresa = pempresa and 
--          proceso = "cierre" and
--          status_proc = "F" and
--          fecha = pfecha;
            
   SELECT status_proc
     INTO vstatus_proc
     FROM bdinteg:sx_contproc
    WHERE empresa = pempresa and 
          proceso = "CierreCred" and
          status_proc = "F" and
	  sistema = "06"  and
          fecha = pfecha;

   if vstatus_proc is null then
      let vcodret = "582";
      return vcodret;
   end if
   
    -- Elimina el Movimiento Generado de la Calificacion anterior

    truncate table sd_movcalcval;

    -- Elimina el Movimiento del Dia en Historico
    DELETE FROM sd_histvalcon 
     WHERE empresa = pEmpresa and 
           year(fecha_alta) = Year(pFecha) and 
           month(fecha_alta) = Month(pFecha);

    update statistics medium for table sd_histvalcon;

FOREACH with hold
    SELECT b.num_credito, b.capital_venc, --+ b.interes_venc, 
           b.periodicidad, b.num_periodos, b.interes_venc,
           b.calificacion_riesgo , a.num_producto, a.sucursal, a.divisa, a.status_cred
      INTO vCredito, vTotal,
           vPeriodo, vNum_Periodo, vInteres_venc,
           vGrado, vProducto, vSucursal, vDivisa, vStatusCred
      FROM sd_maecred a, sd_movvalcon b
     WHERE a.empresa = pempresa
       and a.empresa = b.empresa 
       and a.num_credito = b.num_credito
  ORDER BY b.num_credito 

  if (vcontador_insert = 0) then
     begin work;
  end if;

  -- Determina la Periodicidad del Credito
  IF UPPER(vPeriodo) = "S" THEN
     IF vNum_Periodo > 18 THEN
        LET vNum_Periodo = 18;
     END IF
  END IF   


  IF UPPER(vPeriodo) = "Q" THEN
     IF vNum_Periodo > 13 THEN
        LET vNum_Periodo = 13;
     END IF
  END IF   

  IF UPPER(vPeriodo) = "M" THEN
     IF vNum_Periodo > 9 THEN
        LET vNum_Periodo = 9;
     END IF
  END IF   
     
  -- Extrae el Numero de Periodos Vencidos
  
  SELECT porcentaje, grado, grado
    INTO vPorcentajeReserva, vGrado_Aplicar, vCalificacion
    FROM sd_porc_reserva 
   WHERE empresa = pempresa and 
         periodo = vPeriodo and 
         num_periodo = vNum_Periodo and 
         tipocredito = "01";

-- No se toman los intereses en cuenta para creditos con mas de 1 pago vencido
 -- IF UPPER(vPeriodo) = "M" THEN
 --   IF vNum_Periodo > 1 THEN
 --      LET vTotal = vTotal - vInteres_venc;
 --   END IF
 -- END IF

  -- Calcula el Importe de la Reserva
  LET vImporteReserva = vTotal * (vPorcentajeReserva / 100);

  -- Inserta informacion Calculada
  INSERT INTO sd_movcalcval (empresa,
                             num_credito,
                             periodo,
                             num_periodo,
                             grado_riesgo,
                             importe,
                             porcentaje,
                             imp_reservas,
                             calificacion,
                             fecha)
                     VALUES (pEmpresa,
                             vCredito,
                             vPeriodo,
                             vNum_Periodo,
                             vGrado_Aplicar,
                             vTotal,
                             vPorcentajeReserva,
                             vImporteReserva,
                             vCalificacion,
                             pFecha);
                             
  -- Actualiza Maestro de Credito Central
    
    UPDATE sd_maecred SET calificacion_riesgo = vCalificacion
     WHERE empresa = pempresa and
           num_credito = vCredito;
      
  -- Graba Movimiento en Historico de Calificaciones
     
    INSERT INTO sd_histvalcon (empresa,
                               num_credito,
                               fecha_alta,
                               calif_ant,
                               calif_actual,
                               porcentaje,
                               num_periodos,
                               importe,
                               importe_reserva) 
                       VALUES (pEmpresa,
                               vCredito,
                               pFecha,
                               vGrado, 
                               vCalificacion,
                               vPorcentajeReserva,
                               vNum_Periodo,
                               vTotal,
                               vImporteReserva);

-- Jom ini req 07-012

    IF UPPER(vPeriodo) = "M" Then

       LET vNvoPeriodo = vNum_Periodo;
{
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF
       
       IF vNum_Periodo = 1 THEN
          LET vNvoPeriodo = 1;
       END IF
          
       IF vNum_Periodo = 2 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 3 OR vNum_Periodo = 4 OR vNum_Periodo = 5 OR vNum_Periodo = 6 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 THEN
          LET vNvoPeriodo = 4;
       END IF
}
    END IF     

-- Jom fin req 07-012   

    IF UPPER(vPeriodo) = "Q" THEN
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF

       IF vNum_Periodo = 1 OR vNum_Periodo = 2 THEN
          LET vNvoPeriodo = 1;
       END IF

       IF vNum_Periodo = 3 OR vNum_Periodo = 4 OR vNum_Periodo = 5 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 6 OR vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 OR vNum_Periodo = 10 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 11 OR vNum_Periodo = 12 OR vNum_Periodo = 13 THEN
          LET vNvoPeriodo = 4;
       END IF
    End IF
     
    IF UPPER(vPeriodo) = "S" Then
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF

       IF vNum_Periodo = 1 OR vNum_Periodo = 2 OR vNum_Periodo = 3 OR vNum_Periodo = 4 THEN
          LET vNvoPeriodo = 1;
       END IF

       IF vNum_Periodo = 5 OR vNum_Periodo = 6 OR vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 OR vNum_Periodo = 10 OR vNum_Periodo = 11 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 12 OR vNum_Periodo = 13 OR vNum_Periodo = 14 OR vNum_Periodo = 15 OR vNum_Periodo = 16 OR vNum_Periodo = 17 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 16 THEN
          LET vNvoPeriodo = 4;
       END IF

    END IF

  -- Genera Movimiento para Contabilidad                     
        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNvoPeriodo,
				  "665",
				  pFecha,
				  vImporteReserva,
				  "CalifCartReserva",
				  vSucursal,
				  vDivisa,
				  "0000")
        INTO vcodret, vmensaje;
        IF vcodret <> "00000" THEN
           RETURN vcodret;
        END IF

        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNum_Periodo,
				  "666",
				  pFecha,
				  vTotal,
				  "CalifCart",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

  -- Genera Movimiento Inverso para Contabilidad                     
        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNvoPeriodo,
				  "667",
				  vprox_fecha,  --vpri_hab_mes,
				  vImporteReserva,
				  "CalifCartReserva",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNum_Periodo,
				  "668",
				  vprox_fecha, -- 'vpri_hab_mes,
				  vTotal,
				  "CalifCart",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

    -- Reservas por Riesgos Operativos (Clientes con mal Antecedentes en el circulo de Crédito)

     LET cEvaluaCC = '0';

     SELECT evalua_cc
       INTO cEvaluaCC
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa= pEmpresa
        AND num_solicitud = vCredito;

        IF cEvaluaCC IS NULL THEN
            LET cEvaluaCC = '0';
        END IF;

        LET vImporteReservaBuroCC= vImporteReserva * 0.15;
       
    IF cEvaluaCC= '1' THEN
--Califica malos antecedentes
          EXECUTE PROCEDURE genmov_hist(pEmpresa,
                        vCredito,
                        vProducto,
                        51, -- Codigo_ref
                        "661", -- codigo_fun
                        pFecha,
                        vImporteReservaBuroCC,
                        "CalifCart", -- Descripción
                        vSucursal,
                        vDivisa,
                        "0000")
          INTO vcodret, vmensaje;
          IF vcodret <> "00000" THEN
            RETURN vcodret;
          END IF

-- Cancela reserva
          EXECUTE PROCEDURE genmov_hist(pEmpresa,
                        vCredito,
                        vProducto,
                        51, -- Codigo_ref
                        "663", -- codigo_fun
                        vprox_fecha,
                        vImporteReservaBuroCC,
                        "CalifCart", -- Descripción
                        vSucursal,
                        vDivisa,
                        "0000")
          INTO vcodret, vmensaje;
          IF vcodret <> "00000" THEN
            RETURN vcodret;
          END IF
    END IF;

    -- Reservas por Intereses devengados sobre créditos vencidos.

    LET vtotal_capitalizado = 0;
    LET vmonto_capitalizado = 0;

   if vStatusCred = 'BT' then
        FOREACH 
                        select first 4 monto, codigo_ref
                         into vmonto_capitalizado, vcodigo_ref
                        from bdicred:sd_movhis
                        where empresa = pEmpresa
                          and num_credito = vCredito  
                          and codigo_fun = '605' 
--                          and codigo_ref = 2
                          and fecha_mov >= date(0)
                          and reversado = 'N'
                        order by fecha_mov desc

                        if ( vcodigo_ref = 2 ) then
                          let vtotal_capitalizado = vtotal_capitalizado + vmonto_capitalizado;
                        end if;
                        
                       
        END FOREACH;

        if vtotal_capitalizado > 0 then 
        -- INI JOM requerimiento
            let vtotal_capitalizado = vtotal_capitalizado * (1 - (vPorcentajeReserva / 100));
        -- INI JOM requerimiento
             EXECUTE PROCEDURE genmov_hist(pEmpresa,
                                     vCredito,
                                     vProducto,
                                     50, --- Codigo_ref
                                     "661", -- codigo_fun
                                     pFecha,
                                     vtotal_capitalizado,
                                     "CalifCart", -- Descripción
                                     vSucursal, 
                                     vDivisa,
                                     "0000")
            INTO vcodret, vmensaje;
            IF vcodret <> "00000" THEN
                    RETURN vcodret;
            END IF

             EXECUTE PROCEDURE genmov_hist(pEmpresa,
                                     vCredito,
                                     vProducto,
                                     50, --- Codigo_ref
                                     "663", -- codigo_fun
                                     vprox_fecha,
                                     vtotal_capitalizado,
                                     "CalifCart", -- Descripción
                                     vSucursal, 
                                     vDivisa,
                                     "0000")
            INTO vcodret, vmensaje;
            IF vcodret <> "00000" THEN
                    RETURN vcodret;
            END IF

        end if
   end if

        -- *********************************************
        -- Realiza Pase de Movimiento Diario a Historico *
        -- *********************************************
--        INSERT INTO sd_movhis
--             SELECT * FROM sd_movdia
--              WHERE num_credito = vCredito
--                    AND empresa = pEmpresa;

--        DELETE FROM sd_movdia
--              WHERE num_credito = vCredito
--                    AND empresa = pEmpresa;



    let vcontador_insert = vcontador_insert + 1;

    if (vcontador_insert >= 70000) then
        commit work;
        let vcontador_insert = 0;
        update statistics medium for table sd_histvalcon;
        update statistics medium for table sd_movcalcval;
    end if;

END FOREACH

if (vcontador_insert > 0) then
  commit work;
end if;

let vcodret = "000";
RETURN vcodret;

END

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".log_cierrecrd(vEmpresa CHAR(3),
			    vNumCred CHAR(20),
			    vCodRet  CHAR(5),
			    vFecha   DATE,
			    vDesc    VARCHAR(200,1))
RETURNING SMALLINT;


DEFINE vContador SMALLINT;
DEFINE vParamPara SMALLINT;

	SELECT valor INTO vParamPara
	  FROM sd_param
	 WHERE empresa = vEmpresa
	   AND cod_param ="79";

	INSERT INTO sd_valcierrecrd
	 (empresa, cod_ret, num_credito, secuencia, fecha_proc,
	  desc_err)
	VALUES
	 (vEmpresa, vCodRet, vNumCred, 0, vFecha, vDesc);


	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*) INTO vContador
	  FROM sd_valcierrecrd
	 WHERE empresa = vEmpresa
	   AND fecha_proc = vFecha;

	IF vContador >= vParamPara THEN
		RETURN vContador;
	ELSE
		LET vContador = 0;
	END IF

	RETURN vContador;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cal_fecha
					(
					pFecha 		DATE,	-->Fecha  a Calcular
					pTipoSuma 	INT,    -->Tipo para sumar Dia, Mes, Anio
								-->Dia =1, Mes = 2, Anio =3
					pSuma		INT,	-->Cuanto va sumar
				        pUltDiaLab	INT,	-->Ultimo dia laboral L=0,M=1,M=2,J=3,V=4,S=5,D=6
					pDiaHab 	INT 	-->Dia habil anterior=0, o posterior=1
					)

RETURNING CHAR(5),-->Codigo de Retorno
	  DATE ,  -->Fecha de Calculada
	  INT  ,  -->Periodo en que regresara (mes,añio,dias)
	  INT ;   -->Numero de dias Transcurridos

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;

DEFINE vFechaCalculada	DATE;
DEFINE vPeriodo 	INT;
dEFINE vDiaTras		INT;
DEFINE vUltimoDiaMes    DATE;
DEFINE vDias 		INT;
DEFINE vUltDiaLab       INT;
DEFINE vUltDiaMes	DATE;
DEFINE vAnio		int;


--SET DEBUG FILE TO "sp_cal_fecha.out";
--TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          vFechaCalculada,	-->FechaCaluculada
	          vPeriodo,		-->Fecha regresa
		  vDiaTras;		-->Dias Transcurridos
	END EXCEPTION;

LET vcodret = "00000";
LET vUltDiaLab      = 0;
LET vFechaCalculada = " ";
LET vUltimoDiaMes   = " ";
LET vPeriodo 	    = 0;
LET vDiaTras	    = 0;
LET vDias           = 0;
let pFecha          = pFecha;
Let vAnio 	    = 0;

--Calculo por dia =1

	IF pTipoSuma = '1' THEN

		LET	vFechaCalculada = MONTH(pFecha)||"/"||DAY(pFecha)||"/"||YEAR(pFecha);
		LET	vFechaCalculada = vFechaCalculada + pSuma UNITS DAY;
		LET	vPeriodo = 1;
	END IF;

--Calculo por mes =2

	IF pTipoSuma = '2' THEN

	LET	vPeriodo = 2;

	select {+INDEX (sd_fechas idx_sdfechas)} ult_dia_mes
	into vUltDiaMes
	from sd_fechas where empresa='001';


--Fin de Mes
	If pFecha = vUltDiaMes Then
           IF MONTH(pfecha) = 12 THEN
              LET vFechaCalculada  = "01/01/"|| YEAR(pFecha)+1;
           ELSE
              LET vFechaCalculada  = MONTH(pFecha)+1 ||"/01/"|| YEAR(pFecha);
           END IF
	   LET vFechaCalculada = (vFechaCalculada + pSuma UNITS MONTH); ---1 UNITS DAY;
	   LET vFechaCalculada = (vFechaCalculada - 1 UNITS DAY); ---1 UNITS DAY;
--Si es bisiesto
	Else
	        LET vFechaCalculada = MONTH(pFecha) ||"/01/"|| YEAR(pFecha);
        	LET vFechaCalculada = vFechaCalculada + pSuma UNITS MONTH;


        	IF day(pFecha) >= 29 AND MONTH(vFechaCalculada) = 2 THEN
                   IF MOD(YEAR(vFechaCalculada),4) = 0 THEN
              	      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "29" ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "28" ||"/"|| YEAR(vFechaCalculada);
                   END IF
               ELSE
                     LET vUltimoDiaMes = (vFechaCalculada + 1 UNITS MONTH) - 1 UNITS DAY;
                   IF day(pFecha) <= DAY(vUltimoDiaMes) THEN
                     -- LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(pFecha) ||"/"|| YEAR(vFechaCalculada);
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| DAY(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                  END IF

             end if;
        END IF;
 END IF;
--Calculo por anio =3

	LET pFecha = pfecha;
	LET psuma = pSuma;

	IF pTipoSuma = '3' THEN
		LET vAnio = YEAR(pFecha) + psuma;
                   IF MOD(vAnio,4) = 0 THEN
              	      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "29" ||"/"|| vAnio;
                   ELSE
                      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "28" ||"/"|| vAnio;
                   END IF
		LET	vPeriodo = 3;
	END IF;

	--****Calculo del dia habil y fecha porsterior o anterior***--
        LET vUltDiaLab = WeekDay(vFechaCalculada);
        IF pUltDiaLab = vUltDiaLab THEN
	   if pDiaHab = 0 then
	--	LET vFechaCalculada = vFechaCalculada - 1 UNITS DAY;
	     Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
	   Else
	     Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
	   end if
	Elif pUltDiaLab < vUltDiaLab and pUltDiaLab <> 0 Then

	    if pDiaHab = 0 then
               LET vFechaCalculada = vFechaCalculada - (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
       	    Else
               LET vFechaCalculada = vFechaCalculada + (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
	---Si es Domigo - Sabado

	Elif pUltDiaLab > vUltDiaLab and vUltDiaLab = 0 Then
	    if pDiaHab = 0 then

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada - 2 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	   --      	Let vFechaCalculada = (vFechaCalculada -  1 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
            Else

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada +  1 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	--       	Let vFechaCalculada = (vFechaCalculada +  2 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
        END IF;

	--Calcula los dias Transcurridos--

      LET     vDiaTras= ( vFechaCalculada - pFecha );

        RETURN
	vcodret,              --> Codigo de Retorno
        vFechaCalculada,      -->FechaCaluculada
        vPeriodo,             -->Fecha regresa
        vDiaTras;             -->Dias Transcurridos


END
END PROCEDURE
;