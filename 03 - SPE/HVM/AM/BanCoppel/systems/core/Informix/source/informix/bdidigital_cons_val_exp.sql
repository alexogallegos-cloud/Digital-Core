create procedure "informix".cons_val_exp(pempresa char(3), pcliente    char(20))
            RETURNING
            char(5),char(1),char(1);

   DEFINE v_codret          char(5);
   DEFINE v_cuenta          char(20);
   DEFINE v_prod_nombre     char(40);
   DEFINE v_cod_docto       char(4);
   DEFINE v_fecha_alta      date;
   DEFINE v_cod_grupo       char(3);
   DEFINE v_descrip_gpo     char(30);
   DEFINE v_descrip_docto   char(35);
   DEFINE v_descrip2        char(30);
   DEFINE v_multi_img       char(1);
   DEFINE v_secuencia       smallint;
   DEFINE v_contador        smallint;
   DEFINE sql_err,isam_err  int;
   DEFINE cod_ret			char(5);
   DEFINE v_nomcte          char(104);
   DEFINE v_edad	        smallint;
   DEFINE v_codrespalda		char(5);
   DEFINE v_grupo_uno		char(1);
   DEFINE v_grupo_dos		char(1);
   DEFINE v_existe, v_nro_rows int;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET v_codret            = "000";
        let v_cod_docto         = " ";
        let v_cod_grupo         = " ";
		let v_multi_img         = " ";
        let v_secuencia         = 0;
        let v_contador          = 0;
		let cod_ret				= "000";
		let v_nomcte			= " ";
		let v_edad				= 0;
		let v_codrespalda       = "000";
		let v_grupo_uno			= '0';
		let v_grupo_dos			= '0';
		let v_existe			= 0;
		let v_nro_rows			= 0;

--set debug file to "/informix/cons_rgh.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_grupo_uno,v_grupo_dos;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null or
        pcliente is null then
       -- datos de entrada incompletos
       let v_codret = 110;
       RETURN v_codret,v_grupo_uno,v_grupo_dos;
    END IF;

-- ****************************************************************************
-- obtener edad
-- ****************************************************************************

	EXECUTE PROCEDURE bdinteg:consedadcte(pempresa,  pcliente)
	INTO cod_ret, v_nomcte, v_edad;

	if cod_ret <> '000' then
       let v_codret = '002';
                return v_codret,v_grupo_uno,v_grupo_dos;
	end if

-- ****************************************************************************
-- es mayor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************

	if v_edad >= 18 then

						select count(*)
						into v_existe
						from 	bdidigital@coppelimg_tcp:dg_expediente a,
								bdidigital@coppelimg_tcp:dg_tipodocumento d
						where a.cliente = pcliente
						and d.cod_docto = a.cod_docto
						and d.cod_grupo  in ('002','001')
						and a.producto = '9999';
						--group by  a.cod_docto, d.multi_imagen;

                       if not exists (select a.cod_docto, d.multi_imagen from 	bdidigital@coppelimg_tcp:dg_expediente a,
                                                  bdidigital@coppelimg_tcp:dg_tipodocumento d where a.cliente = pcliente
                                                  and d.cod_docto = a.cod_docto and d.cod_grupo  = '002' and a.producto = '9999'
                                                  group by  a.cod_docto, d.multi_imagen) then
                                LET v_codret = '000';
					   			LET v_grupo_dos = '1';
                       end if;

                       if not exists (select a.cod_docto, d.multi_imagen from 	bdidigital@coppelimg_tcp:dg_expediente a,
                                                  bdidigital@coppelimg_tcp:dg_tipodocumento d where a.cliente = pcliente
                                                  and d.cod_docto = a.cod_docto and d.cod_grupo  = '001' and a.producto = '9999'
                                                  group by  a.cod_docto, d.multi_imagen) then
                                LET v_codret = '000';
					   			LET v_grupo_uno = '1';
                       end if;



						if v_existe > 0 then

							FOREACH

								select a.cod_docto, d.multi_imagen
								into v_cod_docto, v_multi_img
								from 	bdidigital@coppelimg_tcp:dg_expediente a,
										bdidigital@coppelimg_tcp:dg_tipodocumento d
								where a.cliente = pcliente
								and d.cod_docto = a.cod_docto
								and d.cod_grupo  = '002'
								and a.producto = '9999'
								group by  a.cod_docto, d.multi_imagen

							if v_multi_img >= 1 then

								let v_contador = 0;

								FOREACH

									select 1
									into v_secuencia
									from bdidigital@coppelimg_tcp:dg_expediente
									where cliente = pcliente
									and cod_docto = v_cod_docto
									and fecha_alta in (select max(fecha_alta)
														from bdidigital@coppelimg_tcp:dg_expediente
														where cliente = pcliente
														and cod_docto = v_cod_docto)

									let v_contador = v_contador +1;

								CONTINUE FOREACH;

								END FOREACH

									if v_contador > 1 then
										LET v_codret = '000';
										LET v_grupo_dos = '0';
									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;
									end if;
							else
									IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN

										LET v_codret = '000';
										LET v_grupo_dos = '0';

									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;

									end if;

							end if;

						CONTINUE FOREACH;

					END FOREACH

					FOREACH

						select a.cod_docto, d.multi_imagen
						into v_cod_docto, v_multi_img
						from 	bdidigital@coppelimg_tcp:dg_expediente a,
								bdidigital@coppelimg_tcp:dg_tipodocumento d
						where a.cliente = pcliente
						and d.cod_docto = a.cod_docto
						and d.cod_grupo  in ('001')
						and a.producto = '9999'
						group by  a.cod_docto, d.multi_imagen

							if v_multi_img >= 1 then

							let v_contador = 0;

							FOREACH

								select 1
								into v_secuencia
								from bdidigital@coppelimg_tcp:dg_expediente
								where cliente = pcliente
								and cod_docto = v_cod_docto
								and fecha_alta in (select max(fecha_alta)
													from bdidigital@coppelimg_tcp:dg_expediente
													where cliente = pcliente
													and cod_docto = v_cod_docto)

								let v_contador = v_contador +1;

							CONTINUE FOREACH;

							END FOREACH

									if v_contador > 1 then
										LET v_codret = '000';
										LET v_grupo_uno = '0';
									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_uno = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_uno = '1';
										end if
									end if;

							else

									IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '9999') THEN

										LET v_codret = '000';
										LET v_grupo_dos = '0';

									else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											let v_codret = v_codret;
											let v_grupo_dos = '1';
										else
											let v_codret = v_codrespalda;
											let v_grupo_dos = '1';
										end if;

									end if;

							end if;


						CONTINUE FOREACH;

					END FOREACH

					else
										LET v_codret = '001';
										LET v_grupo_uno = '1';
										LET v_grupo_dos = '1';

					end if;
