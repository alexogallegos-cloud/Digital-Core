CREATE PROCEDURE "informix".verifcte1(p_empresa     LIKE si_cliente.empresa,
                           p_numcte      LIKE si_cliente.numcte,
                           p_criterioant LIKE si_cliente.numcte,
                           p_cedant      LIKE si_cliente.numcte)
   RETURNING SMALLINT, CHAR(20), CHAR(20), CHAR(60), CHAR(5), CHAR(80);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_nomcte            CHAR(60);
   DEFINE v_cuantos           SMALLINT;
   

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "VerifCte1.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN  v_cuantos, p_cedant, v_numcte, v_nomcte, cod_ret, p_mensaje;
   END EXCEPTION;

  
   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_cuantos = 0;
   LET p_cedant = '';
   LET v_numcte = '';
   LET v_nomcte = '';
   
   SELECT
      COUNT(*)
   INTO
      v_cuantos
   FROM
      si_cliente cli
   WHERE
      cli.empresa = p_empresa
   AND
      cli.numcte LIKE '%'||p_numcte
   AND
      cli.numcte NOT IN (SELECT
                            lne.numcte
                         FROM
                            sd_listanegra lne
                         WHERE
                            lne.empresa = p_empresa
                         AND
                            lne.numcte = cli.numcte);
   FOREACH
      SELECT
         cli.numcte,
         DECODE(NVL(cli.razon_social, 'AM'),
            'AM',
            NVL(cli.apell_paterno,' ')||' '||
            NVL(cli.apell_materno,' ')||' '||
            NVL(cli.nombre1,' ')||' '||
            NVL(cli.nombre2,' '),
            cli.razon_social) nomcte
         INTO
            v_numcte,
            v_nomcte
         FROM
            si_cliente cli
         WHERE
            cli.empresa = p_empresa
         AND
            cli.numcte LIKE '%'||p_numcte
         AND
            cli.numcte NOT IN (SELECT
                                  lne.numcte
                               FROM
                                  sd_listanegra lne
                               WHERE
                                  lne.empresa = p_empresa
                               AND
                                  lne.numcte = cli.numcte)
      ORDER BY cli.numcte

      RETURN  v_cuantos, p_cedant, v_numcte, v_nomcte, cod_ret, p_mensaje
              WITH RESUME;
      
   END FOREACH;
   RETURN  v_cuantos, p_cedant, v_numcte, v_nomcte, cod_ret, p_mensaje;
END PROCEDURE
DOCUMENT
'SPL migrado del PL del mismo nombre de fondafa',
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".conscedprin( pEmpresa CHAR(3),
	                      pNumCte  CHAR(20),
                              pNumCred CHAR(20),
                              pTp      VARCHAR(1))
RETURNING VARCHAR(20),VARCHAR(6),VARCHAR(80);

DEFINE pCredito VARCHAR(20);
DEFINE pCodRet   VARCHAR(6);
DEFINE pMensaje  VARCHAR(80);

LET pCredito =" ";
LET pCodRet = " ";
LET pMensaje = " ";




     IF (pTp = 'S') THEN
        EXECUTE PROCEDURE ConsCedSol (pEmpresa,
                         pNumCte,
	                 pNumCred)
	INTO pCredito,PCodRet,pMensaje;
     ELSE
        EXECUTE PROCEDURE conscedcred(pEmpresa, pNumCte, pNumCred)
	INTO pCredito,PCodRet,pMensaje;
     END IF;

RETURN pCredito,pCodRet,pMensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sitsolic(
             p_empresa         CHAR(3),
             pnum_solicitud    CHAR(20))

   RETURNING CHAR(6), CHAR(80), CHAR(20), CHAR(60),CHAR(30),CHAR(40), CHAR(40),
             CHAR(20), CHAR(40), MONEY(14,2); 

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_cliente           CHAR(60);
   DEFINE cNomEjecutivo       CHAR(30);
   DEFINE cNomDivisa          CHAR(40);
   DEFINE v_nombre_prod       CHAR(40);
   DEFINE solicitud           CHAR(20);
   DEFINE status              CHAR(40);
   DEFINE v_monto_autorizado  MONEY(14,2);

   DEFINE v_num_solicitud     CHAR(20);
   DEFINE v_secuencia         SMALLINT;
   DEFINE v_tipo_solicitud    CHAR(2);
   DEFINE v_status_solici     CHAR(2);
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(60);
   DEFINE v_num_producto      CHAR(4);
   DEFINE cCveEjecutivo       CHAR(8);
   DEFINE cCveDivisa          CHAR(2);
   DEFINE v_comenaper         CHAR(300);

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SitSolic.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje,
             v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END EXCEPTION;

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_numcte = ' ';
   LET v_cliente = ' ';
   LET cNomEjecutivo = ' ';
   LET cNomDivisa = ' ' ;
   LET v_nombre_prod = ' ';
   LET solicitud = ' ';
   LET status = ' ';
   LET v_monto_autorizado = 0;
   LET v_num_solicitud = ' ';
   
   IF(pnum_solicitud IS NULL OR pnum_solicitud = ' ') THEN
      LET cod_ret = '201';
      LET p_mensaje = 'Numero de Solicitud nulo o en blancos';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;
   END IF;

   SELECT
      COUNT(*) 
   INTO
      nrows
   FROM
      ss_solicitudes
   WHERE
      empresa = p_empresa
   AND
      num_solicitud = pnum_solicitud;

   IF (nrows = 0) THEN
      LET cod_ret = '202';
      LET p_mensaje = 'Solicitud No Existe';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

   END IF;

   SELECT
      tipo_solicitud,
      status_solicitud,
      numcte,
      num_producto,
      monto_solicitado,
      ejecutivo_sol,
      divisa
   INTO
      v_tipo_solicitud,
      v_status_solici,
      v_numcte,
      v_num_producto,
      v_monto_autorizado,
      cCveEjecutivo,
      cCveDivisa
   FROM
      ss_solicitudes,
      ss_anexosol
   WHERE
        ss_solicitudes.empresa = ss_anexosol.empresa
   AND  ss_solicitudes.num_solicitud = ss_anexosol.num_solicitud
   AND  ss_solicitudes.empresa = p_empresa
   AND ss_solicitudes.num_solicitud = pnum_solicitud;

   LET nrows = dbinfo('sqlca.sqlerrd2');
   IF(nrows <> 1) THEN
      LET cod_ret = '202';
      LET p_mensaje = 'Error Al extraer informacion de solicitud';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

   END IF;

   SELECT
      nombre 
   INTO
      cNomEjecutivo
   FROM
      bdinteg:si_ejecut
   WHERE
      empresa = p_empresa
   AND
      ejecutivo = cCveEjecutivo;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET cod_ret = '203';
      LET p_mensaje = 'Ejecutivo de Solicitud no Registrado';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

   END IF;

   SELECT
      descripcion
   INTO
      cNomDivisa
   FROM
      bdinteg:si_divisas
   WHERE
      empresa = p_empresa
   AND
      divisa = cCveDivisa;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF(nrows = 0) THEN
      LET cod_ret = '204';
      LET p_mensaje = 'Divisa de Solicitud no Registrada';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

   END IF;

   IF(v_tipo_solicitud = 'E') THEN
      LET solicitud = 'EMPRESARIAL';
   END IF;
   IF(v_tipo_solicitud = 'T') THEN
      LET solicitud = 'TRADICIONAL';
   END IF;
   IF(v_tipo_solicitud = 'M') THEN
      LET solicitud = 'LINEAS MASIVAS';
   END IF;
   IF(v_tipo_solicitud = 'Q') THEN
      LET solicitud = 'PRESTAMO QUIROGRAFARIO';
   END IF;
   IF(v_tipo_solicitud = 'U') THEN
      LET solicitud = 'UNION DE CREDITO';
   END IF;
   IF(v_tipo_solicitud = 'N') THEN
      LET solicitud = 'NORMAL';
   END IF;

   IF (v_status_solici = 'AT') THEN
      LET status = 'AUTORIZADA';
   END IF;
   IF (v_status_solici = 'AP') THEN
      LET status = 'APERTURADO';
   END IF;
   IF (v_status_solici = 'RE') THEN
      LET status = 'RECHAZADA';
   END IF;
   IF (v_status_solici = 'EE') THEN
      LET status = 'EN ESTUDIO';
   END IF;
   IF (v_status_solici = 'AI') THEN
      LET status = 'AUTORIZADA CON INDIVIDUALIZACION';
   END IF;
   IF (v_status_solici = 'DI') THEN
      LET status = 'DISPONIBLE';
   END IF;
   IF (v_status_solici = 'AR') THEN
      LET status = 'APROBADA EN RESOLUCION';
   END IF;
   IF (v_status_solici = 'AD') THEN
      LET status = 'APROBADA POR EL DIRECTORIO';
   END IF;

   SELECT
      numcte,
      apell_paterno,
      apell_materno,
      nombre1,
      nombre2,
      razon_social
   INTO
      v_numcte,
      v_apell_paterno,
      v_apell_materno,
      v_nombre1,
      v_nombre2,
      v_razon_social
   FROM
      bdinteg:si_cliente
   WHERE
      empresa = p_empresa
   AND
      numcte = v_numcte;

   LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN
      LET cod_ret = '205';
      LET p_mensaje = 'Cliente no Existe';
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;

   END IF;

   IF(v_razon_social IS NULL OR v_razon_social = ' ') THEN
      IF(v_nombre1 IS NULL) THEN 
         LET v_nombre2 =' ';
      END IF;
      LET v_cliente = TRIM(v_nombre1)||' '||TRIM(v_nombre2)||' '||
                      TRIM(v_apell_paterno)||' '||TRIM(v_apell_materno);
  ELSE
      LET v_cliente = v_razon_social;
  END IF;

  IF (v_monto_autorizado IS NULL) THEN
     LET v_monto_autorizado = 0;
  END IF;
   IF(v_status_solici = 'AP') THEN
      LET v_monto_autorizado = 0;
   END IF;

   SELECT
      monto_auto_cont
   INTO
      v_monto_autorizado
   FROM
      sd_maecontrato
   WHERE
      empresa = p_empresa
   AND
      num_contrato[1,11] = pnum_solicitud;


   SELECT
      nombre_prod
   INTO
      v_nombre_prod
   FROM
      bdicred:sd_definicion
   WHERE
      empresa = p_empresa
   AND
      num_producto = v_num_producto;


   LET v_nombre_prod = TRIM(v_num_producto)||' '||TRIM(v_nombre_prod);
   
   SELECT
      comentario
   INTO
      v_comenaper
   FROM
      ss_autorizacion
   WHERE
      empresa = p_empresa
   AND
      num_solicitud = v_num_solicitud;

   LET nrows = dbinfo("sqlca.sqlerrd2"); 
   IF(nrows = 0) THEN
      LET v_comenaper = ' ';
   END IF;

   IF (v_numcte IS NULL) THEN
      LET v_numcte = ' ';
   END IF;

   IF(v_cliente IS NULL) THEN
      LET v_cliente = ' ';
   END IF;
   
   IF (cNomDivisa IS NULL) THEN
      LET cNomDivisa = ' ';
   END IF;

   IF (cNomEjecutivo IS NULL) THEN
      LET cNomEjecutivo = ' ';
   END IF;

   IF (v_nombre_prod IS NULL) THEN
      LET v_nombre_prod = ' ';
   END IF;
      RETURN cod_ret, p_mensaje, v_numcte, v_cliente, cNomEjecutivo, cNomDivisa,
             v_nombre_prod, solicitud, status, v_monto_autorizado;


