CREATE PROCEDURE "informix".sp_cons_nominaempresas 
(	
	pSkip		INTEGER,
	pNumcte		CHAR (20),	
	pFecha		DATE
)
RETURNING
	CHAR (5)  AS cCodRet,
	CHAR (3)  AS codigo,
	CHAR (50) AS nombre,
	CHAR (20) AS numcte,
	SMALLINT  AS tipo_empresa,
	CHAR (50) AS acepta_producto,
	CHAR (20) AS cuenta,
	CHAR (1)  AS status_alta,
	DATE	  AS fecha_alta;
	
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet 		CHAR (5);
	DEFINE cCodigo 		CHAR (3);
	DEFINE cNombre  	CHAR (50);
	DEFINE cNumCte  	CHAR (20);
	DEFINE sTpo_Emp 	SMALLINT;
	DEFINE cAcepta_prod CHAR (50);
	DEFINE cCuenta		CHAR (20);
	DEFINE cStatus_alta CHAR (1);
	DEFINE dFecha_alta  DATE;
	
	LET iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET cCodigo 		= '000';
	LET cNombre  		= '';
	LET cNumCte  		= '';
	LET sTpo_Emp 		= 0;
	LET cAcepta_prod	= '';
	LET cCuenta			= '';
	LET cStatus_alta	= '';
	LET dFecha_alta 	= DATE (1);

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cCodigo, ''), NVL(cNombre, ''), NVL(cNumCte, ''), NVL(sTpo_Emp,0),
				NVL(cAcepta_prod,''), NVL(cCuenta,''), NVL(cStatus_alta,''), NVL(dFecha_alta, DATE(1));
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1479/sp_cons_nominaempresas.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3; 
		
		--CODIGO
		FOREACH
			SELECT SKIP pSkip LIMIT 11 codigo, nombre, numcte, tipo_empresa, acepta_producto, cuenta, status_alta, fecha_alta
			INTO cCodigo, cNombre, cNumCte, sTpo_Emp, cAcepta_prod, cCuenta, cStatus_alta, dFecha_alta
			FROM "informix".sc_nominaempresas
			WHERE codigo = codigo -- Para activar indices
			AND numcte = DECODE (NVL(pNumcte,''),'',numcte,NVL(pNumcte,''))
			AND fecha_alta =  DECODE (NVL(pFecha, DATE(1)),DATE(1),fecha_alta,NVL(pFecha, DATE(1)))
			ORDER BY codigo
		
			RETURN cCodRet,  NVL(cCodigo, ''), NVL(cNombre, ''), NVL(cNumCte, ''), NVL(sTpo_Emp,0),
				NVL(cAcepta_prod,''), NVL(cCuenta,''), NVL(cStatus_alta,''), NVL(dFecha_alta, DATE(1)) WITH RESUME;				
		END FOREACH;
		--VALIDA SI ENCONTRO INFORMACION
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '00001';
				RETURN cCodRet,  NVL(cCodigo, ''), NVL(cNombre, ''), NVL(cNumCte, ''), NVL(sTpo_Emp,0),
				NVL(cAcepta_prod,''), NVL(cCuenta,''), NVL(cStatus_alta,''), NVL(dFecha_alta, DATE(1));
		END IF;

							
	END;

END PROCEDURE	
DOCUMENT
'DESCRIPCION: Procedimiento que realiza una consulta en la tabla bdicheq:informix.sc_nominaempresas ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 06 de Enero del 2015',
'VERSION: 20150106.1300',
'BD: bdicheq',
'Folio: 1479 - ActAutTablaEmpresaSuc',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtmovsprestcoppel_esp(vFechaHoy DATE)
RETURNING CHAR(5);
      
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vFechaDes    CHAR(8);
    DEFINE vsql         CHAR(300);
    DEFINE vstmt        CHAR(200);
	DEFINE vmonto       MONEY(14,2);
	DEFINE vmonto_com   MONEY(14,2);
	DEFINE vmonto_iva   MONEY(14,2);
	DEFINE vcuantos     INTEGER;
	DEFINE vchar4       CHAR(4);
	DEFINE vdate        DATE;
	DEFINE vmoney       MONEY(14,2);
	DEFINE vcodret      char(5);
	DEFINE vIvaBase     DECIMAL(5,3);
    DEFINE vReferencia  CHAR(40);
	DEFINE vmonto_tot   MONEY(14,2);
	    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vFechaDes   = '';
    LET vsql        = '';
    LET vstmt       = '';
	LET vmonto      = 0;
	LET vmonto_com  = 0;
	LET vmonto_iva  = 0;
    LET vReferencia = 'PRESTAMOS COPPEL';
	LET vmonto_tot  = 0;
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsprestcoppel.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsprestcoppel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    SELECT valor 
	  INTO vIvaBase
      FROM bdinteg:si_param
     WHERE empresa = '001'
       AND cod_param = 47;

    IF vIvaBase IS NULL THEN
       LET vIvaBase = 0;
    END IF
 	 
	SELECT sum(monto_tot), count(*)
	  INTO vmonto, vcuantos
	  FROM sc_movhis
	 WHERE fech_alt = vFechaHoy
	   AND transacc = '0283'
	   AND cancelad <> 'S';
	   
	LET vmonto_com = vcuantos * 1.00;
	LET vmonto_iva = vmonto_com * vIvaBase;
    LET vmonto_tot = vmonto + vmonto_com + vmonto_iva;

	IF vmonto > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0270', '0000', '92536921230000', '16000000012', 0, vmonto_tot, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;
       
        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0263', '0000', '92536921230000', '16000000098', 0, vmonto_tot, vmonto_tot, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;
            
            IF vcodret = '000' THEN
                EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0305', '0000', '92536921230000', '16000000098', 0, vmonto, '01', vReferencia, ' ', ' ')
                INTO vcodret, vchar4, vdate, vmoney, vmoney;
                
                IF vcodret = '000' AND vmonto_com > 0 THEN
                    EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0306', '0000', '92536921230000', '16000000098', 0, vmonto_com, '01', vReferencia, ' ', ' ')
                    INTO vcodret, vchar4, vdate, vmoney, vmoney;
                    
                    IF vcodret = '000' AND vmonto_iva > 0  THEN
                        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0307', '0000', '92536921230000', '16000000098', 0, vmonto_iva, '01', vReferencia, ' ', ' ')
                        INTO vcodret, vchar4, vdate, vmoney, vmoney;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
	
	LET vFechaDes = TO_CHAR(vFechaHoy, '%d%m%Y'); 
     
    -- // DESCARGA DE ARCHIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' UNLOAD TO /resplogifx/conciliachq/prestamos_coppel_'||vFechaDes||'.txt '||
               ' SELECT sucursal, fech_alt, cuenta, monto_tot, transacc '||
               ' FROM sc_movhis '||
               ' WHERE fech_alt = '''||vFechaHoy||''' '||
               ' AND transacc = ''0283'' '||
               ' AND cancelad <> ''S'';" > /resplogifx/conciliachq/prestcopp.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/prestcopp.sql';
    SYSTEM vstmt;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;