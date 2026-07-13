create procedure "informix".apertinv(pempresa char(3),
                           pnum_cte      char(20),
			   ppromotor     char(8),
			   psucursal     char(4),
			   ptipo_banca   char(3),
			   preg_firmas   char(1),
			   penvio        char(1),
			   pdirecc_envio smallint,
                           pcobraisr     char(1),
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
			  pdeposito	  char(1),
			  pcta_cheques	  char(20),
			  pcuenta    char(20),
			  pptos_adicional decimal(6,4),
-- Instrucciones Capital
			  pinst_vento1   char(2),
			  pnro_cuenta1   char(20),
-- Instrucciones Intereses
			  pinst_vento2   char(2),
			  pnro_cuenta2   char(20),
-- Beneficiarios 1
		          pnombre1       char(20),
		          pparentesco1   char(2),
		          pporcentaje1   decimal(9,6),
-- Beneficiarios 2
		          pnombre2       char(20),
		          pparentesco2   char(2),
		          pporcentaje2   decimal(9,6),
-- Beneficiarios 3
		          pnombre3       char(20),
		          pparentesco3   char(2),
		          pporcentaje3   decimal(9,6),
-- Beneficiarios 4
		          pnombre4       char(20),
		          pparentesco4   char(2),
		          pporcentaje4   decimal(9,6),
-- Cotitular 1
			  pnombrecot1    char(20),
		          pparentesco5   char(2),
-- Cotitular 2
			  pnombrecot2    char(20),
		          pparentesco6   char(2),

-- Movimiento
                          pfolio_suc     char(16),
			  pdivisa        char(2))

returning char(5),char(20),smallint,smallint,date,money(10,2),
	money(14,2),decimal(9,6),decimal(9,6),decimal (9,6);

define v_codret char(5);
define v_secuencia,v_dias smallint;
define v_inversion char(20);
define v_isr money(10,2);
define v_rendimiento money(14,2);
define v_fecha_venc date;
define v_fecha_hoy date;
define v_bruta,v_tasa_isr,v_neta decimal(9,6);
define v_trancap,v_tranvtopas1 char(4);
define v_hora datetime hour to fraction;
define v_usuario char(8);
define pplaza char(3);
define sql_err int;


let v_codret="000";
let v_secuencia=1;
let v_usuario = pfolio_suc[1,8];
let v_inversion=" ";
let v_dias=0;
let v_fecha_venc=" ";
let v_isr=0;
let v_rendimiento=0;
let v_bruta=0;
let v_tasa_isr=0;
let v_neta=0;
let sql_err = 0;

