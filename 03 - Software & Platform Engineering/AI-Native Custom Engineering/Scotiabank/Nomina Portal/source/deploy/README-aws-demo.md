# Demo en AWS — EC2 única con auto-apagado a 1 hora

Guía de infraestructura del **ambiente demo** del Portal Empresas Nómina. Objetivo: una sola EC2 (`t3.small`, x86 — SQL Server exige x86) que corre API Java + SQL Server Express + Nginx, y que **se detiene sola 60 min después de cada arranque** para que el costo tienda a cero.

> Esto es infraestructura de demo. No es producción (sin HA, sin Multi-AZ, sin residencia de datos CNBV). El costo de delivery/AMS de personas va por el **Pricing & Commercial Modeler**, no aquí.

## Costo esperado

| Modo | Costo aprox. |
|------|-------------|
| `t3.small` encendida 24/7 | ~$15 USD/mes |
| Encendida solo en demos (~10 h/sem) con auto-stop | ~$4-6 USD/mes |
| Detenida (solo disco EBS) | ~$1-2 USD/mes |

## Garantía de "solo 1 hora" — dos capas independientes

1. **Auto-stop interno (primario)** — `user-data.sh` instala un servicio systemd que, en **cada boot**, programa `shutdown -h +60`. Como la instancia inicia con `--instance-initiated-shutdown-behavior stop`, ese apagado **detiene** la instancia (deja de facturar), no la termina.
2. **Temporizador externo (red de seguridad)** — EventBridge detecta que la instancia entró en `running` y lanza una Step Functions que espera 3600 s y la detiene. Cubre el caso de que el SO se cuelgue y el apagado interno no dispare.

Para un demo, la capa 1 basta. La capa 2 es el blindaje si quieres tope duro pase lo que pase.

---

## 1. Lanzar la EC2 con auto-stop interno

```bash
aws ec2 run-instances \
  --image-id ami-XXXXXXXX \                         # Amazon Linux 2023 x86_64
  --instance-type t3.small \
  --key-name mi-llave \
  --security-group-ids sg-XXXXXXXX \                # abre 80/443 (y 22 si necesitas SSH)
  --instance-initiated-shutdown-behavior stop \     # CLAVE: shutdown = STOP, no terminate
  --user-data file://user-data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=nomina-demo}]'
```

Verificación (dentro de la instancia):
```bash
systemctl is-enabled auto-stop-demo.service   # -> enabled
shutdown --show                               # muestra el apagado programado
```

Si alguna vez cambias el shutdown behavior de una instancia existente:
```bash
aws ec2 modify-instance-attribute --instance-id i-XXXX \
  --instance-initiated-shutdown-behavior stop
```

## 2. (Opcional) Red de seguridad — EventBridge + Step Functions

Rol IAM para la state machine (permite detener EC2):
```bash
# Trust policy: states.amazonaws.com ; permiso: ec2:StopInstances sobre la instancia.
aws iam create-role --role-name nomina-demo-autostop-sfn \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"states.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam put-role-policy --role-name nomina-demo-autostop-sfn \
  --policy-name stop-ec2 \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"ec2:StopInstances","Resource":"*"}]}'
```

Crear la state machine:
```bash
aws stepfunctions create-state-machine \
  --name nomina-demo-autostop \
  --definition file://autostop-statemachine.asl.json \
  --role-arn arn:aws:iam::ACCOUNT_ID:role/nomina-demo-autostop-sfn
```

Regla EventBridge (edita `eventbridge-autostop-rule.json` con el `i-...` real) + target:
```bash
aws events put-rule --name nomina-demo-running \
  --event-pattern file://eventbridge-autostop-rule.json

# Rol para que EventBridge inicie la ejecucion de la state machine:
aws events put-targets --rule nomina-demo-running \
  --targets 'Id=1,Arn=arn:aws:states:REGION:ACCOUNT_ID:stateMachine:nomina-demo-autostop,RoleArn=arn:aws:iam::ACCOUNT_ID:role/nomina-demo-eventbridge-invoke'
```

La Step Functions recibe el evento completo y extrae `detail.instance-id`, así que sirve para cualquier instancia que la regla capture.

## 3. Backstop de gasto — AWS Budget

```bash
aws budgets create-budget --account-id ACCOUNT_ID \
  --budget '{"BudgetName":"nomina-demo","BudgetLimit":{"Amount":"20","Unit":"USD"},"TimeUnit":"MONTHLY","BudgetType":"COST"}'
```
Agrega una notificación por email al 80 %. No apaga nada; es la alerta final.

---

## Advertencias

- **x86 obligatorio**: SQL Server en Linux no corre en ARM/Graviton (`t4g`). Esa palanca de ahorro solo se abre migrando a PostgreSQL.
- **Una sola caja a propósito**: un `shutdown` no apaga un RDS separado. Con SQL Server Express en la misma EC2, un solo apagado cierra todo el costo. Si algún día separas la BD a RDS, necesitas una Lambda paralela que haga `StopDBInstance`.
- **`shutdown +60` cuenta desde el boot**: si alguien reinicia el SO dentro de la hora, el contador se reinicia. El tope absoluto de wall-clock lo garantiza la capa 2 (mide desde el evento `running`).
- Precios de lista, región us-east-1. Región México Central puede tener premium.

## Teardown

```bash
aws ec2 terminate-instances --instance-ids i-XXXX
aws events remove-targets --rule nomina-demo-running --ids 1
aws events delete-rule --name nomina-demo-running
aws stepfunctions delete-state-machine --state-machine-arn arn:...:nomina-demo-autostop
```