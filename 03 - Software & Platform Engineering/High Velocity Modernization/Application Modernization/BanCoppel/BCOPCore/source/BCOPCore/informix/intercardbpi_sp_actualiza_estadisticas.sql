CREATE PROCEDURE "informix".sp_actualiza_estadisticas() 
RETURNING VARCHAR(5) as Cod_ret,VARCHAR(80) as Men_ret;
/*Se definen las variables a ser utilizadas para el paso de la información.*/
   DEFINE spconsumo integer;
   DEFINE spsucursal varchar(5);
   DEFINE  p_cod_ret varchar(5);
   DEFINE  p_mensaje varchar(80);
   DEFINE  sql_err integer;
   DEFINE  isam_err integer;
   DEFINE  error_info varchar(80);
 
 /* Las siguientes opciones pueden ser habilitadas para recabar información del store procedure durante su ejecución, es necesario 
 especificar la ruta donde será colocado el log del proceso. */
    --SET DEBUG FILE TO "/informix/HomeInformix/rrm/sp_actualiza_estadistica.out";
    --TRACE ON;
    
 BEGIN
 
 /* El manejo de excepciones que se presenta está diseñado para deshacer los cambios ocasionados y poder verificar cualquier mensaje
 de error proporcionado por la base de datos durante la ejecución de este proceso */
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET  = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;	
    RETURN P_COD_RET,P_MENSAJE;		
   END EXCEPTION;
    
/*Se inicializan las variables  a ser usadas.*/
        let spconsumo = 0;
	let spsucursal = '';
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';
	let sql_err = 0;
        let isam_err = 0;
        let error_info = 'Error durante el proceso de Actualizar Estadisticas.';
  

/*El siguiente FOREACH se encarga de disminuir las existencias del tipo 16 en base a las 
//estadísticas del presente día del tipo 2. Así como añadir el consumo de tipo 2 al tipo
//16 en la tabla de estadisticatarjetasuc ya sea agregando un nuevo registro o sumando el
//consumo al registro actual.*/
   FOREACH SELECT {+INDEX("informix".estadisticatarjetasuc "informix".idx_estadisticatarjetasuc)}
     consumo, clave_sucursal INTO spconsumo, spsucursal FROM "informix".estadisticatarjetasuc WHERE clave_tipotarjeta = 2 AND fecha = TODAY
        
        /*Este UPDATE se encarga de disminuír las existencias del tipo 12 en base al consumo del tipo 5 */
      UPDATE "informix".sucursal_tipotarjeta SET existencia = existencia - spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16;   
      
      /*Este If determina si no existe consumo de tipo 16 ese día para agregar su registro de consumo, en caso de ya existir consumo 
      //procede a aumentarlo con el consumo del tipo 2.*/
      IF (SELECT Count(*) FROM "informix".estadisticatarjetasuc WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16 AND fecha = TODAY) = 0 Then
        INSERT INTO "informix".estadisticatarjetasuc(clave_sucursal, clave_tipotarjeta, fecha, consumo) VALUES (spsucursal, 16, TODAY,spconsumo);
      ELSE
        UPDATE "informix".estadisticatarjetasuc SET consumo = consumo + spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 16 AND fecha = TODAY;
      END IF; 
              
   END FOREACH;
   
 /*El siguiente FOREACH se encarga de disminuir las existencias del tipo 17 en base a las 
//estadísticas del presente día del tipo 12. Así como añadir el consumo de tipo 12 al tipo
//17 en la tabla de estadisticatarjetasuc ya sea agregando un nuevo registro o sumando el
//consumo al registro actual.*/
   FOREACH SELECT {+INDEX("informix".estadisticatarjetasuc "informix".idx_estadisticatarjetasuc)}
     consumo, clave_sucursal INTO spconsumo, spsucursal FROM "informix".estadisticatarjetasuc WHERE clave_tipotarjeta = 12 AND fecha = TODAY
        
        /*Este UPDATE se encarga de disminuír las existencias del tipo 17 en base al consumo del tipo 12 */
      UPDATE "informix".sucursal_tipotarjeta SET existencia = existencia - spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17;   
      
      /*Este If determina si no existe consumo de tipo 17 ese día para agregar su registro de consumo, en caso de ya existir consumo 
      //procede a aumentarlo con el consumo del tipo 12.*/
      IF (SELECT Count(*) FROM "informix".estadisticatarjetasuc WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17 AND fecha = TODAY) = 0 Then
        INSERT INTO "informix".estadisticatarjetasuc(clave_sucursal, clave_tipotarjeta, fecha, consumo) VALUES (spsucursal, 17, TODAY,spconsumo);
      ELSE
        UPDATE "informix".estadisticatarjetasuc SET consumo = consumo + spconsumo WHERE clave_sucursal = spsucursal AND clave_tipotarjeta = 17 AND fecha = TODAY;
      END IF; 
              
   END FOREACH;
 return	P_COD_RET,P_MENSAJE;
 END;     

END PROCEDURE;