BEGIN
   ON EXCEPTION SET sql_err 
   LET v_codret = sql_err;
   return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,v_isr,
      v_rendimiento,v_bruta,v_tasa_isr,v_neta;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3; 



   -- set debug file to "/RESPALDOS/inver/apertinv.out";
      -- trace on;

   SELECT fecha_hoy INTO v_fecha_hoy
      FROM sv_fechas
      where empresa = pempresa;

   select plaza into pplaza
      from bdinteg:si_sucursales
      where empresa = pempresa and sucursal = psucursal;
   IF psucursal = '5011' THEN
      call apertura_app(pempresa,pnum_cte,v_secuencia,pinstrumento,
               ppromotor,ptipo_banca,psucursal,pplaza,preg_firmas,penvio,
               popcion_ret,pespecial,pnum_autorizac,pdias,pfecha_venc,
               pcapital,pper_acred,ptasa_instrum,ppromotor,
               pdeposito,pcta_cheques,pcuenta,pptos_adicional,
                  pdirecc_envio,pcobraisr)
         returning v_codret,v_inversion,v_dias,v_fecha_venc,v_isr,
                     v_rendimiento,v_bruta,v_tasa_isr,v_neta;
      if v_codret!="000" then
         return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
         v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
      else
         let pcuenta = v_inversion;
      end if;
   ELSE 
      call apertura(pempresa,pnum_cte,v_secuencia,pinstrumento,
               ppromotor,ptipo_banca,psucursal,pplaza,preg_firmas,penvio,
               popcion_ret,pespecial,pnum_autorizac,pdias,pfecha_venc,
               pcapital,pper_acred,ptasa_instrum,ppromotor,
               pdeposito,pcta_cheques,pcuenta,pptos_adicional,
                  pdirecc_envio,pcobraisr)
         returning v_codret,v_inversion,v_dias,v_fecha_venc,v_isr,
                     v_rendimiento,v_bruta,v_tasa_isr,v_neta;
      if v_codret!="000" then
         return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
         v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
      else
         let pcuenta = v_inversion;
      end if;
   END IF;
   call instrucc(pempresa,pplaza,psucursal,v_inversion,pcapital,v_rendimiento,
               "C",pinst_vento1,pcapital,pnro_cuenta1,pfecha_venc) 
      returning v_codret;
                           
   if v_codret<>"133" then
      delete from sv_maeinv 
         where empresa = pempresa and cuenta = v_inversion;
      return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
         v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
   end if;

   call instrucc(pempresa,pplaza,psucursal,v_inversion,pcapital,v_rendimiento,
               "I",pinst_vento2,v_rendimiento,pnro_cuenta2,pfecha_venc) 
      returning v_codret;

   if v_codret!="000" then
      delete from sv_maeinv 
         where empresa = pempresa and cuenta = v_inversion;
      delete from sv_maeinstrucc 
         where empresa = pempresa and cuenta = v_inversion;
      return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,
         v_isr,v_rendimiento,v_bruta,v_tasa_isr,v_neta;
   end if;

   if pnombre1 is not null and pnombre1 !="" then
      call benef(pempresa,v_inversion,1,"",pparentesco1,pporcentaje1,pnombre1)
         returning v_codret;
      if v_codret!="000" and v_codret <> "134" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if;
   end if;

   if pnombre2 is not null and pnombre2 !="" then
      call benef(pempresa,v_inversion,2,"",pparentesco2,pporcentaje2,pnombre2)
         returning v_codret;
      if v_codret!="000" and v_codret <> "134" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_benefic 
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if;
   end if;

   if pnombre3 is not null and pnombre3 !="" then
      call benef(pempresa,v_inversion,3,"",pparentesco3,pporcentaje3,pnombre3)
         returning v_codret;
      if v_codret!="000" and v_codret <> "134" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_benefic 
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if;
   end if;

   if pnombre4 is not null and pnombre4 !="" then
      call benef(pempresa,v_inversion,4,"",pparentesco4,pporcentaje4,pnombre4)
         returning v_codret;
      if v_codret!="000" and v_codret <> "134" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_benefic 
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if;
   end if;
   if pnombrecot1 is not null and pnombrecot1!="" then
      call cotit(pempresa,v_inversion,1,"",pparentesco5,pnombrecot1) 
         returning v_codret;
      if v_codret!="000" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_benefic 
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if
   end if;

   if pnombrecot2 is not null and pnombrecot2!="" then
      call cotit(pempresa,v_inversion,2,"",pparentesco6,pnombrecot2) 
         returning v_codret;
      if v_codret!="000" then
         delete from sv_maeinv
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_maeinstrucc 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_benefic 
            where empresa = pempresa and cuenta = v_inversion;
         delete from sv_cotitular
            where empresa = pempresa and cuenta = v_inversion;
         return v_codret,v_inversion,v_secuencia,v_dias,
            v_fecha_venc,v_isr,v_rendimiento,v_bruta,
         v_tasa_isr,v_neta;
      end if
   end if;

   -- Crea el movimiento diario  (sv_movdia)
   if pdeposito = "2" then
      let v_hora = current hour to fraction;
      select trans_cap, trans_vtopas1 into v_trancap,v_tranvtopas1
         from sv_instrum
         where empresa = pempresa and cod_instrum = pinstrumento;
      if v_tranvtopas1 <> "" and v_tranvtopas1 is not null then
         insert into sv_movdia
            values (pempresa,0,pfolio_suc,pplaza,psucursal,v_usuario,v_fecha_hoy,
               v_hora,v_tranvtopas1,psucursal,pcuenta,v_secuencia,pinstrumento,
               0,pcapital,pcapital,0,0,"",0,"0000");
      end if
      update sv_maeinv 
         set status_cta = "1"
         where empresa = pempresa and cuenta = pcuenta;
      insert into sv_movdia
         values (pempresa,0,pfolio_suc,pplaza,psucursal,v_usuario,v_fecha_hoy,
               v_hora,v_trancap,psucursal,pcuenta,v_secuencia,pinstrumento,
               0,pcapital,pcapital,0,0,"",0,"0000");
   end if

   return v_codret,v_inversion,v_secuencia,v_dias,v_fecha_venc,v_isr,
      v_rendimiento,v_bruta,v_tasa_isr,v_neta;
END;
end procedure;