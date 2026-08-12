CREATE PROCEDURE "informix".sp_consulta_empleados_bei(
                            pNumCliente char(9),
                            pNumEmp char(30),
                            pNumCta char(30),
                            pNomEmp char(30),
                            pApePat char(30),
                            pApeMat char(20),
                            pCveBanco char(3),
                            pTipoBusqueda smallint,
                            pRegistro smallint)
 RETURNING char(5), char (30), char(30),CHAR(30),char(20),char(19),char(40),char(18),money(16,2);

 	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LA EMPLEADOS PARA LA BANCA EMPRESARIAL
	--TIPO BUSQUEDA:1 todos los empleados,2 por numero de cliente, 3 por nombre, 4 por banco
	-- AUTOR : Francisco Rodriguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio Leon
	--****************************************************************************************************

   --Declaracion de variabled
   DEFINE vCodRet char(5);
   DEFINE sql_err integer;
   DEFINE vIdEmpresa CHAR(3);
   DEFINE vNumEmp varchar(30);
   DEFINE vNomEmp varchar(30);
   DEFINE vApePat varchar(30);
   DEFINE vApeMat varchar(20);
   DEFINE vFecReg char(19);
   DEFINE v_FechaHoraInsert datetime year to fraction;
   DEFINE vBanco  varchar(40);
   DEFINE vNumCta varchar(18);
   DEFINE  iCont  INTEGER;
   DEFINE  iContReg  INTEGER;
   DEFINE vMonto MONEY(16,2);

   --asigacion de valores a variables
   LET vCodRet='00000';
   LET vIdEmpresa='';
   LET  vNumEmp ='';
   LET  vNomEmp ='';
   LET  vApePat ='';
   LET  vApeMat ='';
   LET  vFecReg ='';
   LET  vBanco  ='';
   LET  vNumCta ='';
   LET iCont=0;
   LET iContReg=0;
   LET vMonto=0.00;

