CREATE PROCEDURE  "informix".prepara_archivo(p_ruta char(100), 
                                             p_archivo char(50))
RETURNING CHAR(8);


DEFINE v_ejecuta CHAR(600);
DEFINE cod_ret   CHAR(8);
DEFINE sql_err   INTEGER;
DEFINE archivo   CHAR(80);
DEFINE baja      CHAR(80);

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
--       ROLLBACK WORK;
--       BEGIN WORK;
         RETURN cod_ret;
      END IF
   END EXCEPTION;



LET cod_ret = "000";

let v_ejecuta = "echo 'unload to "||trim(p_ruta)||
                "/spl/proveedor.txt select * from sq_reqprov' > "||
                trim(p_ruta)||"/spl/exporta2.sql";
SYSTEM v_ejecuta;

let v_ejecuta = "dbaccess bdicntchq " || trim(p_ruta) || "/spl/exporta2.sql";
SYSTEM v_ejecuta ;

let v_ejecuta ="cat " || trim(p_ruta) || 
               "/spl/proveedor.txt |sed 's/*/ /g' > temp";
SYSTEM v_ejecuta ;

let v_ejecuta ="cp temp " || trim(p_ruta) || "/spl/proveedor.txt";
SYSTEM v_ejecuta ;

let v_ejecuta =  "cat " || trim(p_ruta) || 
                 "/spl/proveedor.txt |sed 's/|//g' > temp";
SYSTEM v_ejecuta ;

let v_ejecuta = "cp temp " || trim(p_ruta) || "/spl/proveedor.txt";
SYSTEM v_ejecuta ;

LET v_ejecuta = "cp " || trim(p_ruta) || "/spl/proveedor.txt '"
               || trim(p_ruta) || "/archivos/" || TRIM(p_archivo) || "'";
SYSTEM v_ejecuta;


END
RETURN cod_ret;
END PROCEDURE;