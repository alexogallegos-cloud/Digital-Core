CREATE PROCEDURE "informix".sp_medalia_vent(pEmpresa VARCHAR(3))
RETURNING VARCHAR(5), VARCHAR(5), VARCHAR(50), INTEGER;
   DEFINE Sql_Err              INTEGER;
   DEFINE Isam_Err             INTEGER;
   DEFINE Desc_Err             VARCHAR(80);
   DEFINE vCodRet1             VARCHAR(5);
   DEFINE vCodRet2             VARCHAR(5);
   DEFINE vCodRet3             VARCHAR(80);
   DEFINE vComienza            INTEGER;
   DEFINE vEnTransacc          SMALLINT;
   DEFINE vComienza2           INTEGER;
   DEFINE vEnTransacc2         SMALLINT;
   DEFINE vContador1           INTEGER;
   DEFINE vContador2           INTEGER;
   DEFINE iContar_registros    INTEGER;
   DEFINE vFechaHoy            DATE;
   DEFINE vfecha_ant           DATE;
   DEFINE vCuenta              VARCHAR(20);
   DEFINE vNumCliente          VARCHAR(20);
   DEFINE vNombreCliente       VARCHAR(120);
   DEFINE vsql                 LVARCHAR(1200);
   DEFINE vstmt                VARCHAR(250);
   DEFINE vfecha               VARCHAR(10);
   DEFINE vSucursal            VARCHAR(4);
   DEFINE vnombre1             VARCHAR(30);
   DEFINE vnombre2             VARCHAR(30);
   DEFINE vapell_paterno       VARCHAR(30);
   DEFINE vapell_materno       VARCHAR(30);
   DEFINE vfech_alt            DATE;
   DEFINE vtransacc            VARCHAR(4);
   DEFINE vnombre_suc          VARCHAR(40);
   DEFINE vfecha_nac           DATE;
   DEFINE vsexo                VARCHAR(1);
   DEFINE ves_fisica           VARCHAR(1);
   DEFINE vcorreo              VARCHAR(100);
   DEFINE vtel_casa            VARCHAR(13);
   DEFINE vtel_movil           VARCHAR(13);
   DEFINE vtpo_persona         VARCHAR(2);
   DEFINE vgenero              VARCHAR(10);
   DEFINE vfecha_mov           VARCHAR(10);
   DEFINE vedad                INTEGER;
   DEFINE vtpo_transacc        VARCHAR(80);
   DEFINE vnumero_cajero       VARCHAR(8);
   DEFINE vnumero_usuario       VARCHAR(8);
   DEFINE vNumero_producto     VARCHAR(4);
   DEFINE vtpo_producto	       VARCHAR(4);
   DEFINE vproductoc	       VARCHAR(4);
   DEFINE vproductot	       VARCHAR(4);
   DEFINE vproductop	       VARCHAR(4);
   DEFINE vproducto1	       VARCHAR(4);
   DEFINE vproducto2	       VARCHAR(4);
   DEFINE vproducto3	       VARCHAR(4);
   DEFINE vproducto4	       VARCHAR(4);
   DEFINE vproducto5	       VARCHAR(4);
   DEFINE vproducto6	       VARCHAR(4);
   DEFINE vproducto7	       VARCHAR(4);
   DEFINE vproducto8	       VARCHAR(4);
   DEFINE vproducto9	       VARCHAR(4);
   DEFINE vproducto10	       VARCHAR(4);
   DEFINE vproducto11sol       INTEGER;
   DEFINE vproducto11	       VARCHAR(4);
   DEFINE vproducto12	       VARCHAR(4);
   DEFINE vproducto13	       VARCHAR(4);
   DEFINE vproducto14	       VARCHAR(4);
   DEFINE vproducto15	       VARCHAR(4);
   DEFINE vproducto16sol       INTEGER;
   DEFINE vproducto16	       VARCHAR(4);
   DEFINE vproducto17	       VARCHAR(4);
   DEFINE vproducto18	       VARCHAR(4);
   DEFINE vproducto19sol       INTEGER;
   DEFINE vproducto19	       VARCHAR(4);
   DEFINE vproducto20	       VARCHAR(4);
   DEFINE vproducto21sol       INTEGER;
   DEFINE vproducto21	       VARCHAR(4);
   DEFINE vproducto22sol       INTEGER;
   DEFINE vproducto22	       VARCHAR(4);
   DEFINE vproducto24c_p       INTEGER;
   DEFINE vproducto24	       VARCHAR(4);
   DEFINE vnumctebanca	       VARCHAR(9);
   DEFINE vproducto25 	       VARCHAR(4);
   DEFINE vnombre_cajero       VARCHAR(100);

   DEFINE vl_num_cte           VARCHAR(20);
   DEFINE vl_cuenta            VARCHAR(20);
   DEFINE vl_empresa           VARCHAR(3);
   DEFINE vl_fech_alt          DATE;
   DEFINE vl_cancelad          CHAR(1);
   DEFINE vl_transacc          CHAR(4);
   DEFINE vl_estatus           SMALLINT;
   DEFINE vl_rowid             INTEGER;
   DEFINE iNum_reg_actuales    INTEGER;
   DEFINE iNum_reg_uni		   INTEGER;
   DEFINE vDescripcion         VARCHAR(55);
   
   DEFINE vNumero_cte           VARCHAR(20);
   DEFINE vNumero_cuenta        VARCHAR(20);
   
   

   LET Sql_Err	        = 0;
   LET Isam_Err         = 0;
   LET Desc_Err         = '';
   LET vCodRet1         = '00000';
   LET vCodRet2         = '';
   LET vCodRet3         = '';
   
   LET vComienza        = -1;
   LET vEnTransacc      = 0;
   LET vComienza2       = -1;
   LET vEnTransacc2     = 0;
   LET vContador1       = 0;
   LET vContador2       = 0;
   LET iContar_registros = 0;
   
   LET vFechaHoy        = '';
   LET vCuenta          = '';
   LET vNumCliente      = '';
   LET vsql             = '';
   LET vstmt            = '';
   LET vfecha           = '';
   LET vSucursal        = '';
   LET vnombre1         = '';
   LET vnombre2         = '';
   LET vapell_paterno   = '';
   LET vapell_materno   = '';
   LET vfech_alt        = '';
   LET vfecha_ant       = '';
   LET vtransacc        = '';
   LET vnombre_suc      = '';
   LET vfecha_nac       = '';
   LET vsexo            = '';
   LET ves_fisica       = '';
   LET vcorreo          = '';
   LET vtel_casa        = '';
   LET vtel_movil       = '';
   LET vtpo_persona     = '';
   LET vgenero          = '';
   LET vfecha_mov       = '';
   LET vedad            = 0;
   LET vtpo_transacc    = '';
   LET vnumero_cajero   = '';
   LET vtpo_producto	= '';
   LET vproductoc       = '';
   LET vproductot       = '';
   LET vproductop       = '';
   LET vproducto1       = '';
   LET vproducto2   	= '';
   LET vproducto3       = '';
   LET vproducto4       = '';
   LET vproducto5       = '';
   LET vproducto6       = '';
   LET vproducto7       = '';
   LET vproducto8       = '';
   LET vproducto9       = '';
   LET vproducto10      = '';
   LET vproducto11sol	= 0;
   LET vproducto11      = '';
   LET vproducto12      = '';
   LET vproducto13      = '';
   LET vproducto14      = '';
   LET vproducto15      = '';
   LET vproducto16sol	= 0;
   LET vproducto16      = '';
   LET vproducto17      = '';
   LET vproducto18      = '';
   LET vproducto19sol	= 0;
   LET vproducto19      = '';
   LET vproducto20      = '';
   LET vproducto21sol	= 0;
   LET vproducto21      = '';
   LET vproducto22sol	= 0;
   LET vproducto22      = '';
   LET vnumctebanca     = '';
   LET vproducto24c_p	= 0;
   LET vproducto24      = '';
   LET vproducto25      = '';
   LET vnombre_cajero  	= '';

   LET vl_num_cte       = "";
   LET vl_cuenta        = "";
   LET vl_empresa       = "";
   LET vl_fech_alt      = "";
   LET vl_cancelad      = "";
   LET vl_transacc      = "";
   LET vl_estatus       = 0;
   LET vl_rowid         = 0;
   LET iNum_reg_actuales = 0;
   LET iNum_reg_uni     = 0;
   LET vnumero_usuario = '';
   LET vDescripcion  = '';
   LET vNumero_cte  = '';
   LET vNumero_cuenta = '';
   LET vNumero_producto = '';
   

   /*
	Se realizÃ³ ReingenierÃ­a al SPL, se optimizaron bÃºsquedas, se re organizo la bÃºsqueda de registros.
    ModificaciÃ³n por: Ivan LÃ³pez Escorza Bancoppel - Gerencia de Mantenimiento I - CaptaciÃ³n.  
    */

   BEGIN
      ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
         IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            LET vCuenta = vCuenta;
            LET vNumCliente = vNumCliente;

            -- Se habilita DEBUGER en caso de excepciones (ERROR)
            SET DEBUG FILE TO "/resplogifx/conciliachq/medalia/sp_medalia_vent.err";
            TRACE ON;

            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
         END IF;
      END EXCEPTION;

      SET ISOLATION TO DIRTY READ;
      SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_medalia_vent.out";
    --TRACE ON;
   
      SELECT fecha_hoy, fecha_ant
	  INTO vFechaHoy, vfecha_ant
	  FROM bdicheq:sc_fechas
      WHERE empresa = pEmpresa;

	--LET vFechaHoy = '12/08/2025';--Para pruebas
    --LET vfecha_ant = '12/07/2025';--Para pruebas

		 --Realizamos Truncate a la tabla Final 'sc_medalia_ctes_vent' y a la tabla 'uni_cte_cuenta' que contendrÃ¡ el universo inicial de registros 
		TRUNCATE TABLE bdicheq:uni_cte_cuenta;
		TRUNCATE TABLE bdicheq:sc_medalia_ctes_vent;
		
		 
		 
		UPDATE STATISTICS MEDIUM FOR TABLE uni_cte_cuenta;
		UPDATE STATISTICS MEDIUM FOR TABLE sc_medalia_ctes_vent;
		 
		 
			 --Cargamos registros Iniciales
		 FOREACH cur_universo WITH HOLD FOR 

			--Se usa Directiva porque se presenta Sequential Scan
			SELECT {+INDEX(sc_movdia_concil idx_movdiaconc_1)} 
			mae.num_cte, mae.cuenta, mov.fech_alt, mov.cancelad, mov.transacc,mov.sucursal,mov.usuario,mae.producto,trx.descripcion
			INTO vl_num_cte, vl_cuenta, vl_fech_alt, vl_cancelad, vl_transacc ,vSucursal,vnumero_usuario,vNumero_producto,vtpo_transacc
			FROM bdicheq:sc_movdia_concil mov, bdicheq:sc_maechq mae,bdinteg:si_sucursales suc, bdicheq:sc_medalia_trxs_vent trx
			WHERE  mov.fech_alt = vfecha_ant
			AND    mov.cancelad <> 'S'
			AND    mov.transacc = trx.transacc 
			AND    mae.cuenta   = mov.cuenta     
			AND    suc.sucursal = mov.sucursal 
			AND    suc.tpo_sucursal = 'S'
			AND    suc.sucursal NOT IN ('5003','5008','5007','5011','6700')
			
			UNION ALL
			--Se tiene Sequential Scan en la tabla 'sc_medalia_trxs_vent_cred' , porque son solo 5 registros.Usando Directiva se obtiene 'DIRECTIVES NOT FOLLOWED'
			SELECT {+INDEX sc_medalia_trxs_vent_cred sc_medalia_trxs_vent_cred_trx}
			a.numcte,b.num_credito,b.fecha_mov,b.reversado,b.transacc_suc,b.sucursal,b.usuario,b.num_producto,trx.descripcion
			FROM bdicred:sd_maecred a
			INNER JOIN bdicred:sd_movhis b on (a.empresa = b.empresa AND b.fecha_mov = vfecha_ant AND b.reversado = 'N' and a.num_credito = b.num_credito)
			INNER JOIN bdicheq:sc_medalia_trxs_vent_cred trx on (b.codigo_fun = trx.codigo_fun and b.codigo_ref = trx.codigo_ref)
			INNER JOIN bdinteg:si_sucursales suc on(suc.sucursal = b.sucursal)
			WHERE a.empresa = '001'
			AND suc.sucursal NOT IN ('5003','5008','5007','5011','6700')
			GROUP BY 1,2,3,4,5,6,7,8,9
			
			
				IF (vComienza = -1) THEN
				   LET vComienza = 0;
				   LET vEnTransacc = 1;
				   BEGIN WORK;
				END IF;

				INSERT INTO uni_cte_cuenta(num_cte, cuenta, fech_alt, cancelad, transacc,sucursal,usuario,producto,descripcion)
							   VALUES (vl_num_cte, vl_cuenta, vl_fech_alt, vl_cancelad, vl_transacc,vSucursal,vnumero_usuario,vNumero_producto,vtpo_transacc);

				--MANEJO DE TRANSACCIONES 
				LET vContador1 = vContador1 + 1;
				
				IF vContador1 >= 10000 THEN
					LET vContador1 = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			
		 END FOREACH; -- cur_universo
		 
	    IF (vEnTransacc = 1) THEN
            LET vEnTransacc = 0;
            COMMIT WORK;
         END IF;

		LET vNumero_cte  = '';
		LET vNumero_cuenta = '';

		FOREACH cur_RR WITH HOLD FOR
		
			SELECT DISTINCT a.num_cte,a.cuenta 
			INTO vNumero_cte,vNumero_cuenta
			FROM uni_cte_cuenta a
			
		
		  FOREACH WITH HOLD --Ciclo para cada movimiento del cliente del dÃ­a en la sucursal
		  
			SELECT ucc.num_cte, ucc.cuenta,ucc.sucursal,ucc.fech_alt,ucc.transacc,suc.nombre,ucc.descripcion,ucc.producto,ucc.usuario
			INTO vNumCliente,vCuenta, vSucursal, vfech_alt, vtransacc,vnombre_suc, vtpo_transacc,vtpo_producto, vnumero_cajero
			FROM uni_cte_cuenta ucc 
			LEFT JOIN  bdinteg:si_sucursales suc ON(ucc.sucursal=suc.sucursal)
			WHERE ucc.num_cte = vNumero_cte
			AND ucc.cuenta = vNumero_cuenta
			
			LET vnombre_suc = TRIM(vnombre_suc); 
			LET vtpo_transacc = TRIM(vtpo_transacc);
            LET vfecha_mov = TO_CHAR(vfech_alt, '%d/%m/%Y');


				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');

		  
			--Se obtiene informaciÃ³n del cliente
			  SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno,
					 cpf.fecha_nac, cpf.sexo, tip.es_fisica, mail.correo_elec, tel1.telefono, tel2.telefono
			  INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_nac, vsexo, ves_fisica, vcorreo, vtel_casa, vtel_movil
			  FROM bdinteg:si_cliente cte
			  INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
			  INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
			  LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia =(SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A')) LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
			  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V')
			  WHERE cte.numcte = vNumCliente;

				  IF ( vtel_movil is null OR vtel_movil = '' ) THEN
					 CONTINUE FOREACH;
				  END IF;

				  LET vnombre1       = TRIM(NVL(vnombre1,''));
				  LET vnombre2       = TRIM(NVL(vnombre2,''));
				  LET vapell_paterno = TRIM(NVL(vapell_paterno,''));
				  LET vapell_materno = TRIM(NVL(vapell_materno,''));
				  LET vcorreo        = TRIM(NVL(vcorreo,''));
				  LET vtel_casa      = TRIM(NVL(vtel_casa,''));
				  LET vtel_movil     = TRIM(NVL(vtel_movil,''));

				  IF ves_fisica = 'S' THEN
					 LET vtpo_persona = 'PF';
				  ELSE
					 LET vtpo_persona = 'PM';
				  END IF;

				  IF vsexo = 'F' THEN
					 LET vgenero = 'FEMENINO';
				  ELSE
					 LET vgenero = 'MASCULINO';
				  END IF;

			  LET vedad          = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
			  LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
			  LET vNombreCliente = TRIM(vNombreCliente);
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
			  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
			  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
			  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');


				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
				 LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');

			     --Producto_1, Producto_2, Producto_3, Producto_4, Producto_5, Producto_6
						 
							SELECT FIRST 1 producto
							INTO vproductoc
							FROM bdicheq:sc_maechq
							WHERE num_cte = vNumCliente
							AND status_cta in('1','3','4','5');

							IF vproductoc = '1100' THEN
							   LET vproducto1 = 'SI';
							ELSE
							   LET vproducto1 = 'null';
							END IF;

							IF vproductoc = '1400' then
							   LET vproducto2 = 'SI';
							ELSE
							   LET vproducto2 = 'null';
							END IF;

							IF vproductoc = '1700' then
							   LET vproducto3 = 'SI';
							ELSE
							   LET vproducto3 = 'null';
							END IF;

							IF vproductoc = '1900' then
							   LET vproducto4 = 'SI';
							ELSE
							   LET vproducto4 = 'null';
							END IF;

							IF vproductoc = '2000' then
							   LET vproducto5 = 'SI';
							ELSE
							   LET vproducto5 = 'null';
							END IF;

							IF vproductoc = '2500' then
							   LET vproducto6 = 'SI';
							ELSE
							   LET vproducto6 = 'null';
							END IF;
						
							LET vtpo_producto = vtpo_producto;
							 --Pagare
							 
							 SELECT FIRST 1 cod_instrum
							 INTO vproducto7
							 FROM bdinvers:sv_maeinv
							 WHERE empresa = '001'
							 AND num_cte = vNumCliente
							 AND status_cta = '1';

							 IF vproducto7 = '1100' THEN
								LET vproducto7 = 'SI';
							 ELSE
								LET vproducto7 = 'null';
							 END IF;

			     --Producto_9, Producto_10,Producto_12,Producto_13,Producto_14,Producto_15
									
							 SELECT FIRST 1 num_producto
							 INTO vproductot
							 FROM bdicred:sd_maecredcrd
							 WHERE numcte = vNumCliente
							 AND status_cred in ('AA','BA','BT','E1','E2','E3');

							IF vproductot = '6400' THEN
								LET vproducto9 = 'SI';
							ELSE
								LET vproducto9 = 'null';
							END IF;

							IF vproductot = '6011' THEN
								LET vproducto10 = 'SI';
							ELSE
								LET vproducto10 = 'null';
							END IF;

							IF vproductot = '6300' then
								LET vproducto12 = 'SI';
							ELSE
								LET vproducto12 = 'null';
							END IF;

							IF vproductot = '7600' then
								LET vproducto13 = 'SI';
							ELSE
								LET vproducto13 = 'null';
							END IF;

							IF vproductot = '7700' then
								LET vproducto14 = 'SI';
							ELSE
								LET vproducto14 = 'null';
							END IF;

							IF vproductot = '6800' then
								LET vproducto15 = 'SI';
							ELSE
								LET vproducto15 = 'null';
							 END IF;
	

							SELECT FIRST 1  numcte
							INTO vproducto11sol
							FROM bdisolic:ss_solicitudes
							WHERE empresa = '001'
							AND status_solicitud not in ('CN','AN')
							AND num_producto in ('6300','7600','7700')
							AND numcte = vNumCliente;

							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								LET vproducto11 = 'SI';
							ELSE
								LET vproducto11 = 'null';
							END IF;


							SELECT FIRST 1 numcte
							INTO vproducto16sol
							FROM bdisolic:ss_solicitudes
							WHERE empresa = '001'
							AND status_solicitud not in ('CN','AN')
							AND num_producto in ('6001')
							AND numcte = vNumCliente
							AND num_solicitud <> vCuenta;
							 
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								LET vproducto16 = 'SI';
							ELSE
								LET vproducto16 = 'null';
							END IF;

			 
							SELECT FIRST 1 numcte
							INTO vproducto19sol
							FROM bdisolic:ss_solicitudes
							WHERE empresa = '001'
							AND status_solicitud not in ('CN','AN')
							AND num_producto in ('8500')
							AND numcte = vNumCliente;
							 
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								LET vproducto19 = 'SI';
							ELSE
								LET vproducto19 = 'null';
							END IF;


				 --Producto_17, Producto_18, Producto_20, Producto_8
							SELECT  FIRST 1 num_producto
							INTO vproductop
							FROM bdicred:sd_maecred
							WHERE  numcte = vNumCliente
							AND status_cred IN("AA", "BA", "BT", "E1","E2","E3");

							IF vproductop = '6001' THEN
							   LET vproducto17 = 'SI';
							ELSE
							   LET vproducto17 = 'null';
							END IF;

							IF vproductop = '6600' then
							   LET vproducto18 = 'SI';
							ELSE
							   LET vproducto18 = 'null';
							END IF;

							IF vproductop = '8500' then
							   LET vproducto20 = 'SI';
							ELSE
							   LET vproducto20 = 'null';
							END IF;

							IF vproductop = '7800' then
							   LET vproducto8 = 'SI';
							   LET vproducto8 = 'null';
							END IF;

			 
							SELECT FIRST 1 numcte
							INTO vproducto21sol
							FROM bdisolic:ss_solicitudes
							WHERE 
							 --AND status_solicitud not in ('CN','AN','AP')
							 status_solicitud in ('AT','BC','CC','CE','CM','EC','EE','IN','LC','MC','OA','OS','PA','PC','RT','ST')
							AND num_producto in ('6500')
							AND numcte = vNumCliente;
							
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
									LET vproducto21 = 'SI';
							ELSE
									LET vproducto21 = 'null';
							END IF;
							 
							 
							SELECT FIRST 1 numcte
							INTO vproducto22sol
							FROM bdisolic:ss_solicitudes
							WHERE status_solicitud = 'AP'
							AND num_producto in ('6500')
							AND numcte = vNumCliente;
							 
			 
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
									LET vproducto22 = 'SI';
							ELSE
									LET vproducto22 = 'null';
							END IF;


				 --Producto_25	Banca ElectrÃ³nica
							SELECT FIRST 1 bpi.numcte
							INTO vnumctebanca
							FROM bdinteg:si_bpiusuarios  bpi
							WHERE bpi.empresa='001'
							AND bpi.numcte = vNumCliente
							AND  bpi.id_status NOT IN ('0','1','2','3','4');
							 
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								LET vproducto25 = 'SI';
							ELSE
								LET vproducto25 = 'null';
							END IF;


							--Obtener nombre del promotor
							SELECT nombre
							INTO vnombre_cajero
							FROM bdinteg:si_ejecut
							WHERE ejecutivo = vnumero_cajero;

							LET vnombre_cajero = TRIM(vnombre_cajero);

							IF ((nvl(vSucursal,'') <> '') AND LENGTH(vSucursal) = 4 ) AND ( nvl(vnombre_suc,'') <> '') AND
								(nvl(vNumCliente,'') <> '') AND (nvl(vtransacc,'') <> '') AND (nvl(vtpo_transacc,'') <> '') AND
								(nvl(vfech_alt,'') <> '')  AND (nvl(vNombreCliente,'') <> '') THEN
						  
								 IF (vComienza2 = -1) THEN
									LET vComienza2 = 0;
									LET vEnTransacc2 = 1;
									BEGIN WORK;
								 END IF;
								LET vtpo_producto = vtpo_producto;
								
								
								INSERT INTO sc_medalia_ctes_vent (fecha_insert, sucursal, nombre_suc, tpo_sistema, nombre_cte,
												   apell_paterno, apell_materno, numcte, correo, transacc,
												   tpo_producto, tpo_transacc, fecha_mov, tel_movil, tel_casa,
												   genero, edad, segmento, tpo_persona, producto1, producto2,
												   producto3, producto4, producto5, producto6, producto7,
												   producto8, producto9, producto10, producto11, producto12,
												   producto13, producto14, producto15, producto16, producto17,
												   producto18, producto19, producto20, producto21, producto22,
												   producto23, producto24, producto25, producto26, numero_cajero,
												   nombre_cajero)
										   VALUES (vFechaHoy, vSucursal, vnombre_suc, 'null', vNombreCliente, vapell_paterno, vapell_materno,
												   vNumCliente, vcorreo, vtransacc, vtpo_producto, vtpo_transacc, vfecha_mov, vtel_movil,
												   vtel_casa, vgenero, vedad, 'null', vtpo_persona, vproducto1, vproducto2, vproducto3,
												   vproducto4, vproducto5, vproducto6, 'null', vproducto8, vproducto9, vproducto10,
												   vproducto11, vproducto12, vproducto13, vproducto14, vproducto15, vproducto16, vproducto17,
												   vproducto18, vproducto19, vproducto20, vproducto21, vproducto22, 'null', 'null', vproducto25,
												   'null', vnumero_cajero, vnombre_cajero);		   

		   
								 -- MANEJO DE TRANSACCION
								 LET vContador2 = vContador2 + 1;
						
								 IF vEnTransacc2 >= 1 THEN
									LET vContador2 = 0;
									COMMIT WORK;
									BEGIN WORK;
									
								 END IF;
							END IF;

			  
						LET iContar_registros = iContar_registros + 1;
						   IF (vEnTransacc2 = 1) THEN
							  LET vEnTransacc2 = 0;
							  COMMIT WORK;
						   END IF;
		  END FOREACH;
		END FOREACH; -- cierra cur_RR
   
		LET vfecha = TO_CHAR(vfecha_ant, '%d_%m_%Y');

		LET vsql = '';

		LET vsql = 'echo "NUMERO_SUCURSAL|NOMBRE_SUCURSAL|TIPO_SISTEMA|NOMBRE_CLIENTE|APELLIDOPATERNO_CLIENTE|APELLIDOMATERNO_CLIENTE|NUMERO_CLIENTE|EMAIL_CLIENTE|' || 'ID_TRANSACCION|TIPO_PRODUCTO|TIPO_TRANSACCION|FECHA_TRANSACCION|TELEFONO_CEL|TELEFONO_FIJO|GENERO_CLIENTE|EDAD_CLIENTE|SEGMENTO_CLIENTE|TIPO_PERSONA|' || 'PRODUCTO_1|PRODUCTO_2|PRODUCTO_3|PRODUCTO_4|PRODUCTO_5|PRODUCTO_6|PRODUCTO_7|PRODUCTO_8|PRODUCTO_9|PRODUCTO_10|PRODUCTO_11|PRODUCTO_12|PRODUCTO_13|' || 'PRODUCTO_14|PRODUCTO_15|PRODUCTO_16|PRODUCTO_17|PRODUCTO_18|PRODUCTO_19|PRODUCTO_20|PRODUCTO_21|PRODUCTO_22|PRODUCTO_23|PRODUCTO_24|PRODUCTO_25|PRODUCTO_26|NUMERO_CAJERO|NOMBRE_CAJERO" ' || '> /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_' || vfecha || '.csv.enc';

		SYSTEM vsql;
		LET vsql = '';

		LET vsql = '';

		LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv.det '|| 'SELECT sucursal, REPLACE(REPLACE(trim(nombre_suc),''SUC '',''''),''SUC. '',''''), tpo_sistema, nombre_cte, apell_paterno, apell_materno, numcte, correo, '||'transacc, tpo_producto, tpo_transacc, fecha_mov, tel_movil, tel_casa, genero, edad, segmento, tpo_persona, '||'producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, producto10, producto11, producto12, producto13, '||'producto14, producto15, producto16, producto17, producto18, producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, numero_cajero, nombre_cajero '||'FROM sc_medalia_ctes_vent '||'WHERE fecha_insert = '''||vFechaHoy||''' " >  /resplogifx/conciliachq/medalia/vent_medalia.sql';

		SYSTEM vsql;
		LET vsql = '';

		LET vstmt = '';
		LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/medalia/vent_medalia.sql";
		SYSTEM vstmt;
		LET vstmt = '';

		LET vsql = '';
		LET vsql = 'cat /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv.enc /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv.det > /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv';
		SYSTEM vsql;
		LET vsql = '';

		LET vsql = '';
		LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv.enc';
		SYSTEM vsql;
		LET vsql = '';

		LET vsql = '';
		LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_vent_invitacion_'||vfecha||'.csv.det';
		SYSTEM vsql;
		LET vsql = '';
		
		LET vsql = '';
		LET vsql = 'rm /resplogifx/conciliachq/medalia/vent_medalia.sql';
		SYSTEM vsql;
		LET vsql = '';

   END;
   RETURN vCodRet1, vCodRet2, vCodRet3, iContar_registros;
END PROCEDURE;