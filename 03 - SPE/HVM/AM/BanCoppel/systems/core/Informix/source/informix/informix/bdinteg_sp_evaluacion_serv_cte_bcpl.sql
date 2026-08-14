CREATE PROCEDURE "informix".sp_evaluacion_serv_cte_bcpl()
RETURNING CHAR(5), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE cCodRet 			CHAR(5);
DEFINE cMsjCodRet 		CHAR(100);
DEFINE cMensaje			CHAR(100);
DEFINE cRutaRepor		CHAR(30);
DEFINE vNombreRepor		VARCHAR(100);
DEFINE vNombreRepor2	VARCHAR(100);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE iPaso			SMALLINT;
DEFINE cSystem			CHAR(1500);
DEFINE iFechaHoy		INTEGER;
DEFINE iDiaHoy			INTEGER;
DEFINE dDiaAct			DATE;
DEFINE dDiaAct2		    DATE;
DEFINE dFechaIni		DATE;
DEFINE dFechaFin		DATE;
DEFINE cMes				CHAR(2);
DEFINE cYear			CHAR(4);
DEFINE vArnContReg      INTEGER;
DEFINE vArRegMax		INTEGER;
DEFINE vArnSalto        INTEGER;
DEFINE cNumCte			CHAR(20);
DEFINE cNomCte			CHAR(100);
DEFINE cSexo			CHAR(10);
DEFINE cTelCasa			CHAR(13);
DEFINE cTelCelular		CHAR(13);
DEFINE iEdad			INTEGER;
DEFINE iAntiguedad		INTEGER;
DEFINE cEscolaridad		CHAR(40);
DEFINE mNivelIngre		MONEY;
DEFINE cFechaMov		CHAR(8);
DEFINE cSucursal		CHAR(4);
DEFINE vCiudad			VARCHAR(50);
DEFINE cRegion			CHAR(40);
DEFINE cTpoTramit		CHAR(30);
DEFINE cFechaSolic		CHAR(8);
DEFINE cFechaEntre		CHAR(8);	
DEFINE cTpoTar			CHAR(10);

