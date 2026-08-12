CREATE PROCEDURE "informix".sp_segmentacion_lincred(pEmpresa  CHAR(3), 
													   pSolicitud CHAR(20), 
													   vLinCred DECIMAL(18,2))
															
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;			

DEFINE cod_ret     CHAR(5);
DEFINE vCont       SMALLINT;
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE cNumProd 	CHAR(3);
DEFINE pproducto 	CHAR(3);
DEFINE pNumTarjeta	CHAR(16);


LET cod_ret        = "00000";
LET vCont          = 0;
LET sql_err        = 0;
LET vMen           = "El proceso se ejecuto correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET pNumTarjeta    = 0;
LET cNumProd 	   = 0;
LET pproducto 	   = 0;

BEGIN
	
	ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
		IF sql_err != 0 THEN
			LET cod_ret = sql_err;
			LET vMen= cErrorInfo;
        RETURN cod_ret, vMen;	
		END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/sp_segmentacion_lincred.out';
--TRACE ON ;

IF (NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "") THEN
    LET cod_ret = "00001";
    LET vMen    = "Parametros insuficientes para realizar la consulta";
    RETURN cod_ret, vMen;
END IF;

			SELECT num_tarjeta
			  INTO pNumTarjeta
			  FROM bdicred:"informix".sd_tarjeta 	
			WHERE  empresa = '001'
			AND num_credito = pSolicitud
			AND status_tar = "A"
			AND tipo_tarjeta = "T";			
			
			SELECT	LIMIT 1 TRIM(num_prod)
			INTO	cNumProd
			FROM	"informix".sd_segmentos				
			WHERE	empresa= '001' 
			AND limite_max >= vLinCred 
			AND limite_min <= vLinCred;
		
		IF NVL(cNumProd,'') = '' THEN
			LET cod_ret= "00002";
			LET vMen = "No se encuentra rango establecido";
			RETURN cod_ret, vMen;
			
		ELSE	
		
			SELECT codproductotarjeta INTO pproducto FROM intercard:"informix".tarjeta 
			WHERE numtarjeta = pNumTarjeta;
			
			IF pproducto != cNumProd THEN
			
				UPDATE intercard:"informix".tarjeta
				SET	codproductotarjeta = cNumProd
				WHERE	numtarjeta = TRIM(pNumTarjeta);
			
			END IF;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cod_ret= "00003";
				LET vMen = "No se pudo actualizar codigo de producto";
				RETURN cod_ret, vMen;
			END IF				
		END IF
			
			
		RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar segmento Oro,Clasica,Infinite segun la línea de crédito',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 01/Abril/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_second_multi_ocurrence()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE vnumcuentaq                  CHAR(20);
define vcuenta 						integer;
define vfecha						char(6);

    --SET DEBUG FILE TO "/informix/Janeth_Peinado/Pruebas_shell/sp_depura_second.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET vnumcuentaq      = '';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';

	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
            
FOREACH WITH HOLD
	select DISTINCT(numcuentaq) 
	into vnumcuentaq
	from sd_progesive_01
		
	let vcuenta = 1;	
	
	FOREACH WITH HOLD
	select fecha
	into vfecha
	from sd_progesive_01 
	where numcuentaq = vnumcuentaq
	order by fecha desc
		
		if vcuenta <= 9 then
			let cMensaje = "0" || vcuenta;
		else
			let cMensaje = vcuenta;
		end if
		
		update sd_progesive_01 set progresive_counter_quitar=cMensaje,progresive_counter=cMensaje
		where numcuentaq = vnumcuentaq and
		fecha = vfecha;
	   
	   let vcuenta = vcuenta + 1;
	   
	 END FOREACH; 
	 
END FOREACH; 

     RETURN cCod_ret;
	END;
	
END PROCEDURE;