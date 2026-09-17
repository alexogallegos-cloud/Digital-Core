CREATE PROCEDURE "informix".calc_iva_grav(o_empresa    CHAR(3),
			       o_sucursal   CHAR(4),
			       o_numcred    CHAR(20),
			       o_monto      DECIMAL(14,2),
			       o_folio      CHAR(16),
			       o_tasa       decimal(9,6),
			       o_divisa     CHAR(2),
			       o_diascalc   SMALLINT,
			       o_diasacum   SMALLINT,
			       o_intperiodo DECIMAL(14,2),
			       o_producto   CHAR(4),
			       o_bandera    CHAR(1),
			       o_plaza      CHAR(3),
			       o_contabiliza CHAR(1),
			       o_precioreal DECIMAL(14,6) )

RETURNING CHAR(5),       -- Codigo Retorno
          DECIMAL(14,2),  --iva sobre inetres gravable
          DECIMAL(14,2);  --base interes gravable

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
--DEFINE GLOBAL vIvaOrden       DECIMAL(14,2) DEFAULT 0;
--DEFINE GLOBAL StatusCred      CHAR(2)       DEFAULT '';

DEFINE CodRet              CHAR(5);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE vIntGrav            DECIMAL(14,2);
DEFINE vIntNoGrav	   DECIMAL(14,2);
DEFINE vTasaIva  	   DECIMAL(14,8);
DEFINE vTasaReal  	   DECIMAL(14,6);
DEFINE v360  	   DECIMAL(14,6);
DEFINE v361         DECIMAL(14,6);
DEFINE v362  	   DECIMAL(14,2);
DEFINE v363  	   DECIMAL(14,2);
DEFINE v364  	   DECIMAL(14,2);
DEFINE vIvaIntGrav         DECIMAL(14,2);
DEFINE vIvaReal            DECIMAL(14,6);
DEFINE GLOBAL FechaHoy     DATE DEFAULT NULL;
DEFINE GLOBAL vIvaSuc      DECIMAL(5,3)  DEFAULT 0;
DEFINE GLOBAL vIvaBase     DECIMAL(5,3)  DEFAULT 0;
DEFINE Mensaje             VARCHAR(20);
DEFINE vReferencia         SMALLINT;
DEFINE vTran		   CHAR(4);
DEFINE vIvaOrdAnt          DECIMAL(14,2);
DEFINE vIvaOrden          DECIMAL(14,2);
DEFINE vTasaIntReal       DECIMAL(14,6);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   LET CodRet = sql_err;
   RETURN CodRet, vIvaIntGrav, vIntGrav;
END EXCEPTION;

--SET DEBUG FILE TO "calc_iva_grav.out";
--TRACE ON;


-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET CodRet        = "000";
LET vIvaIntGrav   = 0;
LET vIntGrav      = 0;
LET vIvaReal      = 0;
LET vTasaReal     = 0;
LET vTran         = "0000";
LET vIvaOrdAnt    = 0;
LET vIvaOrden    = 0;
LET v360          = 0;
LET v361         = 0;
LET v362  	= 0;
LET v363  	= 0;
LET v364  	= 0;
LET vTasaIntReal = 0;
LET o_monto = o_monto;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	IF o_contabiliza = "S" THEN

---CAS CALCULA EL INTERES NO GRAVABLE INI
                        SELECT SUM(iva_debe - iva_pagado)
                         INTO   vIvaIntGrav
                         FROM   sd_amortiza_credito
                         WHERE  empresa = o_empresa
                          AND   num_credito = o_numcred
                          AND  fecha_cuota = FechaHoy - 1 UNITS MONTH;

                 LET vIntGrav= vIvaIntGrav/vIvaSuc;

                 IF (vIntGrav > o_intperiodo) then
                     LET vIntGrav = o_intperiodo;
                 END IF;

                 LET vIntNoGrav=o_intperiodo-vIntGrav;
