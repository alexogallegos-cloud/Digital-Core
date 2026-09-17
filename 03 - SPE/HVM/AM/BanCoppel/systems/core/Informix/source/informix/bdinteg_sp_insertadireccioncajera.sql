create procedure "informix".sp_insertadireccioncajera(
                             pModo smallint,--1:GRABA DIRECCION PERSONAL,2:GRABA DIRECCION TRABAJO
                             pempresa char(3),
                             pnumcte char(20),
                             pentre_calles char(40),
                             pestado char(2),
                             pciudad char(3),
                             pcodpostal char(5),
                             ptipotel1 char(1),  
                             ptelefono1 char(13),--9  PARTICULAR
                             ptipotel2 char(1),  
                             ptelefono2 char(13),--11 CELULAR
                             ptipotel3 char(1),  
                             ptelefono3 char(13),--13 REFERENCIA
                             ptelefono4 char(13),--14 TRABAJO
                             pextension char(5),
                             pnoext char(10),
                             pnoint char(10),
                             pdepto char(6),
                             pnocalle integer,
                             pnocolonia integer,
                             ppuntocar char(1),
                             punihabi char(1),
                             pmanz smallint,
                             ppotros smallint,
                             pandador smallint,
                             petapa smallint,
                             plote smallint,
                             pedif smallint,
                             pentrada smallint,
                             pobserva char(80),
                             puser_insert char(8),
                             plugartrabajo char(60),
                             pTienda char(5),
                             pEmpleado char(20))
 returning char(5);

define v_codret char(5);
define v_pais char(3);
define v_ciudadcoppel smallint;
define v_municipio char(3);
define v_secuencia integer;
define v_secuencia2 integer;
define v_sqlerr, v_isamerr integer;
define v_cambio smallint;
define v_teltrabajo char(13);
define v_extension char(5);
--DSB 12/04/2011
DEFINE siOrigen SMALLINT;
--MACF 2011-09-05
define v_codret_tel char(5);

let v_pais = "000";
let v_secuencia = 0;
let v_secuencia2 = 0;
let v_ciudadcoppel = 0;
let v_municipio = "000";
let v_sqlerr = 0;
let v_isamerr = 0;
let v_codret = "000";
let v_cambio = 0;
let v_teltrabajo = "";
let v_extension = "";
--DSB 12/04/2011
LET siOrigen = 0;
--MACF 2011-09-05
let v_codret_tel = '00000';


--SET DEBUG FILE TO "/informix/macf/sp_insertadireccioncajera.trc";
--TRACE ON;

begin
   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         ROLLBACK WORK;
         return v_codret;
      end if;
   end exception;

BEGIN WORK;

	-- DSB 12/04/2011
	-- Se llena variable con el tipo de origen -> 1 = Tienda, 2 = Sucursal, 3 = CAT
	LET siOrigen = 1;

--TOMA EL PAIS Y LA CIUDAD COPPEL DE CATALOGO DE CIUDADES DEL BANCO PARA SU INSERCION EN EL SI_DIRECCIONES
        select pais,ciudad_coppel
        into v_pais,v_ciudadcoppel
        from bdinteg:si_ciudades
        where ciudad = pciudad and estado = pestado;
