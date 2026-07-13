CREATE PROCEDURE "informix".sp_obtenernombcte(p_empresa char(3), p_numcte char(20))
   RETURNING CHAR(5), CHAR(104), smallint;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_nomcte            CHAR(104);

   DEFINE v_ano_cte           SMALLINT;
   DEFINE v_edad	          SMALLINT;
   DEFINE v_fecha_hoy         DATE; 

   LET cod_ret = '000';
   LET p_mensaje = "Operacion Realizada Exitosamente";
   LET v_numcte = '';
   LET v_nomcte = '';
   LET v_ano_cte =0;
   LET v_edad = 0;
   LEt v_fecha_hoy = date(1);
	
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_nomcte, v_edad;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/sp_obtenernombcte.out";
	--TRACE ON;

	IF p_numcte != "" THEN
	
		select fecha_hoy
		into v_fecha_hoy
		from "informix".si_fechas;

		SELECT NVL(trim(cli.nombre1),' ') || ' ' ||
			   NVL(trim(cli.nombre2),' ') || ' ' ||
			   NVL(trim(cli.apell_paterno),' ') || ' ' ||
			   NVL(trim(cli.apell_materno),' ') nomcte,  
			 case when month(fecha_nac) < month(v_fecha_hoy)
					then year(v_fecha_hoy) - year(fecha_nac)
					else case when month(fecha_nac) = month(v_fecha_hoy) and day(fecha_nac) <= day(v_fecha_hoy) 
						then year(v_fecha_hoy) - year(fecha_nac)
						else year(v_fecha_hoy) - year(fecha_nac) - 1 
					end  
			 end edad
		INTO v_nomcte,v_edad
		FROM "informix".si_cliente cli,
			 "informix".si_ctepf pf
		WHERE cli.empresa = p_empresa and
			  pf.numcte = cli.numcte  AND
			  cli.numcte =p_numcte;

		IF v_nomcte is null THEN
			let cod_ret = "002";
			RETURN  cod_ret,v_nomcte, v_edad;
		END IF;
	
		IF v_edad <= 0 THEN
			let cod_ret = "003";
			RETURN  cod_ret,v_nomcte, v_edad;
		END IF;
		
	ELSE
		let cod_ret = '001';
	END IF;		
	
    RETURN  cod_ret,v_nomcte, v_edad;

END
END PROCEDURE
DOCUMENT
'AUTOR: Aaron QuiÃ±onez',
'FECHA: 07/05/2015',
'BD: bdinteg',
'Objetivo: Carga los Datos del Cliente';

CREATE PROCEDURE "informix".sp_busca_producto_deb_cheq_cuenta(p_sNumeroCuenta CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
	DEFINE iSqlErr                      		INTEGER;
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	
	
	--SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_busqueda_cheq_cuenta"||"_"||""||TRIM(p_sNumeroCuenta)||""||"_35.out"; --> TRACE DESDE APP
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto ='';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta;
            END IF;
        END EXCEPTION;
        FOREACH
			SELECT SKIP p_skip DISTINCT bdicheq:sc_maechq.producto as numeroProducto,nombre AS nombreProducto, cuenta AS cuentaProducto, numtarjeta AS tarjetaProducto
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
			FROM bdicheq:sc_maechq 
               	 	LEFT JOIN bdicheq:sc_producto ON (bdicheq:sc_maechq.producto = bdicheq:sc_producto.producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicheq:sc_maechq.cuenta = intercard:tarjetacuenta.numcuenta)
			WHERE bdicheq:sc_maechq.cuenta = p_sNumeroCuenta
			AND bdicheq:sc_maechq.status_cta in ('1','3','4','5')
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta WITH RESUME;
	       END FOREACH;
	END
END PROCEDURE;