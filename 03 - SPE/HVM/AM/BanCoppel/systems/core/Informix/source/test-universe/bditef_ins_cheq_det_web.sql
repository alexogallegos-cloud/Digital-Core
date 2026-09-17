CREATE PROCEDURE "informix".ins_cheq_det_web(
                       pempresa         char(3),
                       pcvebanco   	char(3),
                       pnumcuenta   	char(20),
                       pnumcheque   	char(7), 
                       pfechapresenta   char(10),
                       pmonto   	decimal(14,2),
                       pbandamag	char(40), 
                       pcompensacion    char(3),
                       ptransaccion     char(2),
                       pcodseguridad    char(3),
                       pfechahoracap    char(25),
                       pdigverpre       char(1),
                       pdigverinter     char(1),
                       puser_insert     char(8),
                       pfecha_insert    char(10))
                       RETURNING char(5);  

   DEFINE v_codret char(5);
   DEFINE v_fechapre char(10);
   DEFINE v_existe char(1);
   DEFINE sql_err,isam_err int;   

	--set debug file to "/tmp/ins_cheq_det.out";
	--trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "00000";
   LET v_existe    = "0";

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  	pempresa    	is null or
			pcvebanco       is null or
			pnumcuenta      is null or
			pnumcheque      is null or
			pfechapresenta  is null or
			pmonto          is null or
			pbandamag       is null or
			pcompensacion   is null or 
	        ptransaccion    is null or 
	        pcodseguridad   is null or 
	        pdigverpre      is null or 
	        pdigverinter    is null or 
	        puser_insert    is null or 
        	pfecha_insert   is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = 00110; 
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

-- calcula la fecha correcta de presentacion

	call cal_fechapre(pempresa,pcvebanco,lpad(trim(pnumcuenta),20,"0"),
	     pnumcheque,TODAY)
	     returning v_codret,v_fechapre;
	
	LET v_codret = v_codret;
	
	IF trim(v_codret) <> "000" THEN
		RETURN v_codret;
	END IF;     	


	SELECT  "1"
    INTO    v_existe
    FROM    cce_cheques_det 
	WHERE   empresa = pempresa
    AND     cvebanco = pcvebanco
    AND     numcuenta = pnumcuenta
    AND     numcheque = pnumcheque
    AND     fechapresenta = v_fechapre;

	IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
	
		LET pbandamag = REPLACE(pbandamag, '|', ':');
		--LET pbandamag = REPLACE(pbandamag, ''\'', ':');
		
		-- ****************************************************************************
		-- insertar registro en cce_cheques_det con la fecha de presentacion correcta
		-- ****************************************************************************
		insert into cce_cheques_det (empresa,cvebanco,numcuenta,numcheque,
			fechapresenta,monto,bandamag,compensacion,transaccion,
			codseguridad,fechahoracap,digverpre,digverinter,presentado,
			usuario_alta,fecha_alta) 
		values (pempresa,pcvebanco,pnumcuenta,pnumcheque,
			v_fechapre,pmonto,pbandamag,pcompensacion,
			ptransaccion,pcodseguridad,pfechahoracap,
			pdigverpre,pdigverinter,"0",puser_insert,
			TODAY);
	END IF; 			


-- actualiza la imagen del cheque con la fecha de presentacion correcta
	update cce_cheques_img
	set fechapresenta = v_fechapre
	where empresa = pempresa
	and cvebanco = pcvebanco
	and numcuenta = pnumcuenta
	and numcheque = pnumcheque
	and fecha_alta = TODAY;
			

END;    

RETURN v_codret;
END PROCEDURE
DOCUMENT
'AUTOR ULTIMA MODIFICACION: DULCE KARELY RAMIREZ SANCHEZ',
'DESCRIPCION:  SE MODIFICA PARA QUE VALIDE SI EXISTE EL REGISTRO EN LA cce_cheques_det ANTES DE INTENTAR GUARDARLO',
'YA QUE ESTABA OCACIONANDO ERROR CUANDO EL PROCESO QUEDABA INCONCLUSO',
'FECHA : JUNIO 2010',
'BD    : BDITEF',
'VERSION: 20100611.1207';

CREATE PROCEDURE "informix".sp_obtiene_nombre_img_faltante
(
	pcEmpresa 		CHAR(3),
	pdFechaAlta		DATE
)

RETURNING
--DATOS A REGRESAR--
CHAR (5),
CHAR(60);   					--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE iSql_err 		INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE wBegin			CHAR(1);
DEFINE nombre_img		CHAR (60);

--INICIACION DE VARIABLES--
LET iSql_err 			=	0;
LET cCodRet 			=	'00000';
LET wBegin				=	'N';
LET nombre_img			=   '';

	--SET DEBUG FILE TO "/tmp/sp_valida_imagencheque.out";
	--TRACE ON;


	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				 RETURN cCodRet, nombre_img;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pcEmpresa,'') = '' OR  NVL(pdFechaAlta,"")="" THEN
			LET cCodRet = '00001';
			RETURN cCodRet, nombre_img;
		END IF
		
			FOREACH
			
					select a.cvebanco || RTRIM(RPAD(' ', 20 - LEN(a.numcuenta)) || a.numcuenta) ||
						   RTRIM(RPAD(' ', 7 - LEN(a.numcheque)) || a.numcheque) 
						   || a.lado_ft || a.usuario_alta || YEAR(a.fecha_alta) || MONTH(a.fecha_alta)|| DAY(a.fecha_alta)|| "." || a.imagen_formato as imagen
					  into nombre_img
					  from bditef:"informix".cce_cheques_img a
				inner join bditef:"informix".cce_cheques_det c on a.pcEmpresa = c.empresa
					   and a.cvebanco = c.cvebanco
					   and a.numcuenta = c.numcuenta
					   and a.numcheque = c.numcheque
					   and a.fecha_alta = c.fecha_alta
					 where a.empresa = pcEmpresa
					   and c.fecha_alta = pdFechaAlta
					   and a.imagen is null
					 union all
					select a.cvebanco || RTRIM(RPAD(' ', 20 - LEN(a.numcuenta)) || a.numcuenta) || 
						   RTRIM(RPAD(' ', 7 - LEN(a.numcheque)) || a.numcheque) 
						   || a.lado_ft || a.usuario_alta || YEAR(a.fecha_alta) || MONTH(a.fecha_alta)|| DAY(a.fecha_alta)|| "." || a.imagen_formato as imagen 
					  from bditef:cce_cheques_img a
					 where a.cvebanco = '137'
					   and a.fecha_alta = pdFechaAlta
					   and a.imagen is null
				  order by 1

				RETURN cCodRet,nombre_img WITH RESUME;	
								
			END FOREACH;
			
		
	END;

END PROCEDURE;