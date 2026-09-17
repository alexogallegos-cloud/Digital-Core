CREATE PROCEDURE "informix".cambio_status_nip(pcve_emp          CHAR(20),
                                              pcve_regional     CHAR(3),
                                              pcve_plaza        CHAR(3),
                                              pcve_suc          CHAR(4),
                                              pnumcte           CHAR(20),
                                              pstatus           CHAR(2),
                                              pservicio         CHAR(2),
                                              pusuario          CHAR(8))
  RETURNING CHAR(5),CHAR(2);


-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                       CHAR(5);
DEFINE sql_err                       INTEGER;
DEFINE isam_err                      INTEGER;
DEFINE error_info                    CHAR(40);
DEFINE vempresa                      CHAR(3);
DEFINE vregional                     CHAR(3);
DEFINE vplaza                        CHAR(3);
DEFINE vsucursal                     CHAR(4);
DEFINE vnumcte                       CHAR(20);
DEFINE vservicio                     CHAR(3);
DEFINE vusuario                      CHAR(8);
DEFINE vfecha_alta                   DATE;
DEFINE vfecha_modIF                  DATE;
DEFINE vhora_modIF                   DATETIME HOUR TO FRACTION(3);
DEFINE vstatus                       CHAR(1);
DEFINE vmensaje                      CHAR(20);

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cierre.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN cod_ret, vmensaje;
END EXCEPTION;


-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************

LET cod_ret                        = " ";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET vempresa                       = " ";
LET vregional                      = " ";
LET vplaza                         = " ";
LET vsucursal                      = " ";
LET vnumcte                        = " ";
LET vservicio                      = " ";
LET vusuario                       = " ";
LET vfecha_alta                    = " ";
LET vfecha_modIF                   = TODAY;  --" ";
LET vhora_modIF                    = CURRENT HOUR TO FRACTION(3);
LET vstatus                        = " ";
LET vmensaje                       = " ";



IF pcve_emp      IS NULL or
   pcve_regional    IS NULL OR
   pcve_plaza       IS NULL OR
   pcve_suc         IS NULL OR
   pnumcte          IS NULL OR
   pstatus          IS NULL OR
   pservicio        IS NULL OR
   pusuario         IS NULL THEN
   LET cod_ret = '110';
   RETURN cod_ret,vmensaje;
END IF;

-- **************************************************************************
-- valida la clave de la empresa
-- **************************************************************************

   SELECT empresa INTO vempresa
   FROM bdinteg:si_empresas
   WHERE empresa=pcve_emp;
   
   IF vempresa IS NULL THEN
       LET cod_ret = '122';
       RETURN cod_ret,vmensaje;
   END IF;
  
-- **************************************************************************
-- valida la clave de la regional
-- **************************************************************************

   SELECT regional INTO vregional
   FROM bdinteg:si_regional
   WHERE regional = pcve_regional;

   IF vregional IS NULL THEN
      LET cod_ret ='109';
      RETURN cod_ret,vmensaje;
   END IF;

-- **************************************************************************
-- valida la clave de la plaza
-- **************************************************************************

   SELECT plaza INTO vplaza
   FROM bdinteg:si_plazas
   WHERE si_plazas.plaza    = pcve_plaza
   AND si_plazas.regional = pcve_regional;

   IF vplaza IS null THEN
      LET cod_ret = '003';
      RETURN cod_ret,vmensaje;
   END IF;

-- **************************************************************************
-- valida la clave de la sucursal
-- **************************************************************************

   SELECT sucursal INTO vsucursal
   FROM bdinteg:si_sucursales
   WHERE si_sucursales.sucursal = pcve_suc;
    
   IF vsucursal IS null THEN
      LET cod_ret = '111';
      RETURN cod_ret,vmensaje;
   END if;

-- **************************************************************************
-- valida el no. del cliente
-- **************************************************************************

   SELECT numcte INTO vnumcte
   FROM bdinteg:si_cliente
   WHERE si_cliente.numcte = pnumcte;
    
   IF vnumcte IS null THEN
      LET cod_ret = '119';
      RETURN cod_ret,vmensaje;
   END if;

-- **************************************************************************
-- valida el status del nip
-- **************************************************************************

   SELECT status INTO vstatus
   FROM bdinteg:si_status_serv
   WHERE si_status_serv.status = pstatus;
  
   IF vstatus IS null THEN
      LET cod_ret = '130';
      RETURN cod_ret,vmensaje;
   END IF;

-- **************************************************************************
-- valida la clave del servicio
-- **************************************************************************

   SELECT cve_servicio INTO vservicio
   FROM bdinteg:si_servicios
   WHERE si_servicios.cve_servicio = pservicio;
     
   IF vservicio IS null THEN
      LET cod_ret = '131';
      RETURN cod_ret,vmensaje;
   END IF;

-- **************************************************************************
-- valida la clave del usuario
-- **************************************************************************

   SELECT ejecutivo INTO vusuario
   FROM bdinteg:si_ejecut
   WHERE si_ejecut.ejecutivo = pusuario
   AND si_ejecut.empresa   = pcve_emp
   AND si_ejecut.sucursal  = pcve_suc;
   
   IF vusuario IS null THEN
      LET cod_ret ='002';
      RETURN cod_ret,vmensaje;
   END IF;

-- **************************************************************************
-- cambiar el status del nip para el servicio dado.
-- **************************************************************************

--verifica que exista el registro que se va a actualizar.

   SELECT numcte, status INTO vnumcte, vstatus
   FROM bdinteg:si_servcte
   WHERE si_servcte.numcte = pnumcte
   AND si_servcte.cve_servicio = pservicio;

   IF vnumcte IS null THEN
      LET cod_ret ='134';
      RETURN cod_ret,vmensaje;

   ELSE
      IF vstatus != 'C' THEN
         -- actualiza status del nip
         UPDATE bdinteg:si_servcte
         SET    status = pstatus ,
                fecha_modificacion = vfecha_modIF ,
                hora_modificacion  = vhora_modif
         WHERE si_servcte.numcte = pnumcte
         AND si_servcte.cve_servicio = pservicio;
      ELSE
         LET cod_ret ='139';
         RETURN cod_ret,vmensaje;
      END if;
   END IF; 


 RETURN cod_ret,vmensaje;
END PROCEDURE 
