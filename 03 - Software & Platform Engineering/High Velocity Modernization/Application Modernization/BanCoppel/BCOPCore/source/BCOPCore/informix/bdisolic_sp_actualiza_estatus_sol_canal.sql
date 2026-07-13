CREATE PROCEDURE "informix".sp_actualiza_estatus_sol_canal(p_estatus  CHAR(2), p_canal CHAR(1))

RETURNING CHAR(6);		--Codigo de Retorno

-- DEFINICION DE VARIABLES
DEFINE vcod_ret			CHAR(6);
DEFINE vsqlerr			INTEGER;
DEFINE v_estatus        CHAR(2);
DEFINE v_canal          CHAR(1);       
DEFINE o_empresa        CHAR(3);
DEFINE s_numsol_pros    CHAR(20);
DEFINE scod_ret         CHAR(6);  
DEFINE vAuxMensaje      CHAR(100);

LET vcod_ret = '000000';
LET scod_ret = '';
LET v_estatus = p_estatus;
LET o_empresa = '001';
LET s_numsol_pros = '';
LET vAuxMensaje = '';
 

BEGIN
    ON EXCEPTION SET vsqlerr --, isam_err, error_info
        LET vcod_ret = vsqlerr; 
		--LET cMensaje = error_info;
	    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
	    --        RETURNING vvcCod_ret;
	    RETURN vcod_ret;
    END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

   LET vAuxMensaje = 'Cancelacion x cambio logica BC a CC';
   
   FOREACH WITH HOLD
	   SELECT num_solicitud INTO s_numsol_pros
		 FROM bdisolic:ss_solicitudes
		WHERE status_solicitud = v_estatus
		  AND canal_sol = p_canal
	   
	   --EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema', s_numsol_pros, vAuxNuevoStatus, cCausa_sol,vAuxMensaje) Into scod_ret;
	   EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(o_empresa, 'sistema', s_numsol_pros, 'CN', '',vAuxMensaje) Into scod_ret;
			
     
   END FOREACH;	
	
   RETURN vcod_ret;	
	
END;
END PROCEDURE;