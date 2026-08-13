CREATE PROCEDURE "informix".sp_cobra_com_oxxo(p_empresa CHAR(3), 
                                              p_cuenta  CHAR(20),
											  p_folio   CHAR(16))
    RETURNING   CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vCodRet          CHAR(5);
	DEFINE v_num_cte        CHAR(9);
	DEFINE v_exi_cte        INTEGER;
	DEFINE vValorIva        DECIMAL(9,6);
	DEFINE v_transacc       CHAR(4);
	DEFINE vTranCom         CHAR(4);
	DEFINE vCom_Ma_Iva      DECIMAL(14,2);
	DEFINE v_comision      DECIMAL(14,2);
	DEFINE vMontoIVA       DECIMAL(14,2);
	DEFINE v_comision_mas_iva DECIMAL (14,2);
	DEFINE v_sucursal    CHAR(4);
	DEFINE vUsuario      CHAR(8);
	DEFINE vHora         CHAR(12);
	DEFINE vFolio        CHAR(16);
	DEFINE vDivisa       CHAR(2);
	DEFINE vTranIva      CHAR(4);
	DEFINE vTranRet      CHAR(4);
	
	
	DEFINE v_ret1        CHAR(5);
    DEFINE v_ret2        CHAR(20);
    DEFINE v_ret3        CHAR(20);
    DEFINE v_ret4        CHAR(26);
    DEFINE v_ret5        CHAR(26);
    DEFINE v_ret6        CHAR(26);
    DEFINE v_ret7        CHAR(26);
    DEFINE v_ret8        CHAR(60);
    DEFINE v_ret9        CHAR(1);
    DEFINE v_ret10       MONEY(14,2);
    DEFINE v_ret11       MONEY(14,2);
    DEFINE v_ret12       MONEY(14,2);
    DEFINE v_ret13       MONEY(14,2);
    DEFINE v_ret14       MONEY(14,2);
    DEFINE v_ret15       CHAR(1);
    DEFINE v_ret16       CHAR(40);
    DEFINE v_ret17       CHAR(40); 
    DEFINE v_ret18       MONEY(14,2);
	DEFINE v_ret19       MONEY(14,2);
	DEFINE v_ret20       MONEY(14,2);
	DEFINE v_ret21       CHAR(8);
	DEFINE v_ret22       DATE;
	DEFINE v_ret23       CHAR(16);
	DEFINE v_ret24       CHAR(18);

		
	   		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vCodRet             = "00000";
	LET v_num_cte           = "";
	LET v_exi_cte           = 0;
	LET vValorIva           = 0;
	LET v_transacc          = 0;
	LET vTranCom            = '';
	LET vMontoIVA           = 0.00;
	LET v_comision_mas_iva  = 0.00;
	LET v_sucursal          = '';
	LET vUsuario            = 'informix';
	LET vHora               = '';
	LET vFolio         		= '';
	LET vDivisa             = '01';
	LET vTranIva            = '0260';
	LET vTranRet            = '';
	
	LET v_ret1         = "";
	LET v_ret2         = '';
	LET v_ret3         = '';
	LET v_ret4         ='';
	LET v_ret5         = '';
	LET v_ret6         = '';
	LET v_ret7         = '';
	LET v_ret8         = '';
	LET v_ret9         = '';
	LET v_ret10        = 0 ;
	LET v_ret11        = 0 ;
	LET v_ret12        = 0 ;
	LET v_ret13        = 0 ;
	LET v_ret14        = 0 ;
	LET v_ret15        = " ";
	LET v_ret16        = '';
	LET v_ret17        = "";
	LET v_ret18        = 0 ;
	LET v_ret19        = 0 ;
	LET v_ret20        = 0;
	LET v_ret21        = " ";
	LET v_ret22        = "";
	LET v_ret23        = '';
	LET v_ret24        = "";
	

	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobra_com_oxxo.err";
	 	    TRACE ON;
			LET vCodRet    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        RETURN vCodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/sp_cobra_com_oxxo.txt';
	--SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/oxxo/sp_cobra_com_oxxo.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
	
	--TRANSACCION 0507 EN PARAMETROS
	SELECT valor  
	INTO   v_transacc
	FROM   bdicheq:sc_param 
	WHERE  codparam = 'trancobcomoxxo';
	
	--TRANSACCION 0507 EN SC_TRANSACCION
	SELECT numero
	INTO   vTranCom
	FROM   bdinteg:si_transacc
	WHERE  numero = v_transacc
	AND    sistema = '01';
	
	--VALOR DEL MONTO COMISION IVA INCLUIDO
	SELECT valor  
	INTO   vCom_Ma_Iva
	FROM   bdicheq:sc_param 
	WHERE  codparam = 'montocomoxxo';
	
	IF vCom_Ma_Iva  = 0 THEN 
	   LET vCodRet  = '00001';
	   RETURN  vCodRet;
	END IF; 	
	
    -- VALOR IVA .16 
    SELECT valor 
    INTO   vValorIva 
    FROM   bdinteg:si_param
    WHERE  empresa = p_empresa
    AND    cod_param = 47;
    	
	-- TOTAL DE IVA
	LET vMontoIVA  = TRUNC(vCom_Ma_Iva * vValorIva,2);
	-- TOTAL DE COMISION 
	LET v_comision = vCom_Ma_Iva - vMontoIVA;
	-- TOTAL DE COMISION + IVA
	LET v_comision_mas_iva = v_comision + vMontoIVA;
	-- FOLIO DEL CARGO 
	LET vHora  = CURRENT HOUR TO FRACTION;
    LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
	
	LET vFolio = p_folio;
	
	--SE IDENTIFICA AL CLIENTE DE LA CUENTA A PROCESAR
	SELECT num_cte,   sucursal
    INTO   v_num_cte, v_sucursal
    FROM   bdicheq:"informix".sc_maechq
    WHERE  cuenta = p_cuenta;
	
	--SE VALIDA SI EL CLIENTE TIENE UN PRESTAMO PERSONAL VIGENTE
	SELECT COUNT(*)
	INTO   v_exi_cte 
	FROM   bdicred:sd_ppvigente
	WHERE  numcte =  v_num_cte;
	
	--IF  v_exi_cte  IS NULL OR v_exi_cte = "" THEN 
	IF  v_exi_cte  = 0 THEN 
	    
		EXECUTE PROCEDURE cons_sdos1(p_empresa,p_cuenta,'')
		INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
	
	    IF  v_ret10 >= v_comision_mas_iva THEN 
		
		    --SE REALIZA EL CARGO DE LA COMISION  
			CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranCom, "0000", vFolio, p_cuenta, 0, v_comision, vDivisa, "", "", "")
			RETURNING vCodRet, vTranRet;
			
			--SE REALIZA EL CARGO DEL IVA.                
			CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranIva, "0000", vFolio, p_cuenta, 0, vMontoIVA, vDivisa, "", "", "")
			RETURNING vCodRet, vTranRet;
			
			IF vCodRet = '000' THEN 
			   LET vCodRet = '00000';
			END IF; 			
			
		ELSE 
		LET vCodRet = '00002';
	    --RETURN  vCodRet;	
		END IF; 
		
	ELSE 
	
	    LET vCodRet = '00001';
	    --RETURN  vCodRet;
	END IF;
	
RETURN  vCodRet;
END; 
END PROCEDURE;