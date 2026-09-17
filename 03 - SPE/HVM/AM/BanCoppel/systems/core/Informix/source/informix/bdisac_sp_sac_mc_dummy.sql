CREATE PROCEDURE "informix".sp_sac_mc_dummy(pCategoria CHAR(2), pConvenio CHAR(3), pEstatus CHAR(1))
	RETURNING CHAR(5) AS CodErr, CHAR(50) AS DescErr;

	DEFINE cCodErr 		VARCHAR(5);
	DEFINE cDescErr		VARCHAR(50);
	DEFINE iSqlErr		INTEGER;
	DEFINE vtransaccion INTEGER;
	DEFINE iOperId		INTEGER;
	DEFINE iParamId		INTEGER;
    DEFINE vFecha       VARCHAR(25);
	DEFINE vDia         VARCHAR(2);
	DEFINE vMes         VARCHAR(2);
	DEFINE vAno         VARCHAR(4);
	DEFINE vHrs         VARCHAR(2);
	DEFINE vMin         VARCHAR(2);
	DEFINE vSeg			VARCHAR(2);
    DEFINE vMseg        VARCHAR(2);

/* 	SET DEBUG FILE TO "/home/c90225087/sp_sac_mc_dummy.out";
	TRACE ON; */
	
	LET cCodErr 	 = "00000";
	LET cDescErr	 = "Proceso Dummy Activado";
	LET vtransaccion = 1;
    LET vFecha       = '';
	LET vDia		 = '';
	LET vMes		 = '';
	LET vAno		 = '';
	LET vHrs		 = '';
	LET vMin		 = '';
	LET vSeg		 = '';
    LET vMseg		 = '.0';
	LET iOperId      = -1;
	LET iParamId     = -1;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				LET cDescErr	= "Error";
				RETURN NVL(cCodErr,''),NVL(cDescErr,'');
			END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-535, -255)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;
		
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;
		
		IF (pCategoria IS NULL OR pCategoria = '' OR pConvenio IS NULL OR pConvenio = '' OR pEstatus IS NULL OR pEstatus = '' ) THEN 
			LET cCodErr = '00002';
			LET cDescErr = 'Faltan Parametros';
			
			RETURN cCodErr,cDescErr; 
		END IF;
		
		IF pEstatus NOT IN('A','I') THEN 
			LET cCodErr = '00002';
			LET cDescErr = '"A" activo o "I" inactivo';
			
			RETURN cCodErr,cDescErr; 
		END IF;
		
		IF pCategoria||pConvenio = '06002' AND pEstatus = 'A' THEN --Dish en dummy Activado
			--poner en dummy los servicios de dish
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws = '19' AND id_oper = '87';
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws = '19' AND id_oper = '88';
			--respuesta con valores default dummy CONSULTA dish
			UPDATE intercard:"informix".mc_parametros SET valordefault = '11111111'       WHERE id_oper = '87' AND id_param = '4952'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '4'              WHERE id_oper = '87' AND id_param = '4953'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '1'              WHERE id_oper = '87' AND id_param = '4954'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'CONSULTA DUMMY' WHERE id_oper = '87' AND id_param = '4955';
			UPDATE intercard:"informix".mc_parametros SET valordefault = today            WHERE id_oper = '87' AND id_param = '4956'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '001'            WHERE id_oper = '87' AND id_param = '4957'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'USUARIO DUMMY'  WHERE id_oper = '87' AND id_param = '4958'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0.00'           WHERE id_oper = '87' AND id_param = '4959'; 
			--respuesta con valores default dummy PAGO dish
			UPDATE intercard:"informix".mc_parametros SET valordefault = '9'                    WHERE id_oper = '88' AND id_param = '4966'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '1'                    WHERE id_oper = '88' AND id_param = '4967'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'PAGO APLICADO DUMMY'  WHERE id_oper = '88' AND id_param = '4968'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '001'                  WHERE id_oper = '88' AND id_param = '4969'; 
			COMMIT WORK;
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy Dish Activado';
			RETURN cCodErr,cDescErr;	
		ELIF pCategoria||pConvenio = '06002' AND pEstatus = 'I' THEN --Dish en dummy desactivado
			--Reverso Porduccion Dish
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws = '19' AND id_oper = '87';
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws = '19' AND id_oper = '88';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4952'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4953'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4954'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4955'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4956'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4957'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4958'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '87' AND id_param = '4959'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '88' AND id_param = '4966'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '88' AND id_param = '4967'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '88' AND id_param = '4968'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '88' AND id_param = '4969'; 
			COMMIT WORK;
			
			LET cCodErr = '00001';
			LET cDescErr = 'Dummy Dish Desactivado';
			RETURN cCodErr,cDescErr;				
		END IF; 
		
		IF pCategoria||pConvenio = '06001' AND pEstatus = 'A' THEN --SKY en dummy Activado
			--poner en dummy los servicios de SKY produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws = '10' AND id_oper = '66';
			--respuesta con valores default dummy PAGO sky
			UPDATE intercard:"informix".mc_parametros SET valordefault = '000'             WHERE id_oper = '66' AND id_param = '4373'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = current           WHERE id_oper = '66' AND id_param = '4376'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'APROBADO DUMMY'  WHERE id_oper = '66' AND id_param = '4377'; 
			COMMIT WORK;
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy SKY Activado';
			RETURN cCodErr,cDescErr;
		ELIF pCategoria||pConvenio = '06001' AND pEstatus = 'I' THEN --Dish en dummy desactivado 
			--REVERSO dummy los servicios de SKY produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws = '10' AND id_oper = '66';
			--respuesta con valores default dummy PAGO sky
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '66' AND id_param = '4373'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '66' AND id_param = '4376'; 
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '66' AND id_param = '4377';
			COMMIT WORK;				
			
			LET cCodErr = '00001';
			LET cDescErr = 'Dummy SKY Desactivado';
			RETURN cCodErr,cDescErr;				
		END IF;
		
		IF pCategoria||pConvenio = '03001' AND pEstatus = 'A' THEN --TAE en dummy Activado
            --SELECT FIRST 1 CURRENT YEAR TO SECOND INTO vFecha FROM sac_fechas;

			LET vFecha = CURRENT YEAR TO SECOND;
			LET vDia = SUBSTRING (vFecha FROM 9  FOR 2);
			LET vMes = SUBSTRING (vFecha FROM 6  FOR 2);
			LET vAno = SUBSTRING (vFecha FROM 1  FOR 4);
			LET vHrs = SUBSTRING (vFecha FROM 12 FOR 2);
			LET vMin = SUBSTRING (vFecha FROM 15 FOR 2);
			LET vSeg = SUBSTRING (vFecha FROM 18 FOR 2);
						
            --poner en dummy los servicios de TAE
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE  id_ws = '12' AND id_oper = '68';
			--respuesta con valores default dummy PAGO TAE
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0'          WHERE id_oper = '68' AND  id_param = '4421';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'DUMMY'      WHERE id_oper = '68' AND  id_param = '4422';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '314'        WHERE id_oper = '68' AND  id_param = '4424';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '318'        WHERE id_oper = '68' AND  id_param = '4425';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'C'          WHERE id_oper = '68' AND  id_param = '4426';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '1'          WHERE id_oper = '68' AND  id_param = '4427';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '3'          WHERE id_oper = '68' AND  id_param = '4428';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '1'          WHERE id_oper = '68' AND  id_param = '4429';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '90001'      WHERE id_oper = '68' AND  id_param = '4430';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '95736042'   WHERE id_oper = '68' AND  id_param = '4431';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vDia         WHERE id_oper = '68' AND  id_param = '4432';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vMes         WHERE id_oper = '68' AND  id_param = '4433';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vAno         WHERE id_oper = '68' AND  id_param = '4434';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vHrs         WHERE id_oper = '68' AND  id_param = '4435';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vMin         WHERE id_oper = '68' AND  id_param = '4436';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vSeg         WHERE id_oper = '68' AND  id_param = '4437';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0000000000' WHERE id_oper = '68' AND  id_param = '4438';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '000000'     WHERE id_oper = '68' AND  id_param = '4439';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '000000'     WHERE id_oper = '68' AND  id_param = '4440';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0'          WHERE id_oper = '68' AND  id_param = '4441';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '00000'      WHERE id_oper = '68' AND  id_param = '4442';
            COMMIT WORK;
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy TAE Activado';
			RETURN cCodErr,cDescErr;
		ELIF pCategoria||pConvenio = '03001' AND pEstatus = 'I' THEN --TAE en dummy Desactivado
			--Reverso en dummy los servicios de TAE
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE  id_ws = '12' AND id_oper = '68';
			--Reverso con valores default dummy PAGO TAE
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4421';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4422';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4424';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4425';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4426';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4427';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4428';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4429';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4430';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4431';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4432';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4433';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4434';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4435';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4436';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4437';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4438';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4439';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4440';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4441';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '68' AND  id_param = '4442';
			COMMIT WORK;
			
			LET cCodErr = '00001';
			LET cDescErr = 'Dummy TAE Desactivado';
			RETURN cCodErr,cDescErr;
		END IF;
		
		IF ((pCategoria = '03' AND pConvenio IN ('002','004','005')) 
             OR (pCategoria = '06' AND pConvenio IN ('007','008'))
             OR (pCategoria = '08' AND pConvenio IN ('005','009','010','016'))
             OR (pCategoria = '09' AND pConvenio IN ('019','020')))
            AND pEstatus = 'A' THEN --ANTAD en dummy Activado
            --poner en dummy los servicios de ANTAD
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws ='15' AND id_oper = '79';
			--respuesta con valores default dummy PAGO ANTAD
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0120usu0001'       where id_oper = '79' and id_param = '4780';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'F);M+GzwEu\T{wm6'  where id_oper = '79' and id_param = '4781';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'C790EC7D222959816058BC15C6EC8822' where id_oper = '280' and id_param = '4782';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '005056b95892'      where id_oper = '79' and id_param = '4783';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '120'               where id_oper = '79' and id_param = '4784';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '96'                where id_oper = '79' and id_param = '4787';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '12345'             where id_oper = '79' and id_param = '4788';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'Mensaje Tkt Dummy' where id_oper = '79' and id_param = '4789';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'Mensaje Caj Dummy' where id_oper = '79' and id_param = '4790';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '123456789321'      where id_oper = '79' and id_param = '4791';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '123987654321'      where id_oper = '79' and id_param = '4792';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0.00'              where id_oper = '79' and id_param = '4793';
            COMMIT WORK;
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy ANTAD Activado';
			RETURN cCodErr,cDescErr;
       	
		ELSE IF ((pCategoria = '03' AND pConvenio IN ('002','004','005')) 
             OR (pCategoria = '06' AND pConvenio IN ('007','008'))
             OR (pCategoria = '08' AND pConvenio IN ('005','009','010','016'))
             OR (pCategoria = '09' AND pConvenio IN ('019','020'))) 
            AND pEstatus = 'I' THEN --ANTAD en dummy Desactivado

				--Reverso en dummy los servicios de ANTAD
                UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws ='15' AND id_oper = '79';
				--Reverso con valores default dummy PAGO ANTAD
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4780';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4781';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4782';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4783';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4784';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4787';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4788';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4789';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4790';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4791';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4792';
                UPDATE intercard:"informix".mc_parametros SET valordefault = '' where id_oper = '79' and id_param = '4793';
				COMMIT WORK;
				
				LET cCodErr = '00001';
				LET cDescErr = 'Dummy ANTAD Desactivado';
				RETURN cCodErr,cDescErr;
				
			END IF;
		END IF;
		
		
		IF pCategoria||pConvenio = '00INE' AND pEstatus = 'A' THEN --INEv2.1 y INEv4.0 en dummy Activado
			LET vFecha = CURRENT YEAR TO SECOND;
			LET vDia = SUBSTRING (vFecha FROM 9  FOR 2);
			LET vMes = SUBSTRING (vFecha FROM 6  FOR 2);
			LET vAno = SUBSTRING (vFecha FROM 1  FOR 4);
			LET vHrs = SUBSTRING (vFecha FROM 12 FOR 2);
			LET vMin = SUBSTRING (vFecha FROM 15 FOR 2);
			LET vSeg = SUBSTRING (vFecha FROM 18 FOR 2);
                
			--Activar el dummy INEv2.1
            --poner en dummy los servicios de INE produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws ='20' AND id_oper = '89';
			--respuesta con valores default dummy PAGO INE
			UPDATE intercard:"informix".mc_parametros SET valordefault = '91'   WHERE id_oper = '89' AND id_param = '4983';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'VALIDACION DUMMY' WHERE id_oper = '89' AND id_param = '4984';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4985';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4986';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vAno||'-'||vMes||'-'||vDia||'T'||vHrs||':'||vMin||':'||vSeg||vMseg  WHERE id_oper = '89' AND id_param = '4987';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4988';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4989';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4990';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4991';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4992';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4993';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4994';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4995';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4996';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4997';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4998';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '4999';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5000';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5001';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5002';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5003';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5004';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5005';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5006';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '89' AND id_param = '5007';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '10000'  WHERE id_oper = '89' AND id_param = '5008';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0'      WHERE id_oper = '89' AND id_param = '5009';
			
			--Activar el dummy INEv4.0
			--poner en dummy los servicios de INEv4 produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws ='22' and id_oper = '92';
			--respuesta con valores default dummy PAGO INE
            UPDATE intercard:"informix".mc_parametros SET valordefault = '91' WHERE id_oper = '92' AND id_param = '5069';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'VALIDACION DUMMY' WHERE id_oper = '92' AND id_param = '5070';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true' WHERE id_oper = '92' AND id_param = '5071';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true' WHERE id_oper = '92' AND id_param = '5072';
			UPDATE intercard:"informix".mc_parametros SET valordefault = vAno||'-'||vMes||'-'||vDia||'T'||vHrs||':'||vMin||':'||vSeg||vMseg  WHERE id_oper = '92' AND id_param = '5073';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5074';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5075';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5076';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5077';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5078';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5079';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5080';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5081';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5082';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5083';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5084';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5085';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5086';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5087';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5088';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5089';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5090';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5091';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5092';
            UPDATE intercard:"informix".mc_parametros SET valordefault = 'true'   WHERE id_oper = '92' AND id_param = '5093';
            UPDATE intercard:"informix".mc_parametros SET valordefault = '10000'  WHERE id_oper = '92' AND id_param = '5094';
            UPDATE intercard:"informix".mc_parametros SET valordefault = '10000'  WHERE id_oper = '92' AND id_param = '5095';			
            COMMIT WORK;
			
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy INE Activado';
			RETURN cCodErr,cDescErr;
		ELIF pCategoria||pConvenio = '00INE' AND pEstatus = 'I' THEN --INE en dummy desactivado 
			--Desactivar el dummy INEv2.1
            --REVERSO dummy los servicios de INE produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws ='20' AND id_oper = '89';
			--REVERSO con valores default dummy PAGO INE
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4983';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4984';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4985';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4986';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4987';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4988';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4989';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4990';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4991';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4992';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4993';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4994';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4995';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4996';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4997';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4998';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '4999';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5000';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5001';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5002';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5003';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5004';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5005';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5006';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5007';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5008';
			UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = '89' AND id_param = '5009'; 
			
			--Desactivar el dummy INEv4.0
			--REVERSO dummy los servicios de INE produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws ='22' and id_oper = '92';
			--REVERSO con valores default dummy PAGO INE
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5069';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5070';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5071';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5072';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5073';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5074';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5075';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5076';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5077';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5078';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5079';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5080';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5081';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5082';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5083';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5084';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5085';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5086';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5087';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5088';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5089';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5090';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5091';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5092';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5093';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5094';
            UPDATE intercard:"informix".mc_parametros SET valordefault = ''   WHERE id_oper = '92' AND id_param = '5095';
			COMMIT WORK;				
			
			LET cCodErr = '00001';
			LET cDescErr = 'Dummy INE Desactivado';
			RETURN cCodErr,cDescErr;				
		END IF;
		
		IF pCategoria||pConvenio = '00REN' THEN --RENAPO en dummy Activado
			--Buscar la transaccion apropiada
			SELECT id_oper INTO iOperId	FROM intercard:"informix".mc_operaciones WHERE id_tran = (SELECT id_tran FROM intercard:"informix".mc_iac_transaccion WHERE tran_iac = '20160');
			IF NVL(iOperId, -1) = -1 THEN
				LET cCodErr = '00002';
				LET cDescErr = 'Transaccion RENAPO #20160 no encontrada.';
				RETURN cCodErr,cDescErr; 
			END IF;
			
			SELECT id_param INTO iParamId FROM intercard:"informix".mc_parametros WHERE id_oper = iOperId AND etiqueta LIKE '%descripcionError%';
			IF NVL(iParamId, -1) = -1 THEN
				LET cCodErr = '00002';
				LET cDescErr = 'Parametro RENAPO "descripcionError" no encontrado.';
				RETURN cCodErr,cDescErr; 
			END IF;
			
			IF pEstatus = 'A' THEN --Activar dummy RENAPO
				--poner en dummy los servicios de RENAPO produccion
				UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_oper = iOperId;
				--respuesta con valores default dummy PAGO RENAPO
				UPDATE intercard:"informix".mc_parametros SET valordefault = 'VALIDACION DUMMY' WHERE id_oper = iOperId AND id_param = iParamId;
				COMMIT WORK;
				
				LET cCodErr = '00000';
				LET cDescErr = 'Dummy RENAPO Activado';
				RETURN cCodErr, cDescErr;
			ELIF pEstatus = 'I' THEN --Desactivar dummy RENAPO 
				--REVERSO dummy los servicios de RENAPO produccion
				UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_oper = iOperId;
				--REVERSO con valores default dummy PAGO RENAPO
				UPDATE intercard:"informix".mc_parametros SET valordefault = '' WHERE id_oper = iOperId AND id_param = iParamId;
				COMMIT WORK;				
				
				LET cCodErr = '00001';
				LET cDescErr = 'Dummy RENAPO Desactivado';
				RETURN cCodErr, cDescErr;				
			END IF;
		END IF;
		
		IF pCategoria||pConvenio = '20REN' AND pEstatus = 'A' THEN --RENAPO 20161 en dummy Activado
			LET vFecha = CURRENT YEAR TO SECOND;
/* 			LET vDia = SUBSTRING (vFecha FROM 9  FOR 2);
			LET vMes = SUBSTRING (vFecha FROM 6  FOR 2);
			LET vAno = SUBSTRING (vFecha FROM 1  FOR 4); */
						--poner en dummy los servicios de RENAPO CURP 20161 produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'V' WHERE id_ws ='14' AND id_oper = '91';
			--respuesta con valores default dummy PAGO INE
			UPDATE intercard:"informix".mc_parametros SET valordefault = '0000'             WHERE id_oper = '91' AND id_param = '5030';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5031';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'VALIDACION DUMMY' WHERE id_oper = '91' AND id_param = '5032';
			UPDATE intercard:"informix".mc_parametros SET valordefault = 'EXITOSO'          WHERE id_oper = '91' AND id_param = '5033';			
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5034';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5035';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5036';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5037';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5038';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5039';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5040';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5041';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5042';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5043';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5044';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5045';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5046';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5047';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5048';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5049';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5050';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5051';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5052';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5053';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5054';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5055';
			COMMIT WORK;
			
			LET cCodErr = '00000';
			LET cDescErr = 'Dummy RENAPO Activado';
			RETURN cCodErr,cDescErr;
		ELIF pCategoria||pConvenio = '20REN' AND pEstatus = 'I' THEN --RENAPO en dummy desactivado 
			--REVERSO dummy los servicios de CURP 20161 produccion
			UPDATE intercard:"informix".mc_operaciones SET oper_dummy = 'F' WHERE id_ws ='14' AND id_oper = '91';
			--respuesta con valores default dummy RENAPO
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5030';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5031';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5032';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5033';			
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5034';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5035';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5036';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5037';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5038';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5039';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5040';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5041';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5042';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5043';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5044';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5045';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5046';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5047';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5048';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5049';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5050';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5051';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5052';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5053';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5054';
			UPDATE intercard:"informix".mc_parametros SET valordefault = ''                 WHERE id_oper = '91' AND id_param = '5055';
			COMMIT WORK;				
			
			LET cCodErr = '00001';
			LET cDescErr = 'Dummy RENAPO Desactivado';
			RETURN cCodErr,cDescErr;				
		END IF;		
		LET cCodErr =  '00003';
		LET cDescErr = 'No exite motor de consumo con ese convenio ';
		
		RETURN cCodErr, cDescErr;
	END;
END PROCEDURE
DOCUMENT
'FOLIO.........: RQI 62 850 - Procesos dummy automaticos motor de servicios (DISH,SKY)',
'AUTOR.........: 95736042 - Eduardo Pineda',
'FECHA.........: 12/04/2020',
'MODIFICACION..: Se crea procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo (DISH, SKY)',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC',

'FOLIO.........: RQI 62 866 - Procesos dummy automaticos motor de servicios (TAE)',
'AUTOR.........: 95736042 - Eduardo Pineda',
'FECHA.........: 04/05/2020',
'MODIFICACION..: Se crea procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo TAE',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC',

'FOLIO.........: RQI 62 876 - Procesos dummy automaticos motor de servicios (ANTAD)',
'AUTOR.........: 95736042 - Eduardo Pineda',
'FECHA.........: 28/05/2020',
'MODIFICACION..: Se crea procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo ANTAD',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC',

'FOLIO.........: RQI 62 881 - Procesos dummy automaticos motor de servicios (INE)',
'AUTOR.........: 95736042 - Eduardo Pineda',
'FECHA.........: 10/06/2020',
'MODIFICACION..: Se crea procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo INE',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC',

'FOLIO.........: RQI 62 879 - Procesos dummy automaticos motor de servicios (RENAPO)',
'AUTOR.........: 95736042 - Eduardo Pineda',
'FECHA.........: 22/06/2020',
'MODIFICACION..: Se crea procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo RENAPO',
'SUSTENTO......: ',
'SOLICITA......: LEONARDO HERNANDEZ',
'BD............: BDISAC',

'FOLIO.........: RQI 63 564 - Mantenimiento a proceso de auto-gestiÃÂ³n RENAPO',
'AUTOR.........: 98309684 - Lauro E. Estrada L.',
'FECHA.........: 21/01/2021',
'MODIFICACION..: Se modifica procedimiento para Activa/Desactivar modo dummy los servicios del motor de consumo RENAPO',
'SUSTENTO......: ',
'SOLICITA......: Juan F. Ponce Damian',
'BD............: BDISAC',

'FOLIO.........: RQI 63 956 - Procesos dummy automaticos motor de servicios (RENAPO)',
'AUTOR.........: 93865945 - Juan Ponce 90225087 - Rojas Luis Victor H. y Gabriel Romero Cuauhitzo',
'FECHA.........: 07/08/2023',
'MODIFICACION..: Se crea codigo para Activa/Desactivar modo dummy los servicios del motor de consumo RENAPO transaccion 20161',
'SUSTENTO......: ',
'SOLICITA......: Juan F. Ponce Damian y Jaime Gonzalez',
'BD............: BDISAC',



'FOLIO.........: RQI 63 1139 - servicio 4.0 modo dummy sub trans 90073',
'AUTOR.........: 93865945 - Juan Ponce 90225087 - Rojas Luis Victor H. y Gabriel Romero Cuauhitzo',
'FECHA.........: 25/09/2023',
'MODIFICACION..: Se crea codigo para Activa/Desactivar modo dummy los servicios del motor de consumo INEv4.0 sub transaccion 90073',
'SUSTENTO......: ',
'SOLICITA......: Juan F. Ponce Damian y Jaime Gonzalez',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_remesasapp_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;


	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);
	DEFINE cStatus				CHAR(1);
	DEFINE dFecha_remesa               DATE;
	DEFINE cTipo_remesa              	CHAR(3);
	DEFINE cAbono_cuenta               CHAR(2);
	DEFINE cUnirefnum           CHAR(20);
	DEFINE mMonto_total                MONEY;
	DEFINE mMonto_dolares           	MONEY;
	DEFINE cTransaccion            	CHAR(4);
	DEFINE cFolio_sucursal             CHAR(16);
	DEFINE dFecha_alta           		DATE;
	DEFINE cBeneficiario_nombre1      	CHAR(30);
	DEFINE cBeneficiario_nombre2       CHAR(30);
	DEFINE cBeneficiario_appaterno     CHAR(30);
	DEFINE cBeneficiario_apmaterno 	CHAR(30);
	DEFINE dBeneficiario_fecha_nac     DATE;
	DEFINE cBeneficiario_estado      	CHAR(50);
	DEFINE cBeneficiario_mncpo_del    	CHAR(50);
	DEFINE cBeneficiario_ciudad		CHAR(50);
	DEFINE cBeneficiario_direccion		CHAR(100);
	DEFINE cBeneficiario_colonia		CHAR(80);
	DEFINE cBeneficiario_calle			CHAR(50);
	DEFINE cBeneficiario_num_ext		CHAR(5);
	DEFINE cBeneficiario_num_int		CHAR(5);
	DEFINE cBeneficiario_depto			CHAR(10);
	DEFINE cBeneficiario_cp			CHAR(9);
	DEFINE cOrdenante_nombre1			CHAR(40);
	DEFINE cOrdenante_nombre2			CHAR(40);
	DEFINE cOrdenante_appaterno		CHAR(40);
	DEFINE cOrdenante_apmaterno		CHAR(40);
	DEFINE cOrdenante_direccion		CHAR(100);
	DEFINE cSucursal					CHAR(4);
	DEFINE cUsuario					CHAR(8);
	DEFINE dFecha_Proceso			DATE;
	DEFINE dFecha_Alt				DATE;
	DEFINE cReferencia1				CHAR(40);
	DEFINE iSecuencia				INTEGER;
	DEFINE cAgent_dt				CHAR(8);
	DEFINE cProcess_dt				CHAR(8);
	DEFINE cTerminal				CHAR(15);
	DEFINE iCuantosCheq				INTEGER;
	DEFINE iCuantosMovtos			INTEGER;
	DEFINE iCuantosSdep				INTEGER;
	DEFINE iCuantosQryi				INTEGER;
	DEFINE iCuantosPayi				INTEGER;
	DEFINE cFechaFor          		CHAR(8);

	DEFINE cFecha_peticion 			CHAR(10);
	DEFINE cHora_peticion			CHAR(6);
	DEFINE cHora_transaccion		CHAR(6);
	DEFINE cCnxn_status				CHAR(1);
	DEFINE cCod_pais_origen			CHAR(3);
	DEFINE cCod_moneda_origen		CHAR(3);
	DEFINE cCod_pais_destino        CHAR(3);
	DEFINE cCod_moneda_destino      CHAR(3);
	DEFINE cTipo_cambio             CHAR(21);
	DEFINE cCuenta_benef            CHAR(30);
	DEFINE cTp_id_benef             CHAR(3);
	DEFINE cNum_id_benef            CHAR(20);
	DEFINE cCod_pais_benef          CHAR(3);
	DEFINE cCp_benef                CHAR(10);
	DEFINE cTel_benef               CHAR(15);
	DEFINE cCd_remitente            CHAR(40);
	DEFINE cCod_edo_remitente       CHAR(3);
	DEFINE cCod_pais_remitente      CHAR(3);
	DEFINE cCp_remitente            CHAR(10);
	DEFINE cTel_remitente           CHAR(15);
	DEFINE cNumero_de_cliente_benef	CHAR(20);
	DEFINE dHora_proceso 			DATETIME HOUR to FRACTION(3);
	DEFINE cDescripcionSPJ	 		CHAR(100);
	DEFINE cCodRetSP				CHAR(5);
	DEFINE sCont					SMALLINT;

	DEFINE cHora_remesa				CHAR(8);
	DEFINE cColonia_ordenante		CHAR(100);
	DEFINE cTipo_id_ordenante		CHAR(20);
	DEFINE cNumero_id_ordenante		CHAR(30);
	DEFINE cCiudad_id_ordenante		CHAR(40);
	DEFINE cName_benef_suc			CHAR(120);
	DEFINE cNum_id_benef_suc		CHAR(30);
	DEFINE cUniquereferencenumber 	CHAR(16);
	DEFINE cRefCargo				CHAR(12);

	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	LET cStatus						= '0';
	LET dFecha_remesa               = mdy(01,01,1900);
	LET cTipo_remesa              	= '';
	LET cAbono_cuenta               = '';
	LET cUnirefnum         	= '';
	LET mMonto_total                = 0;
	LET mMonto_dolares           	= 0;
	LET cTransaccion            	= '';
	LET cFolio_sucursal             = '';
	LET dFecha_alta           		= mdy(01,01,1900);
	LET cBeneficiario_nombre1      	= '';
	LET cBeneficiario_nombre2       = '';
	LET cBeneficiario_appaterno     = '';
	LET cBeneficiario_apmaterno 	= '';
	LET dBeneficiario_fecha_nac   	= mdy(01,01,1900);
	LET cBeneficiario_estado      	= '';
	LET cBeneficiario_mncpo_del    	= '';
	LET cBeneficiario_ciudad		= '';
	LET cBeneficiario_direccion		= '';
	LET cBeneficiario_colonia		= '';
	LET cBeneficiario_calle			= '';
	LET cBeneficiario_num_ext		= '';
	LET cBeneficiario_num_int		= '';
	LET cBeneficiario_depto			= '';
	LET cBeneficiario_cp			= '';
	LET cOrdenante_nombre1			= '';
	LET cOrdenante_nombre2			= '';
	LET cOrdenante_appaterno		= '';
	LET cOrdenante_apmaterno		= '';
	LET cOrdenante_direccion		= '';
	LET cSucursal					= '';
	LET cUsuario					= '';
	LET dFecha_Proceso				= FechaFin;
	LET dFecha_Alt					= mdy(01,01,1900);
	LET cReferencia1				= '';
	LET iSecuencia					= 0;
	LET cAgent_dt					= '';
	LET cProcess_dt					= '';
	LET cTerminal					= '';
	LET iCuantosCheq				= 0;
	LET iCuantosMovtos				= 0;
	LET iCuantosSdep				= 0;
	LET iCuantosQryi				= 0;
	LET iCuantosPayi				= 0;
	LET cFechaFor          			= '';

	LET cFecha_peticion 			= '01/01/1900';
	LET cHora_peticion				= '';
	LET cHora_transaccion			= '';
	LET cCnxn_status				= '';
	LET cCod_pais_origen			= '';
	LET cCod_moneda_origen			= '';
	LET cCod_pais_destino       	= '';
	LET cCod_moneda_destino     	= '';
	LET cTipo_cambio            	= '0';
	LET cCuenta_benef           	= '';
	LET cTp_id_benef            	= '';
	LET cNum_id_benef           	= '';
	LET cCod_pais_benef         	= '';
	LET cCp_benef               	= '';
	LET cTel_benef              	= '';
	LET cCd_remitente           	= '';
	LET cCod_edo_remitente      	= '';
	LET cCod_pais_remitente     	= '';
	LET cCp_remitente           	= '';
	LET cTel_remitente          	= '';
	LET cNumero_de_cliente_benef	= '';
	LET dHora_proceso 				= '';
	LET cDescripcionSPJ	 			= 'Inserta datos de Remesas Appriza para sistema de PLD';
	LET cCodRetSP = "00000";
	LET sCont						 = 0;

	LET cHora_remesa				= '';
	LET cColonia_ordenante			= '';
	LET cTipo_id_ordenante			= '';
	LET cNumero_id_ordenante		= '';
	LET cCiudad_id_ordenante		= '';
	LET cName_benef_suc				= '';
	LET cNum_id_benef_suc			= '';
	LET cUniquereferencenumber 		= '';
	LET cRefCargo					='';

	--SET DEBUG FILE TO  '/informix/ENP/sp_remesasapp_pld.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesasapp_pld" || "Remesa:" || cUnirefnum);
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			IF sCont >= 0 THEN
				COMMIT WORK;
			END IF;
		END EXCEPTION WITH RESUME;

		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
			RETURN cCodRet, cMensaje;
		ELSE
			EXECUTE PROCEDURE sp_inicializatablaspld('BAPP','',FechaFin) INTO cCodRetSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE APPRIZA";
				RETURN cCodRet, cMensaje;
			END IF;

			IF FechaIni = FechaFin THEN

				IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_PLD_APP' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_APP', FechaFin, '0', 'informix', 'sp_remesasapp_pld', cDescripcionSPJ);
				ELSE
					SELECT status
					INTO cStatus
					FROM bdisac:"informix".sac_procesos_jobs
					WHERE proceso = 'IND_PLD_APP' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN
						EXECUTE PROCEDURE sp_inicializatablaspld('','APP',FechaFin) INTO cCodRetSP;
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE APPRIZA EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;
						END IF;
					END IF;
				END IF;
			END IF;

			IF cStatus = '0' THEN
				set isolation to dirty read;
				BEGIN WORK;
				FOREACH WITH HOLD
					--12/07/2022 se agrega la columna "referencia" a la tabla sac_cargo_app, para descartar folio_suc duplicados **ENP**
					--ABONO DIRECTO EN CUENTA
					select NVL(folio_suc,''), NVL(fech_alt,mdy(01,01,1900)), NVL(sucursal,''), NVL(usuario,''), NVL(monto_tot,0), NVL(substr(fech_hor,1,8),''),NVL(substr(referencia,17,12),'')
					into cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa, cRefCargo
					  from bdicheq:"informix".sc_movhis
					 where fech_alt >= FechaIni
					   and fech_alt <= FechaFin
					   and cancelad <> 'S'
					   and usuario = 'sys_apz'
					   and transacc = '1355'

					INSERT INTO bdisac:"informix".sac_cargo_app (folio_suc, fech_alt, sucursal, usua, monto_tot, hora_remesa,referencia)
					VALUES (cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa, cRefCargo);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosCheq
				FROM bdisac:"informix".sac_cargo_app;

				BEGIN WORK;
				FOREACH WITH HOLD
					select {+INDEX(bdisac:"informix".sac_cargo_app idxsac_cargo_appff)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(hora_remesa,'')
					into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa
					  from bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_cargo_app b
					 where fecha_pago >= FechaIni
					   and fecha_pago <= FechaFin
					   and numcategoria = '07'
					   and numconvenio = '009'
					   and status_cancelado <> 'S'
					   and a.folio_suc = b.folio_suc
					   and b.fech_alt = a.fecha_pago
					   and a.id_sucursal = b.sucursal
					   and a.usuario = b.usua
					   and a.importe_pago = b.monto_tot
					   and a.referencia1= b.referencia

					INSERT INTO bdisac:"informix".sac_movtos_app (referencia1,folio_suc,fecha_pago,usuario,id_sucursal,hora_remesa)
					VALUES (cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosMovtos
				FROM bdisac:"informix".sac_movtos_app;

				BEGIN WORK;
				FOREACH WITH HOLD
					select {+INDEX(bdisac:"informix".sac_movtos_app idxsac_movtos_appr1)} NVL(fecha_pago,mdy(01,01,1900)) fecha_remesa,'APP' tipo_remesa,'SI' abono_cuenta,NVL(uniquereferencenumber,''),NVL(destinationamount,0) monto_total,NVL(originamount,0) monto_dolares,'8963' transaccion,
						   NVL(folio_suc,'') folio,(today) fecha_alta,NVL(firstnamebenefi,'') beneficiario_nombre1,NVL(middlenamebenefi,'') beneficiario_nombre2,NVL(lastnamebenefi,'') beneficiario_appaterno,
						   NVL(mothermaidennamebenefi,'') beneficiario_apmaterno,mdy(01,01,1900) beneficiario_fecha_nac,NVL(statecodebenefi,'') beneficiario_estado,NVL(citybenefi,'') beneficiario_mncpo_del,
						   NVL(citybenefi,'') beneficiario_ciudad,NVL(addressbenefi,'') beneficiario_direccion, '' beneficiario_colonia, '' beneficiario_calle,'' beneficiario_num_ext,
						   '' beneficiario_num_int,'' beneficiario_depto,NVL(zipcodebenefi,'') beneficiario_cp,NVL(firstnamesender,'') ordenante_nombre1,NVL(middlenamesender,'') ordenante_nombre2,
						   NVL(lastnamesender,'') ordenante_appaterno,NVL(mothermaidennamesender,'') ordenante_apmaterno,NVL(addressbenefi,'') ordenante_direccion,NVL(id_sucursal,'') sucursal,NVL(usuario,''),
						   NVL(processdaterequest,'01/01/1900'), NVL(processtimerequest,''), NVL(processdatedetail,''), NVL(cnxn_status,''), NVL(countrycodeorigin,''), NVL(currencycodeorigin,''), NVL(countrycodedestination,''),
						   NVL(currencycodedestination,''), NVL(retailexchangerate,'0'), NVL(accountnumbersenderpay,''), NVL(typecode,''), NVL(numberid,''),
						   NVL(countrycodebenefi,''), NVL(zipcodebenefi,''), NVL(homephonenumber,''),
						   NVL(citysender,''), NVL(statecodesender,''), NVL(countrycodesender,''), NVL(zipcodesender,''), NVL(processtimedetail,''),NVL(addresssender,''),
						   NVL(citysender,''), NVL(firstnamebenefi,'') || " " || NVL(middlenamebenefi,'') || " " || NVL(lastnamebenefi,'') || " " || NVL(mothermaidennamebenefi,''),
						   NVL(numberid,'')
					INTO dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUniquereferencenumber, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
						cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado,
						cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext,
						cBeneficiario_num_int, cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno,
						cOrdenante_direccion, cSucursal, cUsuario,
						cFecha_peticion,cHora_peticion,cHora_transaccion,cCnxn_status,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,
						cTipo_cambio,cCuenta_benef,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef,
						cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,
						cHora_remesa, cColonia_ordenante, cCiudad_id_ordenante, cName_benef_suc, cNum_id_benef_suc
					 from bdisac:"informix".sac_app_getorder,bdisac:"informix".sac_movtos_app
					  where uniquereferencenumber = referencia1
					  and fecha_insert::date >= FechaIni - 1 UNITS DAY
					  and fecha_insert::date <= FechaFin
					  and fecha_pago::date >= fecha_insert::date
					  and estatus_getorder = '05'

					  IF length(cCuenta_benef)<16 THEN
						select NVL(num_cte,'')
						  into cNumero_de_cliente_benef
						  from bdicheq:"informix".sc_maechq
						  where cuenta = cCuenta_benef;
					  ELSE
						select NVL(numcte,'')
						into cNumero_de_cliente_benef
						from bdicheq:"informix".sc_tarjeta
						where num_tarjeta = cCuenta_benef
						and empresa = '001';
					  END IF;

					  LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

					INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
					VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUniquereferencenumber, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
						cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado,
						cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_colonia, cBeneficiario_calle, cBeneficiario_num_ext, cBeneficiario_num_int,
						cBeneficiario_depto, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,
						cUsuario, dFecha_Proceso,
						cFecha_peticion,cHora_peticion,cHora_transaccion,cCnxn_status,'',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,
						cTipo_cambio,NVL(cNumero_de_cliente_benef,''),'',cCuenta_benef,'',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','',
						cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,
						'','',dHora_proceso,cHora_remesa,cColonia_ordenante,'','',cCiudad_id_ordenante,'',cName_benef_suc,cNum_id_benef_suc,'01011900');

						LET sCont = sCont + 1;
						IF sCont = 5000 THEN
							COMMIT WORK;
							LET sCont = 0;
							BEGIN WORK;
						END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} count(*)
				INTO iCuantosSdep
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFecha_Proceso
				AND tipo_remesa ='APP'
				AND abono_cuenta = 'SI';

				--OBTENER REMESAS QUE NO ESTEN EN ALGUNA DE LAS TABLAS
				IF iCuantosCheq <> iCuantosMovtos THEN
					BEGIN WORK;
					FOREACH WITH HOLD
						select {+INDEX(bdisac:"informix".sac_cargo_app idxsac_cargo_appff)}
						NVL(folio_suc,''), NVL(fech_alt,mdy(01,01,1900)), NVL(sucursal,''), NVL(usua,''), NVL(monto_tot,0), NVL(hora_remesa,''),  NVL(substr(referencia,17,12),'')
						into cFolio_Sucursal, dFecha_Alt, cSucursal, cUsuario, mMonto_total, cHora_remesa,cRefCargo
						from bdisac:"informix".sac_cargo_app
						where folio_suc not in (select {+INDEX(bdisac:"informix".sac_movtos_app idxsac_movtos_appr1)} folio_suc from bdisac:"informix".sac_movtos_app)

						LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

						INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
						VALUES(dFecha_Alt, 'APP', 'SI', '', mMonto_total, 0, '', cFolio_sucursal, (today), '', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cSucursal, cUsuario, dFecha_Proceso,
							mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');

						LET sCont = sCont + 1;
						IF sCont = 5000 THEN
							COMMIT WORK;
							LET sCont = 0;
							BEGIN WORK;
						END IF;

					END FOREACH;

						IF sCont < 5000 and sCont >= 0 THEN
							COMMIT WORK;
							LET sCont = 0;
						END IF;

					ELSE IF iCuantosMovtos <> iCuantosSdep THEN
						BEGIN WORK;
						FOREACH WITH HOLD
							select {+INDEX(bdisac:"informix".sac_movtos_app idxsac_movtos_appr1)}
							NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(hora_remesa,'')
							into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cHora_remesa
							from bdisac:"informix".sac_movtos_app
							where folio_suc not in (select {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} folio_sucursal from bdisac:"informix".sac_pld_remesas WHERE fecha_proceso = dFecha_Proceso
							AND tipo_remesa ='APP'
							AND abono_cuenta = 'SI')
							--12/07/2022 se agrega validacion por "referencia" en el cruce de tabla sac_cargo_app y sac_movtos_app , para descartar folio_suc duplicados **ENP**
							select {+INDEX(bdisac:"informix".sac_cargo_app idxsac_cargo_appff)}  NVL(monto_tot,0)
							into mMonto_total
							from bdisac:"informix".sac_cargo_app
							where folio_suc = cFolio_Sucursal
							and fech_alt = dFecha_Alt
							and sucursal = cSucursal
							and usua = cUsuario
							and referencia = cReferencia1;

							LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

							INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
							beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
							beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
							beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
							fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
							numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
							tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
							cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
							hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
							num_id_benef_suc,fecha_envio_remesa)
							VALUES(dFecha_Alt, 'APP', 'SI', cReferencia1, mMonto_total, 0, '', cFolio_sucursal, (today),
								'', '', '', '', '', '', '', '', '', '', '', '', '',	'', '', '', '', '', '', '', cSucursal,cUsuario, dFecha_Proceso,
								mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');

							LET sCont = sCont + 1;
							IF sCont = 5000 THEN
								COMMIT WORK;
								LET sCont = 0;
								BEGIN WORK;
							END IF;
						END FOREACH;

						IF sCont < 5000 and sCont >= 0 THEN
							COMMIT WORK;
							LET sCont = 0;
						END IF;

					END IF;
				END IF;

				--VENTANILLA
				BEGIN WORK;
				FOREACH WITH HOLD
					select NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''), NVL(sucursal,''), NVL(usuario,''), NVL(monto_tot,0),NVL(substr(fech_hor,1,8),'')
					into cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa
					  from bdicheq:sc_movhis
					 where empresa = '001'
					   and fech_alt >= FechaIni
					   and fech_alt <= FechaFin
					   and transacc in ('1325','1385', '1525')
					   and cancelad <> 'S'
					   and usuario <> 'sys_apz'

					INSERT INTO bdisac:"informix".sac_cheques_app (folio_suc,fech_alt,transacc_suc, sucursal, usua, monto_tot, hora_remesa)
					VALUES (cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosCheq
				FROM bdisac:"informix".sac_cheques_app;

				BEGIN WORK;
				FOREACH WITH HOLD
					--OBTIENE DATOS DE SERVICIOS
					select {+INDEX(bdisac:"informix".sac_cheques_app idxsac_cheques_appff)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(b.transacc_suc,''), NVL(hora_remesa,'')
					into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
					  from bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_cheques_app b
					 where fecha_pago >= FechaIni
					   and fecha_pago <= FechaFin
					   and numcategoria = '07'
					   and numconvenio = '009'
					   and status_cancelado <> 'S'
					   and a.folio_suc = b.folio_suc
					   and b.fech_alt = a.fecha_pago
					   and a.id_sucursal = b.sucursal
					   and a.usuario = b.usua
					   and a.importe_pago = b.monto_tot

					INSERT INTO bdisac:"informix".sac_servicios_app (referencia1,folio_suc,fecha_pago,usuario,id_sucursal,transacc_suc,hora_remesa)
					VALUES (cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion,cHora_remesa);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosMovtos
				FROM bdisac:"informix".sac_servicios_app;

				BEGIN WORK;
				FOREACH WITH HOLD
					--OBTIENE ULTIMAS CONSULTAS DE QRYI
					select {+INDEX(bdisac:"informix".sac_app_qryi idx_sac_app_qryi_ref_fecha)} NVL(unirefnum,''), max(processtime) secuencia
					into cUnirefnum, iSecuencia
					from bdisac:"informix".sac_app_qryi
					where unirefnum in (select {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)} referencia1 from bdisac:"informix".sac_servicios_app)
					  and txn_status = 'A'
					  and r_operacion = '00000'
					  and r_code = '0000'
					  and fecha::date >= FechaIni
					  and fecha::date <= FechaFin
					group by unirefnum

					INSERT INTO bdisac:"informix".sac_secuenciaqryi_app (unirefnum, secuencia)
					VALUES (cUnirefnum, iSecuencia);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				BEGIN WORK;
				FOREACH WITH HOLD
					--OBTIENE DATOS DE QRYI
					select {+INDEX(bdisac:"informix".sac_secuenciaqryi_app idxsac_secuenciaqryi_appus)} NVL(a.unirefnum,''),NVL(r_destinamount,0),
							CASE WHEN r_currencycode = 'USD' THEN r_originamount::money ELSE 0 END,
						   NVL(r_firstname,''),NVL(r_middlename,''),NVL(r_lastname,''),NVL(r_mommaidenname,''),NVL(r_firstname_b,''),NVL(r_middlename_b,''),NVL(r_lastname_b,''),NVL(r_mommaidenna_b,''),
						   NVL(r_address,''),NVL(r_address_b,''),NVL(r_address,''), NVL(r_number,''), NVL(r_city,''),
						   NVL(r_countrycode_o,''),NVL(r_currencycode,''),NVL(r_countrycode_d,''),NVL(r_currencycod_d,''),NVL(r_rexchangerate,''),
						   NVL(r_city,''),NVL(r_statecode,''),NVL(r_countrycode_a,''),NVL(r_zipcode,''),NVL(r_homephonenum,''),NVL(r_typecode_i,'')
						into cUnirefnum, mMonto_total, mMonto_dolares, cOrdenante_nombre1, cOrdenante_nombre2,
						cOrdenante_appaterno, cOrdenante_apmaterno, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
						cOrdenante_direccion, cBeneficiario_direccion, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante,
						cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
						cCp_remitente,cTel_remitente,cTipo_id_ordenante
					  from bdisac:"informix".sac_app_qryi a,bdisac:"informix".sac_secuenciaqryi_app b
					 where a.fecha::date >= FechaIni
					   and a.fecha::date <= FechaFin
					   and a.unirefnum  = b.unirefnum
					  and  a.processtime = secuencia

					INSERT INTO bdisac:"informix".sac_qryi_app (unirefnum,r_destinamount,origin_am,
						   r_firstname,r_middlename,r_lastname,r_mommaidenname,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,
						   r_address,r_address_b,colonia_ordenante,r_number,r_city,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,
						   tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,tipo_id_ordenante)
					VALUES (cUnirefnum, mMonto_total, mMonto_dolares, cOrdenante_nombre1, cOrdenante_nombre2,
						cOrdenante_appaterno, cOrdenante_apmaterno, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
						cOrdenante_direccion, cBeneficiario_direccion,cColonia_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,
						cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
						cCp_remitente,cTel_remitente,cTipo_id_ordenante);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosQryi
				FROM bdisac:"informix".sac_qryi_app;

				BEGIN WORK;
				FOREACH WITH HOLD
				--OBTIENE ULTIMOS REGISTROS DE PAYI PARA DATOS DE BENEFICIARIO
					select {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)} NVL(a.unirefnum,''), max(a.processtime) secuencia
					into cUnirefnum, iSecuencia
					from bdisac:"informix".sac_app_payi a, bdisac:"informix".sac_servicios_app
					where a.unirefnum = referencia1
					  and a.fecha::date >= FechaIni
					  and a.fecha::date <= FechaFin
					group by a.unirefnum

					INSERT INTO bdisac:"informix".sac_secuenciapayi_app (unirefnum, secuencia)
					VALUES (cUnirefnum, iSecuencia);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				BEGIN WORK;
				FOREACH WITH HOLD
					--SE OBTIENEN LOS DATOS DEL BENEFICIARIO
					select {+INDEX(bdisac:"informix".sac_secuenciapayi_app idxsac_secuenciapayi_appus)} NVL(a.unirefnum,''),NVL(firstname,''),NVL(middlename,''),NVL(lastname,''),NVL(mommaidenname,''),
						   NVL(dateofbirth,'01011900') beneficiario_fecha_nac,NVL(statecode,'') beneficiario_estado,NVL(city,'') beneficiario_mncpo_del,
						   NVL(city,'') beneficiario_ciudad,NVL(adress,'') beneficiario_direccion,NVL(zipcode,'') beneficiario_cp, NVL(numberci,'') num_id_benef_suc,
						   NVL(r_firstname,''), NVL(r_middlename,''), NVL(r_lastname,''), NVL(r_mommaidenname,''),
						   NVL(typecodeci,''),NVL(numberci,''),NVL(contrycode,''),NVL(zipcode,''),NVL(homephonenum,'')
						into cUnirefnum, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
						cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion,cBeneficiario_cp, cNum_id_benef_suc,
						cOrdenante_nombre1, cOrdenante_nombre2,cOrdenante_appaterno, cOrdenante_apmaterno,
						cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
					  from bdisac:"informix".sac_app_payi a,bdisac:"informix".sac_secuenciapayi_app b
					 where a.fecha::date >= FechaIni
					   and a.fecha::date <= FechaFin
					   and a.unirefnum  = b.unirefnum
					  and a.processtime = secuencia

					INSERT INTO bdisac:"informix".sac_payi_app (unirefnum,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,
					beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,beneficiario_ciudad,beneficiario_direccion,beneficiario_cp,num_id_benef_suc,
					ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef)
					VALUES (cUnirefnum, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_cp,cNum_id_benef_suc,
					cOrdenante_nombre1, cOrdenante_nombre2,cOrdenante_appaterno, cOrdenante_apmaterno,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef);

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				SELECT count(*)
				INTO iCuantosPayi
				FROM bdisac:"informix".sac_payi_app;

				BEGIN WORK;
				FOREACH WITH HOLD
				   select {+INDEX(bdisac:"informix".sac_qryi_app idxsac_qryi_appu)} NVL(fecha_pago,mdy(01,01,1900)) fecha_remesa,'APP' tipo_remesa,'NO' abono_cuenta,NVL(b.unirefnum,''),NVL(r_destinamount,0),NVL(a.origin_am,0),
						  NVL(transacc_suc,''),NVL(folio_suc,''), (today) fecha_alta, NVL(b.beneficiario_nombre1,''), NVL(b.beneficiario_nombre2,''),
						  NVL(b.beneficiario_appaterno,''),NVL(b.beneficiario_apmaterno,''), NVL(b.beneficiario_fecha_nac,'01011900'), NVL(b.beneficiario_estado,''), NVL(b.beneficiario_mncpo_del,''),
						  NVL(b.beneficiario_ciudad,''),NVL(b.beneficiario_direccion,''), NVL(b.beneficiario_cp,''),NVL(r_firstname,''), NVL(r_middlename,''), NVL(r_lastname,''),
						  NVL(r_mommaidenname,''), NVL(r_address,''),
						  NVL(id_sucursal,''),NVL(usuario,''), NVL(c.hora_remesa,''), NVL(a.colonia_ordenante,''), NVL(a.r_number,''), NVL(a.r_city ,''),
						  NVL(b.beneficiario_nombre1,'') || " " || NVL(b.beneficiario_nombre2,'') || " " || NVL(b.beneficiario_appaterno,'') || " " || NVL(b.beneficiario_apmaterno,''),
						  NVL(b.num_id_benef_suc,''),cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,
						  cod_pais_remitente,cp_remitente,tel_remitente,tipo_id_ordenante,tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef
					INTO dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUnirefnum, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
							cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cFechaFor, cBeneficiario_estado,
							cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno,
							cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante, cName_benef_suc,
							cNum_id_benef_suc,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
							cCp_remitente,cTel_remitente,cTipo_id_ordenante,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
					from bdisac:"informix".sac_qryi_app a, bdisac:"informix".sac_payi_app b, bdisac:"informix".sac_servicios_app c
				   where a.unirefnum = b.unirefnum
				   and b.unirefnum = c.referencia1

				   LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,5,2),SUBSTR(cFechaFor,7,2),SUBSTR(cFechaFor,1,4));
				   LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

					INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,
						cod_agente_org,tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
						fecha_envio_remesa)
						VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUnirefnum, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
							cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado,
							cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion,'','','','','', cBeneficiario_cp, cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno,
							cOrdenante_direccion,cSucursal,cUsuario,dFecha_Proceso,
							mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,'','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',dHora_proceso,cHora_remesa,cColonia_ordenante,cTipo_id_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,'',cName_benef_suc,
							cNum_id_benef_suc,'01011900');

					LET sCont = sCont + 1;
					IF sCont = 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;

				END FOREACH;

				IF sCont < 5000 and sCont >= 0 THEN
					COMMIT WORK;
					LET sCont = 0;
				END IF;

				--OBTENER REMESAS QUE NO ESTEN EN ALGUNA DE LAS TABLAS
				IF iCuantosCheq <> iCuantosMovtos THEN
					BEGIN WORK;
					FOREACH WITH HOLD

						select {+INDEX(bdisac:"informix".sac_cheques_app idxsac_cheques_appff)}
						NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''), NVL(sucursal,''), NVL(usua,''), NVL(monto_tot,0),NVL(hora_remesa,'')
						into cFolio_Sucursal, dFecha_Alt, cTransaccion, cSucursal, cUsuario, mMonto_total, cHora_remesa
						from bdisac:"informix".sac_cheques_app
						where folio_suc not in (select {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)} folio_suc from bdisac:"informix".sac_servicios_app)

						LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

						INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,
						cod_agente_org,tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
						num_id_benef_suc,fecha_envio_remesa)
						VALUES(dFecha_Alt, 'APP', 'NO', '', mMonto_total, 0, cTransaccion, cFolio_sucursal, (today),
							'', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '',	'', '', '', '', '', '', '', cSucursal, cUsuario, dFecha_Proceso,
							mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,'','','','','','','','01011900');

						LET sCont = sCont + 1;
						IF sCont = 5000 THEN
							COMMIT WORK;
							LET sCont = 0;
							BEGIN WORK;
						END IF;

					END FOREACH;

					IF sCont < 5000 and sCont >= 0 THEN
						COMMIT WORK;
						LET sCont = 0;
					END IF;

					ELSE IF (iCuantosQryi <> iCuantosMovtos) AND (iCuantosPayi <> iCuantosMovtos) THEN
						BEGIN WORK;
						FOREACH WITH HOLD
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
							select {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)}
							NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(transacc_suc,''),NVL(hora_remesa,'')
							into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
							from bdisac:"informix".sac_servicios_app
							where referencia1 not in (select {+INDEX(bdisac:"informix".sac_qryi_app )} unirefnum from bdisac:"informix".sac_qryi_app)
							and referencia1 not in (select {+INDEX(bdisac:"informix".sac_payi_app )} unirefnum from bdisac:"informix".sac_payi_app)

							select {+INDEX(bdisac:"informix".sac_cheques_app idxsac_cheques_appff)} NVL(monto_tot,0)
							into mMonto_total
							from bdisac:"informix".sac_cheques_app
							where folio_suc = cFolio_Sucursal
							and fech_alt = dFecha_Alt
							and transacc_suc = cTransaccion
							and sucursal = cSucursal
							and usua = cUsuario;
							

							LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

							INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
							beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
							beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
							beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
							fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
							numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,
							cod_agente_org,tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
							cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
							hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
							num_id_benef_suc,fecha_envio_remesa)
							VALUES(dFecha_Alt, 'APP', 'NO', cReferencia1, NVL(mMonto_total,0), '', cTransaccion, cFolio_sucursal, (today),
								'', '', '', '', mdy(01,01,1900), '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cSucursal,cUsuario,dFecha_Proceso,
								mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',dHora_proceso,cHora_remesa,cColonia_ordenante,'','','','',''
								,'','01011900');

							LET sCont = sCont + 1;
							IF sCont = 5000 THEN
								COMMIT WORK;
								LET sCont = 0;
								BEGIN WORK;
							END IF;

						END FOREACH;

						IF sCont < 5000 and sCont >= 0 THEN
							COMMIT WORK;
							LET sCont = 0;
						END IF;

						ELSE IF iCuantosPayi <> iCuantosMovtos THEN
							BEGIN WORK;
							FOREACH WITH HOLD

								select {+INDEX(bdisac:"informix".sac_qryi_app idxsac_qryi_appu)} NVL(fecha_pago,mdy(01,01,1900)),'APP' tipo_remesa,'NO' abono_cuenta,NVL(unirefnum,''),NVL(r_destinamount,0),NVL(origin_am,0),
									NVL(transacc_suc,''),NVL(folio_suc,''),(today) fech_alt,NVL(r_firstname_b,''),NVL(r_middlename_b,''),NVL(r_lastname_b,''),NVL(r_mommaidenna_b,''),
									NVL(r_address_b,''),NVL(r_firstname,''),NVL(r_middlename,''),NVL(r_lastname,''),NVL(r_mommaidenname,''),NVL(r_address,''),
									NVL(id_sucursal,''),NVL(usuario,''),NVL(hora_remesa,''), NVL(colonia_ordenante,''),NVL(r_number,''),NVL(r_city,''),
									NVL(r_firstname_b,'') || " " || NVL(r_middlename_b,'') || " " || NVL(r_lastname_b,'') || " " || NVL(r_mommaidenna_b,''),
									cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,
									cod_pais_remitente,cp_remitente,tel_remitente,tipo_id_ordenante
								into dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUnirefnum, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
									cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, cBeneficiario_direccion, cOrdenante_nombre1, cOrdenante_nombre2,
									cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal, cUsuario, cHora_remesa, cColonia_ordenante, cNumero_id_ordenante, cCiudad_id_ordenante,
									cName_benef_suc,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
									cCp_remitente,cTel_remitente,cTipo_id_ordenante
								from bdisac:"informix".sac_qryi_app a, bdisac:"informix".sac_servicios_app b
								where unirefnum not in (select {+INDEX(bdisac:"informix".sac_payi_app )} unirefnum from bdisac:"informix".sac_payi_app)
								and a.unirefnum = b.referencia1

								LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

								INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
								beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
								beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
								beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
								fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
								numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,
								cod_agente_org,tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
								cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
								hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
								num_id_benef_suc,fecha_envio_remesa)
								VALUES(dFecha_remesa, cTipo_remesa, cAbono_cuenta, cUnirefnum, mMonto_total, mMonto_dolares, cTransaccion, cFolio_sucursal, dFecha_alta,
									cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, mdy(01,01,1900), '',
									'', '', cBeneficiario_direccion, '', '', '', '',
									'', '', cOrdenante_nombre1, cOrdenante_nombre2, cOrdenante_appaterno, cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,
									cUsuario,dFecha_Proceso,
									mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,'','','','','','','','','','','','','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',dHora_proceso,cHora_remesa,cColonia_ordenante,cTipo_id_ordenante,cNumero_id_ordenante,cCiudad_id_ordenante,'',cName_benef_suc,
									'','01011900');

									LET sCont = sCont + 1;
									IF sCont = 5000 THEN
										COMMIT WORK;
										LET sCont = 0;
										BEGIN WORK;
									END IF;

							END FOREACH;

								IF sCont < 5000 and sCont >= 0 THEN
									COMMIT WORK;
									LET sCont = 0;
								END IF;

							ELSE IF iCuantosQryi <> iCuantosMovtos THEN
								BEGIN WORK;
								FOREACH WITH HOLD

									select {+INDEX(bdisac:"informix".sac_payi_app idxsac_payi_appu)} NVL(unirefnum,''),NVL(beneficiario_nombre1,''),NVL(beneficiario_nombre2,''),NVL(beneficiario_appaterno,''),NVL(beneficiario_apmaterno,''),
										NVL(beneficiario_fecha_nac,'01011900'),NVL(beneficiario_estado,''),NVL(beneficiario_mncpo_del,''),
										NVL(beneficiario_ciudad,''),NVL(beneficiario_direccion,''),NVL(beneficiario_cp,''),NVL(num_id_benef_suc,''),
										NVL(ordenante_nombre1,''),NVL(ordenante_nombre2,''),NVL(ordenante_appaterno,''),NVL(ordenante_apmaterno,''),
										tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef
									into cUnirefnum, cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno,
										cFechaFor, cBeneficiario_estado, cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion,
										cBeneficiario_cp,cNum_id_benef_suc,cOrdenante_nombre1, cOrdenante_nombre2,cOrdenante_appaterno, cOrdenante_apmaterno,
										cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
									from bdisac:"informix".sac_payi_app
									where unirefnum not in (select {+INDEX(bdisac:"informix".sac_qryi_app )} unirefnum from bdisac:"informix".sac_qryi_app)

									select {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)}
									NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(transacc_suc,''), NVL(hora_remesa,'')
									into cReferencia1, cFolio_Sucursal, dFecha_Alt, cUsuario, cSucursal, cTransaccion, cHora_remesa
									from bdisac:"informix".sac_servicios_app
									where referencia1 = cUnirefnum;

									select {+INDEX(bdisac:"informix".sac_cheques_app idxsac_cheques_appff)} NVL(monto_tot,0)
									into mMonto_total
									from bdisac:"informix".sac_cheques_app
									where folio_suc = cFolio_Sucursal
									and fech_alt = dFecha_Alt
									and transacc_suc = cTransaccion
									and sucursal = cSucursal
									and usua = cUsuario;

									LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,5,2),SUBSTR(cFechaFor,7,2),SUBSTR(cFechaFor,1,4));
									LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);

									INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
									beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
									beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
									beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
									fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
									numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,
									cod_agente_org,tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
									cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
									hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,numero_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
									num_id_benef_suc,fecha_envio_remesa)
									VALUES(NVL(dFecha_Alt,mdy(01,01,1900)), 'APP', 'NO', cUnirefnum, NVL(mMonto_total,0), 0, NVL(cTransaccion,''), NVL(cFolio_sucursal,''), (today),
										cBeneficiario_nombre1, cBeneficiario_nombre2, cBeneficiario_appaterno, cBeneficiario_apmaterno, dBeneficiario_fecha_nac, cBeneficiario_estado,
										cBeneficiario_mncpo_del, cBeneficiario_ciudad, cBeneficiario_direccion, '', '', '', '','', cBeneficiario_cp, cOrdenante_nombre1,
										cOrdenante_nombre2,cOrdenante_appaterno, cOrdenante_apmaterno, '', NVL(cSucursal,''),NVL(cUsuario,''),dFecha_Proceso,
										mdy(01,01,1900),'','','','','','','','','0','','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,'','','','','','','','','','','','',dHora_proceso,NVL(cHora_remesa,'00:00:00'),'','','','','','',
										cNum_id_benef_suc,'01011900');

										LET sCont = sCont + 1;
										IF sCont = 5000 THEN
											COMMIT WORK;
											LET sCont = 0;
											BEGIN WORK;
										END IF;

								END FOREACH;

								IF sCont < 5000 and sCont >= 0 THEN
									COMMIT WORK;
									LET sCont = 0;
								END IF;

							END IF;
						END IF;
					END IF;
				END IF;

			END IF;

		END IF;

		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_APP', FechaFin, '1', 'informix', 'sp_remesasapp_pld', cDescripcionSPJ);

		EXECUTE PROCEDURE bdisac:"informix".sp_inicializatablaspld('UPTD','',FechaFin) INTO cCodRetSP;

		IF cCodRetSP <> '00000' THEN
			LET cCodRet = '00001';
			LET cMensaje = "ERROR EN ACTUALIZACION DE ESTADISTICAS";
			RETURN cCodRet, cMensaje;
		ELSE
			RETURN cCodRet, cMensaje;
		END IF;

	END;
END PROCEDURE;