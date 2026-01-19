import { v4 as uuidv4 } from 'uuid';
import { HandshakeMarker, HandoffState, ValidationResult } from './types';
import { HandoffStorage } from '../storage/HandoffStorage';
import { ATOMIntegration } from '../integrations/ATOMIntegration';

/**
 * Main HandshakeProtocol class for managing multi-agent handoffs
 */
export class HandshakeProtocol {
  private storage: HandoffStorage;
  private atomIntegration: ATOMIntegration;

  constructor(
    storageDir: string = '.wave/handoffs',
    atomDir: string = '.wave/atom-trail'
  ) {
    this.storage = new HandoffStorage(storageDir);
    this.atomIntegration = new ATOMIntegration(atomDir);
  }

  /**
   * Create a new handoff marker
   */
  async createHandoff(
    fromAgent: string,
    toAgent: string,
    state: HandoffState,
    context: Record<string, any>,
    sessionId: string,
    coherenceScore?: number
  ): Promise<HandshakeMarker> {
    // Generate UUID using a more Jest-friendly approach
    const uuid = require('crypto').randomUUID();
    
    const marker: HandshakeMarker = {
      id: uuid,
      timestamp: new Date().toISOString(),
      fromAgent,
      toAgent,
      state,
      context,
      atomTrailId: `ATOM-${require('crypto').randomUUID()}`,
      coherenceScore,
      sessionId
    };

    // Save the marker
    await this.storage.saveMarker(marker);

    // Log to ATOM trail
    await this.atomIntegration.logHandoff(marker);

    return marker;
  }

  /**
   * Validate a handoff marker
   */
  async validateHandoff(marker: HandshakeMarker): Promise<ValidationResult> {
    const errors: string[] = [];
    const warnings: string[] = [];

    // Basic validation
    if (!marker.id) {
      errors.push('Marker ID is required');
    }

    if (!marker.fromAgent || marker.fromAgent.trim() === '') {
      errors.push('fromAgent is required');
    }

    if (!marker.toAgent || marker.toAgent.trim() === '') {
      errors.push('toAgent is required');
    }

    if (!marker.state) {
      errors.push('state is required');
    } else {
      const validStates: HandoffState[] = ['WAVE', 'PASS', 'BLOCK', 'HOLD', 'PUSH'];
      if (!validStates.includes(marker.state)) {
        errors.push(`Invalid state: ${marker.state}`);
      }
    }

    if (!marker.timestamp) {
      errors.push('timestamp is required');
    } else {
      // Validate ISO 8601 format
      const date = new Date(marker.timestamp);
      if (isNaN(date.getTime())) {
        errors.push('Invalid timestamp format');
      }
    }

    if (!marker.atomTrailId) {
      errors.push('atomTrailId is required');
    }

    if (!marker.sessionId) {
      errors.push('sessionId is required');
    }

    // Warnings
    if (marker.coherenceScore !== undefined) {
      if (marker.coherenceScore < 0 || marker.coherenceScore > 100) {
        warnings.push('coherenceScore should be between 0 and 100');
      }
    }

    if (marker.state === 'WAVE' && marker.coherenceScore === undefined) {
      warnings.push('WAVE state typically includes a coherenceScore');
    }

    // Verify marker exists in storage
    const storedMarker = await this.storage.findMarkerById(marker.id);
    if (!storedMarker) {
      warnings.push('Marker not found in storage');
    }

    return {
      valid: errors.length === 0,
      errors: errors.length > 0 ? errors : undefined,
      warnings: warnings.length > 0 ? warnings : undefined
    };
  }

  /**
   * Get the handoff chain for a session
   */
  async getHandoffChain(sessionId: string): Promise<HandshakeMarker[]> {
    return await this.storage.loadMarkers(sessionId);
  }

  /**
   * Generate a Mermaid diagram for workflow visualization
   */
  async visualizeWorkflow(sessionId: string): Promise<string> {
    const markers = await this.getHandoffChain(sessionId);

    if (markers.length === 0) {
      return 'graph LR\n  Empty["No handoffs found"]';
    }

    let mermaid = 'graph LR\n';
    
    // Track unique agents
    const agents = new Set<string>();
    markers.forEach(m => {
      agents.add(m.fromAgent);
      agents.add(m.toAgent);
    });

    // Generate connections
    markers.forEach((marker, index) => {
      const from = this.sanitizeNodeName(marker.fromAgent);
      const to = this.sanitizeNodeName(marker.toAgent);
      const label = this.getStateLabel(marker.state, marker.coherenceScore);
      
      mermaid += `  ${from} -->|${label}| ${to}\n`;
    });

    // Add styling based on state
    markers.forEach((marker) => {
      const to = this.sanitizeNodeName(marker.toAgent);
      const style = this.getNodeStyle(marker.state);
      if (style) {
        mermaid += `  style ${to} ${style}\n`;
      }
    });

    return mermaid;
  }

  /**
   * Query handoffs by criteria
   */
  async queryHandoffs(criteria: {
    sessionId?: string;
    fromAgent?: string;
    toAgent?: string;
    state?: HandoffState;
    startTime?: Date;
    endTime?: Date;
  }): Promise<HandshakeMarker[]> {
    return await this.storage.queryMarkers(criteria);
  }

  /**
   * Get all session IDs
   */
  async getAllSessions(): Promise<string[]> {
    return await this.storage.getAllSessions();
  }

  // Helper methods

  private sanitizeNodeName(name: string): string {
    return name.replace(/[^a-zA-Z0-9]/g, '_');
  }

  private getStateLabel(state: HandoffState, coherenceScore?: number): string {
    if (state === 'WAVE' && coherenceScore !== undefined) {
      return `${state}(${coherenceScore}%)`;
    }
    return state;
  }

  private getNodeStyle(state: HandoffState): string | null {
    switch (state) {
      case 'WAVE':
        return 'fill:#90EE90,stroke:#006400,stroke-width:2px';
      case 'PASS':
        return 'fill:#87CEEB,stroke:#0000CD,stroke-width:2px';
      case 'BLOCK':
        return 'fill:#FFB6C1,stroke:#DC143C,stroke-width:2px';
      case 'HOLD':
        return 'fill:#FFD700,stroke:#FF8C00,stroke-width:2px';
      case 'PUSH':
        return 'fill:#DDA0DD,stroke:#8B008B,stroke-width:2px';
      default:
        return null;
    }
  }
}
