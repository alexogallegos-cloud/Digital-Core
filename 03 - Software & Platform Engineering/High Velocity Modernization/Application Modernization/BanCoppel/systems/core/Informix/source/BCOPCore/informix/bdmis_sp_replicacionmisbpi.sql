CREATE PROCEDURE "informix".sp_replicacionmisbpi()
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
DEFINE  iVal             INTEGER;
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- Creado por Manuel Osuna                                   --*              
-- Debug del Procedure                                       --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                      --*
 --TRACE ON;                                                 --*
--**************************************************************

   LET iVal = 0;
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';



    SELECT fecha_ant INTO dFecha FROM bdmis:mi_fechas;

    IF NOT EXISTS (SELECT fecha_registro FROM bdmis:mi_solbanint WHERE fecha_registro = dFecha) THEN

        -- Se Inserta ala Tabla bdmis:mi_solbaninthist Valores de la Tabla bdmis:mi_solbanint

        INSERT INTO bdmis:mi_solbaninthist(sucursal,clientesreg,totalclientesreg,id_status,fecha_registro)
        SELECT sucursal,clientesreg,totalclientesreg,id_status,fecha_registro FROM bdmis:mi_solbanint;

        -- Se Borran Valores de la Tabla bdmis:mi_solbanint

        DELETE FROM bdmis:mi_solbanint;

        -- Contabilizar status
		INSERT INTO bdmis:mi_solbanint(sucursal,id_status,totalclientesreg,fecha_registro,clientesreg)        
		select suc_registro,id_status,nvl(COUNT (numcte),0)as cte_tot,dFecha,
		nvl(sum (case when f_registro = dFecha then 1 end),0)  as cte_nvo
		FROM bdinteg:si_bpiusuarios
		GROUP BY suc_registro,id_status;
        
    ELSE

        LET P_COD_RET = '000-1';
        LET P_MENSAJE = 'ESTA FECHA YA FUE PROCESADA';

    END IF;

    -- Variables de Retorno
 RETURN P_COD_RET,P_MENSAJE;

END
END PROCEDURE;