END PROCEDURE
DOCUMENT
'SPL migrado del PL del mismo nombre de fondafa',
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sitcredito(
      p_empresa    CHAR(3),
      p_numcredito CHAR(20))
   RETURNING CHAR(6), CHAR(80), CHAR(20), CHAR(60), CHAR(40), CHAR(40),
             CHAR(20), CHAR(40), CHAR(40), CHAR(60), CHAR(40),
             DECIMAL(6,3), DECIMAL(6,3), CHAR(30),
             CHAR(40), DATE, DATE, DECIMAL(9,6), DECIMAL(9,6),
             MONEY(14,2), MONEY(14,2);


   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE p_numcte          LIKE si_cliente.numcte;
   DEFINE p_cliente         LIKE si_cliente.razon_social;
   DEFINE p_ejecut          LIKE si_ejecut.nombre;
   DEFINE p_divisa          LIKE si_divisas.descripcion;
   DEFINE p_producto        LIKE sd_definicion.nombre_prod;
   DEFINE p_num_credito     LIKE sd_maecred.num_credito;
   DEFINE p_sucursal        LIKE si_sucursales.nombre;
   DEFINE p_productor       LIKE si_sucursales.nombre;
   DEFINE p_institucion     LIKE si_sucursales.nombre;
   DEFINE p_porc_rec_prop   LIKE sd_maecred.porc_rec_prop;
   DEFINE p_porcen_redesc   LIKE sd_maecred.porc_rec_prop;
   DEFINE p_status          LIKE sd_tipocartera.descripcion;
   DEFINE p_lininv          LIKE sd_lineas.descrip_linea;
   DEFINE p_fecha_apertura  LIKE sd_maecred.fecha_apertura;
   DEFINE p_fecha_vencim    LIKE sd_maecred.fecha_vencim;
   DEFINE p_tasa_interes    LIKE sd_maecred.tasa_interes;
   DEFINE p_tasa_fon        LIKE sd_maecred.tasa_interes;
   DEFINE p_monto_otorgado  LIKE sd_maesdos.monto_otorgado;
   DEFINE p_intereses       LIKE sd_maesdos.sdo_moratorio;

  ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "SitCred.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      RETURN cod_ret, p_mensaje, p_numcte, p_cliente, p_ejecut, p_divisa,
             p_producto, p_num_credito, p_sucursal, p_productor,
             p_institucion, p_porc_rec_prop, p_porcen_redesc,
             p_status, p_lininv, p_fecha_apertura, p_fecha_vencim,
             p_tasa_interes, p_tasa_fon, p_monto_otorgado, p_intereses;

   END EXCEPTION;



   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET p_numcte = ' ';
   LET p_cliente = ' ';
   LET p_ejecut = ' ';
   LET p_divisa = ' ';
   LET p_producto = ' ';
   LET p_num_credito = ' ';
   LET p_sucursal = ' ';
   LET p_productor = ' ';
   LET p_institucion = ' ';
   LET p_porc_rec_prop = 0;
   LET p_porcen_redesc = 0;
   LET p_status = ' ';
   LET p_lininv = ' ';
   LET p_fecha_apertura = ' ';
   LET p_fecha_vencim = ' ';
   LET p_tasa_interes = 0;
   LET p_tasa_fon = 0;
   LET p_monto_otorgado = 0;
   LET p_intereses = 0;

   SELECT
      c.numcte,
      c.num_credito,
      NVL(c.porc_rec_prop, 0),
      c.fecha_apertura,
      c.fecha_vencim,
      c.tasa_interes,
      DECODE(NVL(u.razon_social,'XXX'),
        'XXX',
      NVL(u.apell_paterno,' ')||' '||
      NVL(u.apell_materno,' ')||' '||
      NVL(u.nombre1,' ')||' '||
      NVL(u.nombre2,' '),
      razon_social),
      e.nombre,
      d.descripcion,
      p.nombre_prod,
      s.nombre,
      t.descripcion,
      l.descrip_linea,
      m.monto_otorgado,
      m.sdo_moratorio + m.sdo_exig_int + m.sdo_no_exig +
      m.monto_vencido + m.mto_venc_trasp + m.monto_reservado +
      m.mto_venc_int + m.mto_venc_tra_int + m.mto_finan_vdo +
      m.mto_reser_int
   INTO
      p_numcte,
      p_num_credito,
      p_porc_rec_prop,
      p_fecha_apertura,
      p_fecha_vencim,
      p_tasa_interes,
      p_cliente,
      p_ejecut,
      p_divisa,
      p_producto,
      p_sucursal,
      p_status,
      p_lininv,
      p_monto_otorgado,
      p_intereses
   FROM
     sd_maecred c,
     outer si_cliente u,
     outer si_ejecut e,
     outer si_divisas d,
     outer sd_definicion p,
     outer si_sucursales s,
     outer sd_tipocartera t,
     outer sd_lineas l,
     outer sd_maesdos m
   WHERE
      u.numcte = c.numcte
   AND u.empresa = c.empresa
   AND e.ejecutivo = c.ejecutivo
   AND e.empresa = c.empresa
   AND d.divisa = c.divisa
   AND d.empresa = c.empresa
   AND p.num_producto = c.num_producto
   AND p.empresa = c.empresa
   AND s.sucursal = c.sucursal
   AND s.empresa = c.empresa
   AND t.status_cred = c.status_cred
   AND t.empresa = c.empresa
   AND l.cod_tipo_linea = c.cod_tipo_linea
   AND l.cod_linea = c.cod_linea
   AND l.empresa = c.empresa
   AND m.num_credito = c.num_credito
   AND m.empresa = c.empresa
   AND c.num_credito = p_numcredito
   AND c.empresa = p.empresa;

   LET p_productor = ' ';
   LET p_institucion = ' ';
   LET p_porcen_redesc = 0;
   LET p_tasa_fon = 0;

   RETURN cod_ret, p_mensaje, p_numcte, p_cliente, p_ejecut, p_divisa,
          p_producto, p_num_credito, p_sucursal, p_productor,
          p_institucion, p_porc_rec_prop, p_porcen_redesc,
             p_status, p_lininv, p_fecha_apertura, p_fecha_vencim,
             p_tasa_interes, p_tasa_fon, p_monto_otorgado, p_intereses;


END PROCEDURE
DOCUMENT
'SPL migrado del PL del mismo nombre de fondafa',
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".valida_credito( p_empresa VARCHAR(3)
                                , p_credito VARCHAR(20))
RETURNING VARCHAR(80);

  DEFINE v_status varchar(30);
  DEFINE p_error varchar(80);
  DEFINE sql_err integer;

  BEGIN

    ON EXCEPTION SET sql_err
       IF sql_err <> 0 then
          LET p_error = 'ocurrio un Error';
          RETURN p_error;
       END IF
    END EXCEPTION;

    LET v_status = ' ';
  
    select status_cred
      into v_status
      from sd_maecred
     where status_cred in ('AC','AR','BC','BR','CE','CC','CO'
                          ,'FF','FC','FR','FE','TC','TR','TE'
                          )
       and num_credito   = p_credito
       and empresa   = p_empresa
       and rownum    < 2;
       
    LET p_error = ' exitoso ';
    if v_status != ' '  then
      LET p_error = 'El credito se encuentra en status '|| v_status;
    else
      LET p_error = ' exitoso ';
    end if;
  END;
RETURN p_error;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".pasecont(psucursal      char(8),
                          pfecha_hoy     date,
                          psecuencia     smallint,
                          pempresa       char(3),
                          pccmayor       char(4),
                          pccsub         char(2),
                          pccsubsub      char(4),
                          pccssubsub     char(4),
                          pcargo_abono   char(1),
                          pmonto         money(14,2),
                          pmoneda        char(2),
                          pindicador     char(1),  -- "1" ult renglon
                          pinic_mov_suc  char(1),  -- "1" 2da. vez
                          pauxiliar      char(9))
returning char(5);
   define cod_ret char(5);
   define vw_mca_aplic,v_carabo,v_natur char(1);
   define vw_ccsubsub,vw_ccssubsub,vw_ccsssubsub,vw_sector,
          v_tipo_mon, v_moneda char(2);
   define vw_ciudad,vw_empresa char(3);
   define vw_usuario char(8);
   define vw_proceso,v_proceso char(8);
   define vw_auxiliar char(9);
   define vw_descripcion char(30);
   define band, v_numpol,v_num_poliza,v_existen,v_control smallint;
   define vw_valor_cambio,vw_valor_div,vw_capt_cargo,vw_capt_abono,
          vw_cifra_control, v_monto money(19,2);
   define sql_err integer;
   define contador integer;
   define fech_hora datetime hour to fraction;
   Let fech_hora = current hour to fraction;




-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   let cod_ret         = "000";
   let vw_ccsubsub     = pccsubsub[1,2];
   let vw_ccssubsub    = pccsubsub[3,4];
   let vw_ccsssubsub   = pccssubsub[1,2];
   let vw_sector       = pccssubsub[3,4];
   let vw_auxiliar     = "000000000";
   let vw_descripcion  = "Movimientos de Sucursal del dia de hoy";
   let vw_valor_cambio = 0;
   let vw_valor_div    = 0;
   let vw_mca_aplic    = "0";

   -- Pendiente asignacion de 3 y 4 subcuentas

begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
   if psucursal    is null  or
      pfecha_hoy   is null or
      psecuencia   < 0 or
      pempresa     is null or
      pccmayor     is null or
      pccsub       is null or
      pccsubsub    is null or
      pccssubsub   is null or
      pcargo_abono is null or
      pmonto       is null or
      pmoneda      is null or
      pindicador   is null or
      pinic_mov_suc is null or
      pauxiliar    is null then
      let cod_ret = "110";
      return cod_ret;
   end if
-- valida si el renglon es terminador

   if pauxiliar <> " " then

     let  vw_auxiliar = pauxiliar;
   end if

-- Verifica si la poliza se ha transmitido ya en base a la secuencia.

   if (psecuencia = 1) then
      let contador = 0;
      select count(*) into contador
         from bdicont:co_detpol
         where usuario = psucursal and
               fecha_captura = pfecha_hoy and
               moneda = pmoneda;
      if (contador > 0) then
         delete from bdicont:co_detpol
            where usuario = psucursal and
               fecha_captura = pfecha_hoy and
               moneda = pmoneda;
         delete from bdicont:co_poliza
            where usuario = psucursal and
               fecha_captura = pfecha_hoy and
               moneda = pmoneda;
      end if
  end if


-- Extrae el numero de poliza por usuario

   select max(control_poliza) into v_num_poliza
   from bdicont:co_poliza
   where usuario=psucursal;
   if v_num_poliza is null then
      let v_num_poliza = 0;
   end if

-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   select regional into vw_ciudad
   from bdinteg:si_sucursales, bdinteg:si_plazas
   where sucursal = psucursal[1,4] and
         bdinteg:si_sucursales.plaza = bdinteg:si_plazas.plaza;
   if vw_ciudad is null then
      let cod_ret = "159";
      return cod_ret;
   end if
   let vw_usuario = psucursal;
   -- Proceso de sectorizacion PENDIENTE
   -- Identifica si es envio de poliza por segunda vez
   -- Extrae el numero de la poliza, si ya existe
   select control_poliza into v_numpol from bdicont:co_poliza
         where usuario = psucursal and fecha_captura = pfecha_hoy and
              moneda = pmoneda;
   if v_numpol is null then
      let band = 1;
      let v_num_poliza = v_num_poliza + 1;
   else
      select max(secuencia) into psecuencia from bdicont:co_detpol
         where usuario = psucursal and fecha_captura = pfecha_hoy and
               control_poliza = v_numpol;
      if psecuencia is null then
        let psecuencia=0;
      end if;
      let psecuencia = psecuencia + 1;
      let band = 0;
      let v_num_poliza = v_numpol;
   end if;

   if psecuencia = 1 and band = 1 then
      -- Actualiza el control de polizas
      --execute procedure bdicont:contpolizas(psucursal,v_num_poliza,
        --                                 pfecha_hoy,pmoneda,"SS");
      -- Graba encabezado de la poliza
      insert into bdicont:co_poliza
         values(pempresa, psucursal,v_num_poliza,pfecha_hoy,0,0,0,pmoneda,
                "MOVIMIENTO DE SUCURSAL");
   --   insert into bdicont:co_horas
     --    values(psucursal,fech_hora,pfecha_hoy);
   end if;
   -- Genera el detalle de la poliza
   if pmonto > 0 then
      -- Verifica la moneda/tipo de metal            24/JUN/96  AMF.
      if pmoneda matches "*[^1234567890]*" then
         select tipo into v_tipo_mon
         from bdinteg:si_metales
         where codigo = pmoneda;
         let pmoneda = "  ";
         if v_tipo_mon = "O" then           -- ORO
            let pmoneda = "10";
         elif v_tipo_mon = "P" then         -- PLATA
            let pmoneda = "11";
         end if
      end if
      if (pcargo_abono <> "T") then
         insert into bdicont:co_detpol

         values(vw_usuario,v_num_poliza,pfecha_hoy,psecuencia,pempresa,
             pccmayor,pccsub,vw_ccsubsub,vw_ccssubsub,vw_ccsssubsub,
             vw_sector,vw_ciudad,psucursal,vw_auxiliar,pcargo_abono,
             pmonto,vw_descripcion,pfecha_hoy,pmoneda,0,0,vw_mca_aplic,
             vw_usuario," ");
      end if
   end if

   if pindicador = "1" then
      foreach
         select moneda,control_poliza,naturaleza,sum(monto) into
            v_moneda,v_numpol,v_natur,v_monto
            from bdicont:co_detpol
            where usuario = psucursal and fecha_captura=pfecha_hoy
            group by moneda,control_poliza,naturaleza
         if v_natur = "C" then
            -- Actualiza el total de abonos y cifra control en el encabezado
            -- de la poliza
            update bdicont:co_poliza
               set (capturado_abono,cifra_control) = (v_monto,v_monto)
               where usuario = psucursal and fecha_captura=pfecha_hoy and
                     control_poliza = v_numpol and moneda = v_moneda;
         else
            -- Actualiza el total de cargos en el encabezado de la poliza
            update bdicont:co_poliza
               set (capturado_cargo,cifra_control) = (v_monto,v_monto)
               where usuario = psucursal and fecha_captura=pfecha_hoy and
                     control_poliza = v_numpol and moneda = v_moneda;
         end if;
      end foreach
      -- Actualiza el control de procesos
      let v_proceso = "pase";
     select proceso into vw_proceso from ss_contproc
         where sucursal=psucursal[1,4] and proceso = v_proceso;
      if vw_proceso is null then
         insert into ss_contproc
            values(psucursal,v_proceso,pfecha_hoy);
      else
         update ss_contproc
            set fecha = pfecha_hoy
            where sucursal=psucursal[1,4] and proceso = v_proceso;
      end if
   end if
