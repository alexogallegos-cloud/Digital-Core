CREATE PROCEDURE "informix".sp_movtos_reversados (p_empresa CHAR(3))
RETURNING CHAR (5) AS Codigo;

DEFINE v_empresa char(3); 
DEFINE v_fecha_mov date ;
DEFINE v_sucursal char(4);
DEFINE v_transacc char(4);
DEFINE v_cuenta char(20);
DEFINE v_num_producto char(4);
DEFINE v_folio_suc char(16);
DEFINE v_monto decimal(18,2);
DEFINE v_tipo_mov char(2);
DEFINE v_sistema char(1);
DEFINE v_usuario char(8);
DEFINE vCodret CHAR(5);
DEFINE vFecha DATE;

LET vCodret = '00000';


	--*********************************************************--
    	-- Creado por: Francisco Martinez Viveros	
        --Fecha: 16/NOVIEMBRE/2010 
	     --Objetivo: Obtiene los movimientos reversados del dia y se graban
         --          en la tabla si_movreversados de bdinteg para agilizar el proceso batch
         --          el proceso batch del sorteo 2010.
	--*********************************************************--


BEGIN

-- Set debug file to "/tmp/sp_movtos_reversados.out";
-- Trace on;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;


    FOREACH cursor_filtra WITH HOLD FOR
                      SELECT DISTINCT {+index (bdicheq:sc_movdia idx_movdia2a)}
                             folio_suc, empresa, sucursal, usuario, fech_alt, transacc, cuenta, producto, monto_tot
                        INTO  v_folio_suc, v_empresa, v_sucursal, v_usuario, vFecha, v_transacc, v_cuenta, v_num_producto, v_monto
                        FROM bdicheq:sc_movdia
                       WHERE cancelad = 'S'
                         AND (transacc = "0250" OR transacc = "0202")
                         AND monto_tot > 0
                         --AND fech_alt = today

                     --BEGIN WORK;                  
                      INSERT INTO {+index (bdinteg:si_movreversados idx_si_movrever)}
                             bdinteg:"informix".si_movreversados VALUES 
                              (v_empresa,vFecha,v_sucursal, v_transacc,v_cuenta, v_num_producto, v_folio_suc, v_monto,'10','1', v_usuario);                        
                    --COMMIT WORK;                           
    END FOREACH;


 FOREACH cursor_filtra WITH HOLD FOR
                      SELECT DISTINCT {+index ( bdicred:sd_movdia idx_movdia2)}
                             empresa, fecha_mov, folio_suc, sucursal, usuario, transacc_suc, num_credito, num_producto, monto
                        INTO v_empresa, vFecha, v_folio_suc, v_sucursal, v_usuario, v_transacc, v_cuenta, v_num_producto, v_monto
                        FROM bdicred:sd_movdia 
                       WHERE empresa = '001'
                         AND fecha_mov = today
                         AND codigo_fun IN ("033", "336")
                         AND codigo_ref = 1
                         AND reversado = 'S'

                     --BEGIN WORK;                  
                      INSERT INTO {+index (bdinteg:si_movreversados idx_si_movrever)}
                             bdinteg:"informix".si_movreversados VALUES 
                              (v_empresa,vFecha,v_sucursal, v_transacc,v_cuenta, v_num_producto, v_folio_suc, v_monto,'11','6', v_usuario);                        
                    --COMMIT WORK;                           
    END FOREACH;


RETURN vCodret;

 
END;  --BEGIN
END PROCEDURE;