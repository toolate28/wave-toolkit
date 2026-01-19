/**
 * H&&S (Handshake & Sign) Protocol
 * States for coordinating multi-agent workflows with verifiable state transitions
 */

export type HandoffState = 
  | 'WAVE'  // Coherence check passed, ready for next agent
  | 'PASS'  // Explicit handoff to named agent
  | 'BLOCK' // Gate failure, cannot proceed
  | 'HOLD'  // Waiting for external input/approval
  | 'PUSH'; // Force iteration cycle (doubt detected)

/**
 * Handshake marker for agent-to-agent transitions
 */
export interface HandshakeMarker {
  id: string;              // Unique identifier for this handoff
  timestamp: string;       // ISO 8601 timestamp
  fromAgent: string;       // 'claude-copilot', 'grok', 'user', etc.
  toAgent: string;         // Next agent or 'system'
  state: HandoffState;     // Current handoff state
  context: Record<string, any>;  // Transferred state
  atomTrailId: string;     // ATOM entry linking this handoff
  coherenceScore?: number; // WAVE score at handoff time (0-100)
  signature?: string;      // Cryptographic proof (optional)
  sessionId: string;       // Session identifier
}

/**
 * Validation result for handoff markers
 */
export interface ValidationResult {
  valid: boolean;
  errors?: string[];
  warnings?: string[];
}
