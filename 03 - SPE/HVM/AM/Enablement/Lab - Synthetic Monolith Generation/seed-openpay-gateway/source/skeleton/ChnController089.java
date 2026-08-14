package com.openpay.dashboard.channels;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : channels
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 183
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ChnEntity;
import com.openpay.dto.ChnRequest;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class ChnController089 {

    // Collaborators (match the graph call edges):
    private final BinManagerService binManagerService;
    private final ChnService272 chnService272;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
