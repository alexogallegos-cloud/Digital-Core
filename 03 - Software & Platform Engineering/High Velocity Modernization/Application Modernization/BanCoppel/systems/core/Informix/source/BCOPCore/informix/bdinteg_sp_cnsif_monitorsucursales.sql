CREATE PROCEDURE "informix".sp_cnsif_monitorsucursales(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10), Tp_Busqueda CHAR (1), Id_Plaza CHAR (3), pNumRegistro INTEGER, pRecuperacion INTEGER)
							
				returning CHAR(5)  AS Cod_Retorno,
				          CHAR(3)  AS Id_Plaza,
                          CHAR(4)  AS No_Sucursal,
						  CHAR(40) AS Nom_Sucursal,
						  CHAR(40) AS Gte_Sucursal,
						  CHAR(14) AS Tel_Sucursal,
						  CHAR (8) AS Estat_Suc;
						  
										
DEFINE cCodRet          CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE IdPlaza          CHAR(3);
DEFINE No_Sucursal      CHAR(4);
DEFINE Nom_Sucursal     CHAR(40);
DEFINE Gte_Sucursal     CHAR(40);
DEFINE Tel_Sucursal     CHAR(14);
DEFINE Estat_Suc		CHAR(8);
DEFINE fechadia			DATE;
DEFINE Flag_abrio		INTEGER;
DEFINE Flag_cerro		INTEGER;
DEFINE iCont            INT;

	  --SET DEBUG FILE TO "/informix/omc/sp_cnsif_monitorsucursales.out";
	  --TRACE ON;

--inicializando variables
LET cCodRet 	    = "00000";
LET iSql_err 	    =  0;
LET IdPlaza 	    =  '';
LET No_Sucursal	    =  '';
LET Nom_Sucursal    =  '';
LET Gte_Sucursal    =  '';
LET Tel_Sucursal    =  '';
LET Estat_Suc		=  '';
LET fechadia	    = '01-01-1900';
LET Flag_abrio	    = 0;
LET Flag_cerro 	    = 0;
LET iCont           =0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
		END IF;
	END EXCEPTION;

	  -- SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_monitorsucursales.out";
	  -- TRACE ON;

    IF 	cID_USUARIOC = '' 	OR
        cID_FUNCIONC = '' 	OR
        Tp_Busqueda  = ''   THEN 
            LET cCodRet = "00054";
            RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    END IF;	

	if Tp_Busqueda not in ('1', '2', '3') then
		LET cCodRet = "00049";
            RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
	end if;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
        END IF;
    END IF;    


 	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = "00028" THEN 
		RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
	END IF;	
	
	select fecha_hoy 
		into fechadia
	from bdinteg:"informix".si_fechas
	where empresa = '001';

	set isolation to dirty read;
	if 
		Tp_Busqueda = '1' then
		FOREACH
			SELECT {+INDEX ('informix'.si_sucursales idx_sucursal)}	
					SKIP pNumRegistro FIRST pRecuperacion
					A.plaza, C.id_ptf, A.nombre, A.gerente, C.tel1, 
					B.suc_abrio, B.suc_cerro
				INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Flag_abrio, Flag_cerro
			FROM bdinteg:si_sucursales A, bdisuc:ss_pase_sucursal B, bdinteg:si_ptf C
			where B.fecha_pase = fechadia and trim (B.sucursal) = trim (A.sucursal) and trim (A.sucursal) = trim (C.id_ptf) AND (C.tipo='S')
            AND A.plaza = CASE WHEN Id_Plaza = '' THEN A.plaza ELSE Id_Plaza END
            ORDER BY A.sucursal

           IF Flag_abrio = 1 AND Flag_cerro = 0 THEN 
                LET Estat_Suc = 'ABIERTA';
            ELSE
                IF Flag_abrio = 1 AND Flag_cerro = 1 THEN 
                    LET Estat_Suc = 'CERRADA';
                ELSE
                    LET Estat_Suc = 'NO ABRIO';
                END IF;
            END IF;    
            LET iCont=iCont+1;
		RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc with resume;
		END FOREACH;
		else
		if	Tp_Busqueda = '2' then
			Let Estat_Suc = 'ABIERTA';
			FOREACH
			SELECT {+INDEX ('informix'.si_sucursales idx_sucursal)}
				SKIP pNumRegistro FIRST pRecuperacion
				A.plaza, C.id_ptf, A.nombre, A.gerente, C.tel1, 
				B.suc_abrio, B.suc_cerro
				INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Flag_abrio, Flag_cerro
				FROM bdinteg:si_sucursales A, bdisuc:ss_pase_sucursal B, bdinteg:si_ptf C
				where B.fecha_pase = fechadia and trim (B.sucursal) = trim (A.sucursal) and trim (A.sucursal) = trim (C.id_ptf) AND C.tipo='S'
				and B.suc_abrio = '1' and B.suc_cerro = '0'
                AND A.plaza = CASE WHEN Id_Plaza = '' THEN A.plaza ELSE Id_Plaza END
                ORDER BY A.sucursal

                LET iCont=iCont+1;
				RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc with resume;
			END FOREACH;
		else
			if	Tp_Busqueda = '3' then
				Let Estat_Suc = 'CERRADA';
				FOREACH
				SELECT {+INDEX ('informix'.si_sucursales idx_sucursal)}
					SKIP pNumRegistro FIRST pRecuperacion
					A.plaza, C.id_ptf, A.nombre, A.gerente, C.tel1, 
					B.suc_abrio, B.suc_cerro
					INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Flag_abrio, Flag_cerro
					FROM bdinteg:si_sucursales A, bdisuc:ss_pase_sucursal B, bdinteg:si_ptf C
					where B.fecha_pase = fechadia and trim (B.sucursal) = trim (A.sucursal) and trim (A.sucursal) = trim (C.id_ptf) AND C.tipo='S'
    				and B.suc_abrio = '1' and B.suc_cerro = '1'
                    AND A.plaza = CASE WHEN Id_Plaza = '' THEN A.plaza ELSE Id_Plaza END
                    ORDER BY A.sucursal

                        LET iCont=iCont+1;
					RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc with resume;
				END FOREACH;
			end if;
		end if;
	end if;

    IF pNumRegistro=0 AND iCont=0 THEN
        LET cCodRet='00091';
        RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    END IF;

    IF iCont=0 THEN
        LET cCodRet = '1001';
        RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    END IF;

