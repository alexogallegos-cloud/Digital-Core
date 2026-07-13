CREATE PROCEDURE "informix".ctascarg(p_num_credito CHAR(20),
                          p_numcte      CHAR(20),
                          p_cta_abono   CHAR(20),
                          p_tipo_abo    CHAR(1),
                          p_cta_cargo   CHAR(20),
                          p_tipo_car    CHAR(1),
                          p_empresa     CHAR(3))
 RETURNING CHAR(5);

--Define Variables de Trabajo

DEFINE v_codret              LIKE bdinteg:si_codret.codigo_retorno;
DEFINE vm_num_credito        LIKE sd_maecred.num_credito;
DEFINE vm_num_cte            LIKE sd_maecred.numcte;
DEFINE mc_cuenta             LIKE bdicheq:sc_maechq.cuenta;
DEFINE mc_num_cte            LIKE bdicheq:sc_maechq.num_cte;
DEFINE vt_numero             LIKE sd_ctascarg.numero;
DEFINE vt_con_cap_inte       LIKE sd_ctascarg.con_cap_inte;
DEFINE vt_naturaleza         LIKE sd_ctascarg.naturaleza;
DEFINE vt_tipo_cta           LIKE sd_ctascarg.tipo_cta;
DEFINE vt_num_cta            LIKE sd_ctascarg.num_cta;
DEFINE vt_num_nomina         LIKE sd_ctascarg.num_nomina;
DEFINE i                     INTEGER;
DEFINE vt_num_credito        LIKE sd_maecred.num_credito;
DEFINE sqlerr                SMALLINT;
DEFINE isamerr               SMALLINT;
DEFINE text                  VARCHAR(255);
DEFINE v_divisa              char(2);
DEFINE v_divisa_che          char(2);
DEFINE v_divisa_aho          char(2);
DEFINE v_producto            char(4);
DEFINE v_plaza               char(3);

BEGIN
 ON EXCEPTION SET sqlerr
    LET v_codret = sqlerr;
    ROLLBACK WORK;
    BEGIN WORK;
    RETURN v_codret;
 END EXCEPTION;

--Inicializa Variables



LET vm_num_credito           = "  ";
LET vm_num_cte               = " ";
LET v_codret                 = "000";
LET vt_numero                = 0;
LET vt_con_cap_inte          = " ";
LET vt_naturaleza            = " ";
LET vt_tipo_cta              = " ";
LET vt_num_cta               = " ";
LET vt_num_nomina            = " ";
LET mc_cuenta                = " ";
LET mc_num_cte               = " ";
LET i                        = 0;
LET vt_num_credito           = " ";
let v_divisa                 = " ";
let v_divisa_che             = " ";
let v_divisa_aho             = " ";

--Validacion de los Datos
COMMIT WORK;
BEGIN WORK;

IF p_num_credito IS NULL OR p_num_credito = " " OR
   p_numcte      IS NULL OR p_numcte      = " " OR
   p_cta_abono   IS NULL OR p_cta_abono   = " " OR
   p_tipo_abo    IS NULL OR p_tipo_abo    = " " THEN
   LET v_codret = "076";
   ROLLBACK WORK;
   BEGIN WORK;
   RETURN v_codret;
END IF;

--Valida el Numero de Credito

  SELECT num_credito,numcte,divisa INTO vm_num_credito,vm_num_cte,v_divisa
  FROM sd_maecred
  WHERE num_credito = p_num_credito
  AND empresa       = p_empresa;

  IF vm_num_credito IS NULL OR vm_num_credito = "  " THEN
     LET v_codret = "100";
     ROLLBACK WORK;
     BEGIN WORK;
     RETURN v_codret;
  END IF

  SELECT MAX(numero) INTO vt_numero FROM sd_ctascarg
  WHERE empresa = p_empresa;

  IF vt_numero = 0 Or vt_numero IS NULL THEN
     LET vt_numero = 0;
  END IF;

--Valida el Numero de CUENTA

  IF p_tipo_abo = "2" THEN                       ---------Cheques

        let v_producto = " ";
        let v_plaza    = " ";
     SELECT cuenta,num_cte,producto,plaza INTO mc_cuenta,mc_num_cte,v_producto,v_plaza
       FROM bdicheq:sc_maechq
      WHERE bdicheq:sc_maechq.cuenta = p_cta_abono;

        let v_divisa_che = " ";
     SELECT tp_moneda INTO v_divisa_che
       FROM bdicheq:sc_producto
      WHERE bdicheq:sc_producto.codigo = v_producto
        and bdicheq:sc_producto.plaza  = v_plaza;

     IF v_divisa_che != v_divisa THEN
        LET v_codret = "337";
        ROLLBACK WORK;
        BEGIN WORK;
        RETURN v_codret;
     END IF;