return cod_ret;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".rmonto_financiado(
   P_EMPRESA        VARCHAR(3)
  ,P_SUCURSAL       VARCHAR(10)
  ,P_FECHA_INICIAL  DATE
  ,P_FECHA_FINAL    DATE
  ,P_CICLOS         INTEGER
  ,P_INCREMENTO     INTEGER )

RETURNING VARCHAR(10), VARCHAR(80);

DEFINE  P_COD_RET VARCHAR(10);
DEFINE  P_MENSAJE VARCHAR(80);

DEFINE  I         INTEGER;
DEFINE  V_RANGO1  INTEGER;
DEFINE  V_RANGO2  INTEGER;
DEFINE  V_TOT_REG INTEGER;
DEFINE  V_TOT_MTO DECIMAL(18,2);
DEFINE  V_PORCENT DECIMAL(5,2);
DEFINE  V_REG INTEGER;
DEFINE  V_MTO DECIMAL(18,2);

  BEGIN


     IF P_SUCURSAL = '' THEN
        LET P_SUCURSAL = NULL;
     END IF;
     LET P_COD_RET = '00000';
     LET P_MENSAJE = 'PROCESO EXITOSO';
     LET V_TOT_REG = 0;
     LET V_RANGO1  = 0;
     LET V_RANGO2  = P_INCREMENTO;

     SELECT COUNT(*), SUM(MONTO_OTORGADO)
     INTO   V_TOT_REG, V_TOT_MTO
     FROM   SD_MAECRED A
           ,SD_MAESDOS B
     WHERE  B.NUM_CREDITO = A.NUM_CREDITO
     AND    B.EMPRESA = A.EMPRESA
     AND    FECHA_APERTURA BETWEEN P_FECHA_INICIAL AND P_FECHA_FINAL
     AND    SUCURSAL = NVL(P_SUCURSAL,SUCURSAL)
     AND    A.EMPRESA = NVL(P_EMPRESA, A.EMPRESA);

     --CREATE TABLE RMONTO_FINANCIADO (RANGO1   varchar(10)
     --                               ,RANGO2   varchar(10)
     --                               ,IMPORTE  DECIMAL(18,2)
     --                               ,PORCENT  DECIMAL(3,2)
     --                               ,CANTIDAD INTEGER
     --                               );


     
     DELETE FROM RMONTO_FINANCIADO;
     
     FOR I = 1 TO P_CICLOS
        INSERT INTO RMONTO_FINANCIADO (RANGO1, RANGO2)
                               VALUES (V_RANGO1, V_RANGO2);

        SELECT COUNT(*)
             , NVL(SUM(MONTO_OTORGADO),0)
             , ((NVL(SUM(MONTO_OTORGADO),0) * 100)/V_TOT_MTO) PORCENT
        INTO   V_REG, V_MTO, V_PORCENT
        FROM   SD_MAECRED A
              ,SD_MAESDOS B
        WHERE  B.NUM_CREDITO = A.NUM_CREDITO
        AND    B.EMPRESA = A.EMPRESA
        AND    MONTO_OTORGADO BETWEEN V_RANGO1 AND NVL(V_RANGO2,9999999999999999)
        AND    FECHA_APERTURA BETWEEN P_FECHA_INICIAL AND P_FECHA_FINAL
        AND    SUCURSAL = NVL(P_SUCURSAL,SUCURSAL)
        AND    A.EMPRESA = NVL(P_EMPRESA, A.EMPRESA);

        UPDATE RMONTO_FINANCIADO
        SET    IMPORTE = V_MTO
              ,PORCENT = V_PORCENT
              ,CANTIDAD = V_REG
        WHERE RANGO1 = V_RANGO1;

        LET V_RANGO1 = V_RANGO2 + 1;
        LET V_RANGO2 = V_RANGO2 + p_incremento;

        IF V_RANGO2 = P_INCREMENTO * P_CICLOS THEN
           LET V_RANGO2 = NULL;
        END IF;
     END FOR;
     insert into rmonto_financiado (rango1,rango2,importe,porcent,cantidad)
                 values(' ','TOTALES:',v_tot_mto,100,v_tot_reg);
     
     --DROP TABLE RMONTO_FINANCIADO
     RETURN P_COD_RET, P_MENSAJE;

  END;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".valida_cliente(pempresa char(3),
					   pnumcte char(20))
       returning char(5);

DEFINE vcodret char(5);
DEFINE vsqlerr integer;
DEFINE vnumcte char(20);



begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
       return vcodret;
      end if
   end exception;

   let vcodret = "000";
   let vnumcte = "";

   if pnumcte is null or pnumcte = "000000000"  then
      let vcodret = "110";
   end if;

   set isolation to dirty read;

   select numcte into vnumcte
      from si_cliente
      where numcte = pnumcte;

   if vnumcte is null then
       let vcodret = "000";
       return vcodret;
   else
       let vcodret = "104";
       return vcodret;
   end if;
   return vcodret;
end
end procedure
DOCUMENT
"Verifica exista el cliente ",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".refcomer(pempresa char(3),
                          pnumcte char(20),
			    psecuencia smallint,
			    ptp_refcomer char(2),
			    pnombre_empresa char(60),
			    pno_cuenta char(20),
			    pnombre_plaza char(20),
			    ptitular_cta char(60))
			    returning char(5);

define vcodret char(5);
define vsqlerr integer;
define vexiste char(1);

begin
   on exception set vsqlerr
      if vsqlerr != 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;



   let vcodret = "000";

   -- Valida la informacion de entrada
   if psecuencia is null or psecuencia = 0  or
      pnombre_empresa is null or pnombre_empresa = " " or
      pno_cuenta is null or pno_cuenta = " " or
      ptitular_cta is null or ptitular_cta = " " then
      let vcodret = "110";
      return vcodret;
   end if;

   select 1 into vexiste
      from si_cliente
      where numcte = pnumcte;
   if vexiste is null then
      let vcodret = "104";
      return vcodret;
   end if;

   select 1 into vexiste
      from si_tprefcomer
      where tp_refcomer = ptp_refcomer;
   if vexiste is null then
      let vcodret = "140";
      return vcodret;
   end if;

   if psecuencia = 1 then
      delete from si_refcomer
         where numcte = pnumcte;   
   end if

   select 1 into vexiste
      from si_refcomer
      where numcte = pnumcte and sec_refcomer = psecuencia; 
   if vexiste = 1 then
      let vcodret = "143";
      return vcodret;
   end if;

   begin
      insert into si_refcomer
	   (numcte, sec_refcomer, tp_refcomer, nombre_empresa, 
	    no_cta, nombre_sucursal, titular_cta)
         values
           (pnumcte, psecuencia, ptp_refcomer, pnombre_empresa,
	    pno_cuenta, pnombre_plaza, ptitular_cta);
   end;
   return vcodret;
end;
end procedure
DOCUMENT
"Alta de referencias comerciales del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".refper(pempresa char(3),
                            pnumcte char(20),
			    psecuencia smallint,
			    pparentesco char(10),
			    pnombre char(60),
			    pdireccion char(80),
			    ptelefono char(20),
			    pactividad char(15))
			    returning char(5);

define vcodret char(5);
define vsqlerr integer;
define vexiste char(1);

begin
   on exception set vsqlerr
      if vsqlerr != 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if;
   end exception;



   let vcodret = "000";

   -- Valida la informacion de entrada
   if psecuencia is null or psecuencia = 0  or
      pparentesco is null or pparentesco = " " or
      pdireccion is null or pdireccion = " " or
      pactividad is null or pactividad = " " then
      let vcodret = "110";
      return vcodret;
   end if;

   select 1 into vexiste
      from si_cliente
      where numcte = pnumcte;
   if vexiste is null then
      let vcodret = "104";
      return vcodret;
   end if;

   if psecuencia = 1 then
      delete from si_refper
         where numcte = pnumcte; 
   end if
   
   select 1 into vexiste
      from si_refper
      where numcte = pnumcte and sec_refper = psecuencia;
   if vexiste = 1 then
      let vcodret = "142";
      return vcodret;
   end if;
      
   begin
      insert into si_refper
	    (numcte, sec_refper, parentesco, nombre, direccion,
             telefono, actividad)
         values
            (pnumcte, psecuencia, pparentesco, pnombre, pdireccion, 
             ptelefono, pactividad);
   end;
   return vcodret;
