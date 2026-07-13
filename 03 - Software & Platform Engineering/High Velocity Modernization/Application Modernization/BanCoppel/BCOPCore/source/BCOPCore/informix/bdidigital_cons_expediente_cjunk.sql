CREATE PROCEDURE "informix".cons_expediente_cjunk(pempresa CHAR(3), pcliente CHAR(20), pnum_regs SMALLINT)
	RETURNING	
		CHAR(5), 	--Codigo retorno
		CHAR(20),	--Cuenta
		CHAR(40),	--Nom Producto
		CHAR(4),	--Cod docto
		DATE,		--Fecha alta
		CHAR(3),	--Cod grupo
		CHAR(30),	--Descripcion grupo
		CHAR(35),	--Descripcion docto
		CHAR(30),	--Descripcion2
		CHAR(1),	--Multi imagen
		SMALLINT;	--Secuencia

	--DEFINICION DE VARIABLES--
	DEFINE v_codret          CHAR(5);
	DEFINE v_cuenta          CHAR(20);
	DEFINE v_prod_nombre     CHAR(40);
	DEFINE v_cod_docto       CHAR(4);
	DEFINE v_fecha_alta      DATE;
	DEFINE v_cod_grupo       CHAR(3);
	DEFINE v_descrip_gpo     CHAR(30);
	DEFINE v_descrip_docto   CHAR(35);
	DEFINE v_descrip2        CHAR(30);
	DEFINE v_multi_img       CHAR(1);   
	DEFINE v_secuencia       SMALLINT;
	DEFINE v_contador        SMALLINT;
	DEFINE sql_err,isam_err  INT;
	
	--INICIALIZA VARIABLES
	LET v_codret		= "000";
	LET v_cuenta		= " ";
	LET v_prod_nombre	= " ";
	LET v_cod_docto		= " ";        
	LET v_fecha_alta	= today;
	LET v_cod_grupo		= " ";
	LET v_descrip_gpo	= " ";
	LET v_descrip_docto	= " ";
	LET v_descrip2		= " ";
	LET v_multi_img		= " ";
	LET v_secuencia		= 0;
	LET v_contador		= 0;
	
	--SET DEBUG DILE TO "/respaldosbd/Daniela/cons_expediente_cjunk.txt";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	BEGIN
	
		ON EXCEPTION SET sql_err,isam_err
			IF sql_err <> 0 OR isam_err <> 0 THEN
				LET v_codret = sql_err;
				
				RETURN v_codret,v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,v_cod_grupo, v_descrip_gpo,
					v_descrip_docto,v_descrip2,v_multi_img,v_secuencia;
			END IF;
		END EXCEPTION;

		IF  pempresa IS NULL OR pcliente IS NULL OR pnum_regs IS NULL THEN  
		   
			LET v_codret = 110; 
			
			RETURN v_codret,v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,v_cod_grupo,v_descrip_gpo,v_descrip_docto,
				v_descrip2,v_multi_img,v_secuencia;
		END IF;

		FOREACH

			SELECT  exp.cuenta,exp.producto || ' ' || exp.prod_nombre,exp.cod_docto,exp.fecha_alta,
					gd.cod_grupo,gd.descripcion,td.descripcion,td.multi_imagen,exp.secuencia,nvl(exp.descrip2," ")
			INTO    v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,
					v_cod_grupo,v_descrip_gpo,v_descrip_docto,
					v_multi_img,v_secuencia,v_descrip2
			FROM    bdidigital@coppelimg_tcp:dg_expediente exp,
					bdidigital@coppelimg_tcp:dg_grupodocto gd,
					bdidigital@coppelimg_tcp:dg_tipodocumento td
			WHERE   exp.cod_docto       = td.cod_docto 
					and td.cod_grupo    = gd.cod_grupo 
					and exp.empresa     = pempresa
					and exp.cliente     = pcliente 
					and exp.descrip2    <> 'firma_borra_da'
					and gd.cod_grupo in ('001','002','045')
			ORDER BY 4,1,3

			LET v_contador = v_contador +1;

			IF v_contador < pnum_regs THEN
				CONTINUE FOREACH;
			END IF; 
			
			RETURN  v_codret,v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,v_cod_grupo,v_descrip_gpo,v_descrip_docto,
					v_descrip2,v_multi_img,v_secuencia WITH RESUME;

		END FOREACH     

	END
	
END PROCEDURE;