create procedure "informix".pagoenviar1(pempresa char(3),
                                p_sucursal char(3),
                                p_usuario char(8),
                                p_tipomov char(1),
                                p_movspeua char(6),
                                p_folio_suc char(16),
                                p_plaza_orden char(5),
                                p_cta_propia char(20),
                                p_importe money(14,2),
                                p_comision money(10,2),
                                p_benef char(30),
                                p_banco_rec char(4),
                                p_plaza_rec char(5),
                                p_cta_banco char(20),
                                p_instrucciones char(210),
                                p_hora_local datetime hour to second,
                                p_sucbcodes char(4),
                                p_nomsucbcodes char(40))
                                returning char(5), char(60);

define v_codret char(5);
define v_fecha date;
define v_hora_limite datetime hour to second;
define v_comision money(10,2);
define v_us7 char(7);
define v_us6 char(6);
define v_us5 char(5);
define v_us4 char(4);
define v_us3 char(3);
define v_us2 char(2);
define v_iva decimal(9,6);
define v_ivacom money(10,2);
define v_plaza char(3);
define v_nombre char(60);
define v_materno, v_paterno, v_nombre1, v_nombre2 char(12);
define v_limaut money(16,2);
define v_razon_soc char(35);
define v_transpeua, v_trancheq, v_trancom, v_banco char(4);
define v_rastreo integer;
define v_minimo money(14,2);
define v_dia, v_mes char(2);
define v_year char(4);
define v_fecha_comp char(8);
define v_firmante char(20);
define v_firma_elect char(132);
define v_verif1, v_verif2 char(1);
define v_longitud,longitud,v_long_param_sc smallint;
define sql_err integer;


set lock mode to wait 10;
let v_verif1=" ";
let v_verif2=" ";
let v_codret="000";
let v_ivacom = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
         let v_codret = sql_err;
         return v_codret, p_folio_suc;
      end if
   end exception;

-- **** INICIO DE VALIDACIONES. ****

 return v_codret, p_folio_suc;  --Esta Linea se adiciono para hacer pruebas de Dlls


-- Se valida plaza de envio y hora limite movimientos SPEUA.
let p_plaza_orden = p_plaza_orden;

select hora_limite into v_hora_limite
        from bdispeua:sp_plazasbanxico
        where plaza=p_plaza_orden;
if v_hora_limite is null then
        let v_codret="877";
        return v_codret, p_folio_suc;
end if;
if v_hora_limite < p_hora_local then
        let v_codret="877";
        return v_codret, p_folio_suc;
end if;

--Se valida plaza de Recepcion

select hora_limite into v_hora_limite
        from bdispeua:sp_plazasbanxico
        where plaza=p_plaza_rec;
if v_hora_limite is null then
        let v_codret="876";
        return v_codret, p_folio_suc;
end if;
if v_hora_limite <= current hour to minute then
        let v_codret="876";
        return v_codret, p_folio_suc;
end if;

-- Se valida sucursal

select nombre into v_nombre
        from bdinteg:si_sucursales
        where empresa = pempresa and sucursal=p_sucursal;

if v_nombre is null then
        let v_codret="102";
        return v_codret, p_folio_suc;
end if;

-- Se valida el Usuario

select limaut_mn into v_limaut
        from bdinteg:si_ejecut
        where ejecutivo=p_usuario;

if v_limaut is null then
        let v_codret="106";
        return v_codret, p_folio_suc;
end if;
if p_importe > v_limaut then
        let v_codret="881";
        return v_codret, p_folio_suc;
end if;

-- Se valida Tipo de Movimiento

select transacc_envio into v_transpeua
        from bdispeua:sp_operaciones
        where codigo=p_tipomov;

if v_transpeua is null then
        let v_codret="550";
        return v_codret, p_folio_suc;
end if;

-- Se valida Banco Receptor

select descripcion into v_nombre from bdinteg:si_bancos
        where banco=p_banco_rec;

if v_nombre is null then
        let v_codret="099";
        return v_codret, p_folio_suc;
end if;

let v_firmante=p_usuario;
let v_firma_elect = "0000000000";
select banco_speua, monto_minimo, tran_cargo, tran_comision, ult_cve_rastreo
        into v_banco, v_minimo, v_trancheq, v_trancom, v_rastreo
        from bdispeua:sp_param;

