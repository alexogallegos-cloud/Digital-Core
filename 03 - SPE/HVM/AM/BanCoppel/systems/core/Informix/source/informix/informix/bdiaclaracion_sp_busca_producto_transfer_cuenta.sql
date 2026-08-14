CREATE PROCEDURE "informix".sp_busca_producto_transfer_cuenta(p_sNumeroCuenta CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto         CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
    DEFINE resultado_telefonoTransfer       CHAR(30);
    DEFINE resultado_numClienteTransfer       CHAR(30);
	DEFINE iSqlErr                      		INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_telefonoTransfer = '';
    LET resultado_numClienteTransfer = '';
	LET cStatusTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                LET resultado_telefonoTransfer = '';
                LET resultado_numClienteTransfer = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta;
            END IF;
        END EXCEPTION;
        FOREACH
			SELECT SKIP p_skip DISTINCT bdicheq:sc_producto.producto AS numeroProducto,
                    bdicheq:sc_producto.nombre AS nombreProducto, 
             		bditransfer:tf_maecte.cuenta_tf AS cuentaProducto,
             		bdicheq:sc_tarjeta.num_tarjeta AS tarjetaProducto,
                    bditransfer:tf_maecte.telefono AS telefonoTransfer,
                    bditransfer:tf_maecte.numcte_tf AS numClienteTransfer,
					intercard:tarjeta.codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta,  resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta
			FROM bditransfer:tf_maecte 
               	 	LEFT JOIN bdicheq:sc_producto ON ( bdicheq:sc_producto.producto = bditransfer:tf_maecte.producto) 
					LEFT JOIN bdicheq:sc_tarjeta ON ( bdicheq:sc_tarjeta.cuenta = bditransfer:tf_maecte.cuenta_tf)
					LEFT JOIN intercard:tarjeta ON (bdicheq:sc_tarjeta.numcte = intercard:tarjeta.numcliente and bdicheq:sc_tarjeta.num_tarjeta = intercard:tarjeta.numtarjeta)
                	WHERE bditransfer:tf_maecte.cuenta_tf = p_sNumeroCuenta			
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta WITH RESUME;
	       END FOREACH;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_transfer_tarjeta(p_sNumeroTarjeta CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto 		CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
    DEFINE resultado_telefonoTransfer       CHAR(30);
    DEFINE resultado_numClienteTransfer       CHAR(30);
	DEFINE iSqlErr                      		INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_telefonoTransfer = '';
    LET resultado_numclienteTransfer = '';
	LET cStatusTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                LET resultado_telefonoTransfer = '';
                LET resultado_numclienteTransfer = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta;
            END IF;
        END EXCEPTION;
        FOREACH
			SELECT SKIP p_skip DISTINCT bdicheq:sc_producto.producto as numeroProducto,
                    bdicheq:sc_producto.nombre AS nombreProducto, 
             		bditransfer:tf_maecte.cuenta_tf AS cuentaProducto,
             		bdicheq:sc_tarjeta.num_tarjeta AS tarjetaProducto,
                    bditransfer:tf_maecte.telefono AS telefonoTransfer, 
                    bditransfer:tf_maecte.numcte_tf AS numclienteTransfer,
					intercard:tarjeta.codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta
			FROM bditransfer:tf_maecte 
               	 	LEFT JOIN bdicheq:sc_producto ON ( bdicheq:sc_producto.producto = bditransfer:tf_maecte.producto) 
					LEFT JOIN bdicheq:sc_tarjeta ON ( bdicheq:sc_tarjeta.cuenta = bditransfer:tf_maecte.cuenta_tf)
					LEFT JOIN intercard:tarjeta ON (bdicheq:sc_tarjeta.numcte = intercard:tarjeta.numcliente and bdicheq:sc_tarjeta.num_tarjeta = intercard:tarjeta.numtarjeta)
                	WHERE bdicheq:sc_tarjeta.num_tarjeta = p_sNumeroTarjeta
			
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta WITH RESUME;
	       END FOREACH;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_transfer_telefono(p_sTelefonoCliente CHAR(20), p_skip INT)

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(30) AS telefonoTransfer, CHAR(30) AS numClienteTransfer, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 	CHAR(60);
	DEFINE resultado_numeroCuenta		CHAR(30);
	DEFINE resultado_numeroTarjeta		CHAR(30);
    DEFINE resultado_telefonoTransfer	CHAR(30);
    DEFINE resultado_numclienteTransfer	CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto = '';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
    LET resultado_telefonoTransfer = '';
    LET resultado_numClienteTransfer = '';
	LET cStatusTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                LET resultado_telefonoTransfer = '';
                LET resultado_numClienteTransfer = '';
            RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta;
            END IF;
        END EXCEPTION;

		FOREACH
	        SELECT SKIP p_skip DISTINCT bdicheq:sc_producto.producto as numeroProducto,bdicheq:sc_producto.nombre AS nombreProducto, 
                bditransfer:tf_maecte.cuenta_tf AS cuentaProducto,
                bdicheq:sc_tarjeta.num_tarjeta AS tarjetaProducto,
                bditransfer:tf_maecte.telefono AS telefonoTransfer,
                bditransfer:tf_maecte.numcte_tf AS numClienteTransfer,
				intercard:tarjeta.codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta 
              FROM bditransfer:tf_maecte
              LEFT JOIN bdicheq:sc_producto ON ( bdicheq:sc_producto.producto = bditransfer:tf_maecte.producto)
			  LEFT JOIN bdicheq:sc_tarjeta ON ( bdicheq:sc_tarjeta.cuenta = bditransfer:tf_maecte.cuenta_tf)
			  LEFT JOIN intercard:tarjeta ON (bdicheq:sc_tarjeta.numcte = intercard:tarjeta.numcliente and bdicheq:sc_tarjeta.num_tarjeta = intercard:tarjeta.numtarjeta)
              WHERE bditransfer:tf_maecte.telefono= p_sTelefonoCliente
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, resultado_telefonoTransfer, resultado_numClienteTransfer, cStatusTarjeta WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_producto_deb_cheq_tarjeta(p_sNumeroTarjeta CHAR(20))

     RETURNING	CHAR(6) AS numeroProducto,CHAR(60) AS nombreProducto, CHAR(30) AS numeroCuenta, CHAR(30) AS numeroTarjeta, CHAR(3) AS statusTarjeta;

	--definicion de variables--	    
    DEFINE resultado_numeroProducto CHAR(6);
	DEFINE resultado_nombreProducto 		CHAR(60);
	DEFINE resultado_numeroCuenta			CHAR(30);
	DEFINE resultado_numeroTarjeta			CHAR(30);
	DEFINE iSqlErr                      	INTEGER;
	DEFINE cStatusTarjeta CHAR(3);
	
     -- InicializaciÃ³n de las variables.
    LET resultado_numeroProducto ='';
	LET resultado_nombreProducto = '';
	LET resultado_numeroCuenta = '';
	LET resultado_numeroTarjeta = '';
	LET cStatusTarjeta = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto ='';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_numeroTarjeta = '';
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
            END IF;
        END EXCEPTION;
		
		FOREACH
			SELECT DISTINCT bdicheq:sc_maechq.producto as numeroProducto,bdicheq:sc_producto.nombre AS nombreProducto, cuenta AS cuentaProducto, intercard:tarjetacuenta.numtarjeta AS tarjetaProducto, codstatustarjeta AS estatusTarjeta
			INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta
			FROM bdicheq:sc_maechq 
               		LEFT JOIN bdicheq:sc_producto ON (bdicheq:sc_maechq.producto = bdicheq:sc_producto.producto) 
                	LEFT JOIN intercard:tarjetacuenta ON (bdicheq:sc_maechq.cuenta = intercard:tarjetacuenta.numcuenta)
					LEFT JOIN intercard:tarjeta ON (intercard:tarjetacuenta.numtarjeta = intercard:tarjeta.numtarjeta)
			WHERE intercard:tarjetacuenta.numtarjeta = p_sNumeroTarjeta
			RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta, cStatusTarjeta;
		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_cuestionario_telefonico(p_NumCte CHAR(30))

    RETURNING   CHAR(50) AS estado, CHAR(15) AS fecha_nacimiento, CHAR(10) AS cod_postal,
     CHAR(15) AS numero_exterior, CHAR(50) AS estado_nacio,CHAR(30) AS telefono,
     CHAR(50) AS calle, CHAR(50) AS colonia, CHAR(50) AS municipio, CHAR(50) AS correo_electronico;

    --definicion de variables--
    DEFINE resultado_estado                 CHAR(50);
    DEFINE resultado_estado_nacio           CHAR(50);
    DEFINE resultado_fecha_nacimiento       CHAR(15);
    DEFINE resultado_cod_postal             CHAR(10);
    DEFINE resultado_numero_exterior        CHAR(15);
    DEFINE resultado_apellido_paterno       CHAR(20);
    DEFINE resultado_apellido_materno       CHAR(20);
    DEFINE resultado_telefono               CHAR(30);
    DEFINE resultado_calle                  CHAR(50);
    DEFINE resultado_colonia                CHAR(50);
    DEFINE resultado_municipio              CHAR(50);
    DEFINE resultado_correo_electronico     CHAR(50);
    DEFINE iSqlErr                          INTEGER;
    -- Inicializacion de las variables.
    LET resultado_estado = '';
    LET resultado_estado_nacio ='';
    LET resultado_fecha_nacimiento = '';
    LET resultado_cod_postal = '';
    LET resultado_numero_exterior = '';
    LET resultado_apellido_paterno='';
    LET resultado_apellido_materno='';
    LET resultado_telefono = '';
    LET resultado_calle = '';
    LET resultado_colonia = '';
    LET resultado_municipio = '';
    LET resultado_correo_electronico = '';


    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_estado = '';
                    LET resultado_estado_nacio ='';
                    LET resultado_fecha_nacimiento = '';
                    LET resultado_cod_postal = '';
                    LET resultado_numero_exterior = '';
                    LET resultado_telefono = '';
                    LET resultado_calle = '';
                    LET resultado_colonia = '';
                    LET resultado_municipio = '';
                    LET resultado_correo_electronico = '';
                    RETURN resultado_estado, resultado_fecha_nacimiento, resultado_cod_postal, resultado_numero_exterior,resultado_estado_nacio, resultado_telefono, resultado_calle, resultado_colonia, resultado_municipio, resultado_correo_electronico;
                END IF;
        END EXCEPTION;


        SELECT
                 edo.nombre as estado, ' 02 '|| substr(rfc,5,6) as fecha_nacimiento, ' 03 ' || sd.cod_postal,' 04 ' || numeroextcalle as numero_exterior, ' 06 ' || telefono as 
                 telefono_casa,ct.nombrecalle as calle,
                 sz.nombrezona as colonia, sz.municipiozona as municipio,
                 em.correo_elec as correo_electronico
                 INTO resultado_estado, resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior
                 ,resultado_telefono,resultado_calle,resultado_colonia,resultado_municipio,resultado_correo_electronico
                FROM bdinteg:si_cliente sc
                 Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:si_telefonos st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
            where
            sc.NUMCTE = p_NumCte;
            LET resultado_estado_nacio = ( select estados.nombre from bdinteg:si_ctepf ctpf
            inner join bdinteg:si_estados estados on ctpf.lugar_nac = estados.estado
            where numcte = p_NumCte);

 IF resultado_estado is null THEN
     LET resultado_estado = 'null';
END IF;

  IF resultado_fecha_nacimiento is null THEN
     LET resultado_fecha_nacimiento = '02 null';
END IF;

 IF resultado_cod_postal is null THEN
     LET resultado_cod_postal = '03 null';
END IF;

 IF resultado_numero_exterior is null THEN
     LET resultado_numero_exterior = '04 null';
END IF;

 IF resultado_estado_nacio is null THEN
     LET resultado_estado_nacio = 'null';
END IF;

IF resultado_telefono is null THEN
     LET resultado_telefono = '06 null';
END IF;

 IF resultado_calle is null THEN
     LET resultado_calle = 'null';
END IF;

 IF resultado_colonia is null THEN
     LET resultado_colonia = 'null';
END IF;

 IF resultado_municipio is null THEN
     LET resultado_municipio = 'null';
END IF;

 IF resultado_correo_electronico is null THEN
     LET resultado_correo_electronico = 'null';
END IF;

    RETURN ' 01 '|| Trim(resultado_estado), resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior,' 05 '||resultado_estado_nacio,resultado_telefono,' 07 ' || Trim(resultado_calle),' 08 ' || Trim(resultado_colonia),'09 ' || Trim(resultado_municipio),'10 ' || Trim(resultado_correo_electronico);


END

END PROCEDURE;