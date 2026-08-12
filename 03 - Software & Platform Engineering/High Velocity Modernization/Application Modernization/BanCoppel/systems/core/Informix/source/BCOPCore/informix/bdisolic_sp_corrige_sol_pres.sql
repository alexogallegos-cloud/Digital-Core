CREATE PROCEDURE "informix".sp_corrige_sol_pres ( pEmpresa Char(3))	
RETURNING CHAR(5);       -- Codigo de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMen_ret CHAR(80);

DEFINE cNumSol                CHAR(20);
DEFINE cProducto                CHAR(4);
DEFINE cSucursal                CHAR(4);

DEFINE iNum_periodos            INTEGER;
DEFINE dtFecha_cuota            DATE;
DEFINE dSdo_inicial             MONEY(14,2);
DEFINE dPago_mensual            MONEY(14,2);
DEFINE dMto_Interes             MONEY(14,2);
DEFINE dIva_interes             MONEY(14,2);
DEFINE dCapital                 MONEY(14,2);
DEFINE dSdo_final               MONEY(14,2);
DEFINE sDias_periodo            SMALLINT;
DEFINE v_diaspromedio           DECIMAL(14,2);
DEFINE Codret                   CHAR(6);
DEFINE dtFecha_Aper		        DATE;
DEFINE cNumMesesPagos      CHAR(3);
 
DEFINE dCapacidad              MONEY(14,2);
DEFINE dMonto                  MONEY(14,2);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMen_ret     = "Proceso Exitoso";

LET cNumSol               = "";
LET cProducto               = "";
LET cSucursal               = "";
LET iNum_periodos           = 0;
LET dtFecha_cuota           = DATE(1);
LET dSdo_inicial            = 0;
LET dPago_mensual           = 0;
LET dMto_Interes            = 0;
LET dIva_interes            = 0;
LET dCapital                = 0;
LET dSdo_final              = 0;
LET sDias_periodo           = 0;
LET Codret                  = "000000";
LET dtFecha_Aper            = DATE(1);
LET cNumMesesPagos           = "";

LET dCapacidad        = 0;
LET dMonto          = 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN cCodRet ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/jesus/RQM09408/lib/sp_corrige_sol_pres.out';
--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001' ;
	ELSE
		FOREACH
			SELECT num_solicitud , monto_autorizado, capacidad_pres, num_producto, sucursal
			INTO cNumSol, dMonto,dCapacidad, cProducto,cSucursal
			FROM  bdisolic:ss_solicitudes 
			WHERE empresa = pEmpresa
			AND num_producto in ('6300','7600','7700')
			and fecha_insert = mdy(6,3,2016)
			and capacidad_pres < 3400			
			and status_solicitud IN ('AT','OS')
			
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (dMonto,12,0,cProducto,cSucursal,0,0,cNumSol,"",1)
			INTO Codret,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
			dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;
			
	
			 IF dCapacidad < dPago_mensual THEN	
				UPDATE "informix".ss_solicitudes
				SET capacidad_pres = dPago_mensual			
				WHERE empresa = pEmpresa
				AND num_solicitud = cNumSol;	
			END IF;
		
		
		END FOREACH;
		
					
	END IF;		
	RETURN cCodRet;
END
END PROCEDURE
