create procedure "informix".consdevpre(pe_empresa   char(3),
                                       pe_sucursal  char(4),
                                       pe_moneda    char(2),
                                       pe_secuencia smallint)
   returning char(5),char(3),char(3),char(20),char(3),char(10),
             money(14,2),char(3),char(3),char(2);

-- ****************************** Definicion de Variables *********************
-- Variables para sc_devcam
   define vd_Usuario       char(5);
   define vd_Codigo_Bco    char(3);
   define vd_Num_Remesa    char(4);
   define vd_Secuencia     smallint;
   define vd_Numero_Cta    char(20);
   define vd_Sucursal      char(4);
   define vd_Producto      char(3);
   define vd_Numero_Cheque char(10);
   define vd_Importe       money(14,2);
   define vd_Causa_Dev     char(3);
   define vd_banco         char(2);
   define vd_moneda        char(2);
   define v_secuencia      char(3);

-- Variables solo de trabajo
   define vt_CodRet          char(5);
   define vt_Iteracion       smallint;

-- *************************** Inicializacion de Variables *********************
   let vt_CodRet = "000";

-- *************************** Validaciones y Calculos *************************
-- begin work;
let vt_Iteracion = 0;
-- Genera ciclo para regreso de valores de la captura de un usuario
foreach
   select codigo_bco,Secuencia,Numero_Cta,Producto,Numero_Cheque,
          Importe,Causa_Dev,codigo_bco,sucursal,moneda
      into vd_Codigo_Bco,vd_Secuencia,vd_Numero_Cta,vd_Producto,
           vd_Numero_Cheque,vd_Importe,vd_Causa_Dev,vd_banco,vd_sucursal,
           vd_moneda
      from sc_devcam
      where empresa = pe_empresa and sucursal = pe_sucursal and
            moneda = pe_moneda
      order by codigo_bco
   let vt_Iteracion = vt_Iteracion + 1;
   if vt_Iteracion <= pe_secuencia then
      continue foreach;
   end if
   let  v_secuencia=vd_secuencia;
   return vt_CodRet,vd_Codigo_Bco,vd_Secuencia,vd_Numero_Cta,
          vd_Producto,vd_Numero_Cheque,vd_Importe,
          vd_Causa_Dev,vd_sucursal,vd_moneda with resume;
end foreach

end procedure;