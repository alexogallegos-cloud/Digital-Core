package com.openpay.dashboard.security;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : security
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 74    FAN-OUT : 3    LOC approx: 550
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.SecEntity;
import com.openpay.dto.SecResponse;

@Service
public class RbacService {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final SecRepository061 secRepository061;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
