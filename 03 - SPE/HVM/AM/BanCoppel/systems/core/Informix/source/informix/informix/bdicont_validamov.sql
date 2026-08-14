create procedure "informix".validamov(pempresa char(3),pfecha_hoy date)
returning char(5);

--#***************************************************************************#
--#                                                                           #
--#   ESTA FUNCION VALIDA LA TABLA DE MOVIMIENTOS DIARIOS DE DETERMINADA      #
--#   FECHA Y COMPANIA, POSTERIORMENTE DEBE REALIZAR UN CIERRE DEL DIA        #
--#                                                                           #
--#   co_tabmovdia     --> Tabla Primaria de Lectura                          #
--#   co_detpol        --> Tabla de salida (detalle de polizas)               #
--#   co_poliza        --> Tabla de salida (encabezado de polizas)            #
--#   co_mapeo_rech    --> Tabla de salida (errores detectados en el movto.)  #
--#                                                                           #
--#***************************************************************************#


define vproceso                char(20);
define w_cod_ret               char(5);
define pusuario                char(8);
define pcontrol_poliza         integer;

define tmoempresa              char(3);
define tmoccmayor              char(4);
define tmoccsub                char(2);
define tmoccsubsub             char(2);
define tmoccssubsub            char(2);
define tmoccsssubsub           char(2);
define tmosector               char(2);
define tmodivision             char(3);
define tmoplaza                char(3);
define tmonaturaleza           char(1);
define tmomonto                money(18,2);
define tmodescripcion          char(50);
define tmofecha_captura        date;
define tmousuario              char(8);
define tmofecha_valida         date ;
define tmonum_poliza           smallint;
define tmomoneda               char(2);
define tmoauxiliar             char(9);
define tmosecuencia            integer;
define tmopoliza_usuario       char(8);
define tmotip_mov              char(1);
define tmomoneda_ext           char(3);
define v_pro                   smallint;


delete from co_mapeo_rech;

let w_cod_ret = "000";

foreach
   select *
   into
   tmoempresa,
   tmoccmayor,
   tmoccsub,
   tmoccsubsub,
   tmoccssubsub,
   tmoccsssubsub,
   tmosector,
   tmodivision,
   tmoplaza,
   tmonaturaleza,
   tmomonto,
   tmodescripcion,
   tmofecha_captura,
   tmousuario,
   tmofecha_valida,
   tmonum_poliza,
   tmomoneda,
   tmoauxiliar,
   tmosecuencia,
   tmopoliza_usuario,
   tmotip_mov,
   tmomoneda_ext
   from co_tabmovdia

   if tmoempresa is null or tmoccmayor is null or tmomoneda is null or
                              tmoauxiliar is null or tmosector is null then
      if tmoempresa is null then
         let w_cod_ret = "118";
         insert into co_mapeo_rech
         values(tmoempresa, tmousuario, tmonum_poliza,
                tmofecha_captura, tmosecuencia, w_cod_ret,
                tmomonto,tmonaturaleza," ");
      end if
      if tmoccmayor is null then
         let w_cod_ret = "119";
         insert into co_mapeo_rech
         values(tmoempresa, tmousuario, tmonum_poliza,
                tmofecha_captura, tmosecuencia, w_cod_ret,
                tmomonto,tmonaturaleza,tmoauxiliar);
      end if
      if tmomoneda is null then
         let w_cod_ret = "120";
         insert into co_mapeo_rech
         values(tmoempresa, tmousuario, tmonum_poliza,
                tmofecha_captura, tmosecuencia, w_cod_ret,
                tmomonto,tmonaturaleza,tmomoneda_ext);
      end if
      if tmoauxiliar is null then
         let w_cod_ret = "121";
         insert into co_mapeo_rech
         values(tmoempresa, tmousuario, tmonum_poliza,
                tmofecha_captura, tmosecuencia, w_cod_ret,
                tmomonto,tmonaturaleza," ");
      end if
      if tmosector is null then
         let w_cod_ret = "122";
         insert into co_mapeo_rech
         values(tmoempresa, tmousuario, tmonum_poliza,
                tmofecha_captura, tmosecuencia, w_cod_ret,
                tmomonto,tmonaturaleza,tmopoliza_usuario);
      end if
   else
      insert into bdicont:co_detpol
      values(tmousuario,       tmonum_poliza,
             tmofecha_captura, tmosecuencia,
             tmoempresa,       tmoccmayor,
             tmoccsub,         tmoccsubsub,
             tmoccssubsub,     tmoccsssubsub,
             tmosector,        tmoplaza,
             tmodivision,      " ",
             tmonaturaleza,    tmomonto,
             tmodescripcion,   tmofecha_valida,
             tmomoneda,        0, 0, "N",
             "099",tmotip_mov);
   end if
end foreach

if w_cod_ret != "000" then
   return w_cod_ret;
else
   delete
   from  co_poliza
   where fecha_captura = pfecha_hoy
   and   empresa = pempresa;

   foreach
     select unique usuario, control_poliza
     into          pusuario,pcontrol_poliza
     from co_detpol
     where empresa = pempresa
     and   fecha_captura = pfecha_hoy

     execute procedure gen_encab(pempresa,pusuario,pfecha_hoy,pcontrol_poliza)
     into w_cod_ret;
   end foreach
end if
return w_cod_ret;
end procedure;