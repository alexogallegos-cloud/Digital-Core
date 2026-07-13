CREATE PROCEDURE "informix".sp_consctastraspasar(pNumeroCliente CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(4), CHAR(40), DATE, CHAR(2), DATE, MONEY(10,2);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vc_NumeroCte     CHAR(20);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Producto      CHAR(4);
DEFINE vc_DescProducto  CHAR(40);
DEFINE vd_FechaAlta     DATE;
DEFINE vc_StatusCta     CHAR(2);
DEFINE vc_DescStatus    CHAR(50);
DEFINE vd_FechaUltMov   DATE;
DEFINE vm_Saldo         MONEY(10,2);
DEFINE vi_SqlErr        INTEGER;
DEFINE vc_Empresa       CHAR(3);

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vc_NumeroCte = "";
LET vc_Cuenta = "";
LET vc_Producto = "";
LET vc_DescProducto = "";
LET vd_FechaAlta = "";
LET vc_StatusCta = "";
LET vc_DescStatus = "";
LET vd_FechaUltMov = "";
LET vm_Saldo = 0.00;
LET vi_SqlErr = 0;
LET vc_Empresa = "001";

--***********DATOS DE ELABORACIÃN**********
--ELABORO: AYMME OSUNA PERAZA
--SOLICITO: ING. GERARDO VILLAR
--FECHA: 11-12-2008
--DESCRIPCION: PROCESO QUE SE ENCARGA DE OBTENER LAS CUENTAS QUE LE PERTENECEN A UN DETERMINADO CLIENTE
--******************************************
    --SET DEBUG FILE TO "/tmp/sp_ConsCtasTraspasar.out";
    --TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET vi_SqlErr
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN vc_CodRet, pNumeroCliente, vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo;
                        
        END IF;
    END EXCEPTION;
    
    IF NOT EXISTS(SELECT chq.num_cte FROM bdicheq:sc_maechq chq WHERE chq.num_cte = pNumeroCliente) AND NOT EXISTS(SELECT numcte FROM bdicred:sd_maecred WHERE numcte = pNumeroCliente)
                  AND NOT EXISTS(SELECT num_cte FROM bdinvers:sv_maeinv WHERE num_cte = pNumeroCliente) AND NOT EXISTS (SELECT numcte FROM bdisolic:ss_solicitudes WHERE numcte = pNumeroCliente) THEN
        LET vc_CodRet = "00100";
        RETURN vc_CodRet, pNumeroCliente, vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo;
    END IF;
    CREATE TEMP TABLE cuentas(cuenta CHAR(20), producto CHAR(4), nombre CHAR(40), fecha_alta DATE, status CHAR(2), ultmov DATE, saldo MONEY(16,2));
    SET ISOLATION TO DIRTY READ;
    
        IF EXISTS(SELECT num_cte FROM bdicheq:sc_maechq WHERE num_cte = pNumeroCliente) THEN              
                INSERT INTO cuentas
                SELECT mae.cuenta as cuenta, mae.producto as producto, prod.nombre as nombre, noc.fecha_alta as fecha_alta, nvl(mae.status_cta, "00") as status, fec_ult_mov as ultmov, (mae.sdo_actual - mae.sdo_retenido - mae.sdo_cong -  mae.imp_chq_sbg) as saldo
                FROM bdicheq:sc_maechq mae, bdicheq:sc_maenoc noc, bdicheq:sc_producto prod
                WHERE mae.num_cte = pNumeroCliente AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto;
                --INTO temp cuentas WITH NO LOG;
        END IF;

        IF EXISTS (SELECT numcte FROM bdicred:sd_maecred WHERE numcte = pNumeroCliente) THEN
            FOREACH
                SELECT cred.num_credito as cuenta, cred.num_producto as producto, def.nombre_prod as nombre, cred.fecha_apertura as fecha_alta, cred.status_cred as status, dos.fecha_ult_mov as ultmov, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci) as saldo
                INTO vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo
                FROM bdicred:sd_maecred cred, bdicred:sd_maesdos dos, bdicred:sd_definicion def
                WHERE cred.numcte = pNumeroCliente AND dos.empresa = vc_Empresa AND dos.num_credito = cred.num_credito AND def.empresa = vc_Empresa AND def.num_producto = cred.num_producto
                
                INSERT INTO cuentas(cuenta, producto, nombre, fecha_alta, status, ultmov, saldo)
                VALUES(vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo);            
            END FOREACH;
        END IF;

        IF EXISTS (SELECT num_cte FROM bdinvers:sv_maeinv WHERE num_cte = pNumeroCliente) THEN
            FOREACH
                --SET ISOLATION TO DIRTY READ;
                SELECT {+INDEX (bdinvers:sv_instrum idx_instrum)} inv.cuenta as cuenta, inv.cod_instrum as producto, ins.nombre as nombre, inv.fecha_alta as fecha_alta, inv.status_cta as status, inv.fec_ult_mov as ultmov, capital as saldo
                INTO vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo
                FROM bdinvers:sv_maeinv inv, bdinvers:sv_instrum ins
                WHERE inv.num_cte = pNumeroCliente AND status_cta <> '2' AND inv.cod_instrum = ins.cod_instrum
               
                INSERT INTO cuentas(cuenta, producto, nombre, fecha_alta, status, ultmov, saldo)
                VALUES(vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo);

            END FOREACH; 
        END IF;
        
        IF EXISTS (SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:ss_solicitudes WHERE numcte = pNumeroCliente AND status_solicitud not in ('RT','AN','CN','RP') and empresa='001' ) THEN
            FOREACH
				/*
                SELECT {+INDEX (bdisolic:ss_solicitudes idx_numctesolic)} sol.num_solicitud as cuenta, "016" as producto, fun.desc_funcion as nombre, sol.fecha_insert as fecha_alta, sol.status_solicitud as status, sol.fecha_insert as ultmov, nvl(sol.monto_solicitado, 0.00) as saldo
                INTO vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo
                FROM bdisolic:ss_solicitudes sol, bdisolic:ss_funcionalidad fun
                WHERE sol.numcte = pNumeroCliente AND fun.cod_funcion = "016" and sol.empresa='001'
				*/
				SELECT 
				{+AVOID_FULL (bdisolic:"informix".ss_solicitudes), AVOID_FULL (bdicred:"informix".sd_tipprod)}
				sol.num_solicitud as cuenta, num_producto as producto, ('SOLICITUD DE ' || t.descrip_prod) as nombre, sol.fecha_insert as fecha_alta, sol.status_solicitud as status, sol.fecha_insert as ultmov, nvl(sol.monto_solicitado, 0.00) as saldo
                INTO vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo
				FROM bdisolic:ss_solicitudes sol
				INNER JOIN bdicred:"informix".sd_tipprod t on t.abrevia_prod=sol.num_producto
				WHERE sol.numcte = pNumeroCliente
				and sol.empresa='001'

                INSERT INTO cuentas(cuenta, producto, nombre, fecha_alta, status, ultmov, saldo)
                VALUES(vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo);


            END FOREACH;
        END IF;
        
        FOREACH
            SELECT cuenta, producto, nombre, fecha_alta, status, ultmov, saldo INTO vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo FROM cuentas order by cuenta
            
            RETURN vc_CodRet, pNumeroCliente, vc_Cuenta, vc_Producto, vc_DescProducto, vd_FechaAlta, vc_StatusCta, vd_FechaUltMov, vm_Saldo WITH RESUME;
        END FOREACH;
        DROP TABLE cuentas;
END;
END PROCEDURE;