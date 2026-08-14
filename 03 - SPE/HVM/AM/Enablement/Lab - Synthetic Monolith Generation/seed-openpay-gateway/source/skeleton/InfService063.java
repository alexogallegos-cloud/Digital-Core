package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 4    FAN-OUT : 7    LOC approx: 454
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.InfRequest;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService063 {

    // Collaborators (match the graph call edges):
    private final InfRepository034 infRepository034;
    private final InfRepository075 infRepository075;
    private final InfService006 infService006;
    private final InfService028 infService028;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final RbacService rbacService;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
