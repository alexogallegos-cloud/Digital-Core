CREATE PROCEDURE "informix".connumclte(p_numero        CHAR(20))

    RETURNING CHAR(2),CHAR(3),CHAR(8),CHAR(2),CHAR(1),CHAR(15),CHAR(15),
              CHAR(15),CHAR(15),CHAR(60),CHAR(13),CHAR(2),CHAR(3),CHAR(3),
              CHAR(3),CHAR(3),CHAR(1),DATE,
              CHAR(40),CHAR(48),CHAR(20),DATE,DATE,
              DATE,CHAR(30),CHAR(3),CHAR(18),CHAR(2),CHAR(1),CHAR(3),CHAR(1),
              CHAR(45),CHAR(3),CHAR(20),CHAR(30),MONEY(18,2),CHAR(3),CHAR(60);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                      CHAR(5);
DEFINE sql_err                      INTEGER;
DEFINE isam_err                     INTEGER;
DEFINE error_info                   CHAR(40);
DEFINE v_status                     LIKE BDINTEG:SI_CLIENTE.STATUS_CTE;
DEFINE v_sucursal                   LIKE BDINTEG:SI_CLIENTE.SUCURSAL;
DEFINE v_ejecutivo                  LIKE BDINTEG:SI_CLIENTE.EJECUTIVO;
DEFINE v_tpo_persona                LIKE BDINTEG:SI_CLIENTE.TPO_PERSONA;
DEFINE v_tipo_cliente               LIKE BDINTEG:SI_CLIENTE.TIPO_CLIENTE;
DEFINE v_paterno                    LIKE BDINTEG:SI_CLIENTE.APELL_PATERNO;
DEFINE v_materno                    LIKE BDINTEG:SI_CLIENTE.APELL_MATERNO;
DEFINE v_nombre1                    LIKE BDINTEG:SI_CLIENTE.NOMBRE1;
DEFINE v_nombre2                    LIKE BDINTEG:SI_CLIENTE.NOMBRE2;
DEFINE v_razon_social               LIKE BDINTEG:SI_CLIENTE.RAZON_SOCIAL;
DEFINE v_rfc                        LIKE BDINTEG:SI_CLIENTE.RFC;
DEFINE v_sector                     LIKE BDINTEG:SI_CLIENTE.SECTOR;
DEFINE v_segmento                   LIKE BDINTEG:SI_CLIENTE.SEGMENTO;
DEFINE v_actividad                  LIKE BDINTEG:SI_CLIENTE.ACTIVIDAD_PRINC;
DEFINE v_grupo                      LIKE BDINTEG:SI_CLIENTE.GRUPO;
DEFINE v_subgrupo                   LIKE BDINTEG:SI_CLIENTE.SUBGRUPO;
DEFINE v_residencia                 LIKE BDINTEG:SI_CLIENTE.RESIDENCIA;
DEFINE v_fecha_alta                 LIKE BDINTEG:SI_CLIENTE.FECHA_ALTA;
DEFINE v_nombre_comercial           LIKE BDINTEG:SI_CTEPM.NOMBRE_COMERCIAL;
DEFINE v_nombre_titular             LIKE BDINTEG:SI_CTEPM.NOMBRE_TITULAR;
DEFINE v_giro                       LIKE BDINTEG:SI_CTEPM.GIRO;
DEFINE v_fecha_inscri               LIKE BDINTEG:SI_CTEPM.FECHA_INSCRIP;
DEFINE v_fecha_constit              LIKE BDINTEG:SI_CTEPM.FECHA_CONSTIT;
DEFINE v_fecha_nac                  LIKE BDINTEG:SI_CTEPF.FECHA_NAC;
DEFINE v_lugar_nac                  LIKE BDINTEG:SI_CTEPF.LUGAR_NAC;
DEFINE v_nacionalidad               LIKE BDINTEG:SI_CTEPF.NACIONALIDAD;
DEFINE v_no_fm3                     LIKE BDINTEG:SI_CTEPF.NO_FM3;
DEFINE v_estado_civil               LIKE BDINTEG:SI_CTEPF.ESTADO_CIVIL;
DEFINE v_reg_matrimonio             LIKE BDINTEG:SI_CTEPF.REGIM_MATRIMONIO;
DEFINE v_profesion                  LIKE BDINTEG:SI_CTEPF.PROFESION;
DEFINE v_sexo                       LIKE BDINTEG:SI_CTEPF.SEXO;
DEFINE v_nom_empresa                LIKE BDINTEG:SI_CTEPF.NOM_EMPRESA;
DEFINE v_antiguedad                 LIKE BDINTEG:SI_CTEPF.ANTIGUEDAD;
DEFINE v_nom_depto                  LIKE BDINTEG:SI_CTEPF.NOM_DEPTO;
DEFINE v_puesto                     LIKE BDINTEG:SI_CTEPF.PUESTO;
DEFINE v_ingreso_mensual            LIKE BDINTEG:SI_CTEPF.INGRESO_MENSUAL;
DEFINE v_codret                     CHAR(3);
DEFINE v_mensaje                    CHAR(60);
DEFINE v_esfisica                   CHAR(1);
DEFINE v_long_cte                   CHAR(2);     --NUMBER(6);
DEFINE v_longitud                   CHAR(2);     --number(6);
DEFINE v_numero                     CHAR(20);

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cierre.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN v_status, v_sucursal, v_ejecutivo, v_tpo_persona, v_tipo_cliente,
          v_paterno, v_materno, v_nombre1, v_nombre2, v_razon_social, v_rfc,
          v_sector, v_segmento, v_actividad, v_grupo, v_subgrupo, v_residencia,
          v_fecha_alta,
          v_nombre_comercial, v_nombre_titular, v_giro, v_fecha_inscri, v_fecha_constit,
          v_fecha_nac, v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, v_reg_matrimonio,
          v_profesion, v_sexo, v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto, v_ingreso_mensual,
          cod_ret, v_mensaje;