END
END PROCEDURE
DOCUMENT
"Autor: frg",
"FUNCIONAMIENTO: Consulta detalle de Sucursales de acuerdo a criterios (Consulta por Plaza)",
"FECHA : 18-07-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_obtenerhistmttodehuella(i16Tipo SMALLINT, cSucursal CHAR(4), dFecha DATE, cNumEmpleado CHAR(8), cNumEmpleado2 CHAR(8), i16Registros SMALLINT)

--Se borra el sp con mayúsculas y se reemplaza por solo minusculas

	RETURNING CHAR(5), CHAR(10), CHAR(5), CHAR(20), CHAR(104), CHAR(8), CHAR(8), CHAR(8);

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaHora CHAR(25);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE cNumCte CHAR(20);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNombreCompleto CHAR(104);
	DEFINE cEmpleado CHAR(8);
	DEFINE cOperador CHAR(8);
	DEFINE cUsuario CHAR(8);
	DEFINE i16Contador SMALLINT;
    DEFINE cfechaini char(20);
    DEFINE cfechafin char(20);



	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cFechaHora = '';
	LET cFecha = '';
	LET cHora = '';
	LET cNumCte = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cNombreCompleto = '';
	LET cEmpleado = '';
	LET cOperador = '';
	LET cUsuario = '';
	LET i16Contador = 0;
    let cfechaini = '';
    let cfechafin = '';

--	SET DEBUG FILE TO "sp_ObtenerHistMttoDeHuella.out";
--	TRACE ON;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END EXCEPTION;

         let cfechaini = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 00:00:00';
         let cfechafin = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 23:59:59';

		IF i16Tipo = 1 THEN
			FOREACH
				SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM si_huella_temp a, si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin
                  AND a.sucursal = cSucursal 
                  AND a.numcte = b.numcte
		  AND a.status = 'A'
				ORDER BY b.apell_paterno

				LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
				LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
				LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
									TRIM(NVL(cNombre2,'')) || ' ' ||
									TRIM(NVL(cApellPaterno,'')) || ' ' ||
									TRIM(NVL(cApellMaterno,''));

				LET i16Contador = i16Contador + 1;
				IF i16Contador <= i16Registros THEN
					CONTINUE FOREACH;
				END IF;

				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
			END FOREACH;
		ELIF i16Tipo = 2 THEN
			FOREACH
				SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM si_huella_temp a, si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin
                  AND a.sucursal = cSucursal
		  AND a.status = 'A'
			  	  AND a.numcte = b.numcte AND a.empleado = cNumEmpleado
				ORDER BY b.apell_paterno

				LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
				LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
				LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
									TRIM(NVL(cNombre2,'')) || ' ' ||
									TRIM(NVL(cApellPaterno,'')) || ' ' ||
									TRIM(NVL(cApellMaterno,''));

				LET i16Contador = i16Contador + 1;
				IF i16Contador <= i16Registros THEN
					CONTINUE FOREACH;
				END IF;

				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
			END FOREACH;
		ELIF i16Tipo = 3 THEN
			FOREACH
				SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM si_huella_temp a, si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin
                  AND a.sucursal = cSucursal
		  AND a.status = 'A'
				  AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
				ORDER BY b.apell_paterno

				LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
				LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
				LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
									TRIM(NVL(cNombre2,'')) || ' ' ||
									TRIM(NVL(cApellPaterno,'')) || ' ' ||
									TRIM(NVL(cApellMaterno,''));

				LET i16Contador = i16Contador + 1;
				IF i16Contador <= i16Registros THEN
					CONTINUE FOREACH;
				END IF;

				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
			END FOREACH;
		END IF;
	END;

END PROCEDURE;