end;
end procedure
DOCUMENT
"Alta de referencias personales del cliente",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".respctes(pnum_empresa CHAR(3), pnum_cliente CHAR(20),
                          pnum_creditos SMALLINT)

   RETURNING CHAR(6),CHAR(80),CHAR(20),DATE,DATE,CHAR(42),MONEY(14,2),
             MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),
             MONEY(14,2),MONEY(14,2),CHAR(30),CHAR(45),MONEY(14,2),money(14,2);

   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                  SMALLINT;
   DEFINE text               CHAR(100);
   DEFINE sqlerr,isamerr     SMALLINT;
   DEFINE cod_ret            CHAR(6);
   DEFINE v_ciclo            SMALLINT;
   DEFINE v_conta            SMALLINT;
   DEFINE v_apell_paterno    CHAR(15);
   DEFINE v_apell_materno    CHAR(15);
   DEFINE v_nombre1          CHAR(15);
   DEFINE v_nombre2          CHAR(15);
   DEFINE v_razon_social     CHAR(80);
   DEFINE vg_cliente         CHAR(80);
   DEFINE v_num_credito      LIKE sd_maecred.num_credito;
   DEFINE v_num_cliente      LIKE sd_maecred.numcte;
   DEFINE v_numcte           LIKE sd_maecred.numcte;
   DEFINE v_cliente          CHAR(60);
   DEFINE v_descripcion      CHAR(40);
   DEFINE v_num_producto     LIKE sd_maecred.num_producto;
   DEFINE v_cod_tipcred      LIKE sd_definicion.cod_tipcred;
   DEFINE v_nombre_prod      LIKE sd_definicion.nombre_prod;
   DEFINE v_fecha_apertura   LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim     LIKE sd_maecred.fecha_vencim;
   DEFINE v_monto_otorgado   LIKE sd_maesdos.monto_otorgado;
   DEFINE v_sdo_cap_insol    LIKE sd_maesdos.sdo_cap_insoluto;
   DEFINE v_monto_vencido    LIKE sd_maesdos.monto_vencido;
   DEFINE vg_tipocredito     CHAR(42);
   DEFINE v_hay_maecred      SMALLINT;
   DEFINE v_sdo_no_exig      LIKE sd_maesdos.sdo_no_exig;
   DEFINE v_divisa           LIKE sd_maecred.divisa;
   DEFINE v_divisas          LIKE bdinteg:si_divisas.descripcion;
   DEFINE v_ejecutivo        LIKE sd_maecred.ejecutivo;
   DEFINE vv_nombre          LIKE bdinteg:si_ejecut.nombre;
   DEFINE v_sdo_capitalp     MONEY(14,2);
   DEFINE v_monto_vencidop   MONEY(14,2);
   DEFINE v_mto_venc_traspp  MONEY(14,2);
   DEFINE v_monto_reservadop MONEY(14,2);
   DEFINE v_mto_capitalizadp MONEY(14,2);
   DEFINE v_mto_finan_vdop   MONEY(14,2);
   DEFINE v_sdo_no_exigp     MONEY(14,2);
   DEFINE v_sdo_exig_int     MONEY(14,2);
   DEFINE v_sdo_exig_intp    MONEY(14,2);
   DEFINE v_sdo_capitalf     MONEY(14,2);
   DEFINE v_monto_vencidof   MONEY(14,2);
   DEFINE v_mto_venc_traspf  MONEY(14,2);
   DEFINE v_monto_reservadof MONEY(14,2);
   DEFINE v_mto_capitalizadf MONEY(14,2);
   DEFINE v_mto_finan_vdof   MONEY(14,2);
   DEFINE v_sdo_no_exigf     MONEY(14,2);
   DEFINE v_sdo_exig_intf    MONEY(14,2);
   DEFINE cap_vigente        MONEY(14,2);
   DEFINE cap_vdo            MONEY(14,2);
   DEFINE int_fin_vdo        MONEY(14,2);
   DEFINE v_mto_finan_vdo    MONEY(14,2);
   DEFINE cap_vencidop       MONEY(14,2);
   DEFINE cap_vencidof       MONEY(14,2);
   DEFINE v_sdo_mora_ordi    MONEY(14,2);
   DEFINE v_sdo_mora_cope    MONEY(14,2);
   DEFINE saldo_credito      MONEY(14,2);
   DEFINE v_sdo_anticip      MONEY(14,2);

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr, text
      LET cod_ret = sqlerr;
      SET DEBUG FILE TO "respctes.err"; -- se guarda en /users/desarrollo
      TRACE sqlerr || " * " || isamerr || " * " || text;
      RETURN cod_ret,vg_cliente,v_num_credito,v_fecha_apertura,v_fecha_vencim,
             vg_tipocredito,cap_vigente,cap_vdo,int_fin_vdo,v_mto_finan_vdo,
             v_sdo_no_exig,v_sdo_exig_int,v_sdo_mora_ordi,v_sdo_mora_cope,
             v_divisas,vv_nombre,saldo_credito,v_sdo_anticip;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000000";
   LET v_ciclo            = 0;
   LET v_conta            = 0;
   LET v_num_credito      = " ";
   LET v_fecha_apertura   = " ";
   LET v_fecha_vencim     = " ";
   LET v_num_cliente      = " ";
   LET v_monto_otorgado   = 0;
   LET v_sdo_cap_insol    = 0;
   LET v_monto_vencido    = 0;
   LET vg_tipocredito     = " ";
   LET vg_cliente         = " ";
   LET v_hay_maecred      = 0;
   LET v_sdo_no_exig      = 0;
   LET v_divisas          = " ";
   LET v_divisa           = " ";
   LET v_ejecutivo        = " ";
   LET vv_nombre          = " ";
   LET v_sdo_capitalp     = 0;
   LET v_monto_vencidop   = 0;
   LET v_mto_venc_traspp  = 0;
   LET v_monto_reservadop = 0;
   LET v_mto_capitalizadp = 0;
   LET v_mto_finan_vdop   = 0;
   LET v_sdo_no_exigp     = 0;
   LET v_sdo_exig_int     = 0;
   LET v_sdo_exig_intp    = 0;
   LET v_sdo_capitalf     = 0;
   LET v_monto_vencidof   = 0;
   LET v_mto_venc_traspf  = 0;
   LET v_monto_reservadof = 0;
   LET v_mto_capitalizadf = 0;
   LET v_mto_finan_vdof   = 0;
   LET v_sdo_no_exigf     = 0;
   LET v_sdo_exig_intf    = 0;
   LET cap_vigente        = 0;
   LET cap_vdo            = 0;
   LET int_fin_vdo        = 0;
   LET v_mto_finan_vdo    = 0;
   LET cap_vencidop       = 0;
   LET cap_vencidof       = 0;
   LET v_sdo_mora_ordi    = 0;
   LET v_sdo_mora_cope    = 0;
   LET saldo_credito      = 0;
   LET v_sdo_anticip      = 0;
   LET v_cod_tipcred      = " ";

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_cliente IS NULL OR
      pnum_cliente = " " THEN
      LET cod_ret = "202"; -- CLIENTE NULO O BLANCO
      RETURN cod_ret,vg_cliente,v_num_credito,v_fecha_apertura,v_fecha_vencim,
             vg_tipocredito,cap_vigente,cap_vdo,int_fin_vdo,v_mto_finan_vdo,
             v_sdo_no_exig,v_sdo_exig_int,v_sdo_mora_ordi,v_sdo_mora_cope,
             v_divisas,vv_nombre,saldo_credito,v_sdo_anticip;
   ELSE
      LET v_num_cliente = pnum_cliente;
   END IF;

   SELECT numcte INTO v_cliente
   FROM si_cliente
   WHERE numcte = v_num_cliente;
   IF v_cliente IS NULL OR
      v_cliente = " " THEN
      LET cod_ret = "238"; -- NO EXISTE EL CLIENTE EN CENTRAL
      RETURN cod_ret,vg_cliente,v_num_credito,v_fecha_apertura,v_fecha_vencim,
             vg_tipocredito,cap_vigente,cap_vdo,int_fin_vdo,v_mto_finan_vdo,
             v_sdo_no_exig,v_sdo_exig_int,v_sdo_mora_ordi,v_sdo_mora_cope,
             v_divisas,vv_nombre,saldo_credito,v_sdo_anticip;
   ELSE
      SELECT apell_paterno,apell_materno,nombre1,nombre2,razon_social
      INTO v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,v_razon_social
      FROM si_cliente
      WHERE numcte = v_num_cliente;

      IF v_razon_social IS NULL OR v_razon_social = " " THEN
         if v_apell_paterno is null then let v_apell_paterno = " "; end if;
         if v_apell_materno is null then let v_apell_materno = " "; end if;
         if v_nombre1       is null then let v_nombre1       = " "; end if;
         if v_nombre2       is null then let v_nombre2       = " "; end if;

         LET v_cliente =
            TRIM (v_nombre1) || " " ||
            TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || " " ||
            TRIM (v_apell_paterno) || " " ||
            TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
      LET vg_cliente = v_cliente;
   END IF;

   SELECT COUNT(*) INTO v_hay_maecred
   FROM sd_maecred
   WHERE numcte = v_num_cliente AND status_cred <> "FF" AND status_cred != "DD";

   IF v_hay_maecred = 0 THEN
      LET cod_ret = "263"; -- EL CLIENTE NO TIENE RESPONSABILIDADES sd_maecred
      LET vg_cliente = " ";
      RETURN cod_ret,vg_cliente,v_num_credito,v_fecha_apertura,v_fecha_vencim,
             vg_tipocredito,cap_vigente,cap_vdo,int_fin_vdo,v_mto_finan_vdo,
             v_sdo_no_exig,v_sdo_exig_int,v_sdo_mora_ordi,v_sdo_mora_cope,
             v_divisas,vv_nombre,saldo_credito,v_sdo_anticip;
   END IF;

   FOREACH
      SELECT num_credito,num_producto,divisa,fecha_apertura,fecha_vencim,
             ejecutivo
      INTO v_num_credito,v_num_producto,v_divisa,v_fecha_apertura,
           v_fecha_vencim,v_ejecutivo
      FROM sd_maecred
      WHERE numcte = v_num_cliente AND status_cred <> "FF" AND status_cred != "DD"
      ORDER BY 1

      IF v_fecha_apertura IS NULL OR v_fecha_apertura = " " THEN
         LET v_fecha_apertura = " ";
      END IF;

      IF v_fecha_vencim IS NULL OR v_fecha_vencim = " " THEN
         LET v_fecha_vencim = " ";
      END IF;

      SELECT nombre_prod, cod_tipcred INTO v_descripcion, v_cod_tipcred
      FROM sd_definicion
      WHERE num_producto = v_num_producto;

      LET vg_tipocredito = TRIM (v_num_producto) || " " || TRIM (v_descripcion);

      SELECT descripcion INTO v_divisas
      FROM si_divisas
      WHERE divisa = v_divisa;
      IF v_divisas IS NULL OR v_divisas = " " THEN LET v_divisas = " "; END IF;

      SELECT nombre INTO vv_nombre
      FROM si_ejecut
      WHERE si_ejecut.ejecutivo = v_ejecutivo;
      IF vv_nombre IS NULL THEN LET vv_nombre = "  "; END IF;

      -- RECURSOS PROPIOS
      SELECT sdo_capital,monto_vencido,mto_venc_trasp,monto_reservado,
             mto_capitalizado,mto_finan_vdo,sdo_no_exig,sdo_exig_int,
             (sdo_int_ant_dev-sdo_int_anticip)
      INTO v_sdo_capitalp,v_monto_vencidop,v_mto_venc_traspp,
           v_monto_reservadop,v_mto_capitalizadp,v_mto_finan_vdop,
           v_sdo_no_exigp,v_sdo_exig_intp,v_sdo_anticip
      FROM sd_maesdos
      WHERE num_credito = v_num_credito;

      if v_cod_tipcred != "02" then let v_sdo_anticip = 0; end if;

      IF v_sdo_capitalp IS NULL THEN
         LET v_sdo_capitalp = 0; END IF;
      IF v_monto_vencidop IS NULL THEN
         LET v_monto_vencidop = 0; END IF;
      IF v_mto_venc_traspp IS NULL THEN
         LET v_mto_venc_traspp = 0; END IF;
      IF v_monto_reservadop IS NULL  THEN
         LET v_monto_reservadop = 0; END IF;
      IF v_mto_capitalizadp IS NULL  THEN
         LET v_mto_capitalizadp = 0; END IF;
      IF v_mto_finan_vdop IS NULL  THEN
         LET v_mto_finan_vdop = 0; END IF;
      IF v_sdo_no_exigp IS NULL  THEN
         LET v_sdo_no_exigp = 0; END IF;
      IF v_sdo_exig_intp IS NULL  THEN
         LET v_sdo_exig_intp = 0; END IF;
      IF v_sdo_anticip IS NULL  THEN
         LET v_sdo_anticip = 0; END IF;

      LET cap_vencidop=0;
      LET cap_vencidop=v_monto_vencidop+v_mto_venc_traspp+v_monto_reservadop;
      -- PROPIOS Y FONDOS (INT. DESP. VTO.)
      SELECT sum(sdo_mora_ordi) INTO v_sdo_mora_ordi
      FROM sd_detmora
      WHERE num_credito = v_num_credito;
      IF v_sdo_mora_ordi IS NULL OR v_sdo_mora_ordi = " " THEN
         LET v_sdo_mora_ordi = 0; END IF;

      -- PROPIOS Y FONDOS (INTERESES PENALES)
      SELECT sum(sdo_mora_cope) INTO v_sdo_mora_cope
      FROM sd_detmora
      WHERE num_credito = v_num_credito;
      IF v_sdo_mora_cope IS NULL OR v_sdo_mora_cope = " " THEN
         LET v_sdo_mora_cope = 0; END IF;

      LET cap_vigente     = 0;
      LET cap_vdo         = 0;
      LET int_fin_vdo     = 0;
      LET v_mto_finan_vdo = 0;
      LET v_sdo_no_exig   = 0;
      LET v_sdo_exig_int  = 0;

      LET cap_vigente     = v_sdo_capitalp;     --+v_sdo_capitalf;
      LET cap_vdo         = cap_vencidop;       --+cap_vencidof;
      LET int_fin_vdo     = v_mto_capitalizadp; --+v_mto_capitalizadf;
      LET v_mto_finan_vdo = v_mto_finan_vdop;   --+v_mto_finan_vdof;
      LET v_sdo_no_exig   = v_sdo_no_exigp;     --+v_sdo_no_exigf;
      LET v_sdo_exig_int  = v_sdo_exig_intp;    --+v_sdo_exig_intf;

      LET saldo_credito   = 0;
      LET saldo_credito   = cap_vigente+cap_vdo+int_fin_vdo+v_mto_finan_vdo+
                            v_sdo_no_exig+v_sdo_exig_int+v_sdo_mora_ordi+
                            v_sdo_mora_cope;

      LET v_ciclo = v_ciclo + 1;
      IF v_ciclo <= pnum_creditos THEN CONTINUE FOREACH; END IF;

      RETURN cod_ret,vg_cliente,v_num_credito,v_fecha_apertura,v_fecha_vencim,
             vg_tipocredito,cap_vigente,cap_vdo,int_fin_vdo,v_mto_finan_vdo,
             v_sdo_no_exig,v_sdo_exig_int,v_sdo_mora_ordi,v_sdo_mora_cope,
             v_divisas,vv_nombre,saldo_credito,v_sdo_anticip
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".calc_com(pempresa char(3), p1 char(20), p2 char(5),  p3 money, p4 char(1), p5 char(5), p6 char(10))
       returning char(5), money, money, char(40);

DEFINE vcodret char(5);
DEFINE vsqlerr integer;
DEFINE vnumcte char(40);
DEFINE vcomis money;
DEFINE viva money;

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
       return vcodret, vcomis, viva, vnumcte;
      end if
   end exception;

   let vcodret = "000";
   let vnumcte = "Juan Perez";
   let vcomis = 300.00;
   let viva = 80.00;
  
   return vcodret, vcomis, viva, vnumcte;

end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".cons_capitales(p_empresa CHAR(3),
                                           pnum_credito CHAR(20))
RETURNING CHAR(6),
          CHAR(80),
          CHAR(20),
          CHAR(60),
          CHAR(45),
          CHAR(30),
          CHAR(40),
          CHAR(20),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2),
          DECIMAL(18,2);

   --####################################################################
   --#####                    variables                      #####
   --####################################################################

   DEFINE i                  INTEGER;
   DEFINE text               VARCHAR(100);
   DEFINE v_apell_paterno    VARCHAR(15);
   DEFINE v_apell_materno    VARCHAR(15);
   DEFINE v_nombre1          VARCHAR(15);
   DEFINE v_nombre2          VARCHAR(15);
   DEFINE v_razon_social     VARCHAR(40);
   DEFINE v_num_prod         VARCHAR(04);
   DEFINE v_monto_ven_tras   LIKE SD_MAESDOS.MTO_VENC_TRASP;
   DEFINE p_cod_ret          VARCHAR(8);
   DEFINE p_mensaje          VARCHAR(80);
   DEFINE v_numcte	     VARCHAR(20);
   DEFINE v_cliente	     VARCHAR(60);
   DEFINE v_ejecut	     VARCHAR(45);
   DEFINE v_divnom	     VARCHAR(30);
   DEFINE v_prodnom	     VARCHAR(40);
   DEFINE v_num_credito      VARCHAR(20);
   DEFINE v_sdo_capital      DECIMAL(18,2);
   DEFINE v_mto_ministra     DECIMAL(18,2);
   DEFINE v_monto_otorgado   DECIMAL(18,2);
   DEFINE v_sdo_cap_insoluto DECIMAL(18,2);
   DEFINE v_monto_vencido    DECIMAL(18,2);

BEGIN


   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET p_cod_ret          = '00000';
   LET p_mensaje          = ' ';
   LET v_apell_paterno    = ' ';
   LET v_apell_materno    = ' ';
   LET v_nombre1          = ' ';
   LET v_nombre2          = ' ';
   LET v_cliente          = ' ';
   LET v_divnom           = ' ';
   LET v_prodnom          = ' ';
   LET v_razon_social     = ' ';
   LET v_numcte           = ' ';
   LET v_num_credito      = ' ';
   LET v_sdo_capital      = 0;
   LET v_mto_ministra     = 0;
   LET v_monto_otorgado   = 0;
   LET v_sdo_cap_insoluto = 0;
   LET v_monto_vencido    = 0;
   LET v_monto_ven_tras	  = 0;
