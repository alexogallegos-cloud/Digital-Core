CREATE PROCEDURE "informix".altatardeb_n(pEmpresa CHAR(3), pCuenta CHAR(20), pNumTarjeta CHAR(20), pNumCte CHAR(20), pExpiracion DATE, pTipoTar CHAR(1), pNombre CHAR(104), 
pStatus CHAR(1), pLimiteAut MONEY(14, 2), pProducto CHAR(4), pTipoAsig CHAR(1), pCobroCom CHAR(1), pGerenteAut CHAR(8), pBanderaCobro SMALLINT, pBanderaBonificacion SMALLINT, 
pTotalCobro DECIMAL(18,2), pFechaInsert DATE)

--DATOS A REGRESAR--
RETURNING	CHAR(5) AS CodigoRetorno;

--DEFINICIÓN DE VARIABLES--
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
--INICIALIZACIÓN DE VARIABLES--
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

	LET cCodret = "000";

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
		LET cCodret = "251";
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
		
		-- se agraga validación para que la cuenta siempre sea de 11 digitos y tarjeta de 16
		IF LENGTH(pCuenta) = iLong AND LENGTH(pNumTarjeta) = 16 AND bdinteg:"informix".val_num(pCuenta) AND bdinteg:"informix".val_num(pNumTarjeta) THEN
			INSERT INTO bdicheq:"informix".sc_tarjeta
			(empresa, cuenta, secuencia, num_tarjeta, numcte, expiracion, tipo_tarjeta, status_tar, limite_aut,
			prodtarjeta, nombre, tipo_asignacion, cobro_comision, gerente_autoriza,bandera_cobro, bandera_bonificacion, cobro_tarjeta,iva_cobrotar,fecha_insert)
			VALUES(pEmpresa, pCuenta, iSiguiente, pNumTarjeta, pNumCte, pExpiracion, pTipoTar, pStatus, pLimiteAut,
			pProducto, pNombre, pTipoAsig, pCobroCom, pGerenteAut, pBanderaCobro, pBanderaBonificacion, pTotalCobro,dIvaBase,pFechaInsert);
			
			-- Se agrega asignación de numero de tarjeta en tabla maestra transfer
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
			LET cCodret = "131";
		END IF;
	END IF;

	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
"CREO  : Daniela Ramírez",
"Se agregan tres parametros(pTipoAsig, pCobroCom, pGerenteAut) por alter a tabla sc_tarjeta",
"FECHA : 12/FEBRERO/2013",
"BD    : bdicheq";

CREATE PROCEDURE "informix".sp_obtieneproemps ( pEmpresa CHAR (3), pNumcte CHAR(20), pMeses Char(3))

RETURNING CHAR(5),
	  DECIMAL;


DEFINE  cCodRet                 CHAR(5);
DEFINE  iSql_err                INTEGER;
DEFINE  vNumcta                 CHAR(20);
DEFINE  vTipoCta                CHAR(2);
DEFINE  vPromedio               DECIMAL;
DEFINE  vFecha                  DATE;

LET     cCodRet                 = '00000';
LET     iSql_err                = 0;
LET     vNumcta                 = '';
LET     vTipoCta                = '';
LET     vPromedio               = 0;
LET     vFecha                  = '';



BEGIN

    ON EXCEPTION SET iSql_err
    
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, vPromedio;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_obtieneproemps.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    IF NVL(pEmpresa,'') = '' OR NVL(pNumcte,'')='' THEN
       LET cCodRet = '00001';
       RETURN cCodRet,vPromedio;
    END IF;

    LET vFecha=today;
    LET vFecha=vFecha - 730;
    LET vFecha=vFecha;
    
    SELECT cuenta 
    INTO   vNumcta
    FROM  bdicheq:"informix".sc_maechq 
    WHERE num_cte= pNumcte
    AND   producto='1300'
    AND   status_cta='1';

	
   SELECT (sum(a) / pMeses) as promedio
   --SELECT (sum(a) / 36) as promedio
   INTO vPromedio 
   FROM ( SELECT sum(monto_tot) as A 
	  FROM bdicheq:"informix".sc_movhis 
          WHERE cuenta=vNumcta 
          AND transacc in ('0612','0216','0292','0285','0293','0287','0211')
          AND fech_alt BETWEEN vFecha  
          AND today 
          
          UNION
   
          SELECT sum(monto_tot) as A 
          FROM bdicheq:"informix".sc_movhis_old 
          WHERE cuenta=vNumcta 
          AND transacc in ('0612','0216','0292','0285','0293','0287','0211')
          AND fech_alt BETWEEN vFecha  
          AND today  
    
          UNION
  
          SELECT sum(monto_tot) as A 
          FROM bdicheq:"informix".sc_movhis_old2 
          WHERE cuenta=vNumcta 
          AND transacc in ('0612','0216','0292','0285','0293','0287','0211')
          AND fech_alt between vFecha  
          AND today  
  
          UNION
  
          SELECT sum(monto_tot) as A 
          FROM bdicheq:"informix".sc_movhis_old3 
          WHERE cuenta=vNumcta  
          AND transacc in ('0612','0216','0292','0285','0293','0287','0211') 
          AND fech_alt BETWEEN vFecha  
          AND today ); 
 
   RETURN cCodRet, vPromedio;