--SE TOMA EL TELEFONO DEL TRABAJO Y LA EXTENSION ACTUAL SI ES CAMBIO DE DOMICILIO DEL CTE 
--O LOS NUEVOS PARAMETROS SI ES CAMBIO DE DOMICILIO DEL TRABAJO
        if pModo = 1 then
            --select max(secuencia)
            --into v_secuencia
            --from bdinteg:si_direcciones
            --where numcte = pnumcte and tipo_dir = 2;
            
            --select telefono3,extension
            --into v_teltrabajo,v_extension
            --from bdinteg:si_direcciones
            --where numcte = pnumcte and tipo_dir = 2 and secuencia = v_secuencia;
            
            --tomar directamente el dato de direcciones_actual
            --select telefono3, extension
            --into v_teltrabajo, v_extension
            --from bdinteg:si_direcciones_actual
            --where numcte = pnumcte and tipo_dir = 2;
            
            SELECT telefono, extension INTO v_teltrabajo, v_extension  --2012/09/25 MACF
              FROM bdinteg:si_telefonos_actual
             WHERE numcte = pnumcte AND tipo_tel = 3;
            
        else
            let v_teltrabajo = ptelefono4;
            let v_extension = pextension;
        end if;

        --select max(secuencia)
        --into v_secuencia
        --from bdinteg:si_direcciones
        --where numcte = pnumcte;        
        
        select max(secuencia)
        into v_secuencia
        from bdinteg:si_direcciones_actual
        where numcte = pnumcte;
       
        --Validar que los teléfonos no tengan caractéres diferentes a números. MACF
  
        IF nvl(ptelefono1, '') <> '' THEN
            CALL bdinteg:"informix".sp_validar_telefono(ptelefono1) RETURNING v_codret_tel;
            IF v_codret_tel <> '00000' THEN let ptelefono1 = '';  END IF;
        END IF;
        
        IF nvl(ptelefono2, '') <> '' THEN
            CALL bdinteg:"informix".sp_validar_telefono(ptelefono2) RETURNING v_codret_tel;
            IF v_codret_tel <> '00000' THEN let ptelefono2 = '';  END IF;
        END IF;

        IF nvl(ptelefono3, '') <> '' THEN
            CALL bdinteg:"informix".sp_validar_telefono(ptelefono3) RETURNING v_codret_tel;
            IF v_codret_tel <> '00000' THEN let ptelefono3 = ''; END IF;
        END IF;

        IF pModo <> 1 THEN
            IF nvl(ptelefono4,'') <> '' THEN       
              CALL bdinteg:"informix".sp_validar_telefono(v_teltrabajo) RETURNING v_codret_tel;
              IF v_codret_tel <> '00000' THEN let v_teltrabajo = ''; END IF;
            END IF;
        END IF;
        --Validar que los teléfonos no tengan caractéres diferentes a números. MACF
               
        if pModo = 1 then

            if v_secuencia is null then
                let v_secuencia = 1;
            else
                let v_secuencia = v_secuencia + 1;
            end if;


/*
            insert into bdinteg:si_direcciones
                (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
                pais,estado,ciudad,municipio,cod_postal,apart_postal,
                tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
                numerociudad,numeroextcalle,numerointcalle,departamento,
                numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                user_insert,fecha_insert)
            values
                (pnumcte, v_secuencia, "1", "", "", pentre_calles,
                v_pais,pestado,pciudad, v_municipio, pcodpostal,"",
                ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,
                v_teltrabajo, v_extension ,"","","",
                v_ciudadcoppel,pnoext,pnoint,pdepto,
                pnocalle,pnocolonia,ppuntocar,punihabi,
                pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
                puser_insert,current); */
				
			 call "informix".direcciones( pEmpresa, 'A', 	pNumCte ,v_secuencia,  	1,		  "",         "",       v_municipio, pentre_calles,
                                     v_pais,   pestado, pciudad, pcodpostal,	ptipotel1,ptelefono1, ptipotel2,ptelefono2,  ptipotel3,
								     v_teltrabajo, 		v_extension, "",        "",       "",		  v_ciudadcoppel,pnoext,pnoint,
									 pdepto,   pnocalle,pnocolonia,ppuntocar,	punihabi, pmanz,	  ppotros,	pandador,	petapa,
									 plote,    pedif,	pentrada,	pobserva,	puser_insert, current, substr(pTienda,1,4), 1)
             returning v_codret;                                                                     
                                         				
				
-- DSB 11/04/2011
-- Se comenta código debido a que no se insertará el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de ésto se mandará llamar el sp_registramodifdomicilio
-- que insertará en la tabla si_bitacora_cambiosdom						
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--            insert into bdicobranza:cb_cambiosdomicilio
--                (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--                pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--                numerociudad,numeroextcalle,numerointcalle,departamento,
--                numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                user_insert,fecha_insert,tienda,empleado)
--            values
--                (pnumcte, v_secuencia, "1", "", "", pentre_calles,
--                v_pais,pestado,pciudad, v_municipio, pcodpostal,"",
--               ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,
--                v_teltrabajo, v_extension ,"","","",
--                v_ciudadcoppel,pnoext,pnoint,pdepto,
--                pnocalle,pnocolonia,ppuntocar,punihabi,
--                pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
--                puser_insert,current,pTienda,pEmpleado);

			EXECUTE PROCEDURE "informix".sp_registramodifdomicilio(pnumcte, siOrigen, pModo, v_secuencia, pTienda, 
														           current, puser_insert, pEmpleado)
						 INTO v_codret;
														
        end if;
        
