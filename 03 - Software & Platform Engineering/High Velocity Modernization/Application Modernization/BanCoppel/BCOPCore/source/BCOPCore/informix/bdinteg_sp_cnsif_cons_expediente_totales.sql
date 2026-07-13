CREATE PROCEDURE "informix".sp_cnsif_cons_expediente_totales(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20))
            
			RETURNING   CHAR(5)  AS Cod_Retorno,
						INTEGER  AS NumFilas;


DEFINE v_codret          CHAR(5);
DEFINE v_cuenta          CHAR(20);
DEFINE v_cve_prod        CHAR(4);
DEFINE v_prod_nombre     CHAR(40);
DEFINE v_cod_docto       CHAR(4);
DEFINE v_fecha_alta      DATE;
DEFINE v_cod_grupo       CHAR(3);
DEFINE v_descrip_gpo     CHAR(30);
DEFINE v_descrip_docto   CHAR(35);
DEFINE v_descrip2        CHAR(30);
DEFINE v_multi_img       CHAR(1);   
DEFINE v_secuencia       SMALLINT;
DEFINE iCont             SMALLINT;
DEFINE sql_err,isam_err,iexiste  INT;   
DEFINE v_SistemaC        CHAR(2);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE iNumFilas 		INTEGER;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

LET v_codret            = "000";
LET v_cuenta            = " ";
LET v_cve_prod          = " ";
LET v_prod_nombre       = " ";
LET v_cod_docto         = " ";        
LET v_fecha_alta        = today;
LET v_cod_grupo         = " ";
LET v_descrip_gpo       = " ";
LET v_descrip_docto     = " ";
LET v_descrip2          = " ";
LET v_multi_img         = " ";
LET v_secuencia         = 0;
LET iCont               = 0;
LET iexiste             = 0;  
LET v_SistemaC          ="";    
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET iNumFilas =0;

--SET debug FILE TO "/tmp/mfinis/sp_cnsif_cons_expediente_totales.out";
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET sql_err,isam_err
      IF sql_err <> 0 OR isam_err <> 0 THEN
			LET v_codret = sql_err;
		    UPDATE bdicnweb:"informix".sw_verificastatusexpediente
			SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
         RETURN v_codret,iNumFilas;
      END IF;