--ASIGNACIÃN VARIABLES
LET cCodRet		  = '00000';	
LET cMsjCodRet 	  = 'REPORTE GENERADO SATISFACTORIAMENTE';
LET cMensaje	  = 'ERROR EN PASO: ';
LET cRutaRepor	  = '/home/procesos/';
LET vNombreRepor  = '';
LET vNombreRepor2 = '';
LET iPaso		  = '0';
LET cSystem		  = '';
LET iFechaHoy     = 0;
LET iDiaHoy		  = 0; 
LET dDiaAct		  = TODAY; 
LET dDiaAct2	  = TODAY; 
LET dFechaIni	  = '';
LET dFechaFin	  = '';
LET cMes		  = '';
LET cYear		  = '';
LET vArnContReg   = 0;
LET vArRegMax     = 0;
LET vArnSalto     = '';
LET cNumCte		  = '';
LET cNomCte		  = '';
LET cSexo		  = '';
LET cTelCasa	  = '';
LET cTelCelular   = '';
LET iEdad		  = 0;
LET iAntiguedad   = 0;
LET cEscolaridad  = '';
LET mNivelIngre	  = 0;
LET cFechaMov	  = '';
LET cSucursal	  = '';
LET vCiudad		  = '';
LET cRegion		  = '';	
LET cTpoTramit    = '';
LET cFechaSolic   = '';
LET cFechaEntre   = '';
LET cTpoTar       = '';

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
			
				LET cCodRet = iSqlErr;
			END IF;
			
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			
			RETURN cCodRet, cMensaje;
		END EXCEPTION;


	--SET DEBUG FILE TO "/tmp/ingrid/sp_evaluacion_serv_cte_bcpl.out";
	--TRACE ON;
	
			--SE OBTIENE LA FECHA INICIAL Y FECHA FINAL
			SELECT DAY(TODAY)			
			INTO iDiaHoy
			FROM DUAL;
			
				IF iDiaHoy = 19 THEN
				
					LET varnSalto   = 250;
				
					SELECT DATE( TO_CHAR( TODAY, '%m14%Y' ) ),
					DATE( TO_CHAR( TODAY, '%m18%Y' ) )	 
					INTO dFechaIni, dFechaFin FROM DUAL;
				
				ELSE
				
					LET varnSalto   = 200;
					
					SELECT DATE( TO_CHAR( TODAY, '%m21%Y' ) ),
					DATE( TO_CHAR( TODAY, '%m26%Y' ) )
					INTO dFechaIni, dFechaFin
					FROM DUAL;
					
				END IF;
			
				
				--NOMBRE REPORTE
				SELECT TODAY
				INTO iFechaHoy
				FROM DUAL;
				
				LET cMes = LPAD(MONTH(iFechaHoy), 2, 0);
				LET cYear = LPAD(YEAR(iFechaHoy), 4, 0);
				
				LET vNombreRepor = 'Ventanilla_'||iDiaHoy||cMes||cYear||'.csv';
				LET vNombreRepor2 = 'Promotoria_'||iDiaHoy||cMes||cYear||'.csv';
				
				--BORRADO DE ARCHIVOS EN RUTA
				LET cSystem = 'rm -f /home/procesos/'||vNombreRepor;
				SYSTEM cSystem; 
				
				LET cSystem = 'rm -f /home/procesos/'||vNombreRepor2;
				SYSTEM cSystem; 
				
				LET cSystem = 'rm -f /home/procesos/'||'Reporte_eva_cte_bcpl.zip';
				SYSTEM cSystem;
				
				LET iPaso = 1;
				--TABLA TEMPORAL MOVTOS CTES VENTANILLA DEBITO
					SELECT {+INDEX bdicheq:informix.idx_sc_maechq2)} a.num_cte 
					{+INDEX bdicheq:informix.idx_movhisnew3)}, b.sucursal, 
					CASE WHEN b.transacc = '0202' THEN 'DEPOSITO EN EFECTIVO' ELSE 'RETIRO EN EFECTIVO' END AS transacc, b.fech_alt,
					TRIM( SUBSTR( b.num_serial, 1 , 8 ) ) AS hora
					FROM bdicheq:sc_maechq a JOIN bdicheq:sc_movhis b
					ON a.cuenta = b.cuenta
					WHERE a.status_cta = 1 
					AND b.transacc IN ('0202', '0223')
					AND b.fech_alt BETWEEN dFechaIni AND dFechaFin
					AND TO_CHAR( EXTEND (b.FECH_HOR , hour to second),'%H:%M:%S') BETWEEN '10:00:00' AND '12:00:00' 
					INTO TEMP tmp_ctes_ventanilla WITH NO LOG;
					
				LET iPaso = 2;
				---TABLA TEMPORAL MOVTOS CTES VENTANILLA CREDITO
				-- IFRS Se contempla el nuevo estatus E1 equivalente al estatus AA y se agrega la sd_maesdos para validar el nuevo campo ACT a 0
					INSERT INTO tmp_ctes_ventanilla( num_cte, sucursal, transacc, fech_alt, hora )
					SELECT {+INDEX bdidcred:informix.idx_11a)} a.numcte, b.sucursal,  
					CASE WHEN b.transacc_suc = '0600' THEN 'PAGO TARJETA' ELSE 'RETIRO DE TARJETA' END AS transacc, b.fecha_mov,
					TRIM( SUBSTR( b.secuencia, 1 , 8 ) ) AS hora
					FROM bdicred:sd_maecred a 
					JOIN bdicred:sd_movhis b  ON (a.num_credito = b.num_credito)
					JOIN bdicred:sd_maesdos c ON (a.num_credito = c.num_credito)
					WHERE a.status_cred IN ('AA','AC','AE','AM','AR','E1') 
					AND (c.monto_vencido + c.mto_venc_trasp) = 0
					AND b.transacc_suc IN ('0600','6900')
					AND b.fecha_mov BETWEEN dFechaIni AND dFechaFin
					AND TO_CHAR( EXTEND (b.HORA_MOV , hour to second),'%H:%M:%S') BETWEEN '10:00:00' AND '12:00:00';

					INSERT INTO bdinteg:si_servicio_cte_bcpl(numcte, fecha_movto, sucursal, tpo_tramite, hora)
					SELECT DISTINCT num_cte, MIN( fech_alt ) AS fecha_movto, MIN( sucursal ), MIN( transacc ) AS tpo_tramite, MAX( hora )
					FROM tmp_ctes_ventanilla
					GROUP BY num_cte;

					DROP TABLE tmp_ctes_ventanilla;
				------------------------------------------------------------------------------------------------------------------------
				LET iPaso = 3;
				--TELEFONO CASA CTES VENTANILLA
					UPDATE bdinteg:si_servicio_cte_bcpl
					SET tel_casa = (	SELECT MAX( a.telefono )
                                    FROM bdinteg:si_telefonos a
                                    WHERE a.numcte = si_servicio_cte_bcpl.numcte AND a.tipo_tel = '1' AND a.status_tel = 'A' AND NVL( a.verificado, 'F' ) = 'V'
                                );	

								
				LET iPaso = 4;
				--TELEFONO CELULAR CTES VENTANILLA
					UPDATE bdinteg:si_servicio_cte_bcpl
					SET tel_celular = (	SELECT MAX( a.telefono )
                                    FROM bdinteg:si_telefonos a
                                    WHERE a.numcte = si_servicio_cte_bcpl.numcte AND a.tipo_tel = '2' AND a.status_tel = 'A' AND NVL( a.verificado, 'F' ) = 'V'
                                );
						
						
					DELETE FROM si_servicio_cte_bcpl WHERE tel_casa IS NULL AND tel_celular IS NULL;

				LET iPaso = 5;
				--CREACION TABLA TEMP NOMBRE, ANTIGUEDAD, SEXO, EDAD
					SELECT {+INDEX bdinteg:informix.224_479)} TRIM( TRIM( a.nombre1 ) || ' ' || TRIM( a.nombre2 ) ) || ' ' || TRIM( a.apell_paterno ) || ' ' || TRIM( a.apell_materno ) AS nombre,
					(MONTHS_BETWEEN(DATE(TODAY), a.fecha_insert ) /12 )::INT AS antiguedad, b.numcte as num_cte, (CASE WHEN c.sexo = 'M' THEN 'MASCULINO' ELSE 'FEMENINO' END) AS sexo, ( MONTHS_BETWEEN(DATE(TODAY), c.fecha_nac ) / 12 )::INT AS edad,
					UPPER(d.descripcion) AS escolaridad
					FROM bdinteg:si_servicio_cte_bcpl b JOIN bdinteg:si_cliente a
					ON a.numcte = b.numcte
					JOIN bdinteg:si_ctepf c
					ON a.numcte = c.numcte
					LEFT JOIN bdinteg:si_escolaridad_am d
					ON c.escolaridad::INT = d.elemento

					INTO TEMP tmp_nombre_cte WITH NO LOG;
					
					

					SELECT nombre, antiguedad, num_cte, sexo, edad, NVL( escolaridad, '' ) AS escolaridad FROM tmp_nombre_cte GROUP BY nombre, antiguedad, num_cte, sexo, edad, escolaridad
					INTO TEMP tmp_nombre_cte2 WITH NO LOG;

					CREATE INDEX "informix".idx_tmp_nombre_cte2_num_cte ON tmp_nombre_cte2(num_cte);

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET nom_cte = (SELECT b.nombre FROM tmp_nombre_cte2 b WHERE si_servicio_cte_bcpl.numcte = b.num_cte);

						DELETE FROM si_servicio_cte_bcpl where nom_cte is null;

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET antiguedad = (SELECT b.antiguedad FROM tmp_nombre_cte2 b WHERE si_servicio_cte_bcpl.numcte = b.num_cte);					

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET sexo = (SELECT b.sexo FROM tmp_nombre_cte2 b WHERE si_servicio_cte_bcpl.numcte = b.num_cte);

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET edad = (SELECT b.edad FROM tmp_nombre_cte2 b WHERE si_servicio_cte_bcpl.numcte = b.num_cte);					

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET escolaridad = (SELECT b.escolaridad FROM tmp_nombre_cte2 b WHERE si_servicio_cte_bcpl.numcte = b.num_cte);					

						DROP TABLE tmp_nombre_cte;
						DROP TABLE tmp_nombre_cte2;
				
				LET iPaso = 6;
				--CIUDAD MOVTO VENTANILLA DEB
					/*SELECT {+INDEX informix.idx_sucursal)} b.nombre AS ciudad, a.sucursal
					FROM bdinteg:si_sucursales a JOIN bdinteg:si_ciudades b
					ON b.estado = a.estado AND b.ciudad = a.ciudad*/
					SELECT {+INDEX informix.idx_sucursal)} c.nombre AS ciudad, a.sucursal
					FROM bdinteg:si_sucursales a JOIN bdinteg:si_ptf b
					ON a.sucursal = b.id_ptf AND b.tipo = 'S'
					JOIN bdinteg:si_ciudades c
					ON b.cve_estado = c.estado AND b.cve_ciudad = c.ciudad					
					INTO TEMP tmp_cd_suc_cte_deb WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_cd_suc_cte_deb_sucursal ON tmp_cd_suc_cte_deb(sucursal);						

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET ciudad = (SELECT b.ciudad FROM tmp_cd_suc_cte_deb b WHERE si_servicio_cte_bcpl.sucursal = b.sucursal);

						DROP TABLE tmp_cd_suc_cte_deb;
						
				LET iPaso = 7;
				--REGION DONDE SE REALIZA EL MOVTO
					SELECT {+INDEX bdinteg:informix.idx_sucursal)} a.nombre as region, c.sucursal
					FROM bdinteg:si_regional a JOIN bdinteg:si_plazas b
					ON a.regional = b.regional
					JOIN bdinteg:si_sucursales c
					ON b.plaza = c.plaza
					INTO TEMP tmp_cd_reg_cte_deb WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_cd_reg_cte_deb_sucursal ON tmp_cd_reg_cte_deb(sucursal);						

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET region = (SELECT b.region FROM tmp_cd_reg_cte_deb b WHERE si_servicio_cte_bcpl.sucursal = b.sucursal);

						DROP TABLE tmp_cd_reg_cte_deb;
					
				LET iPaso = 8;
				--NIVEL INGRESO 
					SELECT a.numcte, 0 as ingreso_mensual, MAX( b.sec_ingreso ) AS sec_ingreso
					FROM bdinteg:si_servicio_cte_bcpl a JOIN bdinteg:si_ingresos b 
					ON a.numcte = b.numcte
					GROUP BY a.numcte
					INTO TEMP tmp_ing_cte_deb WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_ing_cte_deb_num_cte ON tmp_ing_cte_deb(numcte, sec_ingreso);

						UPDATE tmp_ing_cte_deb
						SET ingreso_mensual = ( SELECT b.ingreso_mensual FROM bdinteg:si_ingresos b WHERE tmp_ing_cte_deb.numcte = b.numcte AND tmp_ing_cte_deb.sec_ingreso = b.sec_ingreso  );

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET nivel_ingre = ( SELECT b.ingreso_mensual FROM tmp_ing_cte_deb b WHERE si_servicio_cte_bcpl.numcte = b.numcte  );					
				
						DROP TABLE tmp_ing_cte_deb;
				
				LET iPaso = 9;
				--CREACION TABLA TEMPORAL
					CREATE TEMP TABLE tmp_si_servicio_cte_bcpl (
						numcte		CHAR(20),
						nom_cte		CHAR(100),
						sexo		CHAR(10),
						tel_casa	CHAR(13),
						tel_celular	CHAR(13),
						edad		INTEGER,
						antiguedad	INTEGER,
						escolaridad	CHAR(40),
						nivel_ingre	MONEY,
						fecha_movto	DATE,
						sucursal	CHAR(4),
						ciudad		VARCHAR(50),
						region		CHAR(40),
						tpo_tramite	CHAR(30),
						fech_solic	DATE,
						fech_entre	DATE,
						tpo_tarjeta	CHAR(10),
						hora		CHAR(8)
					);		

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
						SELECT numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
						FROM bdinteg:si_servicio_cte_bcpl
						ORDER BY fecha_movto, hora;
						
						TRUNCATE TABLE si_servicio_cte_bcpl DROP storage;
						
					INSERT INTO bdinteg:si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
						SELECT numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
						FROM tmp_si_servicio_cte_bcpl
						ORDER BY fecha_movto, hora;
						
						TRUNCATE TABLE tmp_si_servicio_cte_bcpl DROP storage;

				IF iDiaHoy != 19 THEN
				
				LET iPaso = 10;
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 6
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 6
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;

				END IF;			
			
				LET iPaso = 11;
				--INSERTA EN TABLA TEMPORAL tmp_si_servicio_cte_bcpl
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 5
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 5					
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;
				
				LET iPaso = 12;
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 4
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 4
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;
					
				LET iPaso = 13;
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 3
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 3
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;

				LET iPaso = 14;
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 2
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;

					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 2
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;
				
				LET iPaso = 15;
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl
					WHERE fecha_movto = DATE( dDiaAct ) - 1
					AND tpo_tramite in( 'RETIRO DE TARJETA', 'PAGO TARJETA' )
					ORDER BY hora;
					
					SELECT COUNT(*) INTO varnContReg FROM tmp_si_servicio_cte_bcpl;
					
					LET vArRegMax = 2500 - varnContReg;
					
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT LIMIT vArRegMax numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fecha_movto = DATE( dDiaAct ) - 1
					AND tpo_tramite in( 'RETIRO EN EFECTIVO', 'DEPOSITO EN EFECTIVO' )
					ORDER BY hora;
					
					TRUNCATE TABLE si_servicio_cte_bcpl DROP storage;
				
				LET iPaso = 16;
					INSERT INTO si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora )
					SELECT numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta, hora
					FROM tmp_si_servicio_cte_bcpl;
							
				LET iPaso = 17;
				--IMPRIME ENCABEZADO REPORTE 
					LET cSystem =  'echo "' || 'NO DE CLIENTE' || ',' || 'NOMBRE DEL CLIENTE' || ',' || 'SEXO' || ',' || 'TEL CASA' || ',' || 'TEL CELULAR' || ',' || 'EDAD' || ',' || 'ATIGÃEDAD' || ',' || 'ESCOLARIDAD' || ',' || 'NIVEL DE INGRESOS' || ',' || 'FECHA DEL MOVIMIENTO' || ',' || 'SUCURSAL' || ',' || 'CIUDAD' || ',' || 'REGION' || ',' || 'TIPO DE TRÃMITE' || '" >> ' || TRIM(cRutaRepor) || TRIM(vNombreRepor);
					SYSTEM cSystem;

				LET iPaso = 18;
					FOREACH
						SELECT numcte, NVL(nom_cte, ' '), NVL(sexo, ' '), NVL(tel_casa, ' '), NVL(tel_celular, ' '), NVL(edad, ' '), NVL(antiguedad, ' '), NVL(escolaridad, ' '), NVL(nivel_ingre, ' '), NVL(TO_CHAR(fecha_movto, '%d/%m/%y'), ' '), NVL(sucursal, ' '), NVL(ciudad, ' '), NVL(region, ' '), NVL(tpo_tramite, ' ')
						INTO cNumCte, cNomCte, cSexo, cTelCasa, cTelCelular, iEdad, iAntiguedad, cEscolaridad, mNivelIngre, cFechaMov, cSucursal, vCiudad, cRegion, cTpoTramit
						FROM si_servicio_cte_bcpl
						ORDER BY fecha_movto, hora, tpo_tramite
					
					LET iPaso = 19;
					--IMPRIME REPORTE
						LET cSystem = 'echo "' || TRIM(NVL(cNumCte, ' ')) || ',' || TRIM(NVL(cNomCte, ' ')) || ',' || TRIM(NVL(cSexo, ' ')) || ',' || TRIM(NVL(cTelCasa, ' ')) || ',' || TRIM(NVL(cTelCelular, ' ')) || ',' || TRIM(NVL(iEdad, ' ')) || ',' || TRIM(NVL(iAntiguedad, ' ')) || ',' || TRIM(NVL(cEscolaridad, ' ')) || ',' || TRIM(NVL(mNivelIngre, ' ')) || ',' || TRIM(NVL(cFechaMov, ' ')) || ',' || TRIM(NVL(cSucursal, ' ')) || ',' || TRIM(NVL(vCiudad, ' ')) || ',' || TRIM(NVL(cRegion, ' ')) || ',' || TRIM(NVL(cTpoTramit, ' ')) || '" >> ' || TRIM(cRutaRepor) || TRIM(vNombreRepor);
						SYSTEM cSystem;	
					
					END FOREACH;
			
				
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				----------------------------------------------------------------------------------REPORTE 2-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				LET iPaso = 20;
				--TRUNCATE A TABLAS TEMPORALES
					TRUNCATE TABLE si_servicio_cte_bcpl DROP storage;
					TRUNCATE TABLE tmp_si_servicio_cte_bcpl DROP storage;	
						
					LET vArnContReg = 0;	
					
				LET iPaso = 21;
				--TABLA TEMPORAL CTES CREDITO
					SELECT {+INDEX bdinteg:informix.idx_tel_tipo)} c.numcte,
					MIN( b.sucursal ) AS sucursal, MAX( b.fecha_insert ) AS fech_sol_cred, 
					MAX( a.fecha_insert ) AS fech_ent_cred,
					MAX( TRIM( TRIM( c.nombre1 ) || ' ' || TRIM( c.nombre2 ) ) || ' ' || TRIM( c.apell_paterno ) || ' ' || TRIM( c.apell_materno ) ) AS nombre,
					MAX(CASE WHEN d.sexo = 'M' THEN 'MASCULINO' ELSE 'FEMENINO' END) AS sexo, MAX( MONTHS_BETWEEN(DATE(TODAY), d.fecha_nac ) / 12 )::INT AS edad,
					MAX( UPPER(e.descripcion) ) AS escolaridad, 'CREDITO' AS tpo_tarjeta, MAX( c.fecha_insert ) as fecha_alta, 0 AS tipo
					FROM bdisolic:ss_autorizacion a JOIN bdisolic:ss_solicitudes b
					ON a.num_solicitud = b.num_solicitud
					JOIN bdinteg:si_cliente c
					ON b.numcte = c.numcte
					JOIN bdinteg:si_ctepf d
					ON c.numcte = d.numcte
					LEFT JOIN bdinteg:si_escolaridad_am e
					ON d.escolaridad::INT = e.elemento
					WHERE a.fecha_insert BETWEEN dFechaIni AND dFechaFin
					AND b.num_producto IN( '6001', '7000', '8100' )
					AND a.status_solicitud = 'AP'
					GROUP BY c.numcte
					INTO TEMP tmp_ctes_productos WITH NO LOG;
					
					INSERT INTO bdinteg:si_servicio_cte_bcpl(numcte, sucursal, fech_solic, fech_entre, nom_cte, edad, sexo, escolaridad, tpo_tarjeta)
					SELECT numcte, MIN( sucursal ), MAX( fech_sol_cred ), MAX( fech_ent_cred ), MAX( nombre ), MAX( edad ), MAX( sexo ), MAX( escolaridad ), MAX( tpo_tarjeta )
					FROM tmp_ctes_productos
					WHERE fecha_alta = fech_sol_cred
					AND tipo = 0
					GROUP BY numcte;		

					TRUNCATE TABLE tmp_ctes_productos DROP storage;
				
				
				LET iPaso = 22;
				--INSERTA EN TABLA TEMPORAL tmp_ctes_productos
					INSERT INTO tmp_ctes_productos( numcte, sucursal, fech_sol_cred, fech_ent_cred, nombre, sexo, edad, escolaridad, tpo_tarjeta, fecha_alta, tipo )
					SELECT {+INDEX bdinteg:informix.idx_tel_tipo)} d.numcte, MIN( d.sucursal ) AS sucursal, MAX( DATE( c.fecha_alta ) ) AS fech_sol_cred, 
					MAX( DATE( a.fechaasignacion ) ) AS fech_ent_cred,
					MAX( TRIM( TRIM( d.nombre1 ) || ' ' || TRIM( d.nombre2 ) ) || ' ' || TRIM( d.apell_paterno ) || ' ' || TRIM( d.apell_materno ) ) AS nombre,
					MAX(CASE WHEN e.sexo = 'M' THEN 'MASCULINO' ELSE 'FEMENINO' END) AS sexo, MAX( MONTHS_BETWEEN(DATE(TODAY), e.fecha_nac ) / 12 )::INT AS edad,
					MAX( UPPER(f.descripcion) ) AS escolaridad, 'DEBITO' AS tpo_tarjeta, MAX( d.fecha_insert ) as fecha_alta, 1 as tipo
					FROM intercard:tarjeta a JOIN bdicheq:sc_tarjeta b
					ON a.numtarjeta = b.num_tarjeta
					JOIN bdicheq:sc_maenoc c
					on b.cuenta = c.cuenta
					JOIN bdinteg:si_cliente d
					ON b.numcte = d.numcte
					JOIN bdinteg:si_ctepf e
					ON d.numcte = e.numcte
					LEFT JOIN bdinteg:si_escolaridad_am f
					ON e.escolaridad = f.elemento
					WHERE DATE( a.fechaasignacion ) BETWEEN dFechaIni AND dFechaFin
					GROUP BY d.numcte;
					
				LET iPaso = 23;
				--ACTUALIZA TABLA si_servicio_cte_bcpl
					UPDATE bdinteg:si_servicio_cte_bcpl
					SET tpo_tarjeta = 'AMBAS'
					WHERE numcte IN (  SELECT b.numcte 
									   FROM tmp_ctes_productos b
									   WHERE b.fecha_alta = b.fech_ent_cred);
				
				LET iPaso = 24;
				--INSERTA TABLA FINAL
					INSERT INTO bdinteg:si_servicio_cte_bcpl(numcte, sucursal, fech_solic, fech_entre, nom_cte, edad, sexo, escolaridad, tpo_tarjeta)
					SELECT numcte, MIN( sucursal ), MAX( fech_sol_cred ), MAX( fech_ent_cred ), MAX( nombre ), MAX( edad ), MAX( sexo ), MAX( escolaridad ), MAX( tpo_tarjeta )
					FROM tmp_ctes_productos
					WHERE fecha_alta = fech_ent_cred
					AND numcte NOT IN ( SELECT x.numcte FROM si_servicio_cte_bcpl x )
					GROUP BY numcte;

					DROP TABLE tmp_ctes_productos;
				
				--------------------------------
				LET iPaso = 25;
				--TELEFONO CASA CTES CREDITO
					 UPDATE bdinteg:si_servicio_cte_bcpl
					 SET tel_casa = (	SELECT MAX( a.telefono )
										FROM bdinteg:si_telefonos a
										WHERE a.numcte = si_servicio_cte_bcpl.numcte AND a.tipo_tel = '1' AND a.status_tel = 'A' AND NVL( a.verificado, 'F' ) = 'V'
									 );
			
			
				LET iPaso = 26;
				--TELEFONO CELULAR CTES CREDITO
					UPDATE bdinteg:si_servicio_cte_bcpl
					SET tel_celular = (	SELECT MAX( a.telefono )
										FROM bdinteg:si_telefonos a
										WHERE a.numcte = si_servicio_cte_bcpl.numcte AND a.tipo_tel = '2' AND a.status_tel = 'A' AND NVL( a.verificado, 'F' ) = 'V'
									 );
						
						DELETE FROM si_servicio_cte_bcpl WHERE tel_casa IS NULL AND tel_celular IS NULL;
								
				--------------------------------
				LET iPaso = 27;	
				--CIUDAD MOVTO VENTANILLA DEB
					/*SELECT {+INDEX informix.idx_sucursal)} b.nombre AS ciudad, a.sucursal
					FROM bdinteg:si_sucursales a JOIN bdinteg:si_ciudades b
					ON b.estado = a.estado AND b.ciudad = a.ciudad*/
					SELECT {+INDEX informix.idx_sucursal)} c.nombre AS ciudad, a.sucursal
					FROM bdinteg:si_sucursales a JOIN bdinteg:si_ptf b
					ON a.sucursal = b.id_ptf AND b.tipo = 'S'
					JOIN bdinteg:si_ciudades c
					ON b.cve_estado = c.estado AND b.cve_ciudad = c.ciudad					
					INTO TEMP tmp_cd_suc_cte_deb2 WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_cd_suc_cte_deb2_sucursal ON tmp_cd_suc_cte_deb2(sucursal);						

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET ciudad = (SELECT b.ciudad FROM tmp_cd_suc_cte_deb2 b WHERE si_servicio_cte_bcpl.sucursal = b.sucursal);
						
						DROP TABLE tmp_cd_suc_cte_deb2;

				LET iPaso = 28;
				--REGION DONDE SE REALIZA EL MOVTO
					SELECT {+INDEX bdinteg:informix.idx_sucursal)} a.nombre as region, c.sucursal
					FROM bdinteg:si_regional a JOIN bdinteg:si_plazas b
					ON a.regional = b.regional
					JOIN bdinteg:si_sucursales c
					ON b.plaza = c.plaza
					INTO TEMP tmp_cd_reg_cte_deb2 WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_cd_reg_cte_deb2_sucursal ON tmp_cd_reg_cte_deb2(sucursal);						

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET region = (SELECT b.region FROM tmp_cd_reg_cte_deb2 b WHERE si_servicio_cte_bcpl.sucursal = b.sucursal);
						
						DROP TABLE tmp_cd_reg_cte_deb2;

				LET iPaso = 29;
				--INGRESO MENSUAL
					SELECT a.numcte, 0 as ingreso_mensual, MAX( b.sec_ingreso ) AS sec_ingreso
					FROM bdinteg:si_servicio_cte_bcpl a JOIN bdinteg:si_ingresos b 
					ON a.numcte = b.numcte
					GROUP BY a.numcte
					INTO TEMP tmp_ing_cte_deb2 WITH NO LOG;

						CREATE INDEX "informix".idx_tmp_ing_cte_deb2_num_cte ON tmp_ing_cte_deb2(numcte, sec_ingreso);

						UPDATE tmp_ing_cte_deb2
						SET ingreso_mensual = ( SELECT b.ingreso_mensual FROM bdinteg:si_ingresos b WHERE tmp_ing_cte_deb2.numcte = b.numcte AND tmp_ing_cte_deb2.sec_ingreso = b.sec_ingreso  );

						UPDATE bdinteg:si_servicio_cte_bcpl
						SET nivel_ingre = ( SELECT b.ingreso_mensual FROM tmp_ing_cte_deb2 b WHERE si_servicio_cte_bcpl.numcte = b.numcte  );					
						
						DROP TABLE tmp_ing_cte_deb2;
				
				LET iPaso = 30;
					IF iDiaHoy != 19 THEN
					
						LET varnSalto   = 400;
					
						INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
						SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
						FROM bdinteg:si_servicio_cte_bcpl 
						WHERE fech_entre = DATE( dDiaAct2 ) - 6
						ORDER BY tpo_tarjeta;
						
					ELSE
					
						LET varnSalto   = 500;

					END IF;			
		
				LET iPaso = 31;
				--INSERTA EN TABLA TEMPORAL tmp_si_servicio_cte_bcpl
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fech_entre = DATE( dDiaAct2 ) - 5
					ORDER BY tpo_tarjeta;
					
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fech_entre = DATE( dDiaAct2 ) - 4
					ORDER BY tpo_tarjeta;				
					
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fech_entre = DATE( dDiaAct2 ) - 3
					ORDER BY tpo_tarjeta;				
					
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT LIMIT varnSalto numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fech_entre = DATE( dDiaAct2 ) - 2
					ORDER BY tpo_tarjeta;			
					
					SELECT COUNT(*) INTO varnContReg FROM tmp_si_servicio_cte_bcpl;
					
					LET vArRegMax = 2500 - varnContReg;
					
					INSERT INTO tmp_si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT LIMIT vArRegMax numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM bdinteg:si_servicio_cte_bcpl 
					WHERE fech_entre = DATE( dDiaAct2 ) - 1
					ORDER BY tpo_tarjeta;				
					
					TRUNCATE TABLE si_servicio_cte_bcpl DROP storage;
				
					INSERT INTO si_servicio_cte_bcpl( numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta )
					SELECT numcte, nom_cte, sexo, tel_casa, tel_celular, edad, antiguedad, escolaridad, nivel_ingre, fecha_movto, sucursal, ciudad, region, tpo_tramite, fech_solic, fech_entre, tpo_tarjeta
					FROM tmp_si_servicio_cte_bcpl;		
				
				LET iPaso = 32;
				--IMPRIME ENCABEZADO REPORTE 
					LET cSystem =  'echo "' || 'NO DE CLIENTE' || ',' || 'NOMBRE DEL CLIENTE' || ',' || 'SEXO' || ',' || 'TEL CASA' || ',' || 'TEL CELULAR' || ',' || 'EDAD' || ',' || 'ESCOLARIDAD' || ',' || 'NIVEL DE INGRESOS' || ',' || 'FECHA DE SOLICITUD' || ',' || 'FECHA DE ENTREGA' || ',' || 'SUCURSAL' || ',' || 'CIUDAD' || ',' || 'REGION' || ',' || 'TIPO DE TARJETA QUE ADQUIRIO' || '" >> ' || TRIM(cRutaRepor) || TRIM(vNombreRepor2);
					SYSTEM cSystem;
				
				----AGREGAR CAMPOS CORRESPONDIENTES SEGUNDO REPORTE
				FOREACH     
					SELECT numcte, NVL(nom_cte, ' '), NVL(sexo, ' '), NVL(tel_casa, ' '), NVL(tel_celular, ' '), NVL(edad, ' '), NVL(escolaridad, ' '), NVL(nivel_ingre, ' '), NVL(TO_CHAR(fech_solic, '%d/%m/%y'), ' '), NVL(TO_CHAR(fech_entre, '%d/%m/%y'), ' '), NVL(sucursal, ' '), NVL(ciudad, ' '), NVL(region, ' '), NVL(tpo_tarjeta, ' ')
					INTO cNumCte, cNomCte, cSexo, cTelCasa, cTelCelular, iEdad, cEscolaridad, mNivelIngre, cFechaSolic, cFechaEntre, cSucursal, vCiudad, cRegion, cTpoTar
					FROM si_servicio_cte_bcpl
					ORDER BY fech_entre, tpo_tarjeta		
				
					LET iPaso = 33;
					--IMPRIME REPORTE
						LET cSystem = 'echo "' || TRIM(NVL(cNumCte, ' ')) || ',' || TRIM(NVL(cNomCte, ' ')) || ',' || TRIM(NVL(cSexo, ' ')) || ',' || TRIM(NVL(cTelCasa, ' ')) || ',' || TRIM(NVL(cTelCelular, ' ')) || ',' || TRIM(NVL(iEdad, ' ')) || ',' || TRIM(NVL(cEscolaridad, ' ')) || ',' || TRIM(NVL(mNivelIngre, ' ')) || ',' || TRIM(NVL(cFechaSolic, ' ')) || ',' || TRIM(NVL(cFechaEntre, ' ')) || ',' || TRIM(NVL(cSucursal, ' ')) || ',' || TRIM(NVL(vCiudad, ' ')) || ',' || TRIM(NVL(cRegion, ' ')) || ',' || TRIM(NVL(cTpoTar, ' ')) || '" >> ' || TRIM(cRutaRepor) || TRIM(vNombreRepor2);
						SYSTEM cSystem;	
				
				END FOREACH;
			
				LET iPaso = 34;
					--GENERA ARCHIVO ZIP
						LET cSystem = 'zip '||TRIM(cRutaRepor)||TRIM('Reporte_eva_cte_bcpl')||'.zip '||'-P ReporServCte*98 /'||TRIM(cRutaRepor)||TRIM(vNombreRepor)|| ' ' || '/'||TRIM(cRutaRepor)||TRIM(vNombreRepor2) ;
						SYSTEM cSystem;
				
				LET iPaso = 35;
					--BORRADO DE ARCHIVO EXCEL
						LET cSystem = 'rm -f /home/procesos/'||vNombreRepor;
						SYSTEM cSystem;
						
						LET cSystem = 'rm -f /home/procesos/'||vNombreRepor2;
						SYSTEM cSystem;
					
			
				LET iPaso = 36;
				--BORRA TABLA TEMPORAL
					DROP TABLE tmp_si_servicio_cte_bcpl;
					TRUNCATE TABLE si_servicio_cte_bcpl DROP storage;
		
		RETURN cCodRet, cMsjCodRet;
	END;	
