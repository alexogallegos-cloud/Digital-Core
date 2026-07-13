CREATE PROCEDURE "informix".cons_lista_negra(p_empresa        CHAR(3),
                                             p_numcte         CHAR(20))

  RETURNING CHAR(60),CHAR(3),CHAR(40),DATE,DECIMAL(18,2),CHAR(100),
         CHAR(5),CHAR(60);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cod_ret                       CHAR(5);
DEFINE sql_err                       INTEGER;
DEFINE isam_err                      INTEGER;
DEFINE error_info                    CHAR(40);
DEFINE P_NOMBRE                      LIKE BDINTEG:SI_CLIENTE.RAZON_SOCIAL;
DEFINE P_APELL_P                     LIKE BDINTEG:SI_CLIENTE.APELL_PATERNO;
DEFINE P_APELL_M                     LIKE BDINTEG:SI_CLIENTE.APELL_MATERNO;
DEFINE P_NOMBRE1                     LIKE BDINTEG:SI_CLIENTE.NOMBRE1;
DEFINE P_NOMBRE2                     LIKE BDINTEG:SI_CLIENTE.NOMBRE2;
DEFINE P_TPO_PERSONA                 LIKE BDINTEG:SI_CLIENTE.TPO_PERSONA;
DEFINE P_SUCURSAL                    LIKE BDINTEG:SI_SUCURSALES.SUCURSAL;
DEFINE P_NOMSUCURSAL                 LIKE BDINTEG:SI_SUCURSALES.NOMBRE;
DEFINE P_FEC_LNEGRA                  LIKE BDINTEG:SD_LISTANEGRA.FECHA_ALTA;
DEFINE P_MONTO                       LIKE BDINTEG:SD_LISTANEGRA.MONTO_ADEUDO;
DEFINE P_MOTIVO                      LIKE BDICRED:SD_LISTANEGRA.MOTIVO;
DEFINE P_COD_RET                     CHAR(5);
DEFINE P_MENSAJE                     CHAR(60);
DEFINE wes_fisica                    LIKE BDINTEG:SI_TIPPER.ES_FISICA;

ON EXCEPTION SET sql_err, isam_err, error_info
   LET cod_ret = sql_err;
   SET DEBUG FILE TO "cons_capitales.err";
   TRACE sql_err||" * "||isam_err|| " * "||error_info;
   ROLLBACK WORK;
   RETURN P_NOMBRE, P_SUCURSAL, P_NOMSUCURSAL, P_FEC_LNEGRA, P_MONTO,
          P_MOTIVO,cod_ret,P_MENSAJE;

END EXCEPTION;


-- **************************************************************************
-- verifica parametros de entrada
-- **************************************************************************

LET cod_ret                        = "000";
LET sql_err                        = 0;
LET isam_err                       = 0;
LET error_info                     = " ";
LET P_APELL_P                      = " ";
LET P_APELL_M                      = " ";
LET P_NOMBRE1                      = " ";
LET P_NOMBRE2                      = " ";
LET P_NOMBRE                       = " ";
LET P_TPO_PERSONA                  = " ";
LET P_SUCURSAL                     = " ";
LET P_NOMSUCURSAL                  = " ";
LET P_FEC_LNEGRA                   = " ";
LET P_MONTO                        = 0;
LET P_MOTIVO                       = " ";
LET P_COD_RET                      = "000";
LET P_MENSAJE                      = " ";
LET wes_fisica                     = " ";


IF P_NUMCTE IS NULL OR P_NUMCTE = ' ' THEN
   LET cod_ret = '1009';
   LET P_MENSAJE = 'NO SE ENCONTRO PRAMETRO OBLIGATORIO';
   RETURN P_NOMBRE, P_SUCURSAL, P_NOMSUCURSAL, P_FEC_LNEGRA, P_MONTO,
          P_MOTIVO,cod_ret,P_MENSAJE;
ELSE

    SELECT RAZON_SOCIAL,APELL_PATERNO,APELL_MATERNO,NOMBRE1,NOMBRE2,TPO_PERSONA,
           BDINTEG:SI_SUCURSALES.SUCURSAL,BDINTEG:SI_SUCURSALES.NOMBRE,
           BDICRED:SD_LISTANEGRA.FECHA_ALTA,BDICRED:SD_LISTANEGRA.MONTO_ADEUDO,
           BDICRED:SD_LISTANEGRA.MOTIVO
    INTO   P_NOMBRE, P_APELL_P, P_APELL_M, P_NOMBRE1, P_NOMBRE2, P_TPO_PERSONA,
           P_SUCURSAL, P_NOMSUCURSAL, P_FEC_LNEGRA, P_MONTO, P_MOTIVO
    FROM BDINTEG:SI_CLIENTE, BDINTEG:SI_SUCURSALES,
         BDICRED:SD_LISTANEGRA
   WHERE BDINTEG:SI_SUCURSALES.EMPRESA   = P_EMPRESA
   AND BDINTEG:SI_SUCURSALES.SUCURSAL  = BDINTEG:SI_CLIENTE.SUCURSAL
   AND BDICRED:SD_LISTANEGRA.EMPRESA = P_EMPRESA
   AND BDICRED:SD_LISTANEGRA.NUMCTE = BDINTEG:SI_CLIENTE.NUMCTE
   AND BDINTEG:SI_CLIENTE.NUMCTE    = P_NUMCTE;


   LET wes_fisica                     = " ";
   SELECT ES_FISICA INTO wes_fisica
   FROM BDINTEG:SI_TIPPER
   WHERE BDINTEG:SI_TIPPER.TPO_PERSONA = P_TPO_PERSONA;

   IF wes_fisica = "S" THEN
      LET P_NOMBRE = TRIM(P_APELL_P)|| ' ' || TRIM(P_APELL_M)|| ' ' || TRIM(P_NOMBRE1)|| ' ' || TRIM(P_NOMBRE2);
   END IF;

   IF P_FEC_LNEGRA IS NULL AND P_MONTO IS NULL AND P_MOTIVO IS NULL THEN
      LET cod_ret = '001';
      LET P_MENSAJE = 'EL CLIENTE NO EXISTE EN LA LISTA NEGRA';
      RETURN P_NOMBRE, P_SUCURSAL, P_NOMSUCURSAL, P_FEC_LNEGRA, P_MONTO,
             P_MOTIVO,cod_ret,P_MENSAJE;
   END IF;

END IF;

RETURN P_NOMBRE, P_SUCURSAL, P_NOMSUCURSAL, P_FEC_LNEGRA, P_MONTO,
       P_MOTIVO,cod_ret,P_MENSAJE;

END PROCEDURE;