END EXCEPTION;


	--LIMPIA TABLAS
    DELETE FROM bdicnweb:"informix".sw_expedientetotales_tmp WHERE usuario_insert = TRIM(cID_USUARIOC);
	
	DELETE FROM bdicnweb:"informix".sw_verificastatusexpediente WHERE usuario_insert = TRIM(cID_USUARIOC);
	INSERT INTO bdicnweb:"informix".sw_verificastatusexpediente(usuario_insert,status,num_registros,error_proceso,error) VALUES(cID_USUARIOC,'I',0,'','00000');
		


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE  = ''	THEN
       -- datos de entrada incompletos    
			UPDATE bdicnweb:"informix".sw_verificastatusexpediente
			SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;	   
			LET v_codret = "00054";
       RETURN v_codret,iNumFilas;
    END IF;
  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'11','2')
	INTO
	v_codret;
	IF (v_codret != '00000')  THEN
		 UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		 SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;						
	END IF;
	-- TERMINA VALIDACION		
	
	
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCLIENTE) INTO v_codret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCLIENTE = cNumCtePrincipal;
	END IF;
	
	
	FOREACH
	SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE empresa = '001' AND  numcte = cNUMCLIENTE
	UNION
	SELECT NVL(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE empresa = '001' AND  numcte_tf = cNUMCLIENTE
	ORDER BY 1 desc
	END FOREACH;
	
	IF iexiste  = 0 THEN 
	LET v_codret = "00055";
		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
	RETURN v_codret,iNumFilas;	
	END IF;
 

-- ****************************************************************************
-- obtener registros
-- ****************************************************************************
	SELECT NVL(COUNT(cliente),0) INTO iexiste FROM bdidigital@coppelimg_crx:dg_expediente WHERE empresa = '001' AND  cliente = cNUMCLIENTE; 
	IF iexiste  = 0 THEN 
	LET v_codret = "00093";
	  UPDATE bdicnweb:"informix".sw_verificastatusexpediente
	  SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
	RETURN v_codret,iNumFilas;	
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    
	FOREACH

        SELECT  gd.cod_grupo, gd.descripcion, expe.cod_docto,td.descripcion,nvl(expe.descrip2," "),
                expe.secuencia, expe.cuenta,expe.producto , expe.prod_nombre, expe.fecha_alta
        INTO    v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,v_descrip2,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta
        FROM    bdidigital@coppelimg_crx:dg_expediente expe,
                bdidigital@coppelimg_crx:dg_grupodocto gd,
                bdidigital@coppelimg_crx:dg_tipodocumento td
        WHERE   expe.cod_docto       = td.cod_docto 
                and td.cod_grupo    = gd.cod_grupo 
                and expe.empresa     = '001'
                and expe.cliente     = cNUMCLIENTE 
                and expe.descrip2    <> 'firma_borra_da'
				and expe.cod_docto	<> '0219' 
        --ORDER BY 4,1,3
		
		
		IF v_cod_docto IN('0023','0024','0025') THEN
			LET v_descrip_docto = v_descrip2;
		END IF		


        SELECT NVL(COUNT(producto),0) INTO iexiste FROM bdicheq:sc_producto
        WHERE producto=v_cve_prod;
        IF iexiste>0 THEN 
            LET v_SistemaC='01';
        ELSE
            SELECT NVL(COUNT(num_producto),0) INTO iexiste FROM bdicred:sd_definicion
            WHERE num_producto=v_cve_prod;
            IF iexiste>0 THEN 
                LET v_SistemaC='06';
            ELSE
                SELECT NVL(COUNT(cod_instrum),0) INTO iexiste FROM bdinvers:sv_instrum
                WHERE cod_instrum=v_cve_prod;
                IF iexiste>0 THEN 
                    LET v_SistemaC='03';
                ELSE
                    LET v_SistemaC='00';
                END IF
            END IF;
       END IF;  
	   
		LET iNumFilas = iNumFilas +1;
                      
       INSERT INTO bdicnweb:"informix".sw_expedientetotales_tmp (cod_grupo, descrip_gpo, cod_docto, descrip_docto, secuencia, cuenta, cve_prod, prod_nombre, fecha_alta, sistemac, usuario_insert) 
        VALUES(v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC,cID_USUARIOC);
		
    END FOREACH;
	
	IF iNumFilas = 0 THEN
		LET v_codret = '1001'; 
		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;	
	END IF;

		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'T', error_proceso = 'N', num_registros = iNumFilas WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;

END    
END PROCEDURE
DOCUMENT
"AUTOR : Daniel Reyes Guillen",
"FUNCIONAMIENTO:Obtener la información de los Documentos del Expediente Digital del Cliente. Se agrega hilo. ",
"El SP obtendra la informacion de la Base de Datos central de Informix, enviando como parametro el  Numero  de cliente",
"FECHA : 05/05/2021",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_aut_aviso_terminos_cplpay(pEmpresa CHAR(3),pNumCte CHAR(20),pSucursal CHAR(4), pRespuesta CHAR(1),pCodigo_doc CHAR(20))
	RETURNING   CHAR(5)  AS codigo_retorno;	---cod_ret

	-- declara variables 
    DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(300);
	DEFINE cCodigoRespuesta		CHAR(1);
	DEFINE cCodigodoc		CHAR(20);

	
	
	DEFINE iSqlErr				INTEGER;
	
	-- inicia variables 
	LET cCodRet = '00000';
	LET cMensaje = '';
	LET cCodigoRespuesta = '';
	LET cCodigodoc = '';
	
	LET iSqlErr = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO "/home/sysifx/sp_aut_aviso_terminos_cplpay.out";
		--TRACE ON;	
		
		IF pEmpresa = '' OR  pNumCte = '' OR  pSucursal = '' OR pRespuesta  = '' OR pCodigo_doc  = '' THEN
			
			LET cCodRet = '00001';
		
		ELSE
		
			IF pRespuesta  = '1' THEN -- se acepta documento
			
				SELECT  msj_acepta,codigo_acepta,codigo_doc
				into cMensaje, cCodigoRespuesta, cCodigodoc
				FROM bdinteg:"informix".si_param_doc_cplpay
				WHERE empresa = pEmpresa
				AND codigo_doc = pCodigo_doc;
							
			ELSE
			
				LET cCodRet = '00001';				
				RETURN cCodRet;
			
			END IF;	
				
				
			INSERT INTO bdinteg:"informix".si_aut_aviso_terminos_cplpay(empresa,numcte,sucursal,respuesta,mensaje,codigo_doc,fecha)
			VALUES (pempresa,pnumcte,psucursal,cCodigoRespuesta,cMensaje,cCodigodoc,current);
			
			LET cCodRet = '00000';			
			
		END IF;		
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'Creador: 95451706 - Efrain Miranda Miranda',
'RQM: TDC Coppel Pay',
'Descripcion: El procedimiento se encarga de registrar si se acepta o no el aviso, terminos y condicions',
'Solicito: Citlali Guadalupe Dominguez Gomez',
'BD: BDINTEG';

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