--   v_monto_financiado := 0;
--   v_sdo_acum_vencido := 0;
--   v_monto_recuperado  := 0;
   LET v_ejecut           = ' ';
   LET v_num_prod         = ' ';

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = ' ' THEN
      LET p_cod_ret = '223'; -- NUMERO DE CREDITO NULO O BLANCO
--      GOTO FIN;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;
END;

BEGIN
   SELECT num_credito,sdo_capital,mto_ministra_cap,monto_otorgado,
--          sdo_cap_insoluto,monto_vencido,monto_financiado,
            sdo_cap_insoluto,monto_vencido, mto_venc_trasp
--          sdo_acum_vencido
   INTO v_num_credito,v_sdo_capital,v_mto_ministra,v_monto_otorgado,
--        v_sdo_cap_insoluto,v_monto_vencido,v_monto_financiado,
        v_sdo_cap_insoluto,v_monto_vencido, v_monto_ven_tras
--        v_sdo_acum_vencido
   FROM sd_maesdos
   WHERE empresa = p_empresa
   AND   num_credito = v_num_credito;

--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_num_credito IS NULL OR v_num_credito = ' ' THEN
      LET p_cod_ret = '224'; -- NO EXISTE EL CREDITO
--      GOTO FIN;
   END IF;

BEGIN
      SELECT si_cliente.numcte,apell_paterno,apell_materno,nombre1,
             nombre2,razon_social
      INTO v_numcte,v_apell_paterno,v_apell_materno,v_nombre1,v_nombre2,
           v_razon_social
      FROM sd_maecred, si_cliente
      WHERE sd_maecred.empresa     = p_empresa
      AND   sd_maecred.num_credito = v_num_credito
      AND   sd_maecred.empresa     = si_cliente.empresa
      AND   sd_maecred.numcte      = si_cliente.numcte;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;
      IF v_razon_social IS NULL OR v_razon_social = ' ' THEN
         LET v_cliente = TRIM (v_nombre1) || ' ' || TRIM (v_nombre2);
         LET v_cliente = TRIM (v_cliente) || ' ' ||
                         TRIM (v_apell_paterno) || ' ' ||
                         TRIM (v_apell_materno);
      ELSE
         LET v_cliente = v_razon_social;
      END IF;
--BEGIN
--   SELECT SUM(monto_real_pag) INTO v_monto_recuperado
--  FROM sd_pagocapit
--   WHERE empresa = p_empresa
--   AND   num_credito = v_num_credito
--   AND   status_cuota IN ('3','5','9');
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
--END;
--   IF v_monto_recuperado IS NULL THEN
--     v_monto_recuperado := 0;
--   END IF;
BEGIN
   SELECT nombre INTO v_ejecut
   FROM sd_maecred, si_ejecut
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND  sd_maecred.empresa      = si_ejecut.empresa
   AND  sd_maecred.ejecutivo    = si_ejecut.ejecutivo;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

    IF v_ejecut IS NULL OR v_ejecut = ' ' THEN
      LET v_ejecut    = ' ';
   END IF;

BEGIN
   SELECT num_producto INTO v_num_prod
   FROM sd_maecred
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

BEGIN
   SELECT nombre_prod INTO v_prodnom
   FROM sd_definicion
   WHERE empresa = p_empresa
   AND   num_producto = v_num_prod;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   LET v_prodnom = SUBSTR(TRIM (v_num_prod) || ' ' || TRIM (v_prodnom),1,40);

   IF v_prodnom IS NULL THEN
      LET v_prodnom = ' ';
   END IF;

BEGIN
   SELECT descripcion INTO v_divnom
   FROM sd_maecred, si_divisas
   WHERE sd_maecred.empresa     = p_empresa
   AND   sd_maecred.num_credito = v_num_credito
   AND   sd_maecred.empresa     = si_divisas.empresa
   AND   sd_maecred.divisa      = si_divisas.divisa;
--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN TOO_MANY_ROWS THEN
--     NULL;
END;

   IF v_sdo_capital IS NULL THEN
      LET v_sdo_capital = 0;
   END IF;
   IF v_mto_ministra IS NULL THEN
      LET v_mto_ministra = 0;
   END IF;
   IF v_monto_otorgado IS NULL THEN
      LET v_monto_otorgado = 0;
   END IF;
   IF v_sdo_cap_insoluto IS NULL THEN
      LET v_sdo_cap_insoluto = 0;
   END IF;
   IF v_monto_vencido IS NULL THEN
      LET v_monto_vencido = 0;
   END IF;
   if v_monto_ven_tras is null then
      LET v_monto_ven_tras = 0;
   end if;

   LET v_monto_vencido = v_monto_vencido + v_monto_ven_tras;