END PROCEDURE
DOCUMENT		
'REALIZA: Reporte de EvaluaciÃ³n de servicio al cliente bancoppel',		
'EQUIPO: Gerencia Mantto. 4',	
'FECHA: 10/09/2018',		
'VERSION: 1.0.0',
'CREADO POR: Ingrid Pamela CÃ¡zarez Villegas';

CREATE PROCEDURE "informix".sp_genarchivo_ctetsinhuella()
RETURNING VARCHAR(5) AS CodRetorno, 
		  VARCHAR(200) AS Mensaje;
		  
/*DEFINICION DE VARIABLES */		  
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR (200);

DEFINE cNumctecred		  CHAR (20);
DEFINE cNombreprodcred	  CHAR (40);

DEFINE cNumcteinv		  CHAR (20);
DEFINE cNombreprodinv	  CHAR (40);

DEFINE cFecha			  CHAR (20);
DEFINE cNumcte			  CHAR (20);
DEFINE cNombre			  CHAR (100);
DEFINE cNombreprod		  CHAR (40);

DEFINE cNombreArchivo 	  CHAR(100);
DEFINE cRutaArchivo 	  CHAR(100);

DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);

DEFINE cStmt1			  CHAR(200);
DEFINE cStmt2			  CHAR(200);



LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = 'EL PROCESO SE EJECUTO CORRECTAMENTE';