END EXCEPTION;


-- **************************************************************************
-- Inicializa Variables 
-- *********************a*****************************************************
LET cod_ret                        = "000";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET v_status                       = " ";
LET v_sucursal                     = " ";
LET v_ejecutivo                    = " ";
LET v_tpo_persona                  = " ";
LET v_tipo_cliente                 = " ";
LET v_paterno                      = " ";
LET v_materno                      = " ";
LET v_nombre1                      = " ";
LET v_nombre2                      = " ";
LET v_razon_social                 = " ";
LET v_rfc                          = " ";
LET v_sector                       = " ";
LET v_segmento                     = " ";
LET v_actividad                    = " ";
LET v_grupo                        = " ";
LET v_subgrupo                     = " ";
LET v_residencia                   = " ";
LET v_fecha_alta                   = " ";
LET v_nombre_comercial             = " ";
LET v_nombre_titular               = " ";
LET v_giro                         = " ";
LET v_fecha_inscri                 = " ";
LET v_fecha_constit                = " ";
LET v_fecha_nac                    = " ";
LET v_lugar_nac                    = " ";
LET v_nacionalidad                 = " ";
LET v_no_fm3                       = " ";
LET v_estado_civil                 = " ";
LET v_reg_matrimonio               = " ";
LET v_profesion                    = " ";
LET v_sexo                         = " ";
LET v_nom_empresa                  = " ";
LET v_antiguedad                   = " ";
LET v_nom_depto                    = " ";
LET v_puesto                       = " ";
LET v_ingreso_mensual              = 0;
LET v_codret                       = "000";
LET v_mensaje                      = " ";
LET v_esfisica                     = " ";
LET v_long_cte                     = " ";
LET v_longitud                     = " ";
LET v_numero                       = p_numero;