--     IF mc_num_cte != p_numcte OR mc_num_cte IS NULL THEN
--        LET v_codret = "031";
--        RETURN v_codret;
--     END IF;

     IF mc_cuenta != p_cta_abono OR mc_cuenta IS NULL THEN
        LET v_codret = "101";
        ROLLBACK WORK;
        BEGIN WORK;
        RETURN v_codret;
     END IF;
  END IF;

  IF p_tipo_car = "2" THEN                       ---------Cheques

        let v_producto = " ";
     SELECT cuenta,num_cte,producto INTO mc_cuenta,mc_num_cte,v_producto
       FROM bdicheq:sc_maechq
      WHERE bdicheq:sc_maechq.cuenta = p_cta_cargo;

        let v_divisa_che = " ";
     SELECT tp_moneda INTO v_divisa_che
       FROM bdicheq:sc_producto
      WHERE bdicheq:sc_producto.codigo = v_producto
        and bdicheq:sc_producto.plaza  = v_plaza;

     IF v_divisa_che != v_divisa THEN
        LET v_codret = "337";
        ROLLBACK WORK;
        BEGIN WORK;
        RETURN v_codret;
     END IF;


 --    IF mc_num_cte != p_numcte OR
  --      mc_num_cte IS NULL THEN
   --     LET v_codret = "032";
   --     RETURN v_codret;
   --  END IF;

     IF mc_cuenta != p_cta_cargo OR
        mc_cuenta IS NULL THEN
        LET v_codret = "101";
        ROLLBACK WORK;
        BEGIN WORK;
        RETURN v_codret;
     END IF;

  END IF;        ---------Cheques


     --Rutina para la Insercion de los Registros

     FOR i = 1 to 2
         LET vt_numero = vt_numero + 1;

         IF i = 1 THEN
          --Verifica SI Existe el Numero de credito en la Tabla
            SELECT num_credito INTO vt_num_credito FROM sd_ctascarg
            WHERE num_credito = p_num_credito
            AND empresa = p_empresa
            AND naturaleza    = "C"
            AND con_cap_inte  = "C";

            IF vt_num_credito IS NULL THEN
                ---Inserta el Abono de Capital
                INSERT INTO sd_ctascarg
                VALUES(p_empresa,vt_numero,"C","C",p_num_credito,p_tipo_abo,
                       p_cta_abono," ");
            ELSE
               LET v_codret = "022";
            END IF;
         END IF;

         IF i = 2 THEN
            LET vt_num_credito = " ";
            --Verifica SI Existe el Numero de credito en la Tabla
            SELECT num_credito INTO vt_num_credito FROM sd_ctascarg
            WHERE num_credito = p_num_credito
            AND empresa  = p_empresa
            AND naturaleza    = "C"
            AND con_cap_inte  = "I";

            IF vt_num_credito IS NULL THEN
            --Inserta el Cargo de Capital
               INSERT INTO sd_ctascarg
               VALUES(p_empresa,vt_numero,"I","C",p_num_credito,p_tipo_car,p_cta_cargo,
                      " ");
             END IF;

         END IF;
         {IF i = 3 THEN
                LET vt_num_credito = " ";
                --Verifica SI Existe el Numero de credito en la Tabla
                SELECT num_credito INTO vt_num_credito FROM sd_ctascarg
                WHERE num_credito = p_num_credito
                AND naturaleza    = "C"
                AND con_cap_inte  = "I";

                IF vt_num_credito IS NULL THEN
                   ---Inserta el Cargo de Interes
                   INSERT INTO sd_ctascarg
                   VALUES(vt_numero,"I","C",p_num_credito,p_tipo_car,
                          p_cta_cargo," ");
                END IF;

         END IF;}

     END FOR;

END
  IF v_codret = "000" THEN
        COMMIT WORK;
  ELSE
        ROLLBACK WORK;
  END IF
  BEGIN WORK;
  RETURN v_codret;


END PROCEDURE
DOCUMENT
"AUTOR : Sergio Ruiz ",
"FECHA : 21/Junio/2003",
"Mod.  : ",
"BD.   : bdicred";

CREATE PROCEDURE "informix".crea_plazoniv(ax_montosol MONEY(18,2),
			       ax_montomen MONEY(18,2),
			       ax_tasa     MONEY(18,8))
RETURNING DECIMAL(18,2), INTEGER;

DEFINE V_FACTOR DECIMAL(18,2);
DEFINE V_ELEVADO DECIMAL(18,8);
DEFINE ax_valor CHAR(30);
DEFINE ax_cf DECIMAL(12,8);
DEFINE vsqlerr integer;
DEFINE lerr integer;

LET lerr = 0;
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET lerr = vsqlerr;
      LET V_FACTOR = 0;
      RETURN V_FACTOR,lerr;
   END IF;
END EXCEPTION;

LET V_FACTOR = 0;

let ax_montosol = ax_montosol;
let ax_montomen = ax_montomen;
let ax_tasa = ax_tasa;




    LET ax_cf = 12;
    LET ax_tasa = ((ax_tasa / 100) / (ax_cf)) ;
    LET V_ELEVADO = ax_tasa;
    LET V_FACTOR = (LOGN((ax_montomen) / ( ax_tasa * (-ax_montosol)+ax_montomen))) / (LOGN(1+ ax_tasa));

    LET V_FACTOR = ROUND(V_FACTOR);

	RETURN V_FACTOR, lerr;

END

END PROCEDURE;