CREATE PROCEDURE "informix".sp_reporte_tarjetas()
    RETURNING 	CHAR (06) as cod_ret, CHAR (80) AS mensaje;
			
--variables de retorno
	DEFINE cod_ret CHAR(06);
	DEFINE mensaje CHAR(80);
	
 --variables de control de errores
	DEFINE  SQL_ERR			INTEGER;
	DEFINE  ISAM_ERR		INTEGER;
	DEFINE  ERROR_INFO		VARCHAR(80);			
	DEFINE	vpaso			INTEGER;	
	
--variables de proceso

	DEFINE vcont 			INTEGER;
	
--variables para datos
	                                                          
	DEFINE vbin              	char(6);
	DEFINE vcodstatustarjeta 	varchar(3);
	DEFINE vcodstatusasignada	varchar(3);
	DEFINE vtipo             	char(1);
	DEFINE vfechaexp         	varchar(4);
	DEFINE vproducto         	char(1);
	DEFINE vmarca            	char(1);
	DEFINE vtitular          	char(1);
	DEFINE vcantidad         	INTEGER;
	DEFINE vfecha_ejecucion  	date;
	DEFINE vfecha_exp			char(04);
	DEFINE vfecha_exp_min		char(04);
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET cod_ret    = SQL_ERR;
      LET mensaje  = SQL_ERR || ' ' || ISAM_ERR ||' en paso '|| vpaso ||' '|| ERROR_INFO ;
      RETURN cod_ret, mensaje;
	END EXCEPTION;

	let cod_ret = '00000';
	let mensaje = 'PROCESO EXITOSO';
	
	let vcont  = 0;
		 
	let vpaso = 1;
	let vfecha_exp = lpad(substr( year(date(current)) ,3,2) ,2,'0' ) || lpad(month(date(current)),2,'0') ; 
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
        
    FOREACH CURSOR1 WITH HOLD FOR
        select distinct (b.bin),
            t.codstatustarjeta,
            t.codstatusasignada,
            ( CASE WHEN tipotar.chip = 'F' THEN 'B'
            WHEN tipotar.chip = 'V' THEN 'C'
            END ) as tipo,          
            t.fechaexp,
            b.creditodebito as producto,      
            ( CASE WHEN SUBSTR(b.bin,1,1) = 4 THEN 'V'
            WHEN SUBSTR(b.bin,1,1) = 5 THEN 'M' END) as marca,
            ( CASE WHEN t.titular = 'T' THEN 'T'
            WHEN t.titular = 'A' THEN 'A'
            ELSE 'N' END) as titular,      
            count(*) as cantidad,
            date(current) as fecha_ejecucion
        INTO 	vbin              
               , vcodstatustarjeta 
               , vcodstatusasignada
               , vtipo             
               , vfechaexp         
               , vproducto         							     
               , vmarca            
               , vtitular          
               , vcantidad 
               , vfecha_ejecucion					
        from intercard:bines as b, intercard:tarjeta as t, intercard:tipotarjeta as tipotar, intercard:lote as lt
            where b.bin = SUBSTR(t.numtarjeta,1,6)
            and t.fechaexp >= vfecha_exp
            and tipotar.clave_tipotarjeta=lt.clave_tipotarjeta   
            and t.numerolote=lt.numerolote
            group by 1,2,3,4,5,6,7,8
            order by 1,2,3,4,5,6,7,8
                    
            let vmarca = vmarca;
					 
            if vcont= 0 THEN
                
                BEGIN WORK;
                
            end IF
		
            let vpaso = 3;
            INSERT INTO reporte_tarjetas (bin, codstatustarjeta, codstatusasignada, tipo, fechaexp, producto, marca, titular, cantidad, fecha_ejecucion)
            VALUES( vbin, vcodstatustarjeta, vcodstatusasignada, vtipo, vfechaexp, vproducto, vmarca, vtitular, vcantidad, vfecha_ejecucion);

            let vcont = vcont + 1;      
    
            if vcont= 1000 THEN
					
                let vcont=0;            
                COMMIT WORK;
                
            end IF		
				
    END FOREACH;

    if vcont <> 0 THEN
            
            COMMIT WORK;
    end IF			
		
	  RETURN cod_ret, mensaje;	
END
END PROCEDURE
---Fecha de modificacion: 05 de septiembre del 2018.
---Se agregan las directivas SET ISOLATION Y SET LOCK MODE
---Este procedimiento almacenado es ejecutado mediante el job 377_REPORTE_TARJETAS_VISA_MASTERCARD_PRO
;

