CREATE PROCEDURE "informix".sp_consulta_param_doc_cplpay(pEmpresa CHAR(3),pTipoConsulta CHAR(1),pCodigo_doc CHAR(20))
	RETURNING   CHAR(5)  AS codigo_retorno,	       --- cod_ret
				CHAR(5)  AS codigo_documento,      --- codigo de documento
				CHAR(200)  AS valor,			   --- valor que se mostrara en pantalla
				CHAR(200)  AS comentario,	       --- descripcion
				CHAR(100)  AS nomdoc,			   --  nombre del documento
				CHAR(1)  AS docactivo;		       --  1= docuemtno activo, 0 = documento inactivo

	-- declara variables 
    DEFINE cCodRet              CHAR(5);
	DEFINE cCodigoDoc           CHAR(5);	
	DEFINE cValor				CHAR(200);	
	DEFINE cCmentarios			CHAR(200);	
	DEFINE cNomdoc				CHAR(100);	
	DEFINE cDocactivo			CHAR(1);	
	
	DEFINE iSqlErr				INTEGER;
	
	
	-- inicia variables 
	LET cCodRet = '00000';
	LET cCodigoDoc = '';
	LET cValor = '';
	LET cCmentarios = '';
	LET cNomdoc = '';
	LET cDocactivo = '';
	
	LET iSqlErr = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO "/home/sysifx/sp_consulta_param_doc_cplpay.out";
		--TRACE ON;	
		
		IF pEmpresa = '' OR  pTipoConsulta = '' THEN
			
			LET cCodRet = '00001';
			
		    RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
			
		ELIF  pTipoConsulta = '1' THEN
		--pTipoConsulta = 1 se usa para consultar todos los registros de la tabla		
			FOREACH
				SELECT codigo_doc,valor,comentarios , nomdoc, docactivo
				INTO cCodigoDoc, cValor , cCmentarios, cNomdoc, cDocactivo
				FROM bdinteg: "informix".si_param_doc_cplpay 
				WHERE empresa = pEmpresa
					AND docactivo = '1'
				ORDER BY codigo_doc
				
				RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo WITH RESUME;
			
			END FOREACH;
			
		ELIF  pTipoConsulta = '2' AND pCodigo_doc != '' THEN
		--pTipoConsulta = 2 se usa para consultar registro especifico la tabla	
		
			FOREACH
				SELECT codigo_doc,valor,comentarios , nomdoc, docactivo
				INTO cCodigoDoc, cValor , cCmentarios, cNomdoc, cDocactivo
				FROM bdinteg: "informix".si_param_doc_cplpay 
				WHERE empresa = pEmpresa
					AND codigo_doc = pCodigo_doc
					AND docactivo = '1'
				ORDER BY codigo_doc
				
				RETURN cCodRet,cCodigoDoc,cValor,cCmentarios, cNomdoc, cDocactivo WITH RESUME;
			
			END FOREACH;
		ELSE 
			
			LET cCodRet = '00001';
			
		    RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
			
		END IF;		   
	END;
END PROCEDURE
DOCUMENT
'Creador: 95451706 - Efrain Miranda Miranda',
'RQM: TDC Coppel Pay',
'Descripcion: El procedimiento se encarga de consultar los documentos que se deben aprobar',
'Solicito: Citlali Guadalupe Dominguez Gomez',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtclavetarjeta(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pOperacion CHAR(35))
   RETURNING CHAR(5), CHAR(6), CHAR(3), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cCodBin             CHAR(6);
   DEFINE cCodProdTar            CHAR(3);
   DEFINE cClave            CHAR(3);
     
   LET cCodRet        ='00000';   
   LET cCodBin        ='000000';
   LET cCodProdTar       ='000';
   LET cClave       ='000';
   
BEGIN
                ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cCodBin, cCodProdTar, cClave;
                      END IF;
                END EXCEPTION;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				IF pOperacion <> 'Solicitud de Tarjeta Personalizada' THEN
					SELECT b.bin, b.codproductotarjeta, clave  
					INTO cCodBin, cCodProdTar, cClave
					FROM intercard:binproducto a
					INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
					WHERE a.bin = pBin 
					AND a.producto= pSubBin 
					AND a.codprodcta = pCodProdCta
					AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);
				ELSE
					IF pCodProdCta NOT IN ('7000','8100') THEN
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin and descripcion LIKE 'PERSONALIZADO PREDISE%') ;
					ELSE
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);
					END IF;
				END IF;
        

           IF cCodBin IS NULL or cCodProdTar IS NULL OR cClave IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cCodBin, cCodProdTar, cClave;
END;
END PROCEDURE;