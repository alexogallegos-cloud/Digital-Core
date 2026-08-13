CREATE PROCEDURE "informix".sp_del_reg_edocta()
RETURNING 	CHAR(3) 	AS cod_ret,	CHAR(80)	AS desc_ret

	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cDescRet			CHAR(80);
DEFINE vabierto     	CHAR(1);
DEFINE vcontador   		INTEGER;
DEFINE vidreg			INTEGER;
	
	
---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000";
LET cDescRet			= "PROCESO EXITOSO";
LET vabierto   = '0';
LET vcontador = 0;
LET vidreg 	   = 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = '1' THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/jcgk/sp_del_reg_edocta.out';
	--TRACE ON;
	
	FOREACH WITH HOLD
	
		SELECT NVL(idreg, 0)
        INTO vidreg
        FROM "informix".sc_encabezado_edocta_factelect
		WHERE	 
		idreg >= '4918141'
		
		IF vcontador = 0 THEN
			BEGIN WORK;
			LET vabierto = '1'; 
		END IF
		
		--BORRADO DE ENCABEZADOS  
		DELETE "informix".sc_encabezado_edocta_factelect WHERE idreg = vidreg;
		
		--BORRADO DE ENCABEZADOS 2
		DELETE "informix".sc_encabezado2_edocta_factelect WHERE idreg = vidreg;
		
		--BORRADO DE DETALLES
		DELETE "informix".sc_detalle_edocta_factelect WHERE idreg = vidreg;
		
		--BORRADO DE MENSAJES
		DELETE "informix".sc_mensajes_edocta_factelect WHERE idreg = vidreg;
		
		--BORRADO DE PIES DE PAGINA
		DELETE "informix".sc_piepagina_edocta_factelect WHERE idreg = vidreg;
		
		--BORRADO DE GRAFICAS
		DELETE "informix".sc_grafica_fe WHERE id_reg = vidreg;
		
		--BORRADO DE ACLARACIONES
		DELETE "informix".sc_aclaraciones_edocta_factelect WHERE idreg = vidreg;

		LET vcontador = vcontador + 1;
		
		IF vcontador = 2000 THEN
			LET vabierto = '0';
			LET vcontador = 0;
			COMMIT WORK;
		END IF
		
	END FOREACH

	IF vcontador > 0 THEN
		COMMIT WORK;
	END IF	

	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para eliminar los registros generados para los estados de cuenta con idreg duplicado',
'BD: bdicheq', 
'AUTOR: José Carlos Guerrero Karass ',
'FECHA: Octubre 2015';

create procedure "informix".digver10(pcuenta char(15))
  returning char(5), char(1);

  define cod_ret char(5);
  define p		integer;
  define n1  	integer;
  define n2  	integer;
  define n  	integer;
  define i  	integer;
  define k  	integer;
  define vaux	char(2);
  define digito10	integer;
  

-- ********************************************************************
-- Inicializa variables
-- ********************************************************************
	let cod_ret = "000";
	let p		= 0;
	let n1  	= 0;
	let n2  	= 0;
	let n  		= 0;
	let i  		= 0;
	let k  		= 0;
	let vaux	= "";
	let digito10	= 0;

    If pcuenta = "" Then
        LET digito10 = 0;
    Else
        For i = 1 To length(TRIM(pcuenta))
            LET k = SUBSTR(pcuenta, i, 1);
            If MOD(i,2) = 0 Then
                LET p = 1;
            Else
                LET p = 2;
            End If
            LET vaux = LPAD(k * p, 2, "0");
            LET n1 = SUBSTR(vaux, 1, 1);
            LET n2 = SUBSTR(vaux, 2, 1);
            LET n = n + n1 + n2;
        end for
    End If
    If MOD(n,10) = 0 Then
        LET k = n;
    Else
        LET k = n - MOD(n,10) + 10;
    End If

	LET digito10 = k - n;
return cod_ret, digito10;
end procedure;