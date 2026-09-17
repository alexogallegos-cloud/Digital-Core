create procedure "informix".sp_validacliente_bpi(pEmpresa char(3), pNumCte char(20), pFechaNac date,
                                     pTarjeta char(20), pTipo integer, pFolio char(5))
   returning char(5),char(20),char(20), char(26),char(26),char(26),char(26), smallint;
   
   -- Realizo   : Alfredo Gpe. Avena R.
   -- Actividad : Validar que el cliente cumpla con los establecido para activar el servicio de BPI
   -- Solicitó  : Diana Castellanos
   -- Fecha     :  14/04/2008

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define vTipoTarjeta char;
   define sql_err integer;
   define v_numcte, v_numtarjeta char(20);
   define v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno  char(26);
   DEFINE iCont, v_id_status SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_nombre1 = " ";
   let v_nombre2 = " ";
   let v_apell_paterno = " ";
   let v_apell_materno = " ";
   let v_id_status = 0;
   LET iCont = 0;
   Let vTipoTarjeta = '';

--set debug file to "/tmp/sp_validacliente_bpi.out";
--trace on;

LET v_numcte = pNumCte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
      end if
   end exception;


   --select numcte into v_numcte from bdinteg:si_cliente
      --where numcte = pNumCte;

   --if v_numcte is null then
      --let cod_ret = "104";
     -- return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno;
   --end if


  IF v_numcte <> "" THEN

     IF EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE empresa = pEmpresa AND numcte = v_numcte) THEN

         IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = v_numcte ) THEN

             IF EXISTS ( SELECT folio_contrato FROM bdinteg:si_bpiusuarios  WHERE numcte = v_numcte AND folio_contrato = pFolio) THEN

			SELECT id_status INTO v_id_status FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = v_numcte;

			IF (v_id_status = 10) THEN

				SELECT COUNT(numcte) INTO iCont FROM bdinteg:si_ctepf WHERE empresa = pEmpresa AND numcte = v_numcte
                                                                                AND fecha_nac = pFechaNac;

				IF iCont > 0 THEN
					SELECT LIMIT 1 numcte, nombre1, nombre2, apell_paterno, apell_materno
					INTO  v_numcte,  v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
					FROM bdinteg:si_cliente
					WHERE empresa = pEmpresa
					AND numcte =  v_numcte;

					LET cod_ret = '000';  -- Existe numero de cliente
				ELSE
					LET cod_ret = '004';
				END IF;

			ELSE

				LET cod_ret = '005';  --Estatus diferente

			END IF ;

                    return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

            ELSE
                        LET cod_ret = '006';  -- No existe Folio Capturado
                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
            END IF;         

         ELSE
                        LET cod_ret = '001';  -- No existe numero de cliente pre-activado

                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

          END IF;



     ELSE 
                      LET cod_ret = '008'; --No existe el Cliente en la Tabla si_cliente
                       
                      return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

     END IF

    ELSE     

      IF pTipo = 1 THEN

        --IF EXISTS ( SELECT LIMIT 1 numcte INTO v_numcte FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta ) THEN
            SELECT LIMIT 1 numcte, tipo_tarjeta INTO v_numcte, vTipoTarjeta FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta;

       IF vTipoTarjeta = 'T' THEN
        IF  v_numcte <> ''  AND  v_numcte IS NOT NULL THEN

                IF EXISTS ( SELECT folio_contrato FROM bdinteg:si_bpiusuarios  WHERE numcte = v_numcte AND folio_contrato = pFolio) THEN

		    SELECT id_status INTO v_id_status FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = v_numcte;

			IF (v_id_status = 10) THEN

	            SELECT COUNT(a.numcte) INTO iCont FROM bdinteg:si_ctepf a, bdinteg:si_bpiusuarios b WHERE a.empresa = b.empresa AND a.numcte = b.numcte AND
	                    a.empresa = pEmpresa AND a.numcte = v_numcte AND a.fecha_nac = pFechaNac;

				IF iCont > 0 THEN
						Select  LIMIT 1 nombre1, nombre2, apell_paterno, apell_materno
						 INTO v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
						  from bdinteg:si_cliente
						where numcte = v_numcte;
						--WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta);

						LET v_numtarjeta = pTarjeta;

						LET cod_ret = '000';  -- Existe numero de Tarjeta de Credito
				 ELSE
						LET cod_ret = '004';
				 END IF;

			ELSE

				LET cod_ret = '005';  --Estatus diferente

			END IF ;
               
                     return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

                ELSE
                         LET cod_ret = '006';  -- No existe Folio Capturado
                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
                END IF;

         ELSE
                        LET cod_ret = '002';  -- No existe numero de Tarjeta de Credito

                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

         END IF;
       ELSE
            LET cod_ret = '007';  -- La Tarjete No es del Titular

            return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

       END IF;  

     ELSE

        --IF EXISTS ( SELECT LIMIT 1 numcte INTO v_numcte FROM bdicheq:sc_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta ) THEN
        SELECT LIMIT 1 numcte, tipo_tarjeta INTO v_numcte, vTipoTarjeta FROM bdicheq:sc_tarjeta WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta;

        IF vTipoTarjeta = 'T' THEN
        IF  v_numcte <> ''  AND  v_numcte IS NOT NULL THEN

              IF EXISTS ( SELECT folio_contrato FROM bdinteg:si_bpiusuarios  WHERE numcte = v_numcte AND folio_contrato = pFolio) THEN

			SELECT id_status INTO v_id_status FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = v_numcte;

			IF (v_id_status = 10) THEN

	            SELECT COUNT(a.numcte) INTO iCont FROM bdinteg:si_ctepf a, bdinteg:si_bpiusuarios b WHERE a.empresa = b.empresa AND a.numcte = b.numcte AND
	                    a.empresa = pEmpresa AND a.numcte = v_numcte AND a.fecha_nac = pFechaNac AND b.id_status = 10;

                IF iCont > 0 THEN
                       Select  LIMIT 1 nombre1, nombre2, apell_paterno, apell_materno
                         INTO   v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
                          from bdinteg:si_cliente
                        where numcte = v_numcte;
                        --WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta);

                        LET v_numtarjeta = pTarjeta;

                        LET cod_ret = '000';  -- Existe numero de Tarjeta de Debito
                 ELSE
                        LET cod_ret = '004';
                 END IF;

			ELSE

				LET cod_ret = '005';  --Estatus diferente

			END IF ;

                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
              ELSE
                         LET cod_ret = '006';  -- No existe Folio Capturado
                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
                END IF;          
         ELSE
                        LET cod_ret = '003';  -- No existe numero de Tarjeta de Debito

                        return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;

         END IF;
       ELSE
              LET cod_ret = '007';  -- La Tarjeta no es del Titular

              return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status;
       END IF;

     END IF;

END IF;


       return cod_ret,v_numcte, v_numtarjeta, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_id_status  WITH RESUME;

end
end procedure;