create procedure "informix".sp_altachequeras( pempresa char(3), --Empresa
                                            pcuenta  char(20), -- Cuenta
                                            pcanal   smallint, --Canal 1 OFI, 2 (CAT, Internet)
                                            ptipo    Char(2),   -- Tipo de Chequera
                                            pusuario Char(8)    --Usuario
                                            )
       returning     char(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_altachequeras
   --
   -- Version              1.0.0
   -- Objetivo:            Alta de  chequeras.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Ultima Modificacion: Octubre  - 2009
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vno_cheques     smallint;
   DEFINE vconsec         integer;
   DEFINE v_hoy           date;
   DEFINE v_sucursal      char(4);
   DEFINE v_status        char(1);
   DEFINE v_valor         char(1);
   DEFINE v_inicial       INTEGER;
   DEFINE v_final         INTEGER;
   DEFINE a               SMALLINT;
   DEFINE vnumchq         INTEGER;
   DEFINE vnumactivos     INTEGER;
   DEFINE vmaxpermite     INTEGER;
   DEFINE vdummy          char(100);
   DEFINE vdummy1         char(100);
   define vfecha   	DATETIME hour TO second;
   define vfecha1 		char(8);
   define vhora         char(10);




   LET vcodret      = " ";
   LET vno_cheques  = " ";
   LET vsqlerr      = 0;
   LET v_status     = " ";
   LET vno_cheques  = 0;
   LET vconsec      = 0;
   LET v_sucursal   = " ";
   LET v_status     = " ";
   LET v_inicial    = 0;
   LET v_final      = 0;
   LET a            = 0;
   LET v_valor      = " ";
   LET vnumchq      = 0;
   LET vmaxpermite  = 0;
   LET vdummy      = " ";
   LET vdummy1     = " ";
   LET vfecha1     = current hour to second;
   LET vhora       = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   



   --SET DEBUG FILE TO "/tmp/sp_altachequeras.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          return vcodret;
       END IF;
    end exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   if pempresa = " " or pcuenta = " " or pcanal = 0 then
      let vcodret = "001";
      call sp_errores( v_hoy, vhora, pcuenta, "001","sp_altachequeras","Error en Parametros de Entrada Nulos",pusuario);
      return vcodret;
   end if

   --- Selecciona el numero de cheques por tipo de chequera.
   If ptipo = " " then
       select valor into ptipo
       from sq_param
       where cod_param = 2;
   end if

   --- Selecciona el numero de cheques por tipo de chequera.
   select valor into vmaxpermite
     from sq_param
    where cod_param = 3;

   select no_cheques
   into vno_cheques
   from bdicntchq:sq_chequera
   where chequera = ptipo;

   if vno_cheques is null  then
      let vcodret = "002";
      call sp_errores( v_hoy, vhora, pcuenta, "002","sp_altachequeras","Error al Consultar el Tipo de Chequera",pusuario);
      return vcodret;
   end if

   --- Selecciona el numero maximo de cheques.
   select max(numero)
     into vnumchq
     from bdicheq:sc_contch
    WHERE empresa = pempresa
      and cuenta = pcuenta;

   if vnumchq is null then
      let vnumchq = 1;
   else
      let vnumchq =  vnumchq + 1;
   end if

   --validacion de chequera maxima
   select max(consec)
   into vconsec
   from bdicntchq:sq_maechqra
   where cuenta = pcuenta;

   --Si la chequera es mayor o igual a 1 y el canal es OFI Regreso codigo de error
   If (vconsec >= 1 and pcanal = 1) or (vconsec is null and pcanal = 2) then
      let vcodret = "004";
      call sp_errores( v_hoy, vhora, pcuenta, "004","sp_altachequeras","Error Existen Chequeras Asignadas a esta Cuenta, No Puede Darse de Alta Como Nueva",pusuario);
      return vcodret;
   end if

   if vconsec is null then
      let vconsec = 1;
   else
      let vconsec =  vconsec + 1;
   end if

   --Se trae el numero de sucursal
   SELECT sucursal, status_cta
   INTO v_sucursal, v_status
   FROM bdicheq:sc_maechq
   WHERE cuenta = pcuenta;

   --Valida el status de la cuenta
--   IF v_status <> "1" THEN
   IF v_status = "2" THEN
      LET vcodret = "005";
      call sp_errores( v_hoy, vhora, pcuenta, "005","sp_altachequeras","Error la Cuenta no Esta Activa",pusuario);
      RETURN vcodret;
   END IF

   --Inicia proceso de actualizacion de Datos

   LET v_inicial = vnumchq;
   LET v_final   = vnumchq + vno_cheques;

   If pcanal = 1 then


      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
       let vcodret = "000";
       return vcodret;

   elif pcanal = 2 then

   --- Validacion de Cheque Activo.

       select count(numero)
       into vnumactivos
       from bdicheq:sc_contch
       where cuenta = pcuenta
       and   empresa = pempresa
       and estado = "A";

       if vnumactivos > vmaxpermite then
           let vcodret = "003";
           call sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
           return vcodret;
       end if

      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
       let vcodret = "000";
       return vcodret;
   end if
end
end procedure;