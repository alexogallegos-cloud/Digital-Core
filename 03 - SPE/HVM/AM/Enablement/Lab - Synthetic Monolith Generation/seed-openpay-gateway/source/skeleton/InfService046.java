package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 5    FAN-OUT : 7    LOC approx: 303
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfRequest;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService046 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final InfRepository004 infRepository004;
    private final InfService028 infService028;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final MoneyUtils moneyUtils;
    private final ValidationUtils validationUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
