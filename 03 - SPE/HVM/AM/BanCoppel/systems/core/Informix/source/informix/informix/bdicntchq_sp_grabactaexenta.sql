CREATE PROCEDURE "informix".sp_grabactaexenta(pempresa    CHAR(3),
                                     pcuenta    CHAR(20),
                                     pexenta    CHAR(1),
                                     psucursal 	CHAR(4),
                                     pusuario  	CHAR(8),
                                     pcanal   	CHAR(2))

RETURNING CHAR(5),       -- Codigo de Retorno
	  DATE,      -- fecha registro
      DATE;      -- fecha baja


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE v_f_reg        DATE;
DEFINE v_f_baja       DATE;
DEFINE v_dia_gracia     SMALLINT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = '00000';
LET vsqlerr      = 0;
LET v_f_reg     = '01-01-1900';
LET v_f_baja   = '01-01-1900';
LET v_dia_gracia  = 0;

--SET DEBUG FILE TO "/tmp/sp_grabactaexenta.out";
--TRACE ON;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, v_f_reg, v_f_baja;
   END IF;
END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

 -- Valida Parametros de Entrada

  IF NVL(pempresa, '') = ''  OR NVL(pcuenta, '') = ''  OR NVL(pexenta, '') = ''  THEN
     LET scod_ret = '001';
     RETURN scod_ret, v_f_reg, v_f_baja;
  END IF

    SELECT valor 
    INTO v_dia_gracia
    FROM bdicntchq:sq_param
    WHERE cod_param = '24';
    
    IF NVL(v_dia_gracia, '') = '' THEN
        LET scod_ret = '002';
        RETURN scod_ret, v_f_reg, v_f_baja;
    END IF;

    LET v_f_reg     = TODAY;
    LET v_f_baja   = v_f_reg + v_dia_gracia;

    INSERT INTO bdicntchq:sq_ctaexenta(empresa, cuenta, fecha_rec, fecha_baja, exenta, sucursal, usuario, canal) 
      VALUES(pempresa, pcuenta, v_f_reg, v_f_baja, pexenta, psucursal, pusuario, pcanal);
    
    RETURN scod_ret, v_f_reg, v_f_baja;

END
END PROCEDURE
DOCUMENT
"Inserta la cuenta de cheques exenta de cancelar en periodo ordinario",
"Autor : Ismael Hernández",
"FECHA : Oct de 2010",
"Ver.  : 1.0",
"BD    : bdicntchq",
"PROYECTO  : Apertura Web";

CREATE PROCEDURE "informix".sp_concheques( pempresa char(3),
                                           pcuenta  char(20),
                                           pconsec  char(10),
                                           pnumcheq integer)

       returning     char(5),     -- vcodret
                     integer,     -- numero de cheque final
                     integer,     -- numero de cheque
                     char(1),     -- Cve Estatus
                     date,        -- Fecha de Movimiento
                     decimal(14,2), -- Importe
                     char(50);    -- Detalle de Estatus

   -- ********************************************************************
   --
   -- Nombre:              sp_concheques
   --
   -- Version              1.0.0
   -- Objetivo:            Consulta de cheques.........................
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- ModIFicado por:      Alejandro Rueda Sanchez
   -- ModIFicado por:      Mario Escobar --Lectra especifica y Secuencia por todos
   -- Ultima Modificacion: Octubre  - 2009
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************


   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vsqlerr         integer;
   DEFINE vcuenta         char(20);
   DEFINE vstatus         char(13);
   DEFINE vdetstatus      char(50);
   DEFINE vimporte        decimal(14,2);
   DEFINE vimp_2          decimal(14,2);
   DEFINE vfecha_mov      date;
   DEFINE vfecha_mov2     date;   
   DEFINE vnumero         integer;
   DEFINE vcuantos        integer;
   define vultcheq        integer;


   LET vcodret     = " ";
   LET vcuenta     = " ";
   LET vstatus     = " ";
   LET vdetstatus  = " ";
   LET vfecha_mov  = " ";
   LET vfecha_mov2 = " ";
   LET vnumero     = 0;
   LET vultcheq    = 0;
   LET vcuantos    = 0;
   LET vimporte = 0.00;
   LET vimp_2   = 0.00;

   --SET DEBUG FILE TO "/tmp/sp_concheques.out";
   --TRACE ON;

BEGIN
   on exception set vsqlerr
      IF vsqlerr <> 0 then
         LET vcodret = vsqlerr;
         return vcodret,0,0,"",null,0,
         vdetstatus;
      END IF;
   end exception;

   IF pnumcheq = 0 THEN
      FOREACH
          SELECT estado, fecha_alta, importe, numero
            INTO vstatus, vfecha_mov, vimporte, vnumero
            FROM bdicheq:sc_contch
           WHERE empresa = pempresa
             AND cuenta  = pcuenta
             AND consec = pconsec
   
          EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, pconsec, "")
                    INTO vcodret, vultcheq, vfecha_mov2, vimp_2,vcuantos;
   
          SELECT descripcion
            INTO vdetstatus
            FROM bdicntchq:sq_status_chequera
           WHERE clave = 2
             AND status = vstatus;
   
          return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;
      END FOREACH
   ELSE
      FOREACH
          SELECT estado, fecha_alta, importe, numero
            INTO vstatus, vfecha_mov, vimporte, vnumero
            FROM bdicheq:sc_contch
           WHERE empresa = pempresa
             AND cuenta  = pcuenta
             AND consec = pconsec
             AND numero = pnumcheq 
   
          EXECUTE PROCEDURE sp_ultimo_cheque(pempresa, pcuenta, pconsec, "")
                    INTO vcodret, vultcheq, vfecha_mov2, vimp_2,vcuantos;
   
          SELECT descripcion
            INTO vdetstatus
            FROM bdicntchq:sq_status_chequera
           WHERE clave = 2
             AND status = vstatus;
   
          return vcodret,vultcheq,vnumero,vstatus,vfecha_mov,vimporte,vdetstatus with resume;
      END FOREACH
   END IF;
END

END PROCEDURE;