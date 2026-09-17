CREATE PROCEDURE "informix".cons_val_exp_web(pempresa char(3), pcliente    char(20))
            RETURNING
            char(5),char(1),char(1);

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
   DEFINE cod_ret			CHAR(5);
   DEFINE v_nomcte          CHAR(104);
   DEFINE v_edad	        SMALLINT;
   DEFINE v_codrespalda		CHAR(5);
   DEFINE v_grupo_uno		CHAR(1);
   DEFINE v_grupo_dos		CHAR(1);
   DEFINE v_existe, v_nro_rows INT;
   DEFINE iCuantos			INT;   
   DEFINE iiCuantos			INT; 
   DEFINE iiiCuantos		INT;
   DEFINE ivCuantos			INT;
   DEFINE vCuantos			INT;
   DEFINE viCuantos			INT;
	
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

	LET v_codret            = "000";
	LET v_cod_docto         = " ";
	LET v_cod_grupo         = " ";
	LET v_multi_img         = " ";
	LET v_secuencia         = 0;
	LET v_contador          = 0;
	LET cod_ret				= "000";
	LET v_nomcte			= " ";
	LET v_edad				= 0;
	LET v_codrespalda       = "000";
	LET v_grupo_uno			= '0';
	LET v_grupo_dos			= '0';
	LET v_existe			= 0;
	LET v_nro_rows			= 0;
	LET iCuantos			= 0;
	LET iiCuantos			= 0;
	LET iiiCuantos			= 0;
	LET ivCuantos			= 0;
	LET vCuantos			= 0;
	LET viCuantos			= 0;

--set debug file to "/informix/cons_val_exp.txt";
--trace on;

BEGIN
    ON EXCEPTION SET sql_err,isam_err
        IF sql_err <> 0 or isam_err <> 0 THEN
			LET v_codret = sql_err;
			RETURN v_codret,v_grupo_uno,v_grupo_dos;
        END IF;
    END EXCEPTION;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null or
        pcliente is null THEN
       -- datos de entrada incompletos
       LET v_codret = '110';
       RETURN '00'||v_codret,v_grupo_uno,v_grupo_dos;
    END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
-- ****************************************************************************
-- obtener edad
-- ****************************************************************************

	EXECUTE PROCEDURE bdinteg:consedadcte(pempresa,  pcliente)
	INTO cod_ret, v_nomcte, v_edad;

	IF cod_ret <> '000' THEN
        LET v_codret = '002';
        RETURN '00'||v_codret,v_grupo_uno,v_grupo_dos;
	END IF

