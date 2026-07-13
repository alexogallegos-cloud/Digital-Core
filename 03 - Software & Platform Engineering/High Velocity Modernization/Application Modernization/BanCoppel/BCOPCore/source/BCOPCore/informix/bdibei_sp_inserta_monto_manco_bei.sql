CREATE PROCEDURE "informix".sp_inserta_monto_manco_bei(
pIdusuario INTEGER,
pNumCliente CHAR(9),
tipo_mov SMALLINT,
prestricc CHAR(2),
pcuenta CHAR(16),
poperacionPropias CHAR(2),
plimitePropias DECIMAL(16,2),
poperacionTerceros CHAR(2),
plimiteTerceros DECIMAL(16,2),
poperacionSPEI CHAR(2),
plimiteSPEI DECIMAL(16,2)

)returning char(5),INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
  	DEFINE Id_adminMancoTemp INTEGER;
    LET cod_ret  = "00000";
    LET Id_adminMancoTemp  = 0;


	--****************************************************************************************************
	-- DESCRIPCION:  Inserta Mancomunidad Administracion Montos
	-- AUTOR : Alfonso Ponce - SOLSER
	-- FECHA : 05/01/2015
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015

	-- MODIFICACION: Se agrega filtro extra para bei_admin_manco_montos_temp por prestricc
	-- FECHA PRODUCCION: 30 Junio 2015
	--***************************************************************************************************
	


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret,Id_adminMancoTemp;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;


	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Numero de Cliente
            RETURN cod_ret,Id_adminMancoTemp;
	END IF;

    IF NVL(pIdusuario,0) == 0 THEN
	 	  LET cod_ret = '00002'; -- No contiene Id Usuario
           RETURN cod_ret,Id_adminMancoTemp;
	END IF;

	IF NVL(tipo_mov,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Dato tipo movimiento
            RETURN cod_ret,Id_adminMancoTemp;
	END IF;

    IF NOT EXISTS(
                   select num_cliente from "informix".bei_admin_manco_montos_temp
                   where num_cliente=pNumCliente
                   and id_usuario=pIdusuario
                   and restricc=prestricc
     ) THEN

                    INSERT INTO "informix".bei_admin_manco_temp(
                        id_admin_manco,
                        num_cliente_admin,
                        id_usuario_admin,
                        tipo_oper,
                        tipo_mov,
                        num_cliente
                     )
                    VALUES(
                        0,
                        pNumCliente,
                        pIdusuario,
                        3,
                        tipo_mov,
                        pNumCliente
                    );
                    LET Id_adminMancoTemp = DBINFO('sqlca.sqlerrd1');


                 IF NVL(prestricc,'') == '' THEN
                        IF tipo_mov == 1 THEN
                            LET cod_ret = '00004'; -- No contiene Restriccion de movimiento
                            RETURN cod_ret,Id_adminMancoTemp;
                        END IF;
                END IF;


                IF NVL(poperacionPropias,'') == '' THEN
                        IF tipo_mov == 1 THEN
                            LET cod_ret = '00005'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                        END IF;
                 END IF;


                IF NVL(plimitePropias,'') = '' OR plimitePropias IS NULL THEN
                    IF tipo_mov == 1 THEN
                            LET cod_ret = '00006'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                     END IF;
                 END IF;

                IF NVL(poperacionTerceros,'') == '' THEN
                        IF tipo_mov == 1 THEN
                            LET cod_ret = '00005'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                        END IF;
                 END IF;


                IF NVL(plimiteTerceros,'') = '' OR plimiteTerceros IS NULL THEN
                    IF tipo_mov == 1 THEN
                            LET cod_ret = '00006'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                     END IF;
                 END IF;

                IF NVL(poperacionSPEI,'') == '' THEN
                        IF tipo_mov == 1 THEN
                            LET cod_ret = '00005'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                        END IF;
                 END IF;


                IF NVL(plimiteSPEI,'') = '' OR plimiteSPEI IS NULL THEN
                    IF tipo_mov == 1 THEN
                            LET cod_ret = '00006'; -- No contiene Operacion
                            RETURN cod_ret,Id_adminMancoTemp;
                     END IF;
                 END IF;


                    INSERT INTO "informix".bei_admin_manco_montos_temp
                    VALUES(
                        Id_adminMancoTemp,
                        pIdusuario,
                        pNumCliente,
                        prestricc,
                        pcuenta,
                        poperacionPropias,
                        plimitePropias
                    );


                    INSERT INTO "informix".bei_admin_manco_montos_temp
                    VALUES(
                        Id_adminMancoTemp,
                        pIdusuario,
                        pNumCliente,
                        prestricc,
                        pcuenta,
                        poperacionTerceros,
                        plimiteTerceros
                    );

                    INSERT INTO "informix".bei_admin_manco_montos_temp
                    VALUES(
                        Id_adminMancoTemp,
                        pIdusuario,
                        pNumCliente,
                        prestricc,
                        pcuenta,
                        poperacionSPEI,
                        plimiteSPEI
                    );

        ELSE --Ya existe un registro
            LET cod_ret = '00007';
            RETURN cod_ret,Id_adminMancoTemp;
        END IF;        

         RETURN cod_ret,Id_adminMancoTemp;
END
END PROCEDURE;