END;
END PROCEDURE
DOCUMENT
'Creado: EBH',
'Fecha: 05/08/2019',
'NOTA: Se Deja Spl preparado solo para obtener el promedio del salario de un empleado solo a 3 anios',
' Si se desea extender la antiguedad sera necesario adicionar las tablas movhis_old. ';

CREATE PROCEDURE "informix".sp_notificactasinactivas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
       
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
	DEFINE vSp_CodRet       CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasInformada   INTEGER;
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vProducto        CHAR(4);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vFechaUltimoDep  DATE;
    DEFINE vFechaUltimoRet  DATE;
    DEFINE vFechaAlta       DATE;
    DEFINE vFechaCompara    DATE;
    DEFINE vDiasSinTransacc INTEGER; 
    DEFINE vcodret          CHAR(5);	
    DEFINE vCodRet4         CHAR(5);
    DEFINE vCodRet5         CHAR(50);
	DEFINE vContador3       INTEGER;
	DEFINE vTermCta         CHAR(20);
	
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
	LET vSp_CodRet   = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc  = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
	
    LET vFechaHoy         = '';
    LET vDiasInformada    = 0;
    LET vCuenta           = '';   
    LET vNumCliente       = '';
    LET vStatusCta        = '';
    LET vProducto         = '';
    LET vSdoActual        = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vFechaCompara     = '';
    LET vDiasSinTransacc  = 0;
	LET vcodret           = '';
	LET vCodRet4 = ''; 
	LET vCodRet5 = '';  
	LET vContador3 = 0;
    LET vTermCta = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_notificactasinactivas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    ---SET DEBUG FILE TO "/resplogifx/conciliachq/sp_notificactasinactivas.out";
    ---TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS INFORMADAS
    SELECT valor::INT
      INTO vDiasInformada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaInformada';
    	
    --TABLE QUE TIENE LOS CLIENTES CON ESTATUS FALLECIDOS. 
	CREATE TEMP TABLE  tmp_fallecido( num_cte char(20))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_tmp_fallecido ON tmp_fallecido(num_cte) USING BTREE;
	
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_fallecido;
				
	INSERT INTO tmp_fallecido
	SELECT DISTINCT(numcte)  
	  FROM bdisitesp:se_ctessitespcte 
	 WHERE situacion = 'F' AND causa  IN('42','43');
	
    FOREACH WITH HOLD
        SELECT mae.cuenta, mae.num_cte, mae.status_cta, mae.producto, mae.sdo_actual, mae.fecultdep, mae.fecultret, noc.fecha_alta 
          INTO vCuenta, vNumCliente, vStatusCta, vProducto, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta 
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc
         WHERE mae.status_cta IN('1','4')
		   AND ( mae.producto <> '1100' AND mae.producto NOT LIKE '99%' )
           AND ( ( ( vFechaHoy - mae.fecultdep ) > vDiasInformada ) OR 
                 ( ( vFechaHoy - mae.fecultret ) > vDiasInformada ) OR 
                 ( fecultdep is null OR fecultdep = '' ) OR 
                 ( fecultret is null OR fecultret = '' ) )  
           AND noc.cuenta = mae.cuenta 
		   AND mae.sdo_actual >= 0.00 
		   AND mae.num_cte NOT IN(SELECT DISTINCT(num_cte) FROM tmp_fallecido )
	       AND mae.fecha_proceso = vFechaHoy 
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;    
        
        BEGIN WORK;
        LET vEnTransacc = 1;
        
        -- // OBTIENE FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        -- // MARCA LA CUENTA DEPENDIENDO LA INACTIVIDAD DE LA MISMA
        IF ( vDiasSinTransacc > vDiasInformada ) THEN
		    IF vSdoActual > 0 THEN 
                INSERT INTO bdicheq:"informix".sc_ctasinformadas 
                ( num_cte, producto, cuenta, status_cta, sdo_actual, fech_ult_dep, fech_ult_ret, fecha_marc )
                VALUES
                ( vNumCliente, vProducto, vCuenta, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaHoy );
      		      	   
			    LET vTermCta = TRIM(SUBSTR(vCuenta,8,4));
			      
                ---- REALIZA LA NOTIFICACION MENDIANTE CORREO ELECTRONICO			  
			    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CTAS_INAC','CTAS_INAC',vNumCliente,'','','2',vTermCta,'','','','','','','','','','','',1,'','','','',current,'')
                INTO vSp_CodRet;
			     
			    ---- REALIZA LA NOTIFICACION MENDIANTE SMS
			    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CTAS_INACS','CTAS_INACS',vNumCliente,'','','2',vTermCta,'','','','','','','','','','','',1,'','','','','','')  
			    INTO vSp_CodRet;
			END IF; 
			
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '5'
             WHERE cuenta = vCuenta;
		  
            LET vContador2 = vContador2 + 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        COMMIT WORK;
        LET vEnTransacc = 0;
    END FOREACH;
    
	DROP TABLE tmp_fallecido; 
	
	EXECUTE PROCEDURE  "informix".sp_cancelactasinactivas(pEmpresa)
    INTO vcodret,vCodRet4,vCodRet5,vContador3;
    
    END;
		
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
     
END PROCEDURE;