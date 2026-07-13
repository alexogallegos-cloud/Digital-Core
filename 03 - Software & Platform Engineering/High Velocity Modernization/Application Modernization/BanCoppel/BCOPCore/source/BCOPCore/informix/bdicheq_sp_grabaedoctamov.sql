CREATE PROCEDURE "informix".sp_grabaedoctamov(pEmpresa CHAR(3),
								   pUsuario CHAR(8),
								   pCuenta CHAR(20),
								   pFechaMov DATE,
								   pReferencia CHAR(40),
								   pDescripcion CHAR(50),
								   pRetiro DECIMAL(16, 2),
								   pDeposito DECIMAL(16, 2),
								   pSaldo DECIMAL(16, 2),
								   pGenerico_1 CHAR(50),
								   pGenerico_2 CHAR(50),
								   pGenerico_3 CHAR(50),
								   pGenerico_4 CHAR(50),
								   pGenerico_5 CHAR(50),
                                   pGenerico_6 CHAR(50),
								   iConsulMax INTEGER)

	RETURNING CHAR(6);

	DEFINE vCodRet CHAR(6);
	DEFINE iNumeroRegistro INTEGER;
	DEFINE vSqlErr, vIsamErr INTEGER;

	
	--set debug file to "/tmp/sp_grabaedoctamov.out";
    --trace on;


	LET vCodRet = "000";

	BEGIN
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;

				RETURN vCodRet;
			END IF;
		END EXCEPTION;
		
		SELECT MAX(secuencia)
		INTO iNumeroRegistro
		FROM vedoctamov
		WHERE empresa = pEmpresa AND cod_usuario = pUsuario;
		
		IF iNumeroRegistro IS NULL THEN
			LET iNumeroRegistro = 1;
		ELSE
			LET iNumeroRegistro = iNumeroRegistro + 1;
		END IF;
		
        INSERT INTO vedoctamov
            (empresa, cod_usuario, secuencia, cuenta, fechamov, referencia, descripcion, retiro, deposito, saldo,
            generico_1, generico_2, generico_3, generico_4, generico_5, generico_6, consulta)
        VALUES
            (pEmpresa, pUsuario, iNumeroRegistro, pCuenta, pFechaMov, pReferencia, pDescripcion, pRetiro, pDeposito, pSaldo,
            pGenerico_1, pGenerico_2, pGenerico_3, pGenerico_4, pGenerico_5, pGenerico_6, iConsulMax);

		RETURN vCodRet;
    END;
END PROCEDURE
DOCUMENT
'CAMBIO     : Hector Bojorquez',
'DESCRIPCION: Se modificó para que reciba el folio de la ultima consulta.',
'             Se quito delete del proceso para evitar tardanza en la respuesta',
'			  del sp, asi como tambien se modificó el insert de la tabla vedoctamov',
'             para que tambien se guarde el folio de la consulta recibido.',
'FECHA      : Junio 2010',
'VERSION    : 201006';

CREATE PROCEDURE "informix".act_datosfirmas(pempresa CHAR(3),
                                        pcuenta char(20),
					preg_firmas char(1))
RETURNING CHAR(5);

DEFINE vsqlerr INTEGER;
DEFINE vcodret        CHAR(5);
DEFINE vctaclabe      CHAR(18);
DEFINE psucursal      CHAR(4);
DEFINE pproducto      CHAR(4);
DEFINE pnum_cte       CHAR(20);
DEFINE pclase_cta     CHAR(1);
--DEFINE preg_firmas    CHAR(1);
DEFINE pejecutivo     CHAR(8);
DEFINE penvio_direcc  CHAR(1);
DEFINE pdirecc_envio  SMALLINT;
DEFINE pnofirmas      SMALLINT;
DEFINE vexiste        SMALLINT;
DEFINE vcombinacion   CHAR(100);
DEFINE vfecha_alta    CHAR(100);

begin
   on exception set vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END exception;

     --SET DEBUG FILE TO "/tmp/act_datosfirmas.out";
     --TRACE ON;


-- Inicializa variables
LET vcodret        = "000";
LET vctaclabe      = "";
LET psucursal      = "";
LET pproducto      = "";
LET pnum_cte       = "";
LET pclase_cta     = "";
--LET preg_firmas    = "";
LET pejecutivo     = "";
LET penvio_direcc  = "";
LET pdirecc_envio  = 0;
LET vexiste        = 0;
LET pnofirmas      = 0;
LET vcombinacion   = "";
LET vfecha_alta    = "";

-- Valida la informacion de entrada
   IF pempresa       = "" OR
      pcuenta      = ""  THEN
      LET vcodret = "110";
      RETURN vcodret;
   END IF;

   SELECT 1 INTO vexiste
      FROM sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
   IF vexiste IS NULL THEN
      LET vcodret = "405";
      RETURN vcodret;
   END IF;

let pempresa = pempresa;
let pcuenta = pcuenta;
let preg_firmas = preg_firmas;


   update bdicheq:sc_maenoc set reg_firmas = preg_firmas
    WHERE empresa = pempresa
      AND cuenta = pcuenta;


   RETURN vcodret;

END
END procedure
;