--SI ES CAMBIO DE DOMICILIO DEL TRABAJO (pModo = 2) ENTONCES

        if pModo = 2 then           

           if v_secuencia is null then
               let v_secuencia = 1;
           else
               let v_secuencia = v_secuencia + 1;
           end if;

        /*
           insert into bdinteg:si_direcciones
             (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
	      pais,estado,ciudad,municipio,cod_postal,apart_postal,
	      tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
	      telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
	      numerociudad,numeroextcalle,numerointcalle,departamento,
	      numerocalle,numerocolonia,puntocardinal,unidadhabitac,
	      manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
	      user_insert,fecha_insert)
           values
             (pnumcte, v_secuencia, "2", "", "", pentre_calles,
              v_pais,pestado,pciudad, v_municipio, pcodpostal,"",
              ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,
              v_teltrabajo, v_extension ,"","","",
              v_ciudadcoppel,pnoext,pnoint,pdepto,
              pnocalle,pnocolonia,ppuntocar,punihabi,
              pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
              puser_insert,current);*/
		
			call "informix".direcciones( pEmpresa, 'A', 	pNumCte ,v_secuencia,  	2,		  "",         "",       v_municipio, pentre_calles,
                                     v_pais,   pestado, pciudad, pcodpostal,	ptipotel1,ptelefono1, ptipotel2,ptelefono2,  ptipotel3,
								     v_teltrabajo, 		v_extension, "",        "",       "",		  v_ciudadcoppel,pnoext,pnoint,
									 pdepto,   pnocalle,pnocolonia,ppuntocar,	punihabi, pmanz,	  ppotros,	pandador,	petapa,
									 plote,    pedif,	pentrada,	pobserva,	puser_insert, current, substr(pTienda,1,4), 1)
             returning v_codret;                                                                     
                                 		
			  
-- DSB 11/04/2011
-- Se comenta código debido a que no se insertará el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de ésto se mandará llamar el sp_registramodifdomicilio
-- que insertará en la tabla si_bitacora_cambiosdom			  
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--            insert into bdicobranza:cb_cambiosdomicilio
--             (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--	      pais,estado,ciudad,municipio,cod_postal,apart_postal,
--	      tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--	      telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--	      numerociudad,numeroextcalle,numerointcalle,departamento,
--	      numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--	      manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--	      user_insert,fecha_insert,tienda,empleado)
--          values
--             (pnumcte, v_secuencia, "2", "", "", pentre_calles,
--              v_pais,pestado,pciudad, v_municipio, pcodpostal,"",
--              ptipotel1,ptelefono1,ptipotel2,ptelefono2,ptipotel3,
--              v_teltrabajo, v_extension ,"","","",
--              v_ciudadcoppel,pnoext,pnoint,pdepto,
--              pnocalle,pnocolonia,ppuntocar,punihabi,
--              pmanz,ppotros,pandador,petapa,plote,pedif,pentrada,pobserva,
--              puser_insert,current,pTienda,pEmpleado);
														
			EXECUTE PROCEDURE "informix".sp_registramodifdomicilio(pnumcte, siOrigen, pModo, v_secuencia, pTienda, 
														           current, puser_insert, pEmpleado)
						 INTO v_codret;