-- ****************************************************************************
-- es menor de edad verificar que por lo menos exista un registro si no no hay expediente
-- ****************************************************************************
	else

		select count(*)
		into v_existe
		from 	bdidigital@coppelimg_tcp:dg_expediente a,
				bdidigital@coppelimg_tcp:dg_tipodocumento d
		where a.cliente = pcliente
		and d.cod_docto = a.cod_docto
		and d.cod_grupo  in ('002','045')
		and a.producto = '6501';
		--group by  a.cod_docto, d.multi_imagen;

		if v_existe > 0 then

				FOREACH

					select 	a.cod_docto, d.multi_imagen
					into 	v_cod_docto, v_multi_img
					from 	bdidigital@coppelimg_tcp:dg_expediente a,
							bdidigital@coppelimg_tcp:dg_tipodocumento d
					where 	a.cliente = pcliente
					and 	d.cod_docto = a.cod_docto
					and 	d.cod_grupo  = '002'
					and 	a.producto = '6501'
					group by  a.cod_docto, d.multi_imagen

						if v_multi_img >= 1 then

						let v_contador = 0;

						FOREACH

							select 1
							into v_secuencia
							from bdidigital@coppelimg_tcp:dg_expediente
							where cliente = pcliente
							and cod_docto = v_cod_docto
							and fecha_alta in (select max(fecha_alta)
													from bdidigital@coppelimg_tcp:dg_expediente
													where cliente = pcliente
													and cod_docto = v_cod_docto)

							let v_contador = v_contador +1;

							CONTINUE FOREACH;

							END FOREACH

								if v_contador > 1 then
									LET v_codret = '000';
									LET v_grupo_dos = '0';
								else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_dos = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_dos = '1';
										end if;
								end if;
						else

								IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN

									LET v_codret = '000';
									LET v_grupo_dos = '0';

								ELSE

									LET v_codret = '001';
									call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
									RETURNING v_codrespalda;

									if v_codrespalda = '000' then
										let v_codret = v_codret;
										let v_grupo_dos = '1';
									else
										let v_codret = v_codrespalda;
										let v_grupo_dos = '1';
									end if;

								END IF;

						end if;

					CONTINUE FOREACH;

				END FOREACH

				FOREACH

					select 	a.cod_docto, d.multi_imagen
					into 	v_cod_docto, v_multi_img
					from 	bdidigital@coppelimg_tcp:dg_expediente a,
							bdidigital@coppelimg_tcp:dg_tipodocumento d
					where 	a.cliente = pcliente
					and 	d.cod_docto = a.cod_docto
					and 	d.cod_grupo  in ('045')
					and 	a.producto = '6501'
					group by  a.cod_docto, d.multi_imagen

						if v_multi_img >= 1 then

						let v_contador = 0;

						FOREACH

							select 1
							into v_secuencia
							from bdidigital@coppelimg_tcp:dg_expediente
							where cliente = pcliente
							and cod_docto = v_cod_docto
							and fecha_alta in (select max(fecha_alta)
												from bdidigital@coppelimg_tcp:dg_expediente
												where cliente = pcliente
												and cod_docto = v_cod_docto)

							let v_contador = v_contador +1;

						CONTINUE FOREACH;

						END FOREACH

								if v_contador >= 1 then
									LET v_codret = '000';
									LET v_grupo_uno = '0';
								else
										LET v_codret = '001';
										call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
										RETURNING v_codrespalda;

										if v_codrespalda = '000' then
											LET v_codret = v_codret;
											LET v_grupo_uno = '1';
										else
											LET v_codret = v_codrespalda;
											LET v_grupo_uno = '1';
										end if
								end if;
						else

								IF EXISTS (SELECT *	FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = pempresa AND cliente = pCliente AND cod_docto = v_cod_docto AND producto = '6501') THEN

									LET v_codret = '000';
									LET v_grupo_dos = '0';

								ELSE

									LET v_codret = '001';
									call bdidigital@coppelimg_tcp:resp_elim_imagenes(pempresa, pcliente, v_cod_docto)
									RETURNING v_codrespalda;

									if v_codrespalda = '000' then
										let v_codret = v_codret;
										let v_grupo_dos = '1';
									else
										let v_codret = v_codrespalda;
										let v_grupo_dos = '1';
									end if;

								END IF;

						end if;


					CONTINUE FOREACH;

				END FOREACH

		else
							LET v_codret = '001';
							LET v_grupo_uno = '1';
							LET v_grupo_dos = '1';

		end if;


	end if;

	RETURN v_codret,v_grupo_uno,v_grupo_dos;

END;
END PROCEDURE;