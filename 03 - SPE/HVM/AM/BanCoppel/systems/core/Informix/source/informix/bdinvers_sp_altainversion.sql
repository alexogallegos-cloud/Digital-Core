create procedure "informix".sp_altainversion(
-- APERTINV
    pempresa 	  char(3),
    pnum_cte        char(20),
    ppromotor       char(8),
    psucursal       char(4),
    ptipo_banca     char(3),
    preg_firmas     char(1),
    penvio          char(1),
    pdirecc_envio   smallint,
    pcobraisr       char(1),
-- Instrumento
    pinstrumento    char(4),
    popcion_ret     char(2),
    pespecial       char(1),
    pnum_autorizac  char(13),
    pdias           smallint,
    pfecha_venc     date,
    pcapital        money(14,2),
    pper_acred      char(1),
    ptasa_instrum   char(8),
    pdeposito       char(1),
    pcta_cheques    char(20),
    pcuenta         char(20),
    pptos_adicional decimal(6,4),
-- Instrucciones Capital
    pinst_vento1    char(2),
    pnro_cuenta1    char(20),
-- Instrucciones Intereses
    pinst_vento2    char(2),
    pnro_cuenta2    char(20),
-- Beneficiarios 1
    pnombre1        char(20),
    pparentesco1    char(2),
    pporcentaje1    decimal(9,6),
-- Beneficiarios 2
    pnombre2        char(20),
    pparentesco2    char(2),
    pporcentaje2    decimal(9,6),
-- Beneficiarios 3
    pnombre3        char(20),
    pparentesco3    char(2),
    pporcentaje3    decimal(9,6),
-- Beneficiarios 4
    pnombre4        char(20),
    pparentesco4    char(2),
    pporcentaje4    decimal(9,6),
-- Cotitular 1
    pnombrecot1     char(20),
    pparentesco5    char(2),
-- Cotitular 2
    pnombrecot2     char(20),
    pparentesco6    char(2),
-- Movimiento
    pfolio_suc      char(16),
    pdivisa         char(2),
    ptranCgo        char(4))


    returning char(5),char(20),smallint,smallint,date,money(10,2),
    money(14,2),decimal(9,6),decimal(9,6),decimal (9,6);
    


    DEFINE v_codret char(5);
    DEFINE v_secuencia,v_dias smallint;
    DEFINE v_inversion char(20);
    DEFINE v_isr money(10,2);
    DEFINE v_rendimiento money(14,2);
    DEFINE v_fecha_venc date;
    DEFINE v_fecha_hoy date;
    DEFINE v_bruta,v_tasa_isr,v_neta decimal(9,6); 
    DEFINE vpaso CHAR(10);
    DEFINE vsqlerr integer;
    define vtransaccion integer;

    let vtransaccion = 0;
    let v_neta = 0;
    let v_tasa_isr = 0;
    let v_bruta = 0;
    let v_rendimiento = 0;
    let v_isr = 0;
    let v_fecha_venc = "";
    let v_dias = 0;
    let v_secuencia = 0;
    let v_inversion = "";

    set lock mode to wait 3;

begin
    
    on exception set vsqlerr
    if vsqlerr <> 0  then
        let v_codret = vsqlerr;
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if
        
        return  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,v_isr,
                v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    end if;
    end exception;



    on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;


-- set debug file to "/tmp/sp_altainversion.out";
-- trace on;
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        BEGIN WORK;
    end if;

    -- lanzar cargo
    
    CALL bdicheq:cargo_ref(pempresa, psucursal, ppromotor, ptranCgo,
               "0000", pfolio_suc, pcta_cheques, 0,
               pcapital, pdivisa, "", "", "")
    RETURNING v_codret, vpaso, vpaso, vpaso, vpaso;
    
    if v_codret <> "000" then
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        return  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    end if;    
    
    -- lanzar apertura
    
    CALL apertinv(
    pempresa,
    pnum_cte,
    ppromotor,
    psucursal,
    ptipo_banca,
    preg_firmas,
    penvio,
    pdirecc_envio,
    pcobraisr,
    pinstrumento,
    popcion_ret,
    pespecial,
    pnum_autorizac,
    pdias,pfecha_venc,
    pcapital,
    pper_acred,
    ptasa_instrum,
    pdeposito,
    pcta_cheques,
    pcuenta,
    pptos_adicional,
    pinst_vento1,
    pnro_cuenta1,
    pinst_vento2,
    pnro_cuenta2,
    pnombre1,
    pparentesco1,
    pporcentaje1,
    pnombre2,
    pparentesco2,
    pporcentaje2,
    pnombre3,
    pparentesco3,
    pporcentaje3,
    pnombre4,
    pparentesco4,
    pporcentaje4,
    pnombrecot1,
    pparentesco5,
    pnombrecot2,
    pparentesco6,
    pfolio_suc,
    pdivisa)
    RETURNING   v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    
    if v_codret <> "000" then
        if vtransaccion = 1 then
            ROLLBACK WORK;
            BEGIN WORK;
        else
            ROLLBACK WORK;
        end if;
        return  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
                v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
    end if;
    
    if vtransaccion = 1 then
        COMMIT WORK;
        BEGIN WORK;
    else
        COMMIT WORK;
    end if;
   
    return  v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
            v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
   
end
end procedure;