--INSERTA NUEVO REGISTRO DE DIRECCION DEL CLIENTE SI ES QUE CAMBIO EL TEL DEL TRABAJO Y/O LA EXT
            --select max(secuencia)
            --into v_secuencia2
            --from bdinteg:si_direcciones
            --where numcte = pnumcte and tipo_dir = 1
			/*
            select secuencia
            into v_secuencia2
            from bdinteg:si_direcciones_actual
            where numcte = pnumcte and tipo_dir = 1;

            let v_cambio = 0;

            select 1 as sicambio
            into v_cambio 
            --from bdinteg:si_direcciones
            from bdinteg:si_direcciones_actual
            where numcte = pnumcte and secuencia = v_secuencia2 and ( trim(telefono3) != trim(v_teltrabajo) or trim(extension) != trim(v_extension) );

            if v_cambio = 1 then            

                if v_secuencia is null then
                    let v_secuencia = 1;
                else
                    let v_secuencia = v_secuencia + 1;
                end if;

                insert into bdinteg:si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                    telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
                    numerociudad,numeroextcalle,numerointcalle,departamento,
                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                    user_insert,fecha_insert)                
                select numcte,v_secuencia,tipo_dir,calle,colonia,entre_calles,
                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
                    v_teltrabajo,v_extension,estado_inegi,municipio_inegi,localidad_inegi,
                    numerociudad,numeroextcalle,numerointcalle,departamento,
                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
                    puser_insert,current 
                from bdinteg:si_direcciones where numcte = pnumcte and secuencia = v_secuencia2 and tipo_dir = 1;
-- DSB 11/04/2011
-- Se comenta código debido a que no se insertará el nuevo domicilio en la tabla
-- cb_cambiosdomicilio, en lugar de ésto se mandará llamar el sp_registramodifdomicilio
-- que insertará en la tabla si_bitacora_cambiosdom						
--SE GRABA LA MISMA INFORMACION EN LA NUEVA TABLA CB_CAMBIOSDOMICILIO
--                insert into bdicobranza:cb_cambiosdomicilio(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,
--                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                    telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,
--                    numerociudad,numeroextcalle,numerointcalle,departamento,
--                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                   user_insert,fecha_insert,tienda,empleado)                
--                select numcte,v_secuencia,tipo_dir,calle,colonia,entre_calles,
--                    pais,estado,ciudad,municipio,cod_postal,apart_postal,
--                    tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,
--                    v_teltrabajo,v_extension,estado_inegi,municipio_inegi,localidad_inegi,
--                    numerociudad,numeroextcalle,numerointcalle,departamento,
--                    numerocalle,numerocolonia,puntocardinal,unidadhabitac,
--                    manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,
--                    puser_insert,current,pTienda,pEmpleado 
--                from bdinteg:si_direcciones where numcte = pnumcte and secuencia = v_secuencia2 and tipo_dir = 1;
														
			EXECUTE PROCEDURE "informix".sp_registramodifdomicilio(pnumcte, siOrigen, pModo, v_secuencia, pTienda, 
														           current, puser_insert, pEmpleado)
						 INTO v_codret;														
														
            end if;*/
--AQUI SE INSERTA EL NUEVO REGISTRO DE SI_INGRESOS POR EL CAMPO LUGAR DE TRABAJO (NOMBRE_EMPRESA) SI ES QUE HUBO ALGUN CAMBIO
            select max(sec_ingreso)
            into v_secuencia
            from bdinteg:si_ingresos
            where numcte = pnumcte and empresa = pempresa;

            if v_secuencia is null then
                let v_secuencia = 1;
            else
                let v_secuencia = v_secuencia + 1;
            end if;

            let v_cambio = 0;

            select 1 as sicambio
            into v_cambio 
            from bdinteg:si_ingresos 
            where numcte = pnumcte and empresa = pempresa and sec_ingreso = v_secuencia - 1 and trim(nombre_empresa) != trim(plugartrabajo);

            if v_cambio = 1 then               

                insert into bdinteg:si_ingresos(empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,
                    antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert)
                select empresa,numcte,v_secuencia,tipo_ingreso,plugartrabajo,puesto,puesto_esp,
                    antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,puser_insert,current 
                    from bdinteg:si_ingresos where numcte = pnumcte and empresa = pempresa and sec_ingreso = v_secuencia - 1;

            end if;
        end if;	

      if v_codret = "00000" then
            COMMIT WORK;
      else
            ROLLBACK WORK;
      end if;

      return v_codret;
end;
end procedure;