--   IF v_monto_financiado IS NULL THEN
--      v_monto_financiado := 0;
--   END IF;
--   IF v_sdo_acum_vencido IS NULL THEN
--      v_sdo_acum_vencido := 0;
--   END IF;
--   IF v_monto_recuperado IS NULL THEN
--      v_monto_recuperado := 0;
--   END IF;
--   <<FIN>>
--     NULL;
--   EXCEPTION
--      WHEN OTHERS THEN
--       SIPK_MENSAJES.SP_TRAE_MENSAJE (SQLCODE, SQLERRM, P_COD_RET, P_MENSAJE);
RETURN    p_cod_ret,p_mensaje,
          v_numcte,v_cliente,v_ejecut,v_divnom,v_prodnom,v_num_credito,
          v_sdo_capital,v_mto_ministra,v_monto_otorgado,v_sdo_cap_insoluto,
          v_monto_vencido;  --p_cod_ret,p_mensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Herndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".planpagcap(pempresa char(3),
                            pnum_credito  CHAR(20),
                            pnum_pago     SMALLINT) -- mandan un cero y el
                                                    -- cs2 regresa de 20 en 20.

   RETURNING CHAR(05),         -- codigo de retorno
             CHAR(80),         -- clave y nombre del cliente
             DATE,             -- fecha de apertura
             DATE,             -- fecha de vencimiento
             CHAR(45),         -- nombre del producto
             MONEY(14,2),      -- monto de la cuota propios
             DATE,             -- fecha de la cuota propios
             DATE,             -- fecha de pago de la cuota propios
             CHAR(1),          -- status de la cuota propios
             CHAR(1),          -- segundo status de la cuota propios
                               --(antes recursos de la cuota)
             CHAR(30),         -- nombre de la divisa
             CHAR(54),         -- nombre del ejecutivo
             MONEY(14,2),      -- monto otorgado del credito
             MONEY(14,2),      -- monto ministrado    v_saldo_cuota
             MONEY(14,2),      -- monto capitalizado  v_imp_capitalizado
             MONEY(14,2),      -- valor actual        v_valor_actual
             MONEY(14,2);      -- monto real pagado   v_monto_real_pag


   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                   SMALLINT;
   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;
   DEFINE v_num_credito       CHAR(20);
   DEFINE v_monto_otorgado    MONEY(14,2);
   DEFINE cod_ret             CHAR(5);
   DEFINE v_ejecutivo         LIKE sd_maecred.ejecutivo;
   DEFINE v_ciclo             SMALLINT;
   DEFINE v_conta             SMALLINT;
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_divisa            LIKE sd_maecred.divisa;
   DEFINE v_divisas           LIKE si_divisas.descripcion;
   DEFINE v_nomejecutivo      CHAR(54);
   DEFINE v_producto          CHAR(40);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(80);
   DEFINE v_cliente           CHAR(60);
   DEFINE v_descripcion       CHAR(45);
   DEFINE v_num_producto      LIKE sd_maecred.num_producto;
   DEFINE v_numcte            LIKE sd_maecred.numcte;
   DEFINE vg_cliente          CHAR(80);
   DEFINE v_fecha_apertura    LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim      LIKE sd_maecred.fecha_vencim;
   DEFINE v_monto_cuota       LIKE sd_pagocapit.monto_cuota;
   DEFINE v_monto_cuotas      LIKE sd_pagocapit.monto_cuota;
   DEFINE v_fecha_cuota       LIKE sd_pagocapit.fecha_cuota;
   DEFINE v_fecha_cuota1      LIKE sd_pagocapit.fecha_cuota;
   DEFINE v_fecha_pago        LIKE sd_pagocapit.fecha_pago;
   DEFINE v_fecha_pago1       LIKE sd_pagocapit.fecha_pago;
   DEFINE v_status_cuota      LIKE sd_pagocapit.status_cuota;
   DEFINE v_status_cuota1     LIKE sd_pagocapit.status_cuota;
   DEFINE v_cuota_rec         LIKE sd_pagocapit.cuota_rec;
   DEFINE v_cuota_recr        LIKE sd_pagocapit.cuota_rec;
   DEFINE v_monto_cuota1      LIKE sd_pagocapit.monto_cuota;
   DEFINE v_saldo_cuota       MONEY(14,2);      -- monto minis
   DEFINE v_imp_capitalizado  MONEY(14,2);      -- monto capitalizado  
   DEFINE v_valor_actual      MONEY(14,2);      -- valor actual       
   DEFINE v_monto_real_pag    MONEY(14,2);      -- monto real pagado  

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr
      IF sqlerr != 0 THEN
         LET cod_ret = sqlerr;
         RETURN cod_ret,          vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,   v_descripcion,   
                v_monto_cuota,    v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,   v_cuota_rec,    v_divisas,
                v_nomejecutivo,   v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual, 
                v_monto_real_pag;
      END IF;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret            = "000000";
   LET i                  = 1;
   LET v_ciclo            = 0;
   LET v_conta            = 0;
   LET v_num_credito      = " ";
   LET v_monto_otorgado   = 0;
   LET v_fecha_apertura   = " ";
   LET v_fecha_vencim     = " ";
   LET v_fecha_cuota      = " ";
   LET v_fecha_pago       = " ";
   LET v_monto_cuota      = 0.00;
   LET v_monto_cuotas     = 0.00;
   LET v_status_cuota     = " ";
   LET v_cuota_rec        = " ";
   LET v_nomejecutivo     = " ";
   LET v_ejecutivo        = " ";
   LET v_producto         = " ";
   LET vg_cliente         = " ";
   LET v_monto_cuota1     = 0;
   LET v_descripcion      = " ";
   LET v_num_producto     = " ";
   LET v_descripcion      = " ";
   LET v_divisa           = " ";
   LET v_divisas          = " ";
   LET v_monto_cuota1     = 0;
   LET v_fecha_cuota1     = " ";
   LET v_fecha_pago1      = " ";
   LET v_status_cuota1    = " ";
   LET v_monto_cuotas     = 0;
   let v_saldo_cuota      = 0;
   let v_imp_capitalizado = 0;
   let v_valor_actual     = 0;
   let v_monto_real_pag   = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
      RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
             v_fecha_vencim,  v_descripcion,   
             v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
             v_status_cuota,  v_cuota_rec,     v_divisas,
             v_nomejecutivo,  v_monto_otorgado,
             v_saldo_cuota,   v_imp_capitalizado, v_valor_actual, 
             v_monto_real_pag;
   ELSE
      LET v_num_credito = pnum_credito;

      SELECT num_credito,      numcte,         num_producto,
             fecha_apertura,   fecha_vencim,   divisa,
             ejecutivo
      INTO   v_num_credito,    v_numcte,       v_num_producto,
             v_fecha_apertura, v_fecha_vencim, v_divisa,
             v_ejecutivo
      FROM sd_maecred
      WHERE empresa = pempresa and num_credito = v_num_credito;

      IF v_num_credito IS NULL OR
         v_num_credito = " " THEN
         LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,   
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual, 
                v_monto_real_pag;
      END IF;
      IF v_numcte IS NULL OR
         v_numcte = " " THEN
         LET cod_ret = "202"; -- CLIENTE NULO O EN BLANCO EN sd_maecred
         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,   
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,    v_imp_capitalizado, v_valor_actual, 
                v_monto_real_pag;
      ELSE
         SELECT numcte, TRIM(NVL(razon_social, " ")) || 
                TRIM(NVL(apell_paterno," ")) || " " || 
                TRIM(NVL(apell_materno,' ')) || " " ||
                TRIM(NVL(nombre1," ")) || " " ||
                TRIM(NVL(nombre2," "))
         INTO v_numcte, v_cliente
         FROM si_cliente
         WHERE numcte = v_numcte;
         LET vg_cliente = TRIM (v_numcte) || " " || v_cliente;
      END IF;
   END IF;

   IF v_num_producto IS NULL THEN
      LET v_num_producto = " ";
   ELSE
      SELECT nombre_prod INTO v_descripcion
      FROM sd_definicion
      WHERE empresa = pempresa and num_producto = v_num_producto;
   END IF;

   SELECT descripcion INTO v_divisas
   FROM si_divisas
   WHERE empresa = pempresa and divisa = v_divisa;
   IF v_divisas IS NULL THEN
      LET v_divisas = " ";
   END IF;

   SELECT nombre INTO v_nomejecutivo
   FROM si_ejecut
   WHERE ejecutivo = v_ejecutivo;

   IF v_nomejecutivo IS NULL THEN
      LET v_nomejecutivo = " ";
   ELSE
      LET v_nomejecutivo = TRIM (v_ejecutivo) || " " ||
         TRIM (v_nomejecutivo);
   END IF;

   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE empresa = pempresa and num_credito = v_num_credito;

   IF v_monto_otorgado IS NULL THEN
      LET v_monto_otorgado = 0;
   END IF;

   FOREACH
      SELECT monto_cuota,  fecha_cuota,
             fecha_pago,   status_cuota,   cuota_rec,
             saldo_cuota,  imp_capitalizado, monto_real_pag
      INTO   v_monto_cuota,  v_fecha_cuota,
             v_fecha_pago, v_status_cuota, v_cuota_rec,
             v_saldo_cuota,  v_imp_capitalizado, v_monto_real_pag
             
      FROM sd_pagocapit
      WHERE empresa = pempresa and num_credito = v_num_credito
      ORDER BY 2

      IF v_fecha_cuota IS NULL THEN
         LET v_fecha_cuota = " ";
      END IF;

      IF v_fecha_pago IS NULL THEN
         LET v_fecha_pago = " ";
      END IF;

      LET v_ciclo = v_ciclo + 1;

      IF v_ciclo <= pnum_pago THEN
         CONTINUE FOREACH;
      END IF;

      IF v_monto_cuota IS NULL THEN
         LET v_monto_cuota = 0;
      END IF;
      IF v_monto_cuota1 IS NULL THEN
         LET v_monto_cuota1 = 0;
      END IF;

      LET v_monto_cuotas = v_monto_cuota + v_monto_cuota1;
      LET v_valor_actual = v_saldo_cuota + v_imp_capitalizado - v_monto_real_pag;
      IF vg_cliente IS NULL THEN
         LET vg_cliente = " ";
      END IF;

         RETURN cod_ret,         vg_cliente,      v_fecha_apertura,
                v_fecha_vencim,  v_descripcion,   
                v_monto_cuota,   v_fecha_cuota,   v_fecha_pago,
                v_status_cuota,  v_cuota_rec,     v_divisas,
                v_nomejecutivo,  v_monto_otorgado,
                v_saldo_cuota,   v_imp_capitalizado, v_valor_actual, 
                v_monto_real_pag
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".planpagint(pempresa char(3),
                            pnum_credito  CHAR(20),
                            pnum_pago     SMALLINT) --mandan un cero y el
                                                    -- cs2 regresa de 20 en 20.

   RETURNING CHAR(06),     -- Codigo de retorno
             CHAR(80),     -- Nombre del cliente
             DATE,         -- Fecha de apertura del credito
             DATE,         -- Fecha de vencimiento del credito
             CHAR(45),     -- Nombre del Producto
             MONEY(14,2),  -- Monto de la cuota propios
             DATE,         -- Fecha de vencimiento de la cuota propios
             DATE,         -- Fecha de pago de la cuota propios
             CHAR(1),      -- Status de ls cuota
             CHAR(54),     -- Nombre del ejecutivo
             CHAR(30),     -- Nombre de la divisa
             MONEY(14,2);  -- Monto otorgado


   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                   SMALLINT;
   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;
   DEFINE v_num_credito       CHAR(20);
   DEFINE cod_ret             CHAR(6);
   DEFINE v_ciclo             SMALLINT;
   DEFINE v_conta             SMALLINT;
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(80);
   DEFINE v_cliente           CHAR(60);
   DEFINE v_descripcion       CHAR(44);
   DEFINE v_num_producto      LIKE sd_maecred.num_producto;
   DEFINE v_cod_tipcred       LIKE sd_definicion.cod_tipcred;
   DEFINE v_divisa            LIKE sd_maecred.divisa;
   DEFINE v_ejecutivo         LIKE sd_maecred.ejecutivo;
   DEFINE v_monto_otorgado    LIKE sd_maesdos.monto_otorgado;
   DEFINE vv_nombre           CHAR(54);
   DEFINE vv_descripcion      LIKE si_divisas.descripcion;

   DEFINE v_numcte            LIKE sd_maecred.numcte;
   DEFINE vg_cliente          CHAR(80);
   DEFINE v_fecha_apertura    LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim      LIKE sd_maecred.fecha_vencim;
   DEFINE v_monto_cuota       LIKE sd_paginter.monto_cuota;
   DEFINE v_fecha_cuota       LIKE sd_paginter.fecha_cuota;
   DEFINE v_fecha_pag         LIKE sd_paginter.fecha_pag;
   DEFINE v_status_cuota      LIKE sd_paginter.status_cuota;
   DEFINE v_monto_cuota1      LIKE sd_paginter.monto_cuota;
   DEFINE v_fecha_cuota1      LIKE sd_paginter.fecha_cuota;
   DEFINE v_fecha_pag1        LIKE sd_paginter.fecha_pag;
   DEFINE v_status_cuot1      LIKE sd_paginter.status_cuota;
   DEFINE v_monto_cuotas      MONEY(14,2);

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr
      IF sqlerr != 0 THEN
         LET cod_ret = sqlerr;
         -- este parametro cero (0) es interno de visual es necesario
         -- que lo manden despues del credito.
         IF cod_ret = -696 THEN
            LET cod_ret = "272";
            LET v_fecha_apertura = " ";
            LET v_fecha_vencim   = " ";
            LET v_fecha_pag      = " ";
            LET v_fecha_cuota    = " ";
            LET v_monto_cuota    = 0.00;
            LET v_status_cuota   = " ";
            LET v_fecha_pag1     = " ";
            LET v_fecha_cuota1   = " ";
            LET v_monto_cuota1   = 0.00;
            LET v_status_cuot1   = " ";
            LET vg_cliente       = " ";
            LET v_descripcion    = " ";
            LET v_monto_cuotas   = 0;
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
         END IF;
      END IF;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret           = "000000";
   LET i                 = 1;
   LET v_ciclo           = 0;
   LET v_conta           = 0;
   LET v_num_credito     = " ";
   LET v_fecha_pag       = " ";
   LET v_fecha_apertura  = " ";
   LET v_fecha_vencim    = " ";
   LET v_monto_cuota     = 0;
   LET v_status_cuota    = " ";
   LET v_descripcion     = " ";
   LET vg_cliente        = " ";
   LET v_divisa          = " ";
   LET v_ejecutivo       = " ";
   LET v_monto_otorgado  = 0;
   LET vv_nombre         = " ";
   LET vv_descripcion    = "  ";
   LET v_monto_cuota1    = 0;
   LET v_fecha_cuota1    = " ";
   LET v_fecha_pag1      = " ";
   LET v_status_cuot1    = " ";
   LET v_monto_cuotas    = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;

   SELECT num_credito,   numcte,         divisa,
          ejecutivo,     num_producto,   fecha_apertura,
          fecha_vencim
   INTO   v_num_credito, v_numcte,       v_divisa,
          v_ejecutivo,   v_num_producto, v_fecha_apertura,
          v_fecha_vencim
   FROM sd_maecred
   WHERE empresa = pempresa and num_credito = v_num_credito;

   IF v_num_credito IS NULL OR
      v_num_credito = " " THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
   END IF;

   IF v_numcte IS NULL THEN
      LET v_numcte = " ";
   ELSE
         SELECT numcte, TRIM(NVL(razon_social, " ")) ||
                TRIM(NVL(apell_paterno," ")) || " " ||
                TRIM(NVL(apell_materno,' ')) || " " ||
                TRIM(NVL(nombre1," ")) || " " ||
                TRIM(NVL(nombre2," "))
         INTO v_numcte, v_cliente
         FROM si_cliente
         WHERE numcte = v_numcte;
         LET vg_cliente = TRIM (v_numcte) || " " || v_cliente;
   END IF;

   IF v_num_producto IS NULL THEN
      LET v_num_producto = " ";
   END IF;

   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE empresa = pempresa and num_credito = v_num_credito;

   SELECT nombre INTO vv_nombre
   FROM si_ejecut
   WHERE si_ejecut.ejecutivo = v_ejecutivo;

   IF vv_nombre IS NULL THEN
      LET vv_nombre = " ";
   ELSE
      LET vv_nombre = TRIM (v_ejecutivo) || " " ||
          TRIM (vv_nombre);
   END IF;

   SELECT descripcion INTO vv_descripcion
   FROM si_divisas
   WHERE empresa = pempresa and divisa = v_divisa;

   SELECT nombre_prod INTO v_descripcion
   FROM sd_definicion
   WHERE empresa = pempresa and num_producto = v_num_producto;

   FOREACH
      SELECT monto_cuota,fecha_cuota,fecha_pag,status_cuota
      INTO v_monto_cuota,v_fecha_cuota,v_fecha_pag,v_status_cuota
      FROM sd_paginter
      WHERE empresa = pempresa and num_credito = v_num_credito
      ORDER BY 2

      IF v_fecha_cuota IS NULL OR
         v_fecha_cuota = " " THEN
         LET v_fecha_cuota = " ";
      END IF;

      IF v_fecha_pag IS NULL OR
         v_fecha_pag = " " THEN
         LET v_fecha_pag = " ";
      END IF;

      LET v_ciclo = v_ciclo + 1;

      IF v_ciclo <= pnum_pago THEN
         CONTINUE FOREACH;
      END IF;


      IF v_monto_cuota IS NULL THEN
         LET v_monto_cuota = 0;
      END IF;
      IF v_monto_cuota1 IS NULL THEN
         LET v_monto_cuota1 = 0;
      END IF;

      LET v_monto_cuotas = v_monto_cuota + v_monto_cuota1;

      IF vg_cliente IS NULL THEN
         LET vg_cliente = " ";
      END IF;

            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spsd_cupones(p_credito varchar(20), 
					 p_empresa char(3),
				         p_cuota   SMALLINT,
					 p_cupones SMALLINT)
       returning char(3),       varchar(20),   date,
                 varchar(20),   varchar(60),   varchar(4),
                 integer,       decimal(18,2), decimal(18,2),
                 decimal(18,2), decimal(18,2), date,
                 date,          decimal(18,2), decimal(18,2),
		 decimal(18,2), decimal(18,2), decimal(18,2);
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   define r_credito   varchar(20);
   define r_fecha     date;
   define r_numcte    varchar(20);
   define r_cliente   varchar(60);
   define r_tipocred  varchar(4);
   define r_cuota     integer;
   define r_seguro    decimal(18,2);
   define r_recargo   decimal(18,2);
   define r_monto1    decimal(18,2);
   define r_monto2    decimal(18,2);
   define r_vento     date;
   define r_gracia    date;
   define r_acciones  decimal(18,2);
   --##### Define variables de Trabajo #####
   define v_status    char(1);
   define v_cuantas   integer;
   define v_monto     decimal(18,2);
   define v_tasamora  decimal(9,6);
   define v_gracia    smallint;
   define v_capcuo    decimal(18,2);
   define v_intcuo    decimal(18,2);
   define v_balance   decimal(18,2);
   define v_fechaa    DATE;
   define v_mtoori    DECIMAL(18,2);
   define v_vueltas   SMALLINT;
   DEFINE ax_fecha    DATE;


   --###### Inicializa Variables ###########
   let r_empresa   = p_empresa;
   let r_credito   = p_credito;
   let r_fecha     = '';
   let v_fechaa     = '';
   let r_numcte    = '';
   let r_cliente   = '';
   let r_tipocred  = '';
   let r_cuota     = 0;
   let r_seguro    = 0;
   let r_recargo   = 0;
   let r_monto1    = 0;
   let r_monto2    = 0;
   let r_vento     = '';
   let r_gracia    = '';
   let v_status    = '';
   let v_monto     = 0;
   let v_gracia    = 0;
   LET v_capcuo    = 0;
   LET v_intcuo    = 0;
   LET v_balance   = 0;
   let r_acciones  = 0;
   LET v_vueltas   = 0;




   --###### Indica cuantos cupones se van a imprimir ###########
   --es 12 porque es mensual, pero en caso de variar unicamente
   --se cambia este dato por el numero de cupones a imprimir
   --de acuerdo al periodo
   let v_cuantas    = p_cupones;

   --###### Obtiene la fecha y las de vento ###########
   {SELECT NVL(valor,"0") 
     INTO r_acciones
     FROM sd_param
    WHERE cod_param = "72"
      AND empresa = p_empresa;}

   --###### Obtiene la fecha y las de vento ###########
   select fecha_hoy
   into   r_fecha
   from   sd_fechas
   where  empresa = p_empresa;

   --###### Obtiene datos del cliente y credito ###########
   select c.numcte, c.num_producto, nvl(c.tasa_moratorios, 0),
          nvl(p.gracia_calc_mora, 0), fecha_apertura, por_acciones
   into   r_numcte, r_tipocred,     v_tasamora,
          v_gracia, v_fechaa, r_acciones
   from   sd_maecred c, sd_definicion p
   where  c.empresa = p.empresa
   and    c.num_producto = p.num_producto
   and    c.empresa = r_empresa
   and    c.num_credito = r_credito;

   select decode(nvl(razon_social,''),
          '', trim(nvl(nombre1,'')) ||' '||
              trim(nvl(nombre2,'')) ||' '||
              trim(nvl(apell_paterno,'')) ||' '||
              trim(nvl(apell_materno,'')),
          trim(razon_social))
   into   r_cliente
   from   bdinteg:si_cliente
   where  empresa = r_empresa
   and    numcte = r_numcte;

   -- ##### Determina la Cuota en la que debe iniciar #########
   let r_cuota = 0;
   FOREACH SELECT fecha_cuota 
	     INTO ax_fecha
	     FROM sd_pagocapit
	    WHERE num_credito = r_credito

	LET r_cuota = r_cuota +1;
	IF r_cuota = p_cuota THEN
		EXIT FOREACH;
	END IF
   END FOREACH

   --###### Obtiene recibos a Reportar ###########
   foreach select fecha_cuota, status_cuota
           into   r_vento, v_status
           from   sd_pagocapit
           where  empresa = r_empresa
           and    num_credito = r_credito
	   and    fecha_cuota >= ax_fecha
           order  by fecha_cuota
      --###### Inicializa Variables ###########
      --let r_cuota = r_cuota + 1;

      --###### verifica si esta pagada o no ###########