---CAS CALCULA EL INTERES NO GRAVABLE FIN

	   -- Genera Movmiento de Interes Gravado
        IF vIntGrav IS NOT NULL AND vIntGrav <> 0 THEN

               CALL genmovcierre_movdia(o_empresa, o_numcred, o_producto,10,
                                 "606", FechaHoy, vIntGrav, o_folio,
                                 o_sucursal, o_divisa, "0000",o_plaza)
               RETURNING CodRet, Mensaje;
               IF (CodRet <> "00000") THEN
                     RETURN CodRet, vIvaIntGrav, vIntGrav;
               ELSE
                  LET CodRet = "000";
               END IF;

         ELSE

            LET vIntGrav = 0;

         END IF;

	   -- Genera Movimiento de Interes No Gravado
	   IF vIntNoGrav > 0 THEN
        	CALL genmovcierre_movdia(o_empresa, o_numcred, o_producto,11,
                	    "606", FechaHoy, vIntNoGrav, o_folio,
                  	    o_sucursal, o_divisa, "0000",o_plaza)
        	RETURNING CodRet, Mensaje;
        	IF (CodRet <> "00000") THEN
              	   RETURN CodRet, vIvaIntGrav, vIntGrav;
        	ELSE
           	   LET CodRet = "000";
        	END IF;
	   END IF

	   -- Genera Movimiento de Iva de Int Gravado
	   IF vIvaSuc = vIvaBase THEN
		IF o_bandera = "0" THEN
			LET vReferencia = 20; -- Iva Vigente 15%
		ELSE
			LET vReferencia = 22; -- Iva Vencido 15%
		END IF
	   ELSE
		IF o_bandera = "0" THEN
		   	LET vReferencia = 21; -- Iva Vigente 10%
		ELSE
		   	LET vReferencia = 23; -- Iva Vencido 10%
		END IF
	   END IF

       IF  vIvaIntGrav IS NOT NULL AND vIvaIntGrav <> 0 THEN

           CALL genmovcierre_movdia(o_empresa, o_numcred, o_producto,vReferencia,
                  "340", FechaHoy, vIvaIntGrav, o_folio,
                  o_sucursal, o_divisa, "0000",o_plaza)
           RETURNING CodRet, Mensaje;
           IF (CodRet <> "00000") THEN
                RETURN CodRet, vIvaIntGrav, vIntGrav;
             ELSE
               LET CodRet = "000";
            END IF;

       ELSE

            LET vIvaIntGrav = 0;

       END IF;     

    ELSE

        IF o_precioreal <> 0 THEN
                    LET vTasaIva    =  ((o_tasa / 100) / o_diascalc) * o_diasacum ;
                    LET vTasaIntReal    = vTasaIva - o_precioreal ;
                    LET vIvaReal    = (vTasaIntReal * vIvaSuc)/ vTasaIva; --se cambia el 0.16 por la variable vIvaSuc
                    LET vIvaIntGrav = ROUND(o_monto * vIvaReal,2);

            -- Determina Int Gravado y No Gravado
            LET vTasaIva = (o_tasa / 100) - (o_precioreal * 12);
            LET vTasaReal = vTasaIva / (o_tasa / 100);
            LET vIntGrav = o_intperiodo * vTasaReal;
            LET vIntNoGrav = o_intperiodo - vIntGrav;

        ELSE
            LET vIvaIntGrav = o_intperiodo * vIvaSuc;  --se cambia el 0.16 por la variable vIvaSuc
--            LET vIntGrav = o_intperiodo;
            LET vIntNoGrav = 0;
        END IF

  END IF;

  RETURN CodRet, vIvaIntGrav, vIntGrav;

END PROCEDURE
DOCUMENT
'Procedimiento para el calculo de los intereses',
'gravados y exentos, asi como la generancion de los mismos',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'VERSION : 1.00.001',
'BD    : BDICRED'  ;

CREATE PROCEDURE "informix".sp_depura_sd_maeretenido()
RETURNING CHAR(3);

DEFINE vCodRet CHAR(6); 
DEFINE Vnumcred CHAR(20);
DEFINE vSqlErr, vIsamErr INTEGER;


LET vCodRet = '000';
LET vSqlErr = 0;
LET vIsamErr = 0;
LET Vnumcred ='';
 BEGIN

	ON EXCEPTION SET vSqlErr, vIsamErr

	IF vSqlErr != 0 THEN

		LET vCodRet = vSqlErr;

		RETURN vCodRet;

	END IF;
	
	END EXCEPTION;

	FOREACH WITH HOLD

		select distinct (num_credito) into Vnumcred from "informix".sd_maeretenido
		where empresa ='001' 
		and fecha <= mdy('12','31','2010')
		and estatus <> 'P'

		BEGIN WORK;

			delete from  "informix".sd_maeretenido
			where empresa ='001' 
			and num_credito = Vnumcred
			and fecha <= mdy('12','31','2010')
			and estatus <> 'P';

		COMMIT WORK;  

	end FOREACH	

	UPDATE statistics medium FOR TABLE bdicred:"informix".sd_maeretenido;
	
   return  vCodRet;
   
END

END PROCEDURE;