CREATE PROCEDURE "informix".sp_concilia_ciudades_spmxbcppl ()
       RETURNING CHAR(5), CHAR(80);
       
DEFINE v_concepto         CHAR(3);
DEFINE vCodRet            CHAR(5);
DEFINE vMensaje           CHAR(80);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE v_d_mnpio          CHAR(32);
DEFINE v_c_estado         INTEGER;
DEFINE v_ciudad         INTEGER;
DEFINE va_nombre          CHAR(50);
DEFINE va_ciudad          CHAR(50);
    
    --SET DEBUG FILE TO "/tmp/sp_concilia_ciudades_spmxbcppl.out";
    --TRACE ON; 
    
    LET vCodRet   = "00000";
    LET vMensaje  = "PROCESO EXITOSO";

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet   = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
        RETURN vCodRet, vMensaje;
        END EXCEPTION;

		SET ISOLATION TO dirty READ;
        
        FOREACH        
            select a.estado,a.ciudad, nvl(trim(b.d_ciudad), trim(b.d_mnpio))
              into v_c_estado,v_d_mnpio, va_nombre
              from bdinteg:si_ciudades a, bdinteg:si_catsepomex b
             where b.c_estado = a.estado
               and trim(a.nombre) = nvl(trim(b.d_ciudad), trim(b.d_mnpio))
               and a.ciudad_Coppel>0 
             group by a.estado, a.ciudad,b.d_ciudad,b.d_mnpio
             order by a.estado
             --CODIGO DE COMPARACION, 1 = ES EXACTAMENTE IGUAL SEPOMEX, BANCOPPEL    
             --UPDATE bdinteg:si_ciudades set d_ciudad = va_nombre, nombre_sepomex =1 where estado = v_c_estado and ciudad = v_d_mnpio;                
             UPDATE bdinteg:si_ciudades set d_ciudad = va_nombre where estado = v_c_estado and ciudad = v_d_mnpio;                
                    
        END FOREACH;
        
END 

RETURN vCodRet, vMensaje;
END PROCEDURE;