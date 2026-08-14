package com.openpay.dashboard.channels;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : channels
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 1    LOC approx: 152
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ChnRequest;
import com.openpay.dto.ChnResponse;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class ChnController055 {

    // Collaborators (match the graph call edges):
    private final ChnService094 chnService094;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
