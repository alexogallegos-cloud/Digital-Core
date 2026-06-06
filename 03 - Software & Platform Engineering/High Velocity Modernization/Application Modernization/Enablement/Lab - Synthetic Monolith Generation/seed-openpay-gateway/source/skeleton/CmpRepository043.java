package com.openpay.manager.compliance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : compliance
//  LAYER     : REPO                 ACCESS : inquiry (read-only)
//  FAN-IN    : 6    FAN-OUT : 1    LOC approx: 55
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.CmpEntity;
import com.openpay.dto.CmpResponse;
import com.openpay.dto.ResponseEnvelope;

@Repository
public class CmpRepository043 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
