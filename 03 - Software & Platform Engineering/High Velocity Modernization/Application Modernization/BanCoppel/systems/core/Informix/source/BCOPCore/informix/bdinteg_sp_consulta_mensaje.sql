CREATE PROCEDURE "informix".sp_consulta_mensaje (pNumEmpleado CHAR(15),pNumEmpresa CHAR(20))
RETURNING CHAR(3) as vCodRet1, CHAR(100) as vMensaje, CHAR(2)  as vStatusCta; 

/**
*Creación Solser
*Autor: Gustavo Bujano Guzmán
*Fecha 15/05/2017
*Schema: bdinteg
*
*/

/**
*Modificacion - Se quita la validación de pNumCte y se cambia por Numero de Empresa
*autor: Gustavo Bujano Guzmán
*fecha: 13*07*2017
*/

 DEFINE vCodRet1      CHAR(3);	
 DEFINE vMensaje      CHAR(100);
 DEFINE vStatusCta	  CHAR(2); 
 DEFINE Sql_Err          INTEGER;
 
 LET Sql_Err   = 0;
 LET vCodRet1 = '';
 LET vMensaje = '';
 LET vStatusCta = '';
 BEGIN
     ON EXCEPTION SET Sql_Err
            IF Sql_Err <> 0 THEN
                LET vCodRet1 = Sql_Err;
                RETURN vCodRet1, vMensaje,vStatusCta;
            END IF;
    END EXCEPTION;

    IF TRIM(pNumEmpleado) <> '' AND (pNumEmpresa) <> '' THEN
            SELECT status
            INTO  vStatusCta
            FROM bdinteg:informix.si_altamasivaempnet_det where cve_cte = pNumEmpleado and cod_empresa =pNumEmpresa ;            
            IF (vStatusCta <> '') THEN 
                   SELECT  control, descripcion
                   INTO vcodRet1, vMensaje
                   FROM bdibei:informix.bei_mnsjctanom where id_estatus = vStatusCta;
                   RETURN vCodRet1, vMensaje,vStatusCta;
            ELSE
                LET vCodRet1 = '000'; -- NO SE ENCONTRARON PARAMETROS
                LET vMensaje = 'ERROR GENERAL';
                LET vStatusCta = '0';	
                RETURN vCodRet1, vMensaje,vStatusCta;
            END IF;
    ELSE
            LET vCodRet1 = '000'; -- NO SE ENCONTRARON PARAMETROS
            LET vMensaje = 'ERROR GENERAL';
            LET vStatusCta = '0';	
            RETURN vCodRet1, vMensaje,vStatusCta;
    END IF; 

  END;

END PROCEDURE;