CREATE PROCEDURE "informix".altatardeb_n_web(pEmpresa CHAR(3), pCuenta CHAR(20), pNumTarjeta CHAR(20), pNumCte CHAR(20), pExpiracion DATE, pTipoTar CHAR(1), pNombre CHAR(104), 
pStatus CHAR(1), pLimiteAut MONEY(14, 2), pProducto CHAR(4), pTipoAsig CHAR(1), pCobroCom CHAR(1), pGerenteAut CHAR(8), pBanderaCobro SMALLINT, pBanderaBonificacion SMALLINT, 
pTotalCobro DECIMAL(18,2), pFechaInsert DATE)

--DATOS A REGRESAR--
RETURNING	CHAR(5) AS CodigoRetorno;

--DEFINICIÃN DE VARIABLES--
DEFINE cCodret		CHAR(5);
DEFINE iSiguiente	INTEGER;
DEFINE iExiste		INTEGER;
DEFINE iSqlerr		INTEGER;
DEFINE iExisTar		INTEGER;
DEFINE iLong		INTEGER;
DEFINE dIvaBase		DECIMAL(5,3);

DEFINE cCorreoCli  CHAR(100);
DEFINE iNumProd    INTEGER;
DEFINE cNomProd    CHAR(150);
DEFINE cCelularCli CHAR(13);
DEFINE cCodRetSp1  CHAR(5);
--INICIALIZACIÃN DE VARIABLES--
LET cCodret		= "";
LET iSiguiente	= 0;
LET iExiste		= 0;
LET iSqlerr		= 0;
LET iExisTar	= 0;
LET iLong		= 0;
LET dIvaBase	= 0;

LET cCorreoCli = '';
LET iNumProd = 0;
LET cNomProd ='';
LET cCelularCli ='';
LET cCodRetSp1  = '00000';
--SET DEBUG FILE TO "/tmp/altatardeb_n.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	LET cCodret = "00000";

	SELECT MAX(secuencia) + 1 INTO iSiguiente
	FROM bdicheq:"informix".sc_tarjeta
	WHERE empresa = pEmpresa AND cuenta = pCuenta;

	IF iSiguiente IS NULL THEN
		LET iSiguiente = 1;
	END IF;

	SELECT 1 INTO iExiste
	FROM bdicheq:"informix".sc_tarjeta
	WHERE empresa = pEmpresa AND num_tarjeta = pNumTarjeta;

	IF iExiste = 1 THEN
		LET cCodret = "00251";
	ELSE
		SELECT valor INTO iLong
		FROM bdicheq:"informix".sc_param
		WHERE empresa = '001' AND codparam = 'longcta';

		---Consulta el Valor del IVA 
		SELECT valor INTO dIvaBase
		FROM bdinteg:"informix".si_param
		WHERE empresa = pEmpresa
		AND cod_param = 47;
		
		LET dIvaBase = pTotalCobro * dIvaBase;
		
		-- se agraga validaciÃ³n para que la cuenta siempre sea de 11 digitos y tarjeta de 16
		IF LENGTH(pCuenta) = iLong AND LENGTH(pNumTarjeta) = 16 AND bdinteg:"informix".val_num(pCuenta) AND bdinteg:"informix".val_num(pNumTarjeta) THEN
			INSERT INTO bdicheq:"informix".sc_tarjeta
			(empresa, cuenta, secuencia, num_tarjeta, numcte, expiracion, tipo_tarjeta, status_tar, limite_aut,
			prodtarjeta, nombre, tipo_asignacion, cobro_comision, gerente_autoriza,bandera_cobro, bandera_bonificacion, cobro_tarjeta,iva_cobrotar,fecha_insert)
			VALUES(pEmpresa, pCuenta, iSiguiente, pNumTarjeta, pNumCte, pExpiracion, pTipoTar, pStatus, pLimiteAut,
			pProducto, pNombre, pTipoAsig, pCobroCom, pGerenteAut, pBanderaCobro, pBanderaBonificacion, pTotalCobro,dIvaBase,pFechaInsert);
			
			-- Se agrega asignaciÃ³n de numero de tarjeta en tabla maestra transfer
			UPDATE bditransfer:"informix".tf_maecte SET num_tarjeta = pNumTarjeta WHERE numcte = pNumCte AND cuenta_tf = TRIM(pCuenta);
				
				SELECT LIMIT 1 correo_elec --Obtiene el correo que es del cliente
				INTO cCorreoCli 
				FROM bdinteg:"informix".si_correos 
				WHERE numcte=pnumcte AND tipo_correo=1 AND status_correo='A';				
				/*SELECT LIMIT 1 nombre INTO cNomProd
				FROM bdicheq:"informix".sc_producto    --Obtiene el nombre del producto
				WHERE producto = pProducto;*/

				SELECT 'TARJETA '||descproducto INTO cNomProd 
				FROM intercard:productotarjeta a, intercard:tarjeta b ---Obtiene el nombre del producto
				WHERE a.codproductotarjeta= b.codproductotarjeta and b.numtarjeta=pNumTarjeta;
						
				
				
				IF NVL(cCorreoCli,'') <> '' THEN
				
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','MAIL_ACTTD',TRIM(pnumcte),'','','1','APERTURA',TRIM(cNomProd),
					'','','','','','','','',TRIM(cCorreoCli),'',1,0,0,0,0,'','')INTO cCodRetSp1;		
				ELSE
					SELECT LIMIT 1 telefono  --Obtiene el numero de celular del cliente
					INTO cCelularCli 
					FROM bdinteg:"informix".si_telefonos_actual 
					WHERE numcte = pnumcte	AND tipo_tel='2' AND status_tel='A'; 

					IF NVL(cCelularCli,'') <> '' THEN

						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_ACTTD',TRIM(pnumcte),'','','1','APERTURA',TRIM(cNomProd),'','','','','','','','',
						'',TRIM(cCelularCli),1,0,0,0,0,'','')INTO cCodRetSp1; -------- NOTIFICACION DE CUALQUIER PRODUCTO O SERVICIO (SMS)

					END IF;
				END IF;
			
		ELSE
			LET cCodret = "00131";
		END IF;
	END IF;

	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