-- ****************************************************************************
-- es mayor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************

	IF v_edad >= 18 THEN

		SELECT count(1)
		INTO v_existe
		FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
				bdidigital@coppelimg_tcp:dg_tipodocumento d
		WHERE a.cliente = pcliente
		AND d.cod_docto = a.cod_docto
		AND d.cod_grupo  in ('002','001')
		AND a.producto = '9999';
		--group by  a.cod_docto, d.multi_imagen;

	    SELECT COUNT(a.cod_docto) INTO iCuantos
	    FROM bdidigital@coppelimg_tcp:dg_expediente a,
	    bdidigital@coppelimg_tcp:dg_tipodocumento d 
	    WHERE a.cliente = pcliente
	    AND d.cod_docto = a.cod_docto AND d.cod_grupo  = '002' AND a.producto = '9999'
	    GROUP BY  a.cod_docto;
					   
		IF(iCuantos = 0) THEN 
			LET v_codret = '000';
			LET v_grupo_dos = '1';
		END IF;
					  
					   
		SELECT COUNT(a.cod_docto) INTO iiCuantos
		FROM bdidigital@coppelimg_tcp:dg_expediente a,
			bdidigital@coppelimg_tcp:dg_tipodocumento d 
		WHERE a.cliente = pcliente
		AND d.cod_docto = a.cod_docto AND d.cod_grupo  = '001' AND a.producto = '9999'
		GROUP BY  a.cod_docto;
					   
		IF(iiCuantos = 0) THEN 
			LET v_codret = '000';
			LET v_grupo_uno = '1';
		END IF;

	   IF v_existe > 0 THEN

			FOREACH

				SELECT a.cod_docto, d.multi_imagen
				INTO v_cod_docto, v_multi_img
				FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
						bdidigital@coppelimg_tcp:dg_tipodocumento d
				WHERE a.cliente = pcliente
				AND d.cod_docto = a.cod_docto
				AND d.cod_grupo  = '002'
				AND a.producto = '9999'
				GROUP BY  a.cod_docto, d.multi_imagen

				IF v_multi_img >= 1 THEN
					LET v_contador = 0;

					FOREACH

						SELECT 1
						INTO v_secuencia
						FROM bdidigital@coppelimg_tcp:dg_expediente
						WHERE cliente = pcliente
						AND cod_docto = v_cod_docto
						AND fecha_alta in (select max(fecha_alta)
											from bdidigital@coppelimg_tcp:dg_expediente
											where cliente = pcliente
											and cod_docto = v_cod_docto)

						LET v_contador = v_contador +1;

						CONTINUE FOREACH;
					END FOREACH

					IF v_contador > 1 THEN
						LET v_codret = '000';
						LET v_grupo_dos = '0';
					ELSE
						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							let v_codret = v_codret;
							let v_grupo_dos = '1';
						ELSE
							let v_codret = v_codrespalda;
							let v_grupo_dos = '1';
						END IF;
					END IF;
				ELSE
					--IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN
					
					SELECT COUNT(cliente) INTO iiiCuantos	
					FROM bdidigital@coppelimg_tcp:dg_expediente 
					WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999';
					
					IF(iiiCuantos > 0) THEN
						LET v_codret = '000';
						LET v_grupo_dos = '0';

					ELSE
						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							let v_codret = v_codret;
							let v_grupo_dos = '1';
						ELSE
							let v_codret = v_codrespalda;
							let v_grupo_dos = '1';
						END IF;
					END IF;

				END IF;

				CONTINUE FOREACH;

			END FOREACH

			FOREACH

				SELECT a.cod_docto, d.multi_imagen
				INTO v_cod_docto, v_multi_img
				FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
						bdidigital@coppelimg_tcp:dg_tipodocumento d
				WHERE a.cliente = pcliente
				AND d.cod_docto = a.cod_docto
				AND d.cod_grupo  in ('001')
				AND a.producto = '9999'
				GROUP BY  a.cod_docto, d.multi_imagen

				IF v_multi_img >= 1 THEN

				LET v_contador = 0;

					FOREACH

						SELECT 1
						INTO v_secuencia
						FROM bdidigital@coppelimg_tcp:dg_expediente
						WHERE cliente = pcliente
						AND cod_docto = v_cod_docto
						AND fecha_alta in (select max(fecha_alta)
											from bdidigital@coppelimg_tcp:dg_expediente
											where cliente = pcliente
											and cod_docto = v_cod_docto)

						LET v_contador = v_contador +1;
						CONTINUE FOREACH;
					END FOREACH

					IF v_contador > 1 THEN
						LET v_codret = '000';
						LET v_grupo_uno = '0';
					ELSE
						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							LET v_codret = v_codret;
							LET v_grupo_uno = '1';
						ELSE
							LET v_codret = v_codrespalda;
							LET v_grupo_uno = '1';
						END IF
					END IF;

				ELSE
					--IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN
					SELECT COUNT(1)	INTO ivCuantos
					FROM bdidigital@coppelimg_tcp:dg_expediente 
					WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999';
					
					IF(ivCuantos > 0) THEN
						LET v_codret = '000';
						LET v_grupo_dos = '0';

					ELSE
						LET v_codret = '001';
						CALL bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							LET v_codret = v_codret;
							LET v_grupo_dos = '1';
						ELSE
							LET v_codret = v_codrespalda;
							LET v_grupo_dos = '1';
						END IF;
					END IF;
				END IF;

				CONTINUE FOREACH;
			END FOREACH

		ELSE
			LET v_codret = '001';
			LET v_grupo_uno = '1';
			LET v_grupo_dos = '1';
		END IF;
