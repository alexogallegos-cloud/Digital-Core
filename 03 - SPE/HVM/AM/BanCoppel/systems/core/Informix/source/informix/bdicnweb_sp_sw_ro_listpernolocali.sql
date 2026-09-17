CREATE PROCEDURE "informix".sp_sw_ro_listpernolocali(pUsuario char(8), pIdFuncion char(10),  pIdOficio int, pRegistros int, pRecuperacion int )
	returning CHAR(5) as  CodRet,
		      SMALLINT as TipoBus,
              CHAR(164) as Nombre,
              char(13) as Rfc, 
			  char(20) as Numcte,
			  char(20) as Cuenta,
			  char(20) as Tarjeta

              
		 
		
		
	define cCodRet	   CHAR(5);
	define iSqlErr 	   INT;
    define iContador   INTEGER;
    define iTipoBusq    SMALLINT ;
	define cNombre     CHAR(164); 
	define iBusq       INTEGER;
    define crfc        CHAR(13); 
	define cNumcte     CHAR(20); 
	define cCuenta     CHAR(20); 
	define cTarjeta    CHAR(20);
	
	
	let cCodRet     = '00000';
	let iSqlErr	    = 0;
    let iContador   = 0;
    let iTipoBusq   = 0;
	let cNombre     = ''; 
	let iBusq       = 0;
	let crfc        = ''; 
	let cNumcte     = ''; 
	let cCuenta     = ''; 
    let cTarjeta    = '';
	
	BEGIN
			--EXEPCIONES
				ON EXCEPTION SET  iSqlErr
					IF iSqlErr <> 0 THEN
						let cCodRet= iSqlErr;
						return  cCodRet, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta;
					END IF;				
				END EXCEPTION;
			
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
				execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
				IF cCodRet <> '00000' then
					return  cCodRet, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta;
				END IF;
						
				-- VALIDACIONES DE ENTRADA
				IF  pUsuario = '' or
					pIdFuncion = '' or 
					pRegistros = '' or 
					pRecuperacion = '' or
                    pIdOficio = ''
					THEN
						let cCodRet = '00003';
						return  cCodRet, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta;
				END IF;

			FOREACH
                    select skip  pRegistros first pRecuperacion distinct (rp.id_busqueda),bp.id_tipobusqueda, 
                    trim(trim (trim (trim ( trim(trim(rp.nombre1)|| ' ' ||trim(rp.nombre2))|| ' ' || trim(rp.apell_paterno)) || ' ' || trim(rp.apell_materno)) || ' ' || trim( rp.razon_social))) As nombre,
                    rp.rfc, rp.numcte,rp.cuenta, rp.num_tarjeta
                    INTO iBusq, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta
                    from sw_ro_resulper rp left join sw_ro_resulcte rc 	on rc.id_busqueda = rp.id_busqueda left join sw_ro_buscaper bp
                     on bp.id_busqueda = rp.id_busqueda and bp.id_oficio = rp.id_oficio
                    where rp.id_oficio = pIdOficio  and rp.status_busqueda = 0 and rp.ind_omitir = 0 and rp.status=1

                                       
					 let iContador= iContador + 1;						 
					 return  cCodRet, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta with resume;

			END FOREACH; 
				  IF iContador = 0 THEN
                                 let cCodRet='01001';
								 RETURN cCodRet, iTipoBusq, cNombre, cRfc, cNumcte, cCuenta, cTarjeta;			
                   END IF;

		END;

END PROCEDURE;