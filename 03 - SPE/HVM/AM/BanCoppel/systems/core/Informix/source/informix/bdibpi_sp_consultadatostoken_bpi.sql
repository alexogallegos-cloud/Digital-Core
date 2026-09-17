CREATE PROCEDURE "informix".sp_consultadatostoken_bpi ( pEmpresa char(3), pIdUsuario char(11) )
RETURNING char(5), char(20), char(1), char(12), integer;

DEFINE cCodRet char(5);
DEFINE vsqlerr integer;
DEFINE cNumCliente char (20);	
DEFINE cTipo char(1);
DEFINE cNsToken char(12);
DEFINE iIdStatusToken integer;

LET cCodRet = '00000';
LET vsqlerr = 0;
LET cNumCliente = '';	
LET cTipo = '';
LET cNsToken = '';
LET iIdStatusToken = 0;

    BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET cCodRet = vsqlerr;
				RETURN cCodRet, cNumCliente, cTipo, cNsToken, iIdStatusToken;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        SELECT numcliente INTO cNumCliente  FROM bdibpi:"informix".bpi_usuario WHERE id_usuario=pIdUsuario;

        SELECT tk.tipo_token, tk.ns_token, tk.id_status_token 
        INTO cTipo, cNsToken, iIdStatusToken
        FROM bdinteg:"informix".si_bpiusuarios usu
		LEFT JOIN bdinteg:"informix".si_bpitoken tk ON tk.num_cliente = usu.numcte AND tk.empresa = pEmpresa
		WHERE usu.empresa = pEmpresa AND usu.numcte = cNumCliente;
		--validacion de token nueva bex
		
		  IF cTipo='1' then
			if  iIdStatusToken  in ('140','150','151','152') THEN
				LET cNsToken = cNstoken;
			else				
				let iIdStatusToken='140';
				let cTipo='2';
				let cNsToken='TMTTEMP99999';				
			End if;	
		
		ELIF cTipo='2'  then
				if iIdStatusToken ='140'  THEN
					LET cNsToken = 'TMT' || cNstoken;		
				else					
					let iIdStatusToken='140';
					let cTipo='2';	
					let cNsToken='TMTTEMP99999';					
				End if;										
		ELSE
			IF cTipo IS NULL OR cNsToken IS NULL OR iIdStatusToken IS NULL THEN
				let iIdStatusToken='140';
				let cTipo='2';
				let cNsToken='TMTTEMP99999';							
			END IF;
		END IF;						

     /* IF cTipo IS NULL OR cNsToken IS NULL OR iIdStatusToken IS NULL THEN
            LET cTipo = '0';
            LET cNsToken = '000000000000';
            LET iIdStatusToken = 0;
            LET cCodRet = '00001';
        END IF*/

        RETURN cCodRet, cNumCliente, cTipo, cNsToken, iIdStatusToken;
    END;
END PROCEDURE;