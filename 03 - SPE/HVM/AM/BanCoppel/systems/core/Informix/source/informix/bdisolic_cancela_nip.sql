CREATE PROCEDURE "informix".cancela_nip(pcve_emp     CHAR(20),
                                        pcve_regional   CHAR(3),
                                        pcve_plaza      CHAR(3),
                                        pcve_suc        CHAR(4),
                                        pnumcte         CHAR(20),
                                        pstatus         CHAR(2),
                                        pservicio       CHAR(2),
                                        pusuario        CHAR(8))
   RETURNING CHAR(5),CHAR(2);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret          CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(40);
DEFINE vempresa         CHAR(3);
DEFINE vregional        CHAR(3);
DEFINE vplaza           CHAR(3);
DEFINE vsucursal        CHAR(4);
DEFINE vnumcte          CHAR(20);
DEFINE vservicio        CHAR(3);
DEFINE vusuario         CHAR(8);
DEFINE vfecha_alta      DATE;
DEFINE vfecha_modIF     DATE;
DEFINE vhora_modIF      DATETIME HOUR TO FRACTION(3);
DEFINE vstatus          CHAR(1);
DEFINE vmensaje         CHAR(20); 

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cierre.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN cod_ret, vmensaje;
END EXCEPTION;


-- **************************************************************************
-- inicializa variables
-- **************************************************************************
LET vempresa            = '';
LET vregional           = '';
LET vplaza              = '';
LET vsucursal           = '';
LET vnumcte             = '';
LET vservicio           = '';
LET vusuario            = '';
LET vfecha_alta         = '';
LET vfecha_modIF        = TODAY;
LET vhora_modIF         = CURRENT HOUR TO FRACTION(3);
LET vstatus             = '';
LET cod_ret             = '000';

-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************
IF pcve_emp         IS NULL OR
   pcve_regional    IS NULL OR
   pcve_plaza       IS NULL OR
   pcve_suc         IS NULL OR
   pnumcte          IS NULL OR
   pstatus          IS NULL OR
   pservicio        IS NULL OR
   pusuario         IS NULL THEN

   LET cod_ret = "110";
   RETURN cod_ret,vmensaje; 
END if;

-- **************************************************************************
-- valida la clave de la empresa
-- **************************************************************************

   SELECT empresa INTO vempresa
   FROM bdinteg:si_empresas
   WHERE bdinteg:si_empresas.empresa=pcve_emp;

   IF vempresa IS NULL THEN
      LET cod_ret = '122';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- valida la clave de la regional
-- **************************************************************************

   SELECT regional INTO vregional
   FROM bdinteg:si_regional
   WHERE bdinteg:si_regional.regional = pcve_regional;

   IF vregional IS NULL THEN
      LET cod_ret = '109';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- valida la clave de la plaza
-- **************************************************************************

   SELECT plaza INTO vplaza
   FROM bdinteg:si_plazas
   WHERE bdinteg:si_plazas.plaza=pcve_plaza
   AND bdinteg:si_plazas.regional = pcve_regional;

   IF vplaza IS NULL THEN
      LET cod_ret = '003';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- valida la clave de la sucursal
-- **************************************************************************

   SELECT sucursal INTO vsucursal
   FROM bdinteg:si_sucursales
   WHERE bdinteg:si_sucursales.sucursal = pcve_suc;

   IF vsucursal IS NULL THEN
      LET cod_ret = '111';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- valida el no. del cliente
-- **************************************************************************

   SELECT numcte INTO vnumcte
   FROM bdinteg:si_cliente
   WHERE bdinteg:si_cliente.numcte = pnumcte;

   IF vnumcte IS NULL THEN
      LET cod_ret = '119';
      RETURN cod_ret,vmensaje; 
   END if;
-- **************************************************************************
-- valida el status del nip
-- **************************************************************************

   SELECT status INTO vstatus
   FROM bdinteg:si_status_serv
   WHERE bdinteg:si_status_serv.status = pstatus;

   IF vstatus IS NULL THEN
      LET cod_ret = '119';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- valida la clave del servicio
-- **************************************************************************

   SELECT cve_servicio INTO vservicio
   FROM bdinteg:si_servicios
   WHERE bdinteg:si_servicios.cve_servicio = pservicio;

   IF vservicio IS NULL THEN
      LET cod_ret = '119';
      RETURN cod_ret,vmensaje; 
   END if;
-- **************************************************************************
-- valida la clave del usuario
-- **************************************************************************

   SELECT ejecutivo INTO vusuario
   FROM bdinteg:si_ejecut
   WHERE bdinteg:si_ejecut.ejecutivo = pusuario
   AND bdinteg:si_ejecut.empresa = pcve_emp
   AND bdinteg:si_ejecut.sucursal = pcve_suc;

   IF vusuario IS NULL THEN
      LET cod_ret = '002';
      RETURN cod_ret,vmensaje; 
   END if;

-- **************************************************************************
-- cancelar el status del nip para el servicio dado.
-- **************************************************************************
--verifica que exista el registro que se va a actualizar.

   SELECT numcte INTO vnumcte
   FROM bdinteg:si_servcte
   WHERE bdinteg:si_servcte.numcte = pnumcte
   AND bdinteg:si_servcte.cve_servicio = pservicio;

   IF vnumcte IS null THEN
      LET cod_ret = "134";
      RETURN cod_ret,vmensaje; 
   ELSE
      -- actualiza status del nip
      UPDATE si_servcte
      SET    status = pstatus ,
             fecha_modificacion = vfecha_modIF ,
             hora_modificacion = vhora_modif
      WHERE bdinteg:si_servcte.numcte = pnumcte
      AND bdinteg:si_servcte.cve_servicio = pservicio;
   END if;

 RETURN cod_ret,vmensaje; 

END PROCEDURE;