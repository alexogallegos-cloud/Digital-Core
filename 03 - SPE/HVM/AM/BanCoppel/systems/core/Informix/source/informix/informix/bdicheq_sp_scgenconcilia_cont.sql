CREATE PROCEDURE "informix".sp_scgenconcilia_cont(pempresa CHAR(3),pfecha DATE,pusuario CHAR(10))
RETURNING CHAR(5), CHAR(100);
--//***************************************************************************
--// sp_scgenconcilia_cont
--// Version              1.0.0
--// Obejtivo:            Detalle de movimientos para conciliacion contable
--// Creado por:          Alejandro Rueda Sanchez
--// ModIFicado por:
--// Ultima Modificacion: Octubre - 2008
--//                      Creación de SPL
--//***************************************************************************

--//DEFINICION DE VARIABLES
DEFINE chrCodRet       CHAR(5);
DEFINE intCodRet       INTEGER;
DEFINE cVarDataErr     CHAR(100);

DEFINE vt_transacc     CHAR(4);
DEFINE vt_sucursal     CHAR(4);
DEFINE vt_monto_tot    MONEY(18,2);
DEFINE chrc_ccmayor    CHAR(4);
DEFINE chrc_ccsub      CHAR(2);
DEFINE chrc_ccsubsub   CHAR(2);
DEFINE chrc_ccsssub    CHAR(2);
DEFINE chrc_ccssssub   CHAR(2);
DEFINE chrc_sector     CHAR(2);
DEFINE chra_ccmayor    CHAR(4);
DEFINE chra_ccsub      CHAR(2);
DEFINE chra_ccsubsub   CHAR(2);
DEFINE chra_ccsssub    CHAR(2);
DEFINE chra_ccssssub   CHAR(2);
DEFINE chra_sector     CHAR(2);
DEFINE chrSistema      CHAR(2);
DEFINE vt_divisa       CHAR(2);
DEFINE vt_producto     CHAR(4);
DEFINE vt_naturaleza   CHAR(1);

BEGIN
   ON EXCEPTION SET intCodRet
      IF intCodRet <> 0 THEN
         LET chrCodRet = intCodRet;
         RETURN chrCodRet, cVarDataErr;
      END IF;
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;

    --SET debug file to "/pisa/saldosymov/sp_scgenconcilia_cont.out";
    --TRACE ON;

    --
    LET chrCodRet = '000';
    LET cVarDataErr = '';
    LET chrSistema = '01';

    --
    DELETE FROM bdicont:co_conciliamovs
     WHERE empresa = pempresa
       AND sistema = chrSistema
       AND fecha = pfecha;

    FOREACH
        SELECT mov.transacc, mov.sucursal,mov.producto, sum(monto_tot)
          INTO vt_transacc, vt_sucursal, vt_producto, vt_monto_tot
          FROM sc_movhis mov, bdinteg:si_transacc sit
         WHERE mov.fech_alt = pfecha
           AND mov.transacc = sit.numero
           AND mov.empresa = pempresa
           AND mov.cuenta is not null
           AND mov.cancelad <> "S"    
           AND sit.empresa = pempresa
           AND sit.numero = mov.transacc
           AND sit.se_contabiliza = "S"
         GROUP BY 1,2,3 
         ORDER BY 1,2

        --
        SELECT nvl(prod.divisa,'01'), c_ccmayor, c_ccsub, c_ccsubsub,
               c_ccsssub, c_ccssssub, c_sector, a_ccmayor,
               a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
          INTO vt_divisa, chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
               chrc_ccsssub, chrc_ccssssub, chrc_sector, chra_ccmayor,
               chra_ccsub, chra_ccsubsub, chra_ccsssub, chra_ccssssub, chra_sector
          FROM bdinteg:si_prodtran ptra, bdicheq:sc_producto prod
         WHERE ptra.empresa = prod.empresa
           AND ptra.producto = prod.producto 
           AND ptra.sistema = chrSistema
           AND ptra.transaccion = vt_transacc
           AND ptra.secuencia = 1
           AND prod.empresa = pempresa
           AND prod.producto = vt_producto;

		
		IF  NOT (chrc_ccmayor IS NULL OR chrc_ccsub IS NULL OR chrc_ccsubsub IS NULL OR
			 chrc_ccsssub IS NULL OR chrc_ccssssub IS NULL OR chrc_sector IS NULL) THEN


			--
		INSERT INTO bdicont:co_conciliamovs(empresa, sistema, fecha,transac,
												ccmayor, ccsub, ccsubsub,
												ccssubsub, ccsssubsub, sector,
												sucursal, moneda, naturaleza,
												producto, monto, usuario_alta,
												Fecha_Alta)
				VALUES (pempresa,chrSistema,pfecha,vt_transacc,chrc_ccmayor, chrc_ccsub, chrc_ccsubsub,
						chrc_ccsssub, chrc_ccssssub, chrc_sector,vt_sucursal, vt_divisa,
						"D",vt_producto, vt_monto_tot, pusuario, current);
	     END IF
		 
		 IF  NOT (chra_ccmayor IS NULL OR 
               chra_ccsub IS NULL OR  chra_ccsubsub IS NULL OR  chra_ccsssub  IS NULL OR 
                chra_ccssssub IS NULL OR  chra_sector IS NULL) THEN
			--
			INSERT INTO bdicont:co_conciliamovs(empresa, sistema, fecha,transac,
												ccmayor, ccsub, ccsubsub,
												ccssubsub, ccsssubsub, sector,
												sucursal, moneda, naturaleza,
												producto, monto, usuario_alta,
												Fecha_Alta)
					VALUES (pempresa,chrSistema,pfecha,vt_transacc, chra_ccmayor, chra_ccsub, chra_ccsubsub,
							chra_ccsssub, chra_ccssssub, chra_sector,vt_sucursal, vt_divisa,
							"C",vt_producto, vt_monto_tot, pusuario, current);
		 END IF  	

    END FOREACH;

    RETURN chrCodRet, cVarDataErr;
END
END PROCEDURE;