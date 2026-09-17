CREATE PROCEDURE "informix".sp_proyecta_prestamo_aux(o_empresa CHAR(3),o_numsol CHAR(20),
								o_limite_inferior DECIMAL (18,2),o_capacidad DECIMAL (18,2),
								o_producto CHAR(4), o_sucursal char (4),o_plazo INTEGER,
								o_ejecucion SMALLINT)
	RETURNING 
			CHAR(6)         AS Codigo, 		  -- CODIGO DE RETORNO
			SMALLINT		AS banderaPP12,	  -- bandera aplica PP12
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
			CHAR(3)         AS NumMesesPago;  -- FECHA DE APERTURA
		
		

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

DEFINE vsqlerr                  INTEGER;
   
DEFINE meses_reevalua		SMALLINT;
DEFINE bc_score 			DECIMAL(5,2);
DEFINE score_propietario	DECIMAL(5,2);
DEFINE sc_propietario_1		DECIMAL(5,2);
DEFINE sc_propietario_2		DECIMAL(5,2);
DEFINE sc_propietario_3		DECIMAL(5,2);
DEFINE bscore_1				DECIMAL(5,2);
DEFINE bscore_2				DECIMAL(5,2);

-- VARIABLES PARA RETORNO DE DATOS
DEFINE Codret                   CHAR(6);
DEFINE flag_recalculopp12		SMALLINT;
DEFINE dtFecha_Aper		        DATE;
DEFINE iNum_periodos            INTEGER;
DEFINE dtFecha_cuota            DATE;
DEFINE dSdo_inicial             MONEY(14,2);
DEFINE dPago_mensual            MONEY(14,2);
DEFINE dMto_Interes             MONEY(14,2);
DEFINE dIva_interes             MONEY(14,2);
DEFINE dCapital                 MONEY(14,2);
DEFINE dSdo_final               MONEY(14,2);
DEFINE sDias_periodo            SMALLINT;
DEFINE cNumMesesPagos      		CHAR(3);





	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
LET vsqlerr             	= 0;

LET meses_reevalua			= 0;
LET bc_score  				= 0;
LET score_propietario 		= 0;
LET sc_propietario_1		= 0;
LET sc_propietario_2		= 0;
LET sc_propietario_3		= 0;
LET bscore_1				= 0;
LET bscore_2				= 0;


LET Codret                  = "000000";
let flag_recalculopp12		= 0;
LET dtFecha_Aper            = DATE(1);
LET iNum_periodos           = 0;
LET dtFecha_cuota           = DATE(1);
LET dSdo_inicial            = 0;
LET dPago_mensual           = 0;
LET dMto_Interes            = 0;
LET dIva_interes            = 0;
LET dCapital                = 0;
LET dSdo_final              = 0;
LET sDias_periodo           = 0;
LET cNumMesesPagos  		= "";



   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   

set isolation to dirty read;
set lock mode to wait 3;

   
	BEGIN

		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET Codret=vsqlerr;
			  RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
					dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
		   END IF;
		END EXCEPTION;

	--    SET DEBUG FILE TO '/informix/sp_proyecta_prestamo_aux.out';
	--    TRACE ON;
			
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	
		
		IF  o_ejecucion = 1 THEN 
		
			---- BC score
			SELECT evaluacion
				INTO bc_score
			FROM bdisolic:ss_resumen_scoring 
			WHERE num_solicitud = o_numsol
				AND seccion = 1;
			---- Score propietario
			SELECT evaluacion
				INTO score_propietario
			FROM bdisolic:ss_resumen_scoring 
			WHERE num_solicitud = o_numsol
				AND seccion = 2;

			--- puntajes de corte score propietario 
			SELECT valor
			  INTO sc_propietario_1 
			  FROM bdisolic:"informix".ss_param
			 WHERE empresa = o_empresa
			   AND secuencia = 37;

			SELECT valor
			  INTO sc_propietario_2 
			  FROM bdisolic:"informix".ss_param
			 WHERE empresa = o_empresa
			   AND secuencia = 38;
			   
			SELECT valor
			  INTO sc_propietario_3 
			  FROM bdisolic:"informix".ss_param
			 WHERE empresa = o_empresa
			   AND secuencia = 39;
			--- puntajes de corte BC score
			SELECT valor
			  INTO bscore_1 
			  FROM bdisolic:"informix".ss_param
			 WHERE empresa = o_empresa
			   AND secuencia = 40;

			SELECT valor
			  INTO bscore_2 
			  FROM bdisolic:"informix".ss_param
			 WHERE empresa = o_empresa
			   AND secuencia = 41;	   
			   
			---- ( <= 390 AND <= 674) OR (<= 405 AND  <= 639) OR (score_propietario <= 371) 
			IF (score_propietario <= sc_propietario_1 AND bc_score <= bscore_1) 
				OR (score_propietario <= sc_propietario_2 AND bc_score <= bscore_2) 
					OR	(score_propietario <= sc_propietario_3) THEN
					
					LET flag_recalculopp12 = 1;
					
			END IF;
		
		END IF;

		--- parametro para la reevaluacion PP12
		SELECT valor
		  INTO meses_reevalua 
		  FROM bdisolic:"informix".ss_param
		 WHERE empresa = o_empresa
		   AND secuencia = 42;
		
		IF o_ejecucion = 1 AND flag_recalculopp12 = 1 THEN
			--- se obtiene proyeccion con el minimo
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (o_limite_inferior,meses_reevalua,0,'6300',o_sucursal,0,0,o_numsol,"",1)
				INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
				dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;		
				
				LET flag_recalculopp12 = 1;
				
				IF Codret <> "000000" THEN
					LET Codret = "475";
					RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
						dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
				ELSE
					RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
							dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
						
				END IF;
			
		ELIF o_ejecucion = 2 THEN
			--- se proyecta para obtener la linea a 12 PP con la capacidad real
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (0,meses_reevalua,o_capacidad,'6300',o_sucursal,0,0,o_numsol,"",1)
				INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
				dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;

			--- de la linea obtenida a 12 se proyecta a 18 o 24
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dSdo_inicial,o_plazo,0,o_producto,o_sucursal,0,0,o_numsol,"",1)
				INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
				dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;

				IF Codret <> "000000" THEN
					LET Codret = "475";
					RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
						dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
				ELSE
					RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
							dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
						
				END IF;
		END IF;
	
	END
	RETURN Codret,flag_recalculopp12,iNum_periodos,dtFecha_cuota,dSdo_inicial,
		dPago_mensual,dMto_Interes,dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
END PROCEDURE