if v_banco is null then
        let v_codret="110";
        return v_codret, p_folio_suc;
end if;
if v_minimo > p_importe then
        let v_codret="875";
        return v_codret, p_folio_suc;
end if;

-- Se extrae la fecha del Movimiento

select fecha_hoy into v_fecha from bdinteg:si_fechas where empresa = pempresa;

-- Se realizan cargos a cheques
if p_cta_propia is not null and p_cta_propia!=" " then
-- Se extrae el nombre del Emisor

        select nombre1, nombre2, apell_paterno, apell_materno, razon_social
                into v_nombre1, v_nombre2, v_paterno, v_materno, v_razon_soc
                from bdinteg:si_cliente, sc_maechq
                where sc_maechq.num_cte=bdinteg:si_cliente.numcte
                and sc_maechq.empresa = pempresa and cuenta=p_cta_propia;

        if v_razon_soc is null or v_razon_soc = " " then
                let v_nombre=TRIM(v_nombre1)|| " " || TRIM(v_nombre2)|| " " ||
                              TRIM(v_paterno)|| " " || TRIM(v_materno);
        else
                let v_nombre=TRIM(v_razon_soc);
        end if;
        let v_longitud=length(p_cta_propia);
        if v_longitud=10 then
                let v_verif1=p_cta_propia[10, 10];
        elif v_longitud=9 then
                let v_verif1=p_cta_propia[9, 9];
        elif v_longitud=8 then
                let v_verif1=p_cta_propia[8, 8];
        end if;
        let v_longitud=length(p_cta_banco);
        if v_longitud=10 then
                let v_verif2=p_cta_banco[10, 10];
        elif v_longitud=9 then
                let v_verif2=p_cta_banco[9, 9];
        elif v_longitud=8 then
                let v_verif2=p_cta_banco[8, 8];
        elif v_longitud=7 then
                let v_verif2=p_cta_banco[7, 7];
        elif v_longitud=6 then
                let v_verif2=p_cta_banco[6, 6];
        elif v_longitud=5 then
                let v_verif2=p_cta_banco[5, 5];
        elif v_longitud=4 then
                let v_verif2=p_cta_banco[4, 4];
        elif v_longitud=3 then
                let v_verif2=p_cta_banco[3, 3];
        elif v_longitud=2 then
                let v_verif2=p_cta_banco[2, 2];
        end if;
else
        if p_comision=0 then
                let v_ivacom=0;
        else
                select plaza into v_plaza from bdinteg:si_sucursales
                        where empresa = pempresa and sucursal=p_sucursal;
                if v_plaza is null then
                        let v_iva=0;
                else
                        select iva into v_iva from bdinteg:si_plazas
                                where empresa = pempresa and plaza=v_plaza;
                        if v_iva is null then
                                let v_iva=0;
                        end if
                end if;
                let v_ivacom=p_comision*v_iva;
        end if;
        let v_nombre=" ";
        let p_cta_propia=" ";
end if;

let v_dia=day(v_fecha);
if length(v_dia) < 2 then
        let v_dia="0" || v_dia;
end if
let v_mes=month(v_fecha);
if length(v_mes) < 2 then
        let v_mes="0" || v_mes;
end if
let v_year=year(v_fecha);
let v_fecha_comp=v_dia || v_mes || v_year;
insert into bdispeua:sp_pagoenviar values(p_tipomov,
                                        p_movspeua,
                                        v_banco,
                                        p_plaza_orden,
                                        "CHQ",
                                        p_cta_propia,
                                        v_verif1,
                                        v_nombre,
                                        p_banco_rec,
                                        p_plaza_rec,
                                        "CHQ",
                                        p_cta_banco,
                                        v_verif2,
                                        p_benef,
                                        p_importe,
                                        p_comision,
                                        v_ivacom,
                                        p_folio_suc,
                                        v_fecha_comp,
                                        v_fecha_comp,
                                        p_instrucciones,
                                        "P",
                                        "",
                                        v_firmante,
                                        v_firma_elect,"");

return v_codret, p_folio_suc;
end
end procedure;