LET cNumctecred = '';
LET cNombreprodcred	= '';

LET cNumcteinv = '';
LET cNombreprodinv	= '';

LET cSQL1 = '';
LET cSQL = '';


--SET DEBUG FILE TO "/tmp/ALAN/sp_genarchivo_ctetsinhuella.out";
--RACE ON;

BEGIN


	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET vsMensaje = 'ERROR DE EJECUCION';
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
	TRUNCATE TABLE bdinteg:"informix".si_paso_archivocte;
	UPDATE statistics medium FOR TABLE bdinteg:"informix".si_paso_archivocte;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_ctet_sinhue') THEN
	DROP TABLE tmp_ctet_sinhue;
	END IF;
	
	IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_genera_nombre') THEN
	DROP TABLE tmp_genera_nombre;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	/*CLIENTES TITULARES SIN HUELLA*/
	SELECT {+INDEX( bdinteg:"informix".si_cliente ix_client_3 )} CAST(fecha_alta AS CHAR(20)) fecha_alta,numcte,TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) AS nombre_cliente 
	FROM si_cliente 
	WHERE tipo_cliente = 1 AND numcte NOT IN(SELECT numcte FROM si_cte_huella)
	INTO TEMP tmp_ctet_sinhue WITH NO LOG;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET vsCodRetorno = '00000';
		LET vsMensaje = 'NO EXISTEN CLIENTES TITULARES SIN HUELLA';
		RETURN vsCodRetorno, vsMensaje;
	END IF;
	
	
	/*CUENTA CAPTACION*/
		SELECT a.numcte,c.nombre FROM tmp_ctet_sinhue a INNER JOIN bdicheq: sc_maechq b ON a.numcte = b.num_cte INNER JOIN bdicheq:sc_producto c ON b.producto = c.producto
		WHERE b.status_cta = 1
		INTO TEMP tmp_genera_nombre WITH NO LOG;
	
	/*CREDITO REV*/
	--IFRS Se contempla el nuevo estatus E1 con Act 0 equivalente al estatus AA
	FOREACH
		SELECT a.numcte,c.nombre_prod 
		INTO cNumctecred,cNombreprodcred
		FROM tmp_ctet_sinhue a INNER JOIN bdicred: sd_maecred b ON a.numcte = b.numcte INNER JOIN bdicred:sd_definicion c ON b.num_producto = c.num_producto

		WHERE b.status_cred IN ('AA','E1')
		
		INSERT INTO tmp_genera_nombre VALUES (cNumctecred,cNombreprodcred);
	END FOREACH;
	
	/*CREDITO CRD*/
	--IFRS Se contempla el nuevo estatus E1 con Act 0 equivalente al estatus AA
	FOREACH
		SELECT a.numcte,c.nombre_prod 
		INTO cNumctecred,cNombreprodcred
		FROM tmp_ctet_sinhue a INNER JOIN bdicred: sd_maecredcrd b ON a.numcte = b.numcte INNER JOIN bdicred:sd_definicion c ON b.num_producto = c.num_producto

		WHERE b.status_cred IN ('AA','E1')
		
		INSERT INTO tmp_genera_nombre VALUES (cNumctecred,cNombreprodcred);
	END FOREACH;	
	
	/*INVERSIONES*/
	FOREACH
		SELECT a.numcte,c.nombre 
		INTO cNumcteinv, cNombreprodinv
		FROM tmp_ctet_sinhue a INNER JOIN bdinvers: sv_maeinv b ON a.numcte = b.num_cte INNER JOIN bdinvers: sv_instrum c ON b.cod_instrum = c.cod_instrum
		WHERE b.status_cta = 1
		
		INSERT INTO tmp_genera_nombre VALUES (cNumcteinv, cNombreprodinv);
		
	END FOREACH;

	/*GENERA ARCHIVO*/
	
	LET cStmt1 =  'Fecha_de_alta'||'|'||'N°_Cte'||'|'||'Nombre_Cte'||'|'||'Productos';
	INSERT INTO si_paso_archivocte (linea)
	VALUES(cStmt1); 
	
	FOREACH
		SELECT a.fecha_alta,a.numcte,a.nombre_cliente,NVL(b.nombre,'') AS producto 
		INTO cFecha,cNumcte,cNombre,cNombreprod
		FROM tmp_ctet_sinhue a INNER JOIN tmp_genera_nombre b ON a.numcte = b.numcte
		
		
		LET cStmt2 =  trim(cFecha)||'|'||trim(cNumcte)||'|'||trim(cNombre)||'|'||trim(NVL(cNombreprod,''));
		INSERT INTO si_paso_archivocte (linea)
		VALUES(cStmt2);
	END FOREACH;

		--Nombre del archivo
	LET cRutaArchivo = '/RESPALDOS/';
	LET cNombreArchivo = 'Reporte_de_clientes'||'.csv';
	
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' delimiter '||' SELECT linea FROM bdinteg:"informix".si_paso_archivocte ORDER BY secuencial" >'||TRIM(cRutaArchivo)||'Ejecuta_archivo_reporte.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdinteg '||TRIM(cRutaArchivo)||'Ejecuta_archivo_reporte.sql';
	SYSTEM cSQL;
	
	DROP TABLE tmp_ctet_sinhue;
	DROP TABLE tmp_genera_nombre; 
	
	RETURN vsCodRetorno, vsMensaje;
END;
END PROCEDURE;