--      if v_status = '1' then
	 LET v_vueltas = v_vueltas + 1;
         --###### Obtiene datos de capital ###########
         select sum(monto_cuota - monto_real_pag)
         into   r_monto1
         from   sd_pagocapit
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_cuota = r_vento;
	 LET v_capcuo = r_monto1;

 	SELECT COUNT(*) INTO r_cuota
	  FROM sd_pagocapit
	 WHERE num_credito = r_credito
	   AND fecha_cuota <= r_vento;
         --###### Obtiene datos de intereses ###########
         select nvl(sum(monto_cuota - monto_real_pag), 0)
         into   v_monto
         from   sd_paginter
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_cuota = r_vento;
	 LET v_intcuo = v_monto;


	 SELECT (SELECT SUM(monto_cuota-monto_real_pag)
		   FROM sd_pagocapit
		  WHERE num_credito = r_credito)
		 - (SELECT SUM(monto_cuota-monto_real_pag )
				    FROM sd_pagocapit 
				   WHERE num_credito = r_credito
				     AND fecha_cuota <= r_vento),
		monto_otorgado
	   INTO v_balance, v_mtoori
	   FROM sd_maesdos
	  WHERE num_credito = r_credito;
				   

         --###### Obtiene datos de seguros ###########
         select nvl(sum(monto_com), 0)
         into   r_seguro
         from   sd_detcomi
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_alta = r_vento
         and    estado_com = 'P';

         --###### Obtiene moratorios ###########
         let r_recargo = (r_monto1 + v_monto) * (v_tasamora / 100);

         --###### Calcula los totales ###########
         let r_monto1 = r_monto1 + v_monto + r_seguro + r_acciones;
         let r_monto2 = r_monto1 + r_recargo;

         --###### Obtiene fecha de gracia ###########
         let r_gracia = r_vento + v_gracia;

         --###### Regresa los datos del Cupon ###########
         return r_empresa, r_credito, v_fechaa,
                r_numcte,  r_cliente, r_tipocred,
                r_cuota,   r_seguro,  r_recargo,
                r_monto1,  r_monto2,  r_vento,
                r_gracia,  r_acciones,v_balance,
		v_capcuo,  v_intcuo,  v_mtoori   with resume;
         if mod(v_vueltas,v_cuantas) = 0 then
            exit foreach;
         end if;
--      end if;
   end foreach;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".sp_mesejec( pempresa char(3) )
returning char(20) ,
	  integer ,
	  char(60) ,
	  char(160) ,
	  char(2) ,
	  char(4) ,
	  char(20) ,
	  char(2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  date ,
	  date ,
	  date ,
	  integer ,
	  integer ,
	  char(40) ;

define r_numcte char(20);
define r_tpo integer;
define r_nombre char(60);
define r_titulo char(160);
define r_siglas char(2);
define r_producto char(4);
define r_cuenta char(20);
define r_status char(2);
define r_saldo decimal(14,2);
define r_interes decimal(14,2);
define r_pago decimal(14,2);
define r_saldo_original decimal(14,2);
define r_fecha_apertura date;
define r_fecha_pago date;
define r_fecha_vencimiento date;
define r_plazos_total integer;
define r_plazos_pagados integer;
define r_producto_nombre char(40);

define v_nombre1 char(15);
define v_nombre2 char(15);
define v_apell_paterno char(15);
define v_apell_materno char(15);
define v_tasa char(8);
define v_secuencia integer;



SET ISOLATION TO DIRTY READ;

foreach
    select a.numcte, a.tpo, a.titulo,
	   b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno
    into r_numcte, r_tpo, r_titulo,
	 v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
    from si_repmesejec a
    inner join si_cliente b
    on a.empresa = b.empresa
    and a.numcte = b.numcte
    order by a.numcte
    let r_nombre = TRIM(v_nombre1)||' '||TRIM(V_apell_paterno)||' '||TRIM(v_apell_materno);
    foreach
	select "SD", a.num_credito, a.num_producto, a.status_cred,
	sdo_cap_insoluto + sdo_exig_int + sdo_moratorio
	into r_siglas, r_cuenta, r_producto, r_status, r_saldo
	from sd_maecred a
	inner join sd_maesdos b
	on a.empresa = b.empresa
	and a.num_credito = b.num_credito
	where  a.empresa = pempresa
	and a.numcte = r_numcte
--	union all
--	select "SC", cuenta, producto, status_cta, sdo_actual
--	from bdicheq:sc_maechq
--	where empresa = pempresa and num_cte = r_numcte
--	union all
--	select "SV", cuenta, cod_instrum, status_cta, capital
--	from bdinvers:sv_maeinv
--	where empresa = pempresa and num_cte = r_numcte and status_cta <> "4"
	order by 2
	if r_status = "2" then
	    let r_saldo = 0;
	end if;
	
	let r_interes = 0.0;
	let r_pago = 0.0;
	let r_saldo_original = 0.0;
	let r_fecha_apertura = null;
	let r_fecha_pago = null;
	let r_fecha_vencimiento = null;
	let r_plazos_total = 0;
	let r_plazos_pagados = 0;
	let r_producto_nombre = ' ';

	if r_siglas = "SC" then
		select a.tasa 
		into v_tasa
		from bdicheq:sc_producto a
		where a.empresa = pempresa
		and a.producto = r_producto;
		select a.valor	
		into r_interes
		from bdinteg:si_fechavalor a
		where a.empresa = pempresa
		and a.tasa = v_tasa;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
	elif r_siglas = "SV" then
		select max(a.secuencia)
		into v_secuencia
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa 
		and a.cuenta = r_cuenta;
		select a.tasa + a.sobretasa, a.capital
		into r_interes, r_saldo_original
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa
		and a.secuencia = v_secuencia
		and a.cuenta = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
	elif r_siglas = "SD" then
		select round(a.tasa_interes,2)
		into r_interes
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and num_credito = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		select min(a.monto_cuota + b.monto_cuota)
		into r_pago
		from bdicred:sd_pagocapit a, bdicred:sd_paginter b
		where a.empresa = pempresa
		and a.empresa = b.empresa
		and a.num_credito = r_cuenta
		and a.num_credito = b.num_credito
		and a.fecha_cuota = b.fecha_cuota;
		if r_pago is null then
			let r_pago = 0.0;
		end if;
		select a.monto_otorgado
		into r_saldo_original
		from bdicred:sd_maesdos a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
		select a.fecha_apertura, a.fecha_vencim, a.plazo
		into r_fecha_apertura, r_fecha_vencimiento, r_plazos_total
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		select min(fecha_cuota)
		into r_fecha_pago
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.status_cuota in ('1','2','7');
		select count(*)
		into r_plazos_pagados
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.fecha_cuota < r_fecha_pago;

		select a.nombre_prod
		into r_producto_nombre
		from bdicred:sd_definicion a
		where a.empresa = pempresa
		and a.num_producto = r_producto;
	end if;
	return r_numcte, r_tpo, r_nombre, r_titulo, r_siglas, r_producto, r_cuenta, r_status, r_saldo, 
	       r_interes, r_pago, r_saldo_original,
	       r_fecha_apertura, r_fecha_pago, r_fecha_vencimiento, r_plazos_total, r_plazos_pagados, r_producto_nombre  with resume;
    end foreach;
end foreach;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_calcdia(param smallint)
RETURNING VARCHAR(10);


DEFINE params VARCHAR(10);

	LET params = "0";

	IF param = 1 THEN
		LET params = "UNO";
        END IF

	IF param = 2 THEN
		LET params = "DOS";
        END IF


	IF param = 3 THEN
		LET params = "TRES";
        END IF

	RETURN params;

END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".genmovto()
       returning char(3),char(20);

define vcodret char(3);
define vnumcte char(20);
define vcuenta char(20);
define vtranret char(4);
define i integer;

foreach
   select cuenta into vcuenta
      from sc_maechq
      where numcte between '101018051' and '101068064'
   call abono('001','001','victorlp','0202','0202','victorlp18353904',
              vcuenta,0,100,100,0,0,0,'01')
        returning vcodret;
   if vcodret <> "000" then
      return vcodret,vnumcte;
   end if
   call cargo ('001','001','victorlp','0221','0202','victorlp18353904',
               vcuenta, 222, 100,'01')
        returning vcodret,vtranret;
   if vcodret <> "000" then
      return vcodret,vnumcte;
   end if
end foreach
return vcodret,vnumcte;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".genclientes()
       returning char(3),char(20);

define vcodret char(3);
define vnumcte char(20);
define i integer;



for i = 1 to 5000000
    call ctefisico('001','A','','001','victorlp','01','1',
       'PATERNO'||i,'MATERNO','NOMBRE'||i,'NOMBREPRUEBA','',
       '00','000','001','000','000','','12',
       '01/01/1960','','001','1','','S','1','001','M','','A','2432',
       '8975646','12','423423','423423','9495','','','','01','00','',
       '','','','0','-    -    -','0','00','PROPIA',3,'E',0)
       returning vcodret,vnumcte;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
    call ingresos('001',vnumcte,'1','1','TITULAR','S',
                  'JH','87879987','HJKHJ','7','JHHJ','JHGJGHJH',20000)
       returning vcodret;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
    call Direcciones('001','A',vnumcte,1,'1','A','A','00601','A','001',
                   '01','001','12231','164554564','564564564',' ','01','001','0001')
       returning vcodret;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
end for
return vcodret,vnumcte;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".codpos4()
       returning char(5);

define vcodret	char(5);
define vcodigo_pos char(5);
define vcodigo_pos4 char(5);

let vcodret = "000";
let vcodigo_pos = "";
let vcodigo_pos4 = "";

foreach
      select codigo_pos into vcodigo_pos4
      from si_codigopostal
      where length(trim(codigo_pos)) = 4
      let vcodigo_pos = "0"||trim(vcodigo_pos4);
      update si_codigopostal set codigo_pos = vcodigo_pos
      where codigo_pos = vcodigo_pos4;

end foreach
    return vcodret;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".conscedsol(pEmpresa LIKE si_cliente.EMPRESA,
	                    pNumCte  LIKE si_cliente.NUMCTE,
                            pNumCred varchar(20))
RETURNING CHAR(20),
          CHAR(6),
          CHAR(80);

   DEFINE lContador INTEGER;
   DEFINE pCredito  varchar(20);
   DEFINE pCodRet varchar(6);
   DEFINE pMensaje varchar(80);

   LET lContador = 0;
   LET pCredito = '';
   LET pCodRet = ' ';
   LET pMensaje = ' ';

   FOREACH
      SELECT num_credito
      INTO   pCredito
      FROM   bdicred:sd_maecred  --ss_solicitudes
      WHERE  empresa = pEmpresa
      AND    numcte  = pNumCte
   --   AND    status_solicitud NOT IN ('AT', 'AP','RE')
      LET pCodret  = '00000';
      LET pMensaje = 'Paso de solicitudes';
      RETURN pCredito,
             pCodRet,
             pMensaje
   WITH RESUME;
   LET lContador = lContador + 1;
   END FOREACH;
   LET pCredito = '';
   LET pCodRet = ' ';
   LET pMensaje = ' ';

      RETURN pCredito,
             pCodRet,
             pMensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE  PROCEDURE "informix".cta_cont(v_empresa    CHAR(3),
                          v_ccmayor    CHAR(4),
                          v_ccsub      CHAR(2),
                          v_ccsubsub   CHAR(2),
                          v_ccssubsub  CHAR(2),
                          v_ccsssubsub CHAR(2),
                          v_sector     CHAR(2))
   RETURNING CHAR(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE v_cont  SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "";
   LET v_cont  = 0;



   IF v_ccmayor    IS NULL OR v_ccmayor    = " " OR
      v_ccsub      IS NULL OR v_ccsub      = " " OR
      v_ccsubsub   IS NULL OR v_ccsubsub   = " " OR
      v_ccssubsub  IS NULL OR v_ccssubsub  = " " OR
      v_ccsssubsub IS NULL OR v_ccsssubsub = " " OR
      v_sector     IS NULL OR v_sector     = " " THEN
      LET cod_ret = "110";
      RETURN cod_ret;
   END IF

-- ***************************************************************************
-- Inicia busqueda de cuenta del maestro contable
-- ***************************************************************************
   FOREACH
      SELECT COUNT(*) INTO v_cont FROM bdinteg:si_catalog
      WHERE ccmayor    = v_ccmayor
      AND   ccsub      = v_ccsub
      AND   ccsubsub   = v_ccsubsub
      AND   ccssubsub  = v_ccssubsub
      AND   ccsssubsub = v_ccsssubsub
      AND   sector     = v_sector
   END FOREACH;

   IF v_cont = 0 THEN
      LET cod_ret = "601";
   ELSE
      LET cod_ret = "000";
   END IF

   RETURN cod_ret;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".uniprod_qryb()
RETURNING CHAR(5);

DEFINE v_cod_ret CHAR(5);
DEFINE sql_err   INTEGER;
LET v_cod_ret = '00000';
LET sql_err   = 0;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_cod_ret = sql_err;
         RETURN v_cod_ret;
      END IF
   END EXCEPTION;

 	DROP TABLE axel;
END;

RETURN v_cod_ret;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".confirma_sp(pempresa char(3),
                                        p_rastreo char(16))
