create procedure "informix".sp_pasecontab(pempresa char(3),pfecha_hoy date, pinstancia char(1))
returning char(5);

--// ***************************************************************************
--// sp_pasecontab
--// Version              1.0.0
--// Obejtivo:            Envia el Pase Contable
--// Creado por:          Alejandro Rueda Sanchez
--// ModIFicado por:
--// Ultima Modificacion: Septiembre - 2007
--// ***************************************************************************

--//DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE vw_mca_aplic char(1);
DEFINE vw_ccsub, vw_ccsubsub, vw_ccssubsub, vw_ccsssubsub, vw_sector char(10);
DEFINE vw_moneda,     moneda_ant char(2);
DEFINE vw_ciudad, v_empresa char(3);
DEFINE vw_sucursal, vw_suc_usuario char(4);
DEFINE vwcosto_orig   char(4);
DEFINE vw_ccmayor     char(4);
DEFINE vw_usuario     char(8);
DEFINE vw_auxiliar    char(9);
DEFINE vw_descripcion char(50);
DEFINE vw_totcar, vw_totabo,vw_valor_cambio, vw_valor_div,
       vw_capt_cargo, vw_capt_abono,
       vw_cifra_control money(14,2);
DEFINE v_valor money(14,7);
DEFINE vw_control_poliza, vw_secuencia integer;
DEFINE vw_fecha_hoy   date;
DEFINE w_descripcion  char(30);
DEFINE sql_err        integer;
DEFINE vmensaje       char(80);
DEFINE sUsuario       CHAR(8);
DEFINE iLongitud      smallint;

-- Inicializa variables
LET cod_ret         = "000";
LET vw_secuencia    = 0;
LET vw_descripcion  = "MOVIMIENTO DE SPEI DEL DIA: "|| pfecha_hoy;
LET vw_valor_cambio = 0;
LET vw_valor_div    = 0;
LET vw_mca_aplic    = "0";
LET moneda_ant      = "  ";


 --set debug file to "/tmp/sp_pasecontab.out";
 --trace on;

begin
   on exception set sql_err
      if sql_err <> 0 then
 --set debug file to "/tmp/sp_pasecontab.trc";
 --trace on;
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

    --SET DEBUG FILE TO "/ifxsif01/Axel/Conta2023/sp_pasecontab.out";
    --TRACE ON;
	
   --//Asigna y ajusta a 8 posiciones nombre del Usuario
   LET iLongitud = LENGTH(trim(user)) -8 ;

   IF iLongitud > 0 THEN
      LET sUsuario = substr(user,iLongitud +1,8);
   ELSE
      LET sUsuario = trim(user);
   END IF

   --// Extrae el usuario a asignar en el Pase Contable
   SELECT ejecutivo, sucursal
     INTO vw_usuario, vw_suc_usuario
     FROM bdinteg:si_ejecut
    WHERE ejecutivo = sUsuario;

   LET vw_usuario = "spei";

   IF vw_usuario is null or vw_suc_usuario is null then
      let cod_ret = "158";
      return cod_ret;
   END IF;


   --// Asigna la fecha de hoy dada como parametro
   LET vw_fecha_hoy = pfecha_hoy;

   --// Cada registro de la Tabla Contable de SPEI lo graba en Detalle de Poliza
   --DELETE FROM bdicont:co_poldet
   -- WHERE empresa = pempresa 
   --   AND usuario = vw_usuario 
   --   AND fecha_captura = vw_fecha_hoy;

Foreach 
	SELECT chrsucursal, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, ccsector,
	 0 as tot_cargo, SUM(mnymonto) as tot_abono, chrdivisa, chrempresa, ccauxiliar, costo_orig
        INTO vw_sucursal, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
         vw_ccsssubsub, vw_sector, vw_totcar, vw_totabo, vw_moneda,
         v_empresa, vw_auxiliar, vwcosto_orig
	  FROM bdispei:tblpaseconthist
	WHERE chrcargoabono = "C" and dtfechacont=vw_fecha_hoy and instancia = pinstancia
	GROUP BY 1,2,3,4,5,6,7,10,11,12,13
	UNION
       SELECT chrsucursal, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, ccsector,
	 SUM(mnymonto) as tot_cargo, 0 as tot_abono, chrdivisa, chrempresa, ccauxiliar, costo_orig
 --       INTO vw_sucursal, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
 --       vw_ccsssubsub, vw_sector, vw_totcar, vw_totabo, vw_moneda,
 --       v_empresa, vw_auxiliar, costo_orig
	 FROM bdispei:tblpaseconthist
	WHERE chrcargoabono = "D" and dtfechacont=vw_fecha_hoy and instancia = pinstancia
	GROUP BY 1,2,3,4,5,6,7,10,11,12,13
	ORDER BY chrdivisa, chrempresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            ccsector

   select regional into vw_ciudad
      from bdinteg:si_sucursales su,bdinteg:si_plazas pl
      where su.empresa = pempresa and sucursal = vw_sucursal and
            pl.empresa = su.empresa and pl.plaza = su.plaza;

   if vw_totcar > 0 then
      let vw_secuencia = vw_secuencia + 1;
      insert into bdicont:co_poldet
         values(vw_usuario, vw_fecha_hoy, vw_secuencia,
            v_empresa, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
            vw_ccsssubsub, vw_sector, vw_ciudad, vw_sucursal, vw_auxiliar,
            "D", vw_totcar, vw_descripcion, vw_fecha_hoy, vw_moneda,vwcosto_orig);

   end if
   if vw_totabo > 0 then
      let vw_secuencia = vw_secuencia + 1;
      insert into bdicont:co_poldet
         values(vw_usuario, vw_fecha_hoy, vw_secuencia,
            v_empresa, vw_ccmayor, vw_ccsub, vw_ccsubsub, vw_ccssubsub,
            vw_ccsssubsub, vw_sector, vw_ciudad, vw_sucursal, vw_auxiliar,
            "C", vw_totabo, vw_descripcion, vw_fecha_hoy, vw_moneda,vwcosto_orig);

   end if
   let vw_mca_aplic = "1";
end foreach;
if vw_mca_aplic = "1" then
   execute procedure bdicont:auditapase(vw_fecha_hoy,v_empresa,vw_usuario)
           into cod_ret;
end if

return cod_ret;
end
end procedure;