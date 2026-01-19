import { HandshakeMarker } from '../handshake/types';

/**
 * ATOM Trail integration interface
 */
export interface ATOMEntry {
  actor: string;
  decision: string;
  rationale: string;
  outcome: string;
  coherenceScore?: number;
  timestamp?: string;
}

/**
 * ATOM Trail logger for handoff events
 */
export class ATOMIntegration {
  private atomDir: string;

  constructor(atomDir: string = '.wave/atom-trail') {
    this.atomDir = atomDir;
  }

  /**
   * Log a handoff to the ATOM trail
   */
  async logHandoff(marker: HandshakeMarker): Promise<void> {
    const entry: ATOMEntry = {
      actor: marker.fromAgent,
      decision: `H&&S: ${marker.state} to ${marker.toAgent}`,
      rationale: `Coherence: ${marker.coherenceScore ?? 'N/A'}%, Context: ${JSON.stringify(marker.context)}`,
      outcome: 'success',
      coherenceScore: marker.coherenceScore,
      timestamp: marker.timestamp
    };

    // For now, we'll create a simple log file
    // In a real implementation, this would integrate with an existing ATOM trail system
    const fs = require('fs');
    const path = require('path');
    
    await fs.promises.mkdir(this.atomDir, { recursive: true });
    
    const atomFile = path.join(this.atomDir, `${marker.sessionId}.atom.jsonl`);
    const line = JSON.stringify(entry) + '\n';
    await fs.promises.appendFile(atomFile, line, 'utf-8');
  }

  /**
   * Get ATOM entries for a session
   */
  async getEntries(sessionId: string): Promise<ATOMEntry[]> {
    const fs = require('fs');
    const path = require('path');
    
    const atomFile = path.join(this.atomDir, `${sessionId}.atom.jsonl`);
    
    try {
      const content = await fs.promises.readFile(atomFile, 'utf-8');
      const lines = content.trim().split('\n').filter((line: string) => line.length > 0);
      return lines.map((line: string) => JSON.parse(line) as ATOMEntry);
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return [];
      }
      throw error;
    }
  }
}
