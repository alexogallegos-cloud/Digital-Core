CREATE PROCEDURE "informix".sp_reportesbc_pba(vEmpresa char(3),vfechareporte char(10))

RETURNING CHAR(3)AS vcod_ret, CHAR(20)AS vcuenta, CHAR(4)AS vsucursal,
          DATE AS vfecha_alta,CHAR(4)AS vtransacc,CHAR(40)AS vreferencia,
          INTEGER AS vnum_chq,SMALLINT AS vdias_ori, MONEY(14,2) AS vmonto_ori, 
          CHAR(2)AS vsiglas,CHAR (40) AS vBanco, char (10) AS vfecharep;

--**********************************************************************
--*    sp_reporteSBC                                                   *
--*    Version              1.0.0                                      *
--*    Objetivo:            Obtener el reporte de la liberacion SBC    *
--*    Supuestos:           Ninguno                                    *
--*    Creado por:          Edith Rodríguez Arellano                   *
--*    ModIFicado por:                                                 *
--*    Ultima Modificacion: Enero - 2009                               *
--*                         Creación de SPL                            *
--*    Modificado por JYDG de dia.codigo_fun = '033' a '336'           *
--**********************************************************************

DEFINE vcod_ret CHAR(3);
DEFINE sql_err  integer;
DEFINE vcuenta  CHAR(20);
DEFINE vsucursal CHAR(4);  
DEFINE vfecha_alta DATE;
DEFINE vtransacc CHAR(4);
DEFINE vreferencia CHAR(40);
DEFINE vnum_chq INTEGER;
DEFINE vdias_ori SMALLINT;
DEFINE vmonto_ori MONEY(14,2);
DEFINE vsiglas CHAR(2);
DEFINE vtranlibsbc CHAR(4); 
DEFINE vtranlibctadev CHAR(4);
DEFINE vtranlibsbcTC CHAR(4);
DEFINE vBanco CHAR(40); 

DEFINE vfecharep char(10);

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
         let vcod_ret = sql_err;
        return vcod_ret,null,null,
           null,null,null,
           null,null,null,
           null,null,null;
      end if;
   end exception;

  --SET DEBUG FILE TO "/tmp/sp_reporteSBC.out";
  --TRACE ON;  

LET vcod_ret ='000';
LET vtranlibsbc = "0000";
LET vtranlibctadev = "0000";
LET vtranlibsbcTC = "0000";
LET vfecharep=vfechareporte;
   select valor into vtranlibsbc
     from sc_param
    where empresa = vEmpresa and codparam = "tranlibsbc";

   select valor into vtranlibctadev
     from sc_param
    where empresa = vEmpresa and codparam = "tranlibctadev";

   select valor into vtranlibsbcTC
     from bdicred:sd_param
    where empresa = vEmpresa and cod_param = "83";


   FOREACH
   
   
      SELECT {+INDEX(sc_movdia idx_movdia7a), +INDEX(sc_docret idx_docret2)} ret.cuenta,ret.sucursal,ret.fecha_alta,
             ret.transacc,ret.referencia,ret.num_chq,
             ret.dias_ori,ret.monto_ori,ret.siglas, 
             ban.descripcion
        INTO vcuenta,vsucursal,vfecha_alta,
             vtransacc,vreferencia,vnum_chq,
             vdias_ori,vmonto_ori,vsiglas,
             vBanco  
        FROM sc_movdia dia, 
             sc_docret ret, 
             bdinteg:si_bancos ban
       WHERE dia.cuenta=ret.cuenta
         --AND dia.empresa=ret.empresa
         AND dia.monto_tot=ret.monto_ori
         AND dia.num_cheq=ret.num_chq
         AND dia.folio_suc=ret.folio_suc
         AND (dia.transacc = vtranlibsbc OR dia.transacc = vtranlibctadev OR dia.transacc = vtranlibsbcTC ) 
         AND ret.transacc = dia.transacc
         AND ret.cancelado='L'
         AND ret.siglas='SC'
         AND ban.banco= ret.referencia[1,3] 
   UNION
   
      SELECT ret.cuenta,ret.sucursal,ret.fecha_alta,
             ret.transacc,ret.referencia,ret.num_chq,
             ret.dias_ori,ret.monto_ori,ret.siglas,
             ban.descripcion
        FROM bdicred:sd_movdia dia, 
             sc_docret ret,
             bdicred:sd_tarjeta tar, 
             bdinteg:si_bancos ban 
       WHERE tar.num_tarjeta = ret.cuenta
         AND dia.num_credito = tar.num_credito       
         AND dia.empresa = ret.empresa
         AND dia.monto = ret.monto_ori     
         AND dia.folio_suc[1,14] = ret.folio_suc[1,14]
         AND dia.codigo_fun = '336'
         AND dia.codigo_ref = 1
         AND ret.cancelado = 'L'
         AND ret.siglas = 'SD'
         AND ban.banco = ret.referencia[1,3]  
   
   
   RETURN vcod_ret,vcuenta,vsucursal,
           vfecha_alta,vtransacc,vreferencia,
           vnum_chq,vdias_ori,vmonto_ori,
           vsiglas,vBanco,vfecharep WITH RESUME;
   END FOREACH;

END
END PROCEDURE;