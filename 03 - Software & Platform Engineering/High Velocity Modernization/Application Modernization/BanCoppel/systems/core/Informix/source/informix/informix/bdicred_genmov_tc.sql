CREATE PROCEDURE "informix".genmov_tc(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4),
   p_tarjeta                VARCHAR(20),
   p_referencia             VARCHAR(40),
   p_tipo_cambio            DECIMAL(14,6),
   p_monto_dls              DECIMAL(14,2),
   p_usuario                CHAR(8),
   p_sucorigen		    CHAR(4),
   p_rfc_comer	  	    VARCHAR(20),
   p_referencia23	    VARCHAR(23))

RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);
DEFINE   vCodFun         CHAR(3);
DEFINE   vCodRef         SMALLINT;
define   v_refpaso       varchar(63);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;
   let v_refpaso      = '';

   IF (p_transacc_suc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   ELSE
      SELECT codigo_fun, codigo_ref
	INTO vCodFun, vCodRef
       FROM sd_transfun
      WHERE empresa = p_empresa
	AND transacc = p_transacc_suc;

      IF vCodFun IS NULL THEN
      	LET p_cod_ret = '110';
      	LET P_MENSAJE = 'ERROR';
      	RETURN P_COD_RET, P_MENSAJE;
      END IF
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

--   let vcadena = length(p_foliosuc) - 8;
--   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   IF p_referencia IS NULL OR p_referencia = " " THEN
	SELECT nvl(abreviatura,'') INTO p_referencia
	  FROM sd_transfun a, bdinteg:si_transacc b
	 WHERE a.empresa = p_empresa
	   AND a.codigo_fun = vCodFun
	   AND a.codigo_ref = vCodRef
	   AND b.empresa = a.empresa
	   AND b.numero = a.transacc
	   AND b.sistema = "06";
   END IF

   if (length(p_referencia) > 1) then
      LET v_refpaso = trim(p_foliosuc || " " || trim(p_referencia));
   else
      LET v_refpaso = trim(p_foliosuc);
   end if;

-- En caso de no tener referencia23 utilzia espacios para guardar referencia adicional
   if (trim(nvl(p_referencia23,'')) = '' and length(trim(v_refpaso)) > 40) then
      LET p_referencia23 = substr(trim(v_refpaso),41);
   end if;

   let p_referencia = trim(v_refpaso);

-- limpia referencia en IVA
   if (vCodFun = '340') then
      LET p_referencia = '';
   end if;

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   INSERT INTO sd_movdia (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       NRO_TARJETA    ,
	       REFERENCIA     ,
               TIPO_CAMBIO    ,
	       MONTO_DLS      ,
	       SUC_ORIGEN     ,
	       RFC_COMER      ,
	       REFERENCIA23   )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               p_usuario,
               v_monto,
               vCodFun,
               vCodRef,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       p_tarjeta,
	       p_referencia,
	       p_tipo_cambio,
	       p_monto_dls,
               p_sucorigen,
	       p_rfc_comer,
	       p_referencia23);

   RETURN P_COD_RET, P_MENSAJE;

END
END PROCEDURE
DOCUMENT
'Esta funcion realiza el Registro de los Movimientos generados por T.C.',
'AUTOR : Antonio Ruiz Martinez',
'FECHA : 29/12/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".cargo_ref_cel(pnum_tarjeta  char(16),
                                       psucursal    char(4),
                                       pusuario     char(8),
                                       ptransacc    char(4),
                                       ptransuc     char(4),
                                       pfolsuc      char(16),
                                       pcuenta      char(20),
                                       pcheque      integer,
                                       pmtocompra   money(14,2),
                                       pmontoefe    money(14,2),
                                       ptransefe    char(4),
                                       pfolioefe    char(16),
                                       pdivisa      char(2),
                                       preferencia  char(40),
                                       psucursalcom char(4),
                                       pusuariocom  char(8),
                                       ptrancencom  char(4),
                                       ptransuccom  char(4),
                                       pfolsuccom   char(16),
                                       pcuentacom   char(20),
                                       pchequecom   integer,
                                       pmontocom    money(14,2),
                                       pdivisacom   char(2),
                                       prefercom    char(40),
                                       pbanderacom  char(1),
                                       ptrancomefe  char(4),
                                       ptrascomefe  char(4),
                                       pfolcomefe   char(16),
                                       pchequeefe   integer,
                                       pmtocomefe   money(14,2),
                                       pdivcomefe   char(2),
                                       prefcomefe   char(40))

       returning char(5),char(4),date,money(14,2),money(14,2),
                 char(5),char(4),date,money(14,2),money(14,2);

define vsqlerr int;
define vcodret,vcodret1,vcodretcom char(5);
define vtranret1,vtranret,vtransacc char(4);
define vtiporef char(1);
define vfechoy date;
define vsdodisp money(14,2);
define vcompend money(14,2);
define vmontoret,vtotcom money(14,2);
define vempresa char(3);
define vejecargo char(1);
define vconreg smallint;
define vcuenta char(20);
define vtotiva money(14,2);
define vtasaiva decimal(9,3);
define vivacom money(14,2);
define vtotret money(14,2);
define vsuccta char(4);
define vtraniva char(4);
define vfecapli date;