--SELECT longitud_cte INTO v_long_cte FROM bdinteg:si_param;

     SELECT status_cte		, sucursal		, ejecutivo
           , tpo_persona	, tipo_cliente		, apell_paterno
           , apell_materno	, nombre1		, nombre2
           , razon_social	, rfc			, sector
           , segmento		, actividad_princ	, grupo
           , subgrupo		, residencia		, fecha_alta
           , nombre_comercial	, nombre_titular	, giro
           , fecha_inscrip	, fecha_constit		, fecha_nac
           , lugar_nac		, nacionalidad		, no_fm3
           , estado_civil	, regim_matrimonio	, profesion
           , sexo		, nom_empresa		, antiguedad
           , nom_depto		, puesto		, ingreso_mensual
      INTO   v_status		, v_sucursal		, v_ejecutivo
           , v_tpo_persona	, v_tipo_cliente	, v_paterno
           , v_materno		, v_nombre1		, v_nombre2
           , v_razon_social	, v_rfc			, v_sector
           , v_segmento		, v_actividad		, v_grupo
           , v_subgrupo		, v_residencia		, v_fecha_alta
           , v_nombre_comercial	, v_nombre_titular	, v_giro
           , v_fecha_inscri	, v_fecha_constit	, v_fecha_nac
           , v_lugar_nac	, v_nacionalidad	, v_no_fm3
           , v_estado_civil	, v_reg_matrimonio	, v_profesion
           , v_sexo		, v_nom_empresa		, v_antiguedad
           , v_nom_depto	, v_puesto		, v_ingreso_mensual
      FROM  bdinteg:si_cliente
          , bdinteg:si_ctepf
          , bdinteg:si_ctepm
      WHERE si_cliente.numcte  = v_numero
      AND si_ctepf.numcte = bdinteg:si_cliente.numcte
      AND si_ctepm.numcte = bdinteg:si_cliente.numcte;


       IF v_tpo_persona = ' ' OR v_tpo_persona IS NULL THEN
          LET cod_ret = '800';
          --GOTO fin;
          RETURN v_status, v_sucursal, v_ejecutivo, v_tpo_persona, v_tipo_cliente,
                 v_paterno, v_materno, v_nombre1, v_nombre2, v_razon_social, v_rfc,
                 v_sector, v_segmento, v_actividad, v_grupo, v_subgrupo, v_residencia,
                 v_fecha_alta,
                 v_nombre_comercial, v_nombre_titular, v_giro, v_fecha_inscri, v_fecha_constit,
                 v_fecha_nac, v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, v_reg_matrimonio,
                 v_profesion, v_sexo, v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto, v_ingreso_mensual,
                 cod_ret, v_mensaje;
       ELSE
     
         SELECT es_fisica INTO v_esfisica FROM bdinteg:si_tipper
         WHERE tpo_persona = v_tpo_persona;
        
           IF v_esfisica <> 'S' THEN
              LET v_paterno = ' ';
              LET v_materno = ' ';
              LET v_nombre1 = ' ';
              LET v_nombre2 = ' ';
         
              SELECT regpub_comer INTO v_puesto
              FROM bdinteg:si_ctepm
              WHERE numcte = v_numero;
           
           ELSE
              LET v_giro = '';
              LET v_fecha_inscri  = '';
           END if;
        END if;

  RETURN v_status, v_sucursal, v_ejecutivo, v_tpo_persona, v_tipo_cliente,
         v_paterno, v_materno, v_nombre1, v_nombre2, v_razon_social, v_rfc,
         v_sector, v_segmento, v_actividad, v_grupo, v_subgrupo, v_residencia,
         v_fecha_alta,
         v_nombre_comercial, v_nombre_titular, v_giro, v_fecha_inscri, v_fecha_constit,
         v_fecha_nac, v_lugar_nac, v_nacionalidad, v_no_fm3, v_estado_civil, v_reg_matrimonio,
         v_profesion, v_sexo, v_nom_empresa, v_antiguedad, v_nom_depto, v_puesto, v_ingreso_mensual,
         cod_ret, v_mensaje;

END PROCEDURE
