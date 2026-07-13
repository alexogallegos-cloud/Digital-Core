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