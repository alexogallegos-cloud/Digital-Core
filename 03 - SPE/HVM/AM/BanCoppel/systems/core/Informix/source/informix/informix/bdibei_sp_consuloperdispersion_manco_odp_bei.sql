CREATE PROCEDURE "informix".sp_consuloperdispersion_manco_odp_bei(pRegIni INTEGER, pIdOperacion INTEGER)
RETURNING CHAR(5), CHAR(10),CHAR(10), CHAR(20),MONEY,MONEY,MONEY,MONEY,MONEY,
INTEGER,CHAR(30),CHAR(20),CHAR(30),CHAR(30),CHAR(30),CHAR(30),CHAR(25),CHAR(50),MONEY;


    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vf_aplicacion       CHAR(10);
    DEFINE vf_operacion        CHAR(10);
    DEFINE vcuenta_origen      CHAR(20);
    DEFINE vImporte            MONEY;
    DEFINE vComision           MONEY;
    DEFINE vIva                MONEY;
    DEFINE vIvaComision        MONEY;
    DEFINE vmontoTotal         MONEY;
    DEFINE vid_usuario         INTEGER;
    DEFINE vConcepto           CHAR(30);
    DEFINE vAlias              CHAR(20);
    DEFINE vPrimerNombre       CHAR(30);
    DEFINE vSegundoNombre      CHAR(30);
    DEFINE vApellidoPaterno    CHAR(30);
    DEFINE vApellidoMaterno    CHAR(30);
    DEFINE vTelefono           CHAR(25);
    DEFINE vDireccion          CHAR(50);
    DEFINE vImporteBene        MONEY;
    

    LET cCod_ret = '00000';
    LET vf_aplicacion ='';
    LET vf_operacion='';
    LET vcuenta_origen='';
    LET vImporte= 0;
    LET vComision= 0;
    LET vIva= 0;
    LET vIvaComision= 0;
    LET vmontoTotal= 0;
    LET vid_usuario= 0;
    LET vConcepto= '';
    LET vAlias= '';
    LET vPrimerNombre= '';
    LET vSegundoNombre= '';
    LET vApellidoPaterno= '';
    LET vApellidoMaterno= '';
    LET vTelefono='';
    LET vDireccion='';
    LET vImporteBene=0;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret,vf_aplicacion, vf_operacion,vcuenta_origen, vImporte, vComision, vIva, vIvaComision, vmontoTotal, vid_usuario,vConcepto,
            vAlias,vPrimerNombre,vSegundoNombre,vApellidoPaterno,vApellidoMaterno,vTelefono,vDireccion,vImporteBene;
      END IF ;
    END EXCEPTION ;

SET LOCK MODE TO WAIT 4;

   FOREACH
    Select SKIP pRegIni FIRST 10 to_char(op.f_operacion,'%d/%m/%iY'), to_char(op.f_aplicacion,'%d/%m/%iY'), op.cuenta_origen, op.importe totalSinIva, op.comision, op.valor_iva,op.ivacomision,op.montototal, op.id_usuario,
    bn.concepto, bn.alias, bn.primer_nombre, bn.segundo_nombre, bn.apellido_paterno, bn.apellido_materno,bn.telefono,bn.direccion,bn.importe
    INTO vf_aplicacion, vf_operacion,vcuenta_origen, vImporte, vComision, vIva, vIvaComision, vmontoTotal, vid_usuario,vConcepto,
            vAlias,vPrimerNombre,vSegundoNombre,vApellidoPaterno,vApellidoMaterno,vTelefono, vDireccion, vImporteBene
    From   bei_operacionesmancomunadasoperador op
    Inner Join bei_beneficiariosmanco_odp bn On (op.id_operacion = bn.id_mancomunidad)
    Where  op.id_operacion = pIdOperacion

    RETURN cCod_ret,vf_aplicacion, vf_operacion,vcuenta_origen, vImporte, vComision, vIva, vIvaComision, vmontoTotal, vid_usuario,vConcepto,
            vAlias,vPrimerNombre,vSegundoNombre,vApellidoPaterno,vApellidoMaterno,vTelefono,vDireccion,vImporteBene 
WITH RESUME;
   END FOREACH;

END

END PROCEDURE;