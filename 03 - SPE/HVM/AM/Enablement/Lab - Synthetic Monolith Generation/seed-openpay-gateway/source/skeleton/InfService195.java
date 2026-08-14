package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 6    FAN-OUT : 6    LOC approx: 544
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfRequest;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Service
public class InfService195 {

    // Collaborators (match the graph call edges):
    private final InfRepository051 infRepository051;
    private final InfService006 infService006;
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final RskService258 rskService258;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