RETURNING char(5);

-- ************* Definicion de Variables ************************************

DEFINE v_codret char(5);
--DEFINE sql_err  integer;

-- **************************************************************************

LET v_codret = "000";

BEGIN
/*
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;
*/
-- ************************************************************************
/*
UPDATE bdispeua:sp_pagoenviar SET status_envio = " "
 WHERE clave_rastreo = p_rastreo;
*/
RETURN v_codret;

-- ***********************************************************************
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".spobtenfechasinteg()
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    VARCHAR(64),        -- DescripcionError
    DATE,               -- Fecha Hoy
    DATE,               -- Fecha Anterior
    DATE,               -- Fecha Proxima
    DATE,               -- Fecha inicio mes natural
    DATE,               -- Fecha inicio mes habil
    DATE,               -- Fecha fin mes natural
    DATE;               -- Fecha fin mes habil
        
-- ***************************************************************************
-- spObtFechasinteg
-- Version              1.0.0
-- Obejtivo:            Proporcionar fechas de si_fechas
--                      Operaciones Inusuales
-- Supuestos:           Ninguno
-- Valores de Entrada:  Ninguno
-- Valores de Regreso:  
--                      VARCHAR(5)          CodigoRetorno     
--                      VARCHAR(64)         DescripcionError  
--                      DATE                Fecha Hoy
--                      DATE                Fecha Anterior
--                      DATE                Fecha Proxima
--                      DATE                Fecha inicio mes natural
--                      DATE                Fecha inicio mes habil
--                      DATE                Fecha fin mes natural
--                      DATE                Fecha fin mes habil
-- Creado por:          Alejandro Rueda Sanchez   
-- ModIFicado por:      
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet              CHAR(5);

DEFINE dFechaHoy            DATE;
DEFINE dFechaAnt            DATE;
DEFINE dProxFecha           DATE;
DEFINE dPriDiaNaturalMes    DATE;
DEFINE dPriDiaHabilMes      DATE;
DEFINE dUltDiaNaturalMes    DATE;
DEFINE dUltDiaHabilMes      DATE;




BEGIN
    ON EXCEPTION 
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Obtiene fechas a partir del sistema Integral (Central de Bsi)
    SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes,
	pri_hab_mes, ult_dia_mes, ult_hab_mes
    INTO dFechaHoy, dFechaAnt, dProxFecha, dPriDiaNaturalMes,
    	dPrIDiaHabilMes, dUltDiaNaturalMes, dUltDiaHabilMes
    FROM bdinteg:si_fechas;

    IF  dFechaHoy = '' OR dFechaHoy IS NULL THEN
	LET cCodret ='224';
	LET cVarDataErr ='No hay fecha registrada para hoy';
        RETURN cCodret, cVarDataErr, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;        

    RETURN '000', '', dFechaHoy, dFechaAnt, dProxFecha, dPriDiaNaturalMes,
            dPriDiaHabilMes, dUltDiaNaturalMes,dUltDiaHabilMes;
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spobtentipocambio(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_tpcambio
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tpcambio = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spobtentipocambiohist(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_histdiv
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tc = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".ctefisicomel(pempresa CHAR(3),
                          pfuncion CHAR(1),
			  pnumcte CHAR(20),
			  psucursal CHAR(4))
  RETURNING CHAR(5),CHAR(20);

DEFINE vcodret CHAR(5);
DEFINE vtutor,vnumcte CHAR(20);
DEFINE vfecha DATE;
DEFINE vsignumcte INT;
DEFINE vtppersona CHAR(2);
DEFINE vexiste CHAR(1);
DEFINE vcont SMALLINT;
DEFINE vesfisica CHAR(1);
DEFINE vlongitud,vlong_cte SMALLINT;
DEFINE vsucursal CHAR(4);
define vdiferencia,i smallint;


LET vcodret = "000";
LET vnumcte = " ";
LET vsucursal = psucursal;


IF pnumcte IS NULL OR pnumcte = " " THEN
   SELECT valor
     INTO vlong_cte
     FROM si_param
    WHERE cod_param = 7
      AND empresa = pempresa;

   IF vlong_cte IS NULL THEN
      LET vcodret="105";
      RETURN vcodret,vnumcte;
   ELSE
      SELECT valor INTO vsignumcte
         FROM si_param
         WHERE empresa = pempresa and cod_param = 6;
      if vsignumcte is null then
         let vsignumcte = 1;
      end if
      LET vnumcte=vsignumcte;
      LET vsignumcte=vsignumcte + 1;
      UPDATE si_param
         SET (valor) = (vsignumcte)
         WHERE empresa = pempresa and cod_param = 6;
      let vdiferencia = vlong_cte - length(vnumcte);
      if vdiferencia > 0 then
         for i = 1 to vdiferencia
             let vnumcte = "0" || vnumcte;
         end for;
      end if
   END IF;
ELSE
   LET vnumcte = pnumcte;
END IF;
RETURN vcodret,vnumcte;
END PROCEDURE
DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".splvalfecha(pCodPais 	  CHAR(3),
			    		pPriDiaNaturalMes DATE,
					pDiasBloque       integer)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

-- ***************************************************************************
-- splvalfecha          
-- Version              1.0.0
-- Obejtivo:            Calcula la fecha del mes actual FechaIniMes + DiasBloque - 1
--                      donde Días bloque son número de días hábiles del mes
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;




BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque


    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
	LET dFechaActual = pPriDiaNaturalMes + j;
	LET siFeriado = 0;

	IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
           SELECT COUNT(*) 
	     INTO siFeriado       
	    FROM si_feriado
	    WHERE fecha = dFechaActual
	     AND pais = pCodPais and laborable = "N";
	   IF siFeriado IS NULL OR siFeriado = 0 THEN
	     LET i = i + 1;
	   END IF;
	END IF;
	LET j = j + 1;
    END WHILE


   RETURN '000',dFechaActual;
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".determina_lincred_tc(o_empresa CHAR(3),
                                      o_numsol  CHAR(20),
			              o_cte_nvo CHAR(1))


RETURNING CHAR(5), MONEY(14,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret          CHAR(3);
DEFINE vsqlerr           INTEGER;
DEFINE v_tasa            DECIMAL(9,6);
DEFINE v_factor	         CHAR(1);
DEFINE v_sobretasa       DECIMAL(9,6);
DEFINE v_porc_linea      DECIMAL(6,3);
DEFINE v_salariomin      DECIMAL(14,2);
DEFINE v_porcsalmin      DECIMAL(6,3);
DEFINE v_paramfactor     SMALLINT;
DEFINE v_ingreso         MONEY(14,2);
DEFINE v_situacion       DECIMAL(6,3);
DEFINE v_meseshist       SMALLINT;
DEFINE v_comproboingreso SMALLINT;
DEFINE v_porcpermitido   DECIMAL(6,3);
DEFINE v_mesespermitido  SMALLINT;
DEFINE v_capacidad       MONEY(14,2);
DEFINE v_linea      	 MONEY(14,2);
DEFINE v_factor_calc     DECIMAL(21,10);
DEFINE v_compromisos     MONEY(14,2);
DEFINE v_lintienda       MONEY(14,2);
DEFINE v_plazo		 SMALLINT;
DEFINE v_elevado         DECIMAL(21,6);
DEFINE v_moneypaso       MONEY(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_plazo      = 12;
LET v_linea      = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, v_linea;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- **************************************************
	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************
	SELECT valor INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_mesespermitido -- Meses de Historia base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

	IF v_mesespermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_salariomin -- Salario Minimo Base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 303;

	IF v_salariomin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************
	-- Extrae Porcentaje de ingresos del cliente *
	-- *******************************************
	IF o_cte_nvo = 1 THEN
	    LET v_paramfactor = 302; -- Cliente Nuevo
	ELSE
	    LET v_paramfactor = 301; -- Cliente No Nuevo
	END IF

	SELECT valor / 100 INTO v_porcsalmin
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = v_paramfactor;

	IF v_porcsalmin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************
        SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
	       linea_tienda
	  INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda
          FROM ss_resum_scor_fin
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

        IF v_ingreso IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_compromisos IS NULL THEN
		LET v_compromisos = 0;
        END IF

        IF v_situacion IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_meseshist IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_lintienda IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************

	SELECT COUNT(*) INTO v_comproboingreso
	  FROM ss_detalle_scoring
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND seccion = 2
	   AND grupo = 14
	   AND elemento = 1;

	IF v_comproboingreso IS NULL THEN
		LET v_comproboingreso = 0;
	END IF

        -- *************************************
        -- Extrae Tasa de interes del producto *
        -- *************************************

	SELECT valor, c.factor_sobretasa, c.sobretasa
	  INTO v_tasa, v_factor, v_sobretasa
	  FROM ss_solicitudes a, bdinteg:si_fechavalor b,
	       bdicred:sd_definicion c
	 WHERE a.empresa = o_empresa
	   AND a.num_solicitud = o_numsol
	   AND c.empresa = a.empresa
	   AND c.num_producto = a.num_producto
	   AND b.empresa = c.empresa
	   AND b.tasa = c.cod_tasa_base
           AND b.fecha = (select max(fecha) from bdinteg:si_fechavalor s
                          where s.tasa = c.cod_tasa_base);




        IF v_tasa IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	IF v_factor = "+" THEN
		LET v_tasa = v_tasa + v_sobretasa;
	ELIF v_factor = "-" THEN
		LET v_tasa = v_tasa - v_sobretasa;
	ELIF v_factor = "*" THEN
		LET v_tasa = v_tasa * v_sobretasa;
	ELSE
		LET v_tasa = v_tasa / v_sobretasa;
	END IF

        -- **********************************************************
        -- Extrae Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente			    *
        -- **********************************************************
	IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
		SELECT valor / 100 INTO v_porc_linea
		  FROM ss_param
		 WHERE empresa = o_empresa
		   AND secuencia = 304;
	ELSE

		IF  v_situacion >= v_porcpermitido
        	AND v_meseshist <= v_mesespermitido
        	AND v_comproboingreso = 1 THEN
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 305;
		ELSE
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 306;
		END IF
	END IF
        IF v_porc_linea IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- ************************************
	-- Inicia Proceso de Calculo de Linea *
	-- ************************************
	LET v_capacidad = ((v_ingreso * v_porcsalmin) - v_compromisos)
			  * v_porc_linea;

	LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_plazo*-1));
	LET v_factor_calc = 1-(v_factor_calc);
	LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo);

        -- **********************************************************
        -- Valida Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente                            *
        -- **********************************************************
        IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
                SELECT valor / 100 INTO v_porc_linea
                  FROM ss_param
                 WHERE empresa = o_empresa
                   AND secuencia = 304;

	        IF v_porc_linea IS NULL THEN
        	        LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	END IF

		LET v_moneypaso = v_linea * v_porc_linea;
		IF v_lintienda < v_moneypaso THEN
			LET v_linea = v_lintienda;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		ELSE
			LET v_linea = v_moneypaso;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		END IF
        ELSE
                IF  v_situacion >= v_porcpermitido
                AND v_meseshist <= v_mesespermitido
                AND v_comproboingreso = 1 THEN
                        SELECT valor / 100 INTO v_porc_linea
                          FROM ss_param
                         WHERE empresa = o_empresa
                           AND secuencia = 305;

        	     IF v_porc_linea IS NULL THEN
                	LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 4) THEN
                   	LET v_linea  = v_salariomin * 4;
                     ELSE
                        LET v_linea = v_linea * v_porc_linea;
                     END IF

                ELSE
                     SELECT valor / 100 INTO v_porc_linea
                       FROM ss_param
                      WHERE empresa = o_empresa
                        AND secuencia = 306;

                     IF v_porc_linea IS NULL THEN
                          LET scod_ret = "100";
                          RETURN scod_ret, v_linea;
                     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 2) THEN
                   	 LET v_linea  = v_salariomin * 2;
                     ELSE
                         LET v_linea = v_linea * v_porc_linea;
                     END IF
                END IF
        END IF


	LET v_linea = ROUND(v_linea,-1);

END
	RETURN scod_ret, v_linea;

END PROCEDURE
;