define vmtoapli money(14,2);


-- set debug file to "/tmp/cargo_ref_cel.out";
-- trace on;

set lock mode to wait 2;
begin
   on exception set vsqlerr
      if vsqlerr <> 0  then
         let vcodret = vsqlerr;
          ROLLBACK WORK; 
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if;
   end exception;

   --set isolation to cursor stability;

   BEGIN WORK;

   let vcodret = "000";
   let vtranret = " ";
   let vsdodisp = 0;
   let vmontoret = 0;
   let vcodretcom = "000";
   let vtotcom = 0;
   let psucursal = "9"||trim(psucursal);
   let psucursalcom = "9"||trim(psucursalcom);

   select empresa into vempresa
      from bdinteg:si_ejecut
      where ejecutivo = pusuario;

   select fecha_hoy into vfechoy
      from sc_fechas
      where empresa = vempresa;

   let vmontoret = pmtocompra+pmontoefe;
   let vtotcom = pmontocom + pmtocomefe;
   let vfecapli = vfechoy;
   select cuenta into vcuenta
      from sc_tarjeta
      where empresa = vempresa and
            num_tarjeta = pnum_tarjeta;
   if vcuenta is null then
      let vcodret = "100";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if
   select sucursal,sdo_actual-sdo_retenido-sdo_cong
      into vsuccta, vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   select iva into vtasaiva
      from bdinteg:si_sucursales
      where empresa = vempresa and sucursal = vsuccta;
   if vtasaiva is null then
      let vtasaiva = 0;
   end if
   let vtotiva = vtotcom * vtasaiva;
   let vtotret = pmtocompra + pmontoefe + vtotcom + vtotiva;
   if vsdodisp < vtotret then
      let vcodret = "400";
      ROLLBACK WORK; 
      return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
             vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
   end if

   if pmtocompra > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransacc,ptransuc,
                   pfolsuc,vcuenta,pcheque,pmtocompra,pdivisa,preferencia,
                   pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
   {      call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if

   if pmontoefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptransefe,ptransuc,
                      pfolioefe,vcuenta,pcheque,pmontoefe,pdivisa,preferencia,
                      pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      end if
   end if
   if pmontocom > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancencom,ptransuccom,
                      pfolsuccom,vcuenta,pchequecom,pmontocom,pdivisacom,
                      prefercom,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                        vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                        vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                        vcuenta,ptrancencom)
              returning vcodret1;}
         return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmontocom * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,"0000",
                     pfolsuccom,vcuenta,pchequecom,vivacom,pdivisacom,
                     prefercom,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
               {
               call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   if pmtocomefe > 0 then
      call cargo_ref_td(vempresa,psucursal,pusuario,ptrancomefe,
                      ptrancomefe,pfolcomefe,vcuenta,pchequeefe,
                      pmtocomefe,pdivcomefe,prefcomefe,pnum_tarjeta,"")
           returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
      if vcodret <> "000" then
         ROLLBACK WORK; 
         {
         call reversiontd(vempresa,psucursal,pusuario,pfolsuc,"A",
                          vcuenta,ptransacc)
              returning vcodret1;
         
         call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                          vcuenta,ptransefe)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                          vcuenta,ptrancencom)
              returning vcodret1;
         call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                          vcuenta,ptrancomefe)
              returning vcodret1;}
      else
         select tran_relac into vtraniva
            from bdinteg:si_transacc
            where empresa = vempresa and numero = ptrancencom;
         let vivacom = pmtocomefe * vtasaiva;
         if vivacom > 0 then
            call cargo_ref_td(vempresa,psucursal,pusuario,vtraniva,
                      "0000",pfolcomefe,vcuenta,pchequeefe,
                      vivacom,pdivcomefe,prefcomefe,pnum_tarjeta,"")
                 returning vcodret,vtranret,vfecapli,vsdodisp,vmtoapli;
            if vcodret <> "000" then
               ROLLBACK WORK; 
              { 
               call reversiontd(vempresa,psucursal,pusuario,pfolcomefe,"A",
                                vcuenta,ptransacc)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolioefe,"A",
                                vcuenta,ptransefe)
                    returning vcodret1;
               call reversiontd(vempresa,psucursal,pusuario,pfolsuccom,"A",
                                vcuenta,ptrancencom)
                    returning vcodret1;}
               return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
                      vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
            end if
         end if
      end if
   end if
   let vfechoy = vfecapli;
   select sdo_actual-sdo_retenido-sdo_cong into vsdodisp
      from sc_maechq
      where empresa = vempresa and cuenta = vcuenta;
   COMMIT WORK;
   return vcodret,vtranret,vfechoy,vsdodisp,vmontoret,
          vcodretcom,ptrancomefe,vfechoy,vsdodisp,vtotcom;
end
end procedure;