"CREO  : Daniela RamÃ­rez",
"Se agregan tres parametros(pTipoAsig, pCobroCom, pGerenteAut) por alter a tabla sc_tarjeta",
"FECHA : 12/FEBRERO/2013",
"BD    : bdicheq";

CREATE PROCEDURE "informix".cons_cuentas_web(pempresa char(3), pnum_cte char(20))
   returning char(5),char(11),char(4),char(4),char(18);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE v_numcte char(9);
   DEFINE v_cuenta char(11);
   DEFINE v_producto char(4);
   DEFINE v_sucursal char(4);
   DEFINE v_cuenta_clabe char(18);
   DEFINE v_valor integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "00000";
   LET v_cuenta      = "";
   LET v_numcte      = "";
   LET v_cuenta      = "";
   LET v_producto    = "";
   LET v_sucursal    ="";
   LET v_cuenta_clabe ="";
   LET v_valor = 0;
BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
      end if
   end exception;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   select numcte into v_numcte from bdinteg:si_cliente
      where numcte = pnum_cte;
   if v_numcte is null then
      let cod_ret = "00104";
      return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe;
   end if

   select count(1)
         into v_valor
         from sc_maechq
        where empresa = pempresa and
               num_cte = pnum_cte and
               status_cta not in('2','6','7');
   
   IF v_valor > 0 THEN
   
   FOREACH
      select cuenta, producto, sucursal, cuenta_clabe
      into v_cuenta, v_producto, v_sucursal, v_cuenta_clabe
         from sc_maechq
         where empresa = pempresa and
               num_cte = pnum_cte and
               status_cta not in('2','6','7')
               order by cuenta
  
  			return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe WITH RESUME;
		
    END FOREACH
	ELSE
	let cod_ret       = "00001";
			return cod_ret,v_cuenta, v_producto, v_sucursal, v_cuenta_clabe WITH RESUME;
	END IF
END
END PROCEDURE;