CREATE PROCEDURE "informix".sp_identifica_tipo_conciliacion_mc (
				psOriginalEncontrado CHAR(5),	--intercard:movimiento
				psConsecutivo INTEGER,
				psNumtarjeta CHAR(16),			--bditarjeta:td_movimientos_conciliacion
				psSecuencia325 CHAR(6),			--bditarjeta:td_movimientos_conciliacion
				psMovconciliado CHAR(1),		--intercard:movimiento
				pmMontointercard MONEY,		    --intercard:movimiento resultado de busca movimiento intercard
				pmMontointercardCashback MONEY, --intercard:movimiento resultado de busca movimiento intercard
				psMonto325 CHAR(13),			--bditarjeta:td_movimientos_conciliacion  Monto325
				psMontoCashback325 CHAR(13),    --bditarjeta:td_movimientos_conciliacion  MontoCashBack325
				pmSumaMonto325 MONEY,			--bditarjeta:td_movimientos_conciliacion  Suma de monto325
				pmSumaMontoCashback325 MONEY,	--bditarjeta:td_movimientos_conciliacion  Suma de montocashback325
				psTipotransaccion325 CHAR(15),  --bditarjeta:td_movimientos_conciliacion
				psConciliacionArchivo CHAR(1),	--bditarjeta:td_archivo_origen
				psConciliacion CHAR(1),   		--bditarjeta:td_movimientos_conciliacion
				psSecuenciaorig CHAR(7),		--intercard:movimiento
				psSecuencia_extendida CHAR(15),	--intercard:movimiento
				pdFechatransaccion DATETIME YEAR TO FRACTION(5), 	--intercard:movimiento
				psInfreceptor CHAR(40),			--intercard:movimiento
				psIdterminal CHAR(16),			--intercard:movimiento
				psMetodocaptura CHAR(2),		--intercard:movimiento
				psMovreversado CHAR(1),			--intercard:movimiento
				psCodigoiso CHAR(2),			--intercard:movimiento
				psFormato CHAR(4),				--intercard:movimiento	
				piTipo_LayOut INTEGER,			--BdiTarjeta:Td_Archivo_OrigenTmp 
				psISO323 CHAR(2),				--BdiTarjeta:Td_Movimientos_Conciliacion
				psMovRev325 CHAR(1),			--BdiTarjeta:Td_Movimientos_Conciliacion
				psCodReversa CHAR(1),			--Intercard:Movimiento
				psCodigoCentral CHAR(5),		--Intercard:Movimiento
				psfolio_reg CHAR(16)			--Se genera folio regulatorio
)

	RETURNING CHAR(5) AS Retorno,
	CHAR(1) AS Conciliacion,
	CHAR(7) AS Secuencia,
	CHAR(15) AS Secuencia_extendida,
	MONEY AS Montointercard,
	MONEY AS Montointercardcashback, -- Se agrega por integracion de Cash Back
	DATETIME YEAR TO FRACTION(5) AS FechaTransaccion,
	CHAR(40) AS Infreceptor,
	CHAR(16) AS Idterminal,
	CHAR(2) AS Metodocaptura,
	CHAR(1) AS Movconciliado,
	CHAR(1) AS Movreversado,
	CHAR(1) AS Tipo_mov,
	CHAR(16) AS Folio_mov,
	DATETIME YEAR TO FRACTION(5) AS Fechaconcilia,
	INTEGER AS Tipo_conciliacion,
	CHAR(60) AS Desc_conciliacion,
	CHAR(250) AS ErrorActividad;

	/*
	-- DESCRIPCION:  IDENTIFICA EL TIPO DE CONCILIACION  ------------------------------------------------
	-- AUTOR : Victoria Quiñones  -----------------------------------------------------------------------
	-- FECHA : 12/06/2018  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Conciliacion automatica de MASTER - OXXO / Validacion de Integridad  -------------------
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE ERRORES*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsErrorActividad CHAR(250);
	DEFINE vsCodRetFecha CHAR(5);
	DEFINE vsFechaHora CHAR(8);
	DEFINE vmMonto325 MONEY;
	DEFINE vmMontoCashBack325 MONEY;

	/*VARIABLES DE RETORNO*/
	DEFINE vsConciliacion CHAR(1);
	DEFINE vdFechaTransaccion DATETIME YEAR TO FRACTION (5);
	DEFINE vsMovconciliado CHAR(1);
	DEFINE vsTipo_mov CHAR(1);
	DEFINE vsFolio_mov CHAR(16);
	DEFINE vdFechaconcilia DATETIME YEAR TO FRACTION (5);
	DEFINE viTipo_Conciliacion INTEGER;
	DEFINE vsDesc_conciliacion CHAR(60);
	
	/*VARIABLES DE ENTORNO*/
	DEFINE StatusTarjeta VARCHAR (3);
	DEFINE numcredito VARCHAR(13);
	DEFINE statuscred CHAR(2);
	DEFINE vsmensaje char(20);

	--SET DEBUG FILE TO "/informix/LVRQ/CNC_MC_OXXO/NvoDev/dev/TraceIDENTIFICATIPO.out";
	--TRACE ON;
	
	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000' ;
	LET vsErrorActividad = '';
	LET vsCodRetFecha='';
	LET vsFechaHora = '';

	/*VARIABLES DE RETORNO*/
	LET vsConciliacion = 'V';  -- PARA TODOS
	LET psSecuenciaorig = NVL(psSecuenciaorig,'');
	LET psSecuencia_extendida = NVL(psSecuencia_extendida,'');
	LET vmMonto325 = psMonto325;
	LET vmMontoCashBack325 = ( ( REPLACE( psMontoCashback325,'.',''))::MONEY /100 ); -- Para integracion de CashBack
	LET pmMontointercard = NVL(pmMontointercard,'');
	LET pmMontointercardCashback = NVL (pmMontointercardCashback,'');
	LET vdFechaTransaccion = NVL(pdFechatransaccion,  CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5)));
	LET psInfreceptor = NVL(psInfreceptor,'');
	LET psIdterminal = NVL(psIdterminal,'');
	LET psMetodocaptura = NVL(psMetodocaptura,'');
	LET vsMovconciliado = NVL(psMovconciliado,'');
	LET psMovreversado = NVL(psMovreversado,'');
	LET vsTipo_mov = '';
	LET vsFolio_mov = '';
	LET vdFechaconcilia = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET viTipo_Conciliacion = 0;
	LET vsDesc_conciliacion = '';
	LET psTipotransaccion325 = TRIM(NVL(psTipotransaccion325,''));

	/*VARIABLES DE ENTORNO*/
	LET StatusTarjeta = '';
	LET numcredito = '';
	LET statuscred = '';
	
	let vsmensaje = '';

	BEGIN

		ON EXCEPTION SET visqlerr   --CACHA EL ERROR EN CASO DE QUE EXISTA Y REGRESA UN VALOR PREDETERMINADO

				LET vssqlerr = visqlerr;
				RETURN vssqlerr,
					NVL(vsConciliacion,''),
					NVL(psSecuenciaorig,''),
					NVL(psSecuencia_extendida,''),
					NVL(pmMontointercard,0),
					NVL(pmMontointercardCashback,0),
					NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(psInfreceptor,''),
					NVL(psIdterminal,''),
					NVL(psMetodocaptura,''),
					NVL(vsMovconciliado,''),
					NVL(psMovreversado,''),
					NVL(vsTipo_mov,''),
					NVL(vsFolio_mov,''),
					NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(viTipo_Conciliacion,0),
					NVL(vsDesc_conciliacion,''),
					NVL(vsErrorActividad,'');

		END EXCEPTION;



		--------REINGENIERIA-CONCILIACION-AUTOMATICA---------
		--------2012/06/25-MGTI-HECTOR CASANOVA------------------


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		LET vsConciliacion = 'V'; --TODOS V 
		LET vdFechaconcilia = CURRENT;
		
		--SE REQUIERE SOLO UNA VEZ POR EJECUCION
		
		LET viTipo_Conciliacion = -2; --DEFAULT
	
		
		--IDENTIFICA TIPO DE LAYOUT PARA REALIZAR VALIDACIONES DE MOVIMIENTOS (CORRESPONSALES POS)
		IF (piTipo_LayOut = 1) THEN -- CORRESPONSALES OXXO
			
			IF ((psOriginalEncontrado = '00000') AND (psTipotransaccion325 = 'FREC' ) AND (vmMonto325 = pmMontointercard) ) THEN 
				
				LET viTipo_Conciliacion = 1; -- CONCILIADA CORRECTA (MONTOS IGUALES)
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
			
			ELIF ((psOriginalEncontrado = '00000') AND (psTipotransaccion325 = 'FREC' ) AND (vmMonto325 != pmMontointercard) ) THEN 

				LET viTipo_Conciliacion = 2; -- CONCILIADA CON MONTOS DIFERENTES
				LET vsMovconciliado = 'V'; --STATUS DE INTERCARD EN BDITARJETA
				
			ELIF ((psOriginalEncontrado = '00400') AND (psTipotransaccion325 = 'FREC' )) THEN --
	
				LET viTipo_Conciliacion = 20; -- TRANSACCION NO ENCONTRADA EN INTERCARD
				
			ELIF (psMovreversado = 'V') THEN 
				--MOVIMIENTO ORIGINAL REVERSADO
				LET viTipo_Conciliacion = 30; 
				
			ELSE --ERROR

				LET viTipo_Conciliacion = 0; --MOV NO CONCUERDA CON NINGUN TIPO
				
			END IF;
			
		END IF;
		
		--MENSAJE DE RASTREO
		LET vsErrorActividad  = 'CONSECUTIVO ' || psConsecutivo || ' SE DETECTO EL TIPO CONCILIACION ' || DECODE (viTipo_Conciliacion, -1, 0, viTipo_Conciliacion);
		

		--OBTIENE LA DESCRIPCION DEL TIPO DE CONCILIACION 
		
		SELECT FIRST 1 Desc_Conciliacion INTO vsDesc_Conciliacion 
			FROM BdiTarjeta:"informix".td_Tipo_Conciliacion_mc 
		WHERE Tipo_Conciliacion = viTipo_Conciliacion;

		-- SE CREA EL FOLIO_REGULATORIO
		
		LET vsFolio_mov = psfolio_reg; 
	

		IF ((viTipo_Conciliacion IN (1,2))) THEN --TIPOS DE CONCILIACION QUE ACTUALIZAN EN REGISTRO ORIGINAL DE INTERCARD

			--ACTUALIZA EL MOVIMIENTO DE INTERCARD 
			UPDATE Intercard:"informix".Movimiento
			SET MovConciliado = 'V'
			WHERE NumTarjeta = psNumtarjeta AND secuencia= "1" || psSecuencia325;

		END IF;
		
		LET vsTipo_mov = 'A'; -- ABONOS [A]
		
		UPDATE BdiTarjeta:"informix".td_Movimientos_Conciliacion_mc
			SET Tipo_Conciliacion = DECODE (viTipo_Conciliacion, -2, 0, viTipo_Conciliacion), --REEMPLAZA EL TIPO -1 POR UN 0 Y DEJA LOS DEMAS TIPOS IGUAL
			Desc_Conciliacion = vsDesc_conciliacion, 
			Conciliacion = vsConciliacion, --BANDERA DE QUE FUE TRABAJADO
			FechaConcilia = vdFechaconcilia,
			Folio_Mov = vsFolio_mov, 
			Tipo_Mov = vsTipo_mov,  -- CARGOS [C]
			Secuencia = psSecuenciaorig, 
			Secuencia_extendida = psSecuencia_extendida, 
			MontoIntercard = pmMontointercard,
			montocashback = pmMontointercardCashback,
			FechaTransaccion = pdFechatransaccion, 
			InfReceptor = psInfreceptor, 
			IdTerminal = psIdterminal,
			MetodoCaptura = psMetodocaptura, 
			MovConciliado = vsMovconciliado, --- puede cambiar ok
			MovReversado = psMovreversado,
			integridad_error = vsmensaje  -- Pone mensaje de tipo de CNC
			WHERE NumTarjeta = psNumtarjeta AND Secuencia325 = psSecuencia325 AND Consecutivo = psConsecutivo;


			/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
			
		RETURN vssqlerr,
			NVL(vsConciliacion,''),
			NVL(psSecuenciaorig,''),
			NVL(psSecuencia_extendida,''),
			NVL(pmMontointercard,0),
			NVL(pmMontointercardCashback,0),	-- Integracion de CashBack
			NVL(vdFechaTransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(psInfreceptor,''),
			NVL(psIdterminal,''),
			NVL(psMetodocaptura,''),
			NVL(vsMovconciliado,''),
			NVL(psMovreversado,''),
			NVL(vsTipo_mov,''),
			NVL(vsFolio_mov,''),
			NVL(vdFechaconcilia,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
			NVL(viTipo_Conciliacion,0),
			DECODE (vssqlerr, '00000', '', NVL(vsDesc_conciliacion,'')),
			NVL(vsErrorActividad,'');
			
	END
END PROCEDURE;