CREATE PROCEDURE "informix".sp_busca_productos_catalogo(pNombreProducto CHAR(100), pNumeroProducto CHAR(6), pTipoProducto CHAR(1), pTipoConsulta CHAR(6), p_skip INT)

	RETURNING CHAR(6) AS resultado_numeroProducto,CHAR(100) AS resultado_nombreProducto, CHAR(1) AS resultado_tipoProducto;

	--definicion de variables--	    
	DEFINE resultado_nombreProducto 	CHAR(100);
    DEFINE resultado_numeroProducto     CHAR (6);
    DEFINE resultado_tipoProducto           CHAR (1);
	DEFINE iSqlErr                          	INTEGER;
	
	-- InicializaciÃÂ³n de las variables.
	LET resultado_nombreProducto = '';
    LET resultado_numeroProducto = '';
    LET resultado_tipoProducto = '';

	SET ISOLATION TO dirty READ;
    BEGIN
        ON EXCEPTION
        SET iSqlErr 
            IF iSqlErr <> 0 THEN
                LET resultado_nombreProducto = '';
                LET resultado_numeroProducto = '';
                RETURN resultado_nombreProducto,resultado_numeroProducto,resultado_tipoProducto;
           	END IF;
        END EXCEPTION;

        -- NUD NUMERO DE PRODUCTO EN DEBITO
        IF(pTipoConsulta = 'NUD') THEN
            FOREACH
                SELECT SKIP p_skip deb.producto as numero_producto, deb.nombre as nombre_producto, '2'
                INTO resultado_numeroProducto,resultado_nombreProducto, resultado_tipoProducto
                FROM bdicheq:sc_producto as deb
                WHERE deb.producto = pNumeroProducto 
                and deb.producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = deb.producto)
                UNION ALL
                SELECT '3000' as numero_producto, inv.nombre as nombre_producto, '2'
                FROM bdinvers:sv_instrum inv
                where '3000' = pNumeroProducto                 
                and '3000' not in (select producto from bdiaclaracion:acl_tipo_producto where producto = '3000')
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- NUC NUMERO DE PRODUCTO EN CREDITO
        IF(pTipoConsulta = 'NUC') THEN
            FOREACH
                SELECT SKIP p_skip cred.num_producto as numero_producto, cred.nombre_prod as nombre_producto,'1'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicred:sd_definicion as cred 
                WHERE cred.num_producto = pNumeroProducto 
                and cred.num_producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = cred.num_producto)
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;    

        -- NBD NOMBRE PRODUCTO EN DEBITO
        IF(pTipoConsulta = 'NBD') THEN
            FOREACH
                SELECT SKIP p_skip deb.producto as numero_producto, deb.nombre as nombre_producto ,'2'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicheq:sc_producto as deb
                WHERE deb.nombre like ('%' || TRIM(pNombreProducto) || '%')
                and deb.producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = deb.producto)
                UNION ALL
                SELECT '3000' as numero_producto, inv.nombre as nombre_producto, '2'
                FROM bdinvers:sv_instrum inv
                where inv.nombre like ('%' || TRIM(pNombreProducto) || '%')                
                and '3000' not in (select producto from bdiaclaracion:acl_tipo_producto where producto = '3000')
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- NBC NOMBRE PRODUCTO EN CREDITO
        IF(pTipoConsulta = 'NBC') THEN
            FOREACH
                SELECT SKIP p_skip cred.num_producto as numero_producto, cred.nombre_prod as nombre_producto,'1'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicred:sd_definicion as cred 
                WHERE cred.nombre_prod like ('%' || TRIM(pNombreProducto) || '%')
                and cred.num_producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = cred.num_producto)
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- NBNUD NOMBRE,NUMERO PRODUCTO EN DEBITO
        IF(pTipoConsulta = 'NBNUD') THEN
            FOREACH
                SELECT SKIP p_skip deb.producto as numero_producto, deb.nombre as nombre_producto ,'2'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicheq:sc_producto as deb
                WHERE deb.nombre like ('%' || TRIM(pNombreProducto) || '%') and deb.producto = pNumeroProducto                
                AND deb.producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = deb.producto)       
                UNION ALL
                SELECT '3000' as numero_producto, inv.nombre as nombre_producto, '2'
                FROM bdinvers:sv_instrum inv
                where inv.nombre like ('%' || TRIM(pNombreProducto) || '%') and '3000' = pNumeroProducto                
                and '3000' not in (select producto from bdiaclaracion:acl_tipo_producto where producto = '3000')
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- NBNUC NOMBRE,NUMERO PRODUCTO EN CREDITO
        IF(pTipoConsulta = 'NBNUC') THEN
            FOREACH
                SELECT SKIP p_skip cred.num_producto as numero_producto, cred.nombre_prod as nombre_producto,'1'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicred:sd_definicion as cred 
                WHERE cred.nombre_prod like ('%' || TRIM(pNombreProducto) || '%') and cred.num_producto = pNumeroProducto
                and cred.num_producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = cred.num_producto)                
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- TIPO PRODUCTO CREDITO
        IF(pTipoConsulta = 'TPC') THEN
            FOREACH
                 SELECT SKIP p_skip cred.num_producto as numero_producto, cred.nombre_prod as nombre_producto,'1'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicred:sd_definicion as cred 
                where cred.num_producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = cred.num_producto)
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        -- TIPO PRODUCTO DEBITO
        IF(pTipoConsulta = 'TPD') THEN
            FOREACH
                SELECT SKIP p_skip deb.producto as numero_producto, deb.nombre as nombre_producto ,'2'
                INTO resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto
                FROM bdicheq:sc_producto as deb
                where deb.producto not in (select producto from bdiaclaracion:acl_tipo_producto where producto = deb.producto)
                UNION ALL
                SELECT '3000' as numero_producto, nombre as nombre_producto, '2'
                FROM bdinvers:sv_instrum
                where '3000' not in (select producto from bdiaclaracion:acl_tipo_producto where producto = '3000')
                RETURN resultado_numeroProducto,resultado_nombreProducto,resultado_tipoProducto WITH RESUME;
            END FOREACH;
        END IF;

        
	END
END PROCEDURE;