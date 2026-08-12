CREATE PROCEDURE "informix".sp_obtenerchequescce_pbas2(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

CREATE PROCEDURE "informix".sp_obtenerchequescce(pEmpresa CHAR(3),pBanco CHAR(3),pNumCta CHAR(20), pNumChq CHAR(7),pFormato CHAR(3), pFechaAlta DATE)
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(3),        -- BANCO
            CHAR(40),       -- DESCRIPCION BANCO           
			CHAR(20),		-- CUENTA
			CHAR(7),		-- NUMERO CHEQUE
			CHAR(1),   		-- LADO
			DATE,  		    -- FECHA ALTA
			DATE,			--FECHA PRESENTA
			CHAR(8);		--USUARIO ALTA
			
DEFINE iSqlErr       	INT;
DEFINE cCodret       	CHAR(5);  
DEFINE cBanco		 	CHAR(3);
DEFINE cDescripcion		CHAR(40);
DEFINE cNumcta		 	CHAR(20);
DEFINE cNumchq		 	CHAR(7);
DEFINE cLado 		 	CHAR(1);
DEFINE dFechaAlta	 	DATE;
DEFINE dFechaPresenta	DATE;
DEFINE cUsuarioAlta		CHAR(8);

LET cCodret			= '00000';  
LET cBanco			= '';
LET cDescripcion	= '';
LET cNumcta			= '';
LET cNumchq			= '';
LET cLado 			= '';
LET dFechaAlta		= '';
LET dFechaPresenta	= '';
LET cUsuarioAlta	= '';
LET iSqlErr         = 0;


BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta;   
        END IF;
   END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_ConsultarChequesDevueltos.out";
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pFechaAlta IS NULL OR pFechaAlta = '' THEN

	
		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE
			SELECT --{+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC, a.fecha_alta ASC 	

			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH

	ELSE 

		FOREACH

			--OBTIENE CHEQUES ORDENADOS POR BANCO Y NUMERO DE CHEQUE

			SELECT -- {+INDEX(bditef:cce_cheques_img idx_cce_cheques_img)}
				a.cvebanco,b.descripcion,a.numcuenta,a.numcheque,a.lado_ft,a.fecha_alta,a.fechapresenta,a.usuario_alta 
				INTO cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta
				FROM bditef:cce_cheques_img a, bdinteg:si_bancos b 
				WHERE empresa = pEmpresa
				AND a.cvebanco = b.banco
				AND a.cvebanco = CASE WHEN pBanco = '' THEN a.cvebanco ELSE pBanco END  
				AND a.numcuenta = CASE WHEN pNumCta = '' THEN a.numcuenta ELSE pNumCta END  
				AND a.numcheque = CASE WHEN pNumChq = '' THEN a.numcheque ELSE pNumChq END  
				AND a.imagen_formato = CASE WHEN pFormato = '' THEN a.imagen_formato ELSE pFormato END 
				AND a.fecha_alta = pFechaAlta 
				ORDER BY a.cvebanco ASC, a.numcheque::INTEGER ASC	
				
			RETURN  cCodRet,cBanco, cDescripcion, cNumcta, cNumchq, cLado , dFechaAlta, dFechaPresenta, cUsuarioAlta WITH RESUME;
		
		END FOREACH
	END IF;
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100305.0831';

create procedure "informix".cons_img_nula(pempresa       char(3),
                                          pcvebanco   	 char(3),
                                          pnumcuenta   	 char(20),
                                          pnumcheque   	 char(7),
                                          plado_ft       char(1),
                                          pfechapresenta char(10))
RETURNING char(5);  

    DEFINE v_codret char(5);
    DEFINE sql_err,isam_err int;   
    --DEFINE v_existe char(1);
	DEFINE iimagen  int;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  is null or
       pcvebanco      is null or
       pnumcuenta     is null or
       pnumcheque     is null or
       plado_ft       is null or
       pfechapresenta is null THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
    
    BEGIN

		on exception set sql_err,isam_err
			if sql_err <> 0 or isam_err <> 0 then
				let v_codret = sql_err;
				return v_codret;
			end if;
		end exception;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		select length(imagen::lvarchar) 
		INTO iimagen
		from "informix".cce_cheques_img
		 where empresa = pempresa
		   and cvebanco = pcvebanco
		   and numcuenta = pnumcuenta
		   and numcheque = pnumcheque
		   and lado_ft = plado_ft
		   and fechapresenta = pfechapresenta;

        IF iimagen is null or iimagen = '' THEN
            LET v_codret = 130; 
            RETURN v_codret;                 
        END IF;
    
    END;    

    RETURN v_codret;

END PROCEDURE;