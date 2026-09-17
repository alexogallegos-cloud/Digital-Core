create procedure "informix".consultcam(pe_empresa char(3),
                                  pe_Usuario      char(5),
                                  pe_RengNoConsid smallint,
                                  pe_Codigo_Bco   char(4),
                                  pe_Num_Remesa   char(4),
                                  pe_Sucursal     char(4))
   returning char(5),  money(14,2), money(14,2), money(14,2),
             char(3), char(20),    char(10),     money(14,2),
             char(2),  char(2);

-- ****************************** Definicion de Variables *********************
-- Variables para sc_camara
   define vc_Indicador     numeric(1);
   define vc_Usuario       char(5);
   define vc_Codigo_Bco    char(4);
   define vc_Num_Remesa    char(4);
   define vc_Sucursal      char(4);
   define vc_Importe_Tot   money(14,2);
   define vc_Imp_Capturado money(14,2);
   define vc_Imp_Pendiente money(14,2);

-- Variables para sc_detcam
   define vd_Secuencia     char(3);
   define vd_Numero_Cta    char(20);
   define vd_Numero_Cheque char(10);
   define vd_Importe       money(14,2);
   define vd_Tipo_Docto    char(2);
   define vd_Causa_Dev     char(2);

-- Variables solo de trabajo
   define vt_CodRet          char(5);
   define vt_Iteracion       smallint;

-- ************************ Inicializacion de Variables *********************
   let vt_CodRet = "000";

-- ************************ Validaciones y Calculos *************************
-- begin work;
let vt_Iteracion = 0;
-- Genera ciclo para regreso de valores correspondientes a la captura de un usuario
foreach
   select ca.Importe_Tot, ca.Imp_Capturado, ca.Imp_Pendiente,
          dc.Secuencia, dc.Numero_Cta, dc.Numero_Cheque,
          dc.Importe, dc.Tipo_Docto, dc.Causa_Dev
      into vc_Importe_Tot, vc_Imp_Capturado, vc_Imp_Pendiente,
           vd_Secuencia, vd_Numero_Cta, vd_Numero_Cheque,
           vd_Importe, vd_Tipo_Docto, vd_Causa_Dev
      from sc_camara ca, sc_detcam dc
      where ca.empresa    = pe_empresa and
            ca.Usuario    = pe_Usuario and
            ca.Codigo_Bco = pe_Codigo_Bco and
            ca.Num_Remesa = pe_Num_Remesa and
            ca.Sucursal   = pe_Sucursal and
            ca.empresa    = dc.empresa and
            ca.Usuario    = dc.Usuario and
            ca.Codigo_Bco = dc.Codigo_Bco and
            ca.Num_Remesa = dc.Num_Remesa and
            ca.Sucursal   = dc.Sucursal
      group by ca.Usuario, ca.Codigo_Bco, ca.Num_Remesa,
               ca.Sucursal, 1, 2, 3, 4, 5, 6, 7, 8, 9
      order by dc.Secuencia
   let vt_Iteracion = vt_Iteracion + 1;
   -- Se Verifica el Numero de Renglones que seran Obviados (Por el CS2)
   if vt_Iteracion <= pe_RengNoConsid then
      continue foreach;
   end if
   return vt_CodRet, vc_Importe_Tot, vc_Imp_Capturado,
          vc_Imp_Pendiente, vd_Secuencia, vd_Numero_Cta,
          vd_Numero_Cheque, vd_Importe, vd_Tipo_Docto,
          vd_Causa_Dev with resume;
end foreach

-- commit work;

end procedure;