--set debug file to "/home/informix/ivonne/sp_consulta_empleados_bei.out";
--trace on;

  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, '', '', '', '', '','','',vMonto;
      END IF ;
   END EXCEPTION ;

    SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;

   IF (pTipoBusqueda is null or pTipoBusqueda ='' or pNumCliente is null or pNumCliente='') THEN
		LET vCodRet='00001';
		RETURN vCodRet, '', '', '', '', '','','',vMonto;
   ELSE  
		select codigo into vIdEmpresa from bdicheq:"informix".sc_nominaempresas where numcte = TRIM(pNumCliente);

		IF (vIdEmpresa is not null or vIdEmpresa <> '') THEN

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;

			IF(pTipoBusqueda = 0) THEN --Consulta todos los empleados

				FOREACH
					select SKIP pRegistro FIRST 10 e.num_empleado,e.nombre_empleado,e.apell_pat,e.apell_mat,e.f_registro,b.descripcion,e.cta_empleado,NVL(monto,0)
							into vNumEmp,vNomEmp,vApePat,vApeMat,vFecReg,vBanco,vNumCta,vMonto
					    from bdibpi:"informix".bpi_empleadospm as e,bdinteg:"informix".si_bancos as b,bdicheq:"informix".sc_nominaempresas as n
					    where e.id_empresa=vIdEmpresa
					    and ((current-e.f_registro) > '0 00:30:00' )
					    and e.cve_banco=b.banco
						and e.id_empresa=n.codigo
						order by e.nombre_empleado --Se agrego para que aparezcan ordenados por nombre de empleado
                        

						LET iContReg = iCont + 1;
						LET iCont=1;
                        RETURN vCodRet, vNumEmp, vNomEmp, vApePat, vApeMat, vFecReg,vBanco,vNumCta,vMonto WITH RESUME;

				END FOREACH;

				IF(iCont = 0 AND pRegistro=0 )THEN
					LET vCodRet='00003';
					RETURN vCodRet, '', '', '', '', '','','',vMonto;
				END IF

			END IF;

			IF(pTipoBusqueda = 1) THEN --Consulta por numcliente

				select e.num_empleado,e.nombre_empleado,e.apell_pat,e.apell_mat,e.f_registro,b.descripcion,e.cta_empleado,NVL(monto,0)
						into vNumEmp,vNomEmp,vApePat,vApeMat,vFecReg,vBanco,vNumCta,vMonto
					from bdibpi:"informix".bpi_empleadospm as e,bdinteg:"informix".si_bancos as b,bdicheq:"informix".sc_nominaempresas as n
					where e.id_empresa=vIdEmpresa
					and e.id_empresa=n.codigo
					and e.cve_banco=b.banco
					and e.num_empleado=trim(pNumEmp);

                    

					IF(vNumEmp is not null or vNumEmp<>'') THEN
						LET v_FechaHoraInsert = (vFecReg)::DATETIME YEAR TO fraction;
						IF (current - v_FechaHoraInsert) > '0 00:30:00' THEN
							RETURN vCodRet, vNumEmp, vNomEmp, vApePat, vApeMat, vFecReg,vBanco,vNumCta,vMonto;

						END IF;

					ELSE
						LET vCodRet='00003';
						RETURN vCodRet, '', '', '', '', '','','',vMonto;
					END IF

			END IF;

			IF(pTipoBusqueda = 4) THEN --Consulta todos los empleados

				FOREACH
					select SKIP pRegistro FIRST 10 e.num_empleado,e.nombre_empleado,e.apell_pat,e.apell_mat,e.f_registro,b.descripcion,e.cta_empleado,NVL(monto,0)
							into vNumEmp,vNomEmp,vApePat,vApeMat,vFecReg,vBanco,vNumCta,vMonto
					    from bdibpi:"informix".bpi_empleadospm as e,bdinteg:"informix".si_bancos as b,bdicheq:"informix".sc_nominaempresas as n
					    where e.id_empresa=vIdEmpresa
					    and ((current-e.f_registro) > '0 00:30:00' )
					    and e.cve_banco=b.banco
						and e.id_empresa=n.codigo
                        and e.cta_empleado=trim(pNumCta)
						order by e.nombre_empleado --Se agrego para que aparezcan ordenados por numero de empleado

						LET iContReg = iCont + 1;
						LET iCont=1;
						RETURN vCodRet, vNumEmp, vNomEmp, vApePat, vApeMat, vFecReg,vBanco,vNumCta,vMonto WITH RESUME;

				END FOREACH;

				IF(iCont = 0 AND pRegistro=0 )THEN
					LET vCodRet='00003';
					RETURN vCodRet, '', '', '', '', '','','',vMonto;
				END IF

			END IF;

			IF(pTipoBusqueda = 2) THEN --Consulta por nombre

				FOREACH

					select SKIP pRegistro FIRST 10 e.num_empleado,e.nombre_empleado,e.apell_pat,e.apell_mat,e.f_registro,b.descripcion,e.cta_empleado,NVL(monto,0)
							into vNumEmp,vNomEmp,vApePat,vApeMat,vFecReg,vBanco,vNumCta,vMonto
						from bdibpi:"informix".bpi_empleadospm as e,bdinteg:"informix".si_bancos as b,bdicheq:"informix".sc_nominaempresas as n
						where e.id_empresa=vIdEmpresa
						and e.id_empresa=n.codigo
						and e.cve_banco=b.banco
						and UPPER(e.nombre_empleado) MATCHES (TRIM(UPPER(pNomEmp)) ||'*' )
						and UPPER(e.apell_pat) MATCHES (TRIM(UPPER(pApePat)) ||'*' )
						and UPPER(e.apell_mat) MATCHES CASE WHEN TRIM(UPPER(pApeMat))='' THEN '*' ELSE (TRIM(UPPER(pApeMat)) ||'*') END

						LET v_FechaHoraInsert = (vFecReg)::DATETIME YEAR TO fraction;

						IF (current - v_FechaHoraInsert) > '0 00:30:00' THEN
							LET iContReg = iCont + 1;

							LET iCont=1;
							RETURN vCodRet, vNumEmp, vNomEmp, vApePat, vApeMat, vFecReg,vBanco,vNumCta,vMonto WITH RESUME;

						END IF;
						--LET iCont=1;


				END FOREACH;

					IF(iCont = 0 AND pRegistro=0 ) THEN
					LET vCodRet='00003';
					RETURN vCodRet, '', '', '', '', '','','',vMonto;
				END IF
			END IF;

			IF(pTipoBusqueda = 3)THEN--Consulta por banco
				FOREACH
					select SKIP pRegistro FIRST 10 e.num_empleado,e.nombre_empleado,e.apell_pat,e.apell_mat,e.f_registro,b.descripcion,e.cta_empleado,NVL(monto,0)
							into vNumEmp,vNomEmp,vApePat,vApeMat,vFecReg,vBanco,vNumCta,vMonto
					    from bdibpi:"informix".bpi_empleadospm as e,bdinteg:"informix".si_bancos as b,bdicheq:"informix".sc_nominaempresas as n
					    where e.id_empresa=vIdEmpresa
						and e.cve_banco=pCveBanco
					    and e.id_empresa=n.codigo
					    and e.cve_banco=b.banco order by e.nombre_empleado --Se agrego para que aparezcan ordenados por numero de empleado

						LET v_FechaHoraInsert = (vFecReg)::DATETIME YEAR TO fraction;

						IF (current - v_FechaHoraInsert) > '0 00:30:00' THEN
							LET iContReg = iCont + 1;

								LET iCont=1;
								RETURN vCodRet, vNumEmp, vNomEmp, vApePat, vApeMat, vFecReg,vBanco,vNumCta,vMonto WITH RESUME;

						END IF;

				END FOREACH;
				IF(iCont = 0 AND pRegistro=0 ) THEN
						LET vCodRet='00003';
						RETURN vCodRet, '', '', '', '', '','','',vMonto;
				END IF

			END IF
		ELSE
			LET vCodRet='00002';
			RETURN vCodRet, '', '', '', '', '','','',vMonto;
		END IF;



   END IF;


END

END PROCEDURE;