-- ****************************************************************************
-- es menor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************
	ELSE

		SELECT count(1)
		INTO v_existe
		FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
				bdidigital@coppelimg_tcp:dg_tipodocumento d
		WHERE a.cliente = pcliente
		AND d.cod_docto = a.cod_docto
		AND d.cod_grupo  in ('002','045')
		AND a.producto = '6501';
		--group by  a.cod_docto, d.multi_imagen;

		IF v_existe > 0 THEN

			FOREACH

				SELECT 	a.cod_docto, d.multi_imagen
				INTO 	v_cod_docto, v_multi_img
				FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
						bdidigital@coppelimg_tcp:dg_tipodocumento d
				WHERE 	a.cliente = pcliente
				AND 	d.cod_docto = a.cod_docto
				AND 	d.cod_grupo  = '002'
				AND 	a.producto = '6501'
				GROUP BY  a.cod_docto, d.multi_imagen

				IF v_multi_img >= 1 THEN

					LET v_contador = 0;

					FOREACH

						SELECT 1
						INTO v_secuencia
						FROM bdidigital@coppelimg_tcp:dg_expediente
						WHERE cliente = pcliente
						AND cod_docto = v_cod_docto
						AND fecha_alta in (select max(fecha_alta)
												from bdidigital@coppelimg_tcp:dg_expediente
												where cliente = pcliente
												and cod_docto = v_cod_docto)

						LET v_contador = v_contador +1;
						CONTINUE FOREACH;
					END FOREACH

					IF v_contador > 1 THEN
						LET v_codret = '000';
						LET v_grupo_dos = '0';
					ELSE
						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							LET v_codret = v_codret;
							LET v_grupo_dos = '1';
						ELSE
							LET v_codret = v_codrespalda;
							LET v_grupo_dos = '1';
						END IF;
					END IF;
				ELSE
					--IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN
					SELECT COUNT(1)	INTO vCuantos
					FROM bdidigital@coppelimg_tcp:dg_expediente 
					WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501';
					
					IF(vCuantos > 0) THEN
						LET v_codret = '000';
						LET v_grupo_dos = '0';

					ELSE

						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							let v_codret = v_codret;
							let v_grupo_dos = '1';
						ELSE
							let v_codret = v_codrespalda;
							let v_grupo_dos = '1';
						END IF;
					END IF;
				END IF;

				CONTINUE FOREACH;
			END FOREACH

			FOREACH

				SELECT 	a.cod_docto, d.multi_imagen
				INTO 	v_cod_docto, v_multi_img
				FROM 	bdidigital@coppelimg_tcp:dg_expediente a,
						bdidigital@coppelimg_tcp:dg_tipodocumento d
				WHERE 	a.cliente = pcliente
				AND 	d.cod_docto = a.cod_docto
				AND 	d.cod_grupo  in ('045')
				AND 	a.producto = '6501'
				GROUP BY  a.cod_docto, d.multi_imagen

				IF v_multi_img >= 1 THEN

					LET v_contador = 0;

					FOREACH

						SELECT 1
						INTO v_secuencia
						FROM bdidigital@coppelimg_tcp:dg_expediente
						WHERE cliente = pcliente
						AND cod_docto = v_cod_docto
						AND fecha_alta in (select max(fecha_alta)
											from bdidigital@coppelimg_tcp:dg_expediente
											where cliente = pcliente
											and cod_docto = v_cod_docto)

						LET v_contador = v_contador +1;

						CONTINUE FOREACH;
					END FOREACH

					IF v_contador >= 1 THEN
						LET v_codret = '000';
						LET v_grupo_uno = '0';
					ELSE
						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' THEN
							LET v_codret = v_codret;
							LET v_grupo_uno = '1';
						ELSE
							LET v_codret = v_codrespalda;
							LET v_grupo_uno = '1';
						END IF
					END IF;
				ELSE

					--IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN
					SELECT COUNT(1)	INTO viCuantos
					FROM bdidigital@coppelimg_tcp:dg_expediente 
					WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501';
					
					IF(viCuantos > 0) THEN					
						LET v_codret = '000';
						LET v_grupo_dos = '0';
					ELSE

						LET v_codret = '001';
						call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
						RETURNING v_codrespalda;

						IF v_codrespalda = '000' then
							LET v_codret = v_codret;
							LET v_grupo_dos = '1';
						ELSE
							LET v_codret = v_codrespalda;
							LET v_grupo_dos = '1';
						END IF;

					END IF;

				END IF;
				CONTINUE FOREACH;
			END FOREACH

		ELSE
			LET v_codret = '001';
			LET v_grupo_uno = '1';
			LET v_grupo_dos = '1';
		END IF;
	END IF;
	RETURN '00'||v_codret,v_grupo_uno,v_grupo_dos;
END;
END PROCEDURE;