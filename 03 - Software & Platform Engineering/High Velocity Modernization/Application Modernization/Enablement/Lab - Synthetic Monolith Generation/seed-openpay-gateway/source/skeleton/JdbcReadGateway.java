package com.openpay.shared.shared;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : shared (WAR)      DOMAIN : shared
//  LAYER     : UTIL                 ACCESS : inquiry (read-only)
//  FAN-IN    : 160    FAN-OUT : 0    LOC approx: 224
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;

(static helper)
public class JdbcReadGateway {

    // Collaborators (match the graph call edges):
    // (no collaborators)

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
