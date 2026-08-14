CREATE PROCEDURE "informix".sp_consctastraspasadas(pNumCteTraspasar CHAR(20))
RETURNING
CHAR(4), CHAR(40), CHAR(20), CHAR(20), CHAR(2), DATE, MONEY(16,2);
--DECLARACION DE VARIABLES
DEFINE vc_producto      CHAR(4);
DEFINE vc_descproducto  CHAR(40);
DEFINE vc_cuenta        CHAR(20);
DEFINE vc_cliente       CHAR(20);
DEFINE vc_estatus       CHAR(2);
DEFINE vd_fechaalta     DATE;
DEFINE vm_saldo         MONEY(16,2);
DEFINE vi_sqlerr        INTEGER;
DEFINE vc_Empresa       CHAR(3);
DEFINE vtabla           INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_producto = "";
LET vc_descproducto = "";
LET vc_cuenta = "";
LET vc_cliente = "";
LET vc_estatus = "";
LET vd_fechaalta = "";
LET vm_saldo = 0.00;
LET vi_sqlerr = 0;
LET vc_Empresa = '001';
LET vtabla=0;

BEGIN
    ON EXCEPTION SET vi_sqlerr
    IF vi_sqlerr <> 0 THEN
        LET vc_producto = vi_sqlerr;
        RETURN vc_producto, vc_descproducto, vc_cuenta, vc_cliente, vc_estatus, vd_fechaalta, vm_saldo;
    END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/VH/integ/sp_consctastraspasadas.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    
    DELETE {+INDEX (bdinteg:si_fuscuentas idxctecta)} FROM si_fuscuentas WHERE num_cte = pNumCteTraspasar;

    IF EXISTS(SELECT {+INDEX (bdinteg:si_fusmaechq pk_fusmacte)} num_cte FROM bdinteg:si_fusmaechq WHERE num_cte = pNumCteTraspasar) THEN              
        INSERT INTO si_fuscuentas
        SELECT {+INDEX (bdinteg:si_fusmaechq pk_fusmacte)} mae.producto as producto, prod.nombre as nombre, mae.cuenta as cuenta, mae.num_cte as num_cte,  nvl(mae.status_cta, "00") as status, noc.fecha_alta as fecha_alta, (mae.sdo_actual - mae.sdo_retenido - mae.sdo_cong -  mae.imp_chq_sbg) as saldo
        FROM bdinteg:si_fusmaechq mae, bdicheq:sc_maenoc noc, bdicheq:sc_producto prod
        WHERE mae.num_cte = pNumCteTraspasar AND noc.cuenta = mae.cuenta AND mae.producto = prod.producto;
    END IF;
    IF EXISTS(SELECT {+INDEX (bdinteg:si_fusmaecred pk_fcredcte)} numcte FROM bdinteg:si_fusmaecred WHERE numcte = pNumCteTraspasar) THEN
        INSERT INTO si_fuscuentas
        SELECT {+INDEX (bdinteg:si_fusmaecred pk_fcredcte)} cred.num_producto as producto, def.nombre_prod as nombre, cred.num_credito as cuenta, cred.numcte as num_cte, cred.status_cred as status, cred.fecha_apertura as fecha_alta, (dos.sdo_capital + dos.monto_vencido + dos.mto_venc_trasp + dos.cap_tras_no_venci)  as saldo
        FROM bdinteg:si_fusmaecred cred, bdicred:sd_maesdos dos, bdicred:sd_definicion def
        WHERE cred.numcte = pNumCteTraspasar AND dos.empresa = vc_Empresa AND dos.num_credito = cred.num_credito AND def.empresa = vc_Empresa AND def.num_producto = cred.num_producto;
    END IF;

    IF EXISTS (SELECT {+INDEX (bdinteg:si_fusmaeinv pk_invcte)} num_cte FROM bdinteg:si_fusmaeinv WHERE num_cte = pNumCteTraspasar) THEN
        INSERT INTO si_fuscuentas
        SELECT {+ INDEX (bdinteg:si_fusmaeinv pk_invcte)} inv.cod_instrum as producto, ins.nombre as nombre, inv.cuenta as cuenta, inv.num_cte as num_cte, inv.status_cta as status, inv.fecha_alta as fecha_alta, sdo_dia_ant as saldo
        FROM bdinteg:si_fusmaeinv inv, bdinvers:sv_instrum ins
        WHERE inv.num_cte = pNumCteTraspasar AND inv.cod_instrum = ins.cod_instrum; 
    END IF;
    IF EXISTS (SELECT {+INDEX (bdinteg:si_fussolicitudes pk_fussolicitudes)} numcte FROM bdinteg:si_fussolicitudes WHERE numcte = pNumCteTraspasar) THEN
        INSERT INTO si_fuscuentas
        SELECT {+INDEX (bdinteg:si_fussolicitudes pk_fussolicitudes)} "016" as producto, fun.desc_funcion as nombre, sol.num_solicitud as cuenta, sol.numcte as num_cte, sol.status_solicitud as status, sol.fecha_insert as fecha_alta, nvl(sol.monto_solicitado, 0.00) as saldo
        FROM bdinteg:si_fussolicitudes sol, bdisolic:ss_funcionalidad fun
        WHERE sol.numcte = pNumCteTraspasar AND fun.cod_funcion = "016";
    END IF;
        
    FOREACH
        SELECT {+INDEX (bdinteg:si_fuscuentas idxctecta)} producto, nombre, cuenta, num_cte, status, fecha_alta,  saldo
        INTO vc_producto, vc_descproducto, vc_cuenta, vc_cliente, vc_estatus, vd_fechaalta, vm_saldo
        FROM si_fuscuentas
        WHERE num_cte = pNumCteTraspasar
        ORDER BY producto
        RETURN vc_producto, vc_descproducto, vc_cuenta, vc_cliente, vc_estatus, vd_fechaalta, vm_saldo WITH RESUME;
    END FOREACH;
    DELETE {+INDEX (bdinteg:si_fuscuentas idxctecta)} FROM si_fuscuentas WHERE num_cte = pNumCteTraspasar;   
END;
END PROCEDURE;