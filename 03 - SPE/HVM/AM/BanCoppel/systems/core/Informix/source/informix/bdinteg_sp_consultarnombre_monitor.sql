CREATE PROCEDURE "informix".sp_consultarnombre_monitor(pEmpresa char (3), pNombre1 char(26), pNombre2 char(26), pApe_pat char (26),pApe_mat char(26), pRegistros SMALLINT)
    returning char (5) AS retorno, char (9) AS numcliente, char (26) AS nombre1, char (26) AS nombre2, char (26) AS apepaterno, char (26) AS apematerno, char (13) AS RFC;

   --Elaboró: Javier A. Chávez T.
   --Actividad: consulta los datos de un cliente por nombre
   --Solicito: Mauricio León
   --Fecha: 26-03-09

   --DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE vNomCte1 char (26);
    DEFINE vNomCte2 char (26);
    DEFINE vApe_pat char (26);
    DEFINE vApe_mat char (26);
    DEFINE vNumCte char (9);
    DEFINE vRfc char (13);

    --SET DEBUG FILE TO "/tmp/sp_consultanombre_monitoreo.out";
    -- TRACE ON;

    --Inicializa
    LET cod_ret  = "000";
    LET vNomCte1 = "";
    LET vNumCte = "0";
    LET vNomCte2 = "";
    LET vApe_pat = "";
    LET vApe_mat = "";
    LET vRfc = "";
    LET pNombre1 = UPPER(TRIM(pNombre1));
    LET pNombre2 = UPPER(TRIM(pNombre2));
    LET pApe_pat = UPPER(TRIM(pApe_pat));
    LET pApe_mat = UPPER(TRIM(pApe_mat));

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat,vRfc;
      END IF ;
   END EXCEPTION ;


   IF (pNombre1 <> "") THEN
        IF (pApe_pat <> "" or pApe_mat <> "") THEN

        {    IF(pNombre2 = '')THEN
                LET pNombre2 = NULL;
            END IF;

            IF(pApe_pat = '')THEN
                LET pApe_pat = NULL;
            END IF;

            IF(pApe_mat = '')THEN
                LET pApe_mat = NULL;
            END IF;}

            set lock mode to wait 3;
            SET ISOLATION DIRTY READ;

            let pNombre1 = trim(pNombre1)||"*";
            let pNombre2 = trim(pNombre2)||"*";
            let pApe_pat = trim(pApe_pat)||"*";
            let pApe_mat = trim(pApe_mat)||"*";

            FOREACH
                SELECT SKIP pRegistros FIRST 10 numcte, nombre1,nombre2,apell_paterno, apell_materno, rfc
                INTO vNumCte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc
                FROM bdinteg:si_cliente
                WHERE --razon_social is null and
                apell_paterno MATCHES pApe_pat
                AND apell_materno  MATCHES pApe_mat
                and nombre1 MATCHES pNombre1
                AND nombre2 MATCHES pNombre2                                
                AND empresa = pEmpresa
		AND tipo_cliente = '1'

                RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc WITH RESUME;

            END FOREACH;

         IF (vNomCte1 = "") THEN

          LET cod_ret = "001";
           RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;

          END IF;
        ELSE
         LET cod_ret = "003";
         RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;
        END IF;

    ELSE
        LET cod_ret = "002";
         RETURN cod_ret, vNumcte, vNomCte1, vNomCte2, vApe_pat, vApe_mat, vRfc;
   END IF;

 END;
END PROCEDURE;