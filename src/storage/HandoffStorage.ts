import * as fs from 'fs';
import * as path from 'path';
import { HandshakeMarker } from '../handshake/types';

/**
 * Storage manager for handoff markers
 * Stores markers as JSONL (newline-delimited JSON) files
 */
export class HandoffStorage {
  private baseDir: string;

  constructor(baseDir: string = '.wave/handoffs') {
    this.baseDir = baseDir;
  }

  /**
   * Initialize storage directory
   */
  async initialize(): Promise<void> {
    await fs.promises.mkdir(this.baseDir, { recursive: true });
  }

  /**
   * Get the file path for a session
   */
  private getSessionFile(sessionId: string): string {
    return path.join(this.baseDir, `${sessionId}.jsonl`);
  }

  /**
   * Save a handoff marker
   */
  async saveMarker(marker: HandshakeMarker): Promise<void> {
    await this.initialize();
    const filePath = this.getSessionFile(marker.sessionId);
    const line = JSON.stringify(marker) + '\n';
    await fs.promises.appendFile(filePath, line, 'utf-8');
  }

  /**
   * Load all markers for a session
   */
  async loadMarkers(sessionId: string): Promise<HandshakeMarker[]> {
    const filePath = this.getSessionFile(sessionId);
    
    try {
      const content = await fs.promises.readFile(filePath, 'utf-8');
      const lines = content.trim().split('\n').filter(line => line.length > 0);
      return lines.map(line => JSON.parse(line) as HandshakeMarker);
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return [];
      }
      throw error;
    }
  }

  /**
   * Find a marker by ID across all sessions
   */
  async findMarkerById(markerId: string): Promise<HandshakeMarker | null> {
    await this.initialize();
    
    const files = await fs.promises.readdir(this.baseDir);
    
    for (const file of files) {
      if (!file.endsWith('.jsonl')) continue;
      
      const filePath = path.join(this.baseDir, file);
      const content = await fs.promises.readFile(filePath, 'utf-8');
      const lines = content.trim().split('\n').filter(line => line.length > 0);
      
      for (const line of lines) {
        const marker = JSON.parse(line) as HandshakeMarker;
        if (marker.id === markerId) {
          return marker;
        }
      }
    }
    
    return null;
  }

  /**
   * Query markers by criteria
   */
  async queryMarkers(criteria: {
    sessionId?: string;
    fromAgent?: string;
    toAgent?: string;
    state?: string;
    startTime?: Date;
    endTime?: Date;
  }): Promise<HandshakeMarker[]> {
    await this.initialize();
    
    let markers: HandshakeMarker[] = [];
    
    if (criteria.sessionId) {
      markers = await this.loadMarkers(criteria.sessionId);
    } else {
      // Load all markers from all sessions
      const files = await fs.promises.readdir(this.baseDir);
      for (const file of files) {
        if (!file.endsWith('.jsonl')) continue;
        const sessionId = file.replace('.jsonl', '');
        const sessionMarkers = await this.loadMarkers(sessionId);
        markers.push(...sessionMarkers);
      }
    }
    
    // Apply filters
    return markers.filter(marker => {
      if (criteria.fromAgent && marker.fromAgent !== criteria.fromAgent) return false;
      if (criteria.toAgent && marker.toAgent !== criteria.toAgent) return false;
      if (criteria.state && marker.state !== criteria.state) return false;
      if (criteria.startTime && new Date(marker.timestamp) < criteria.startTime) return false;
      if (criteria.endTime && new Date(marker.timestamp) > criteria.endTime) return false;
      return true;
    });
  }

  /**
   * Get all session IDs
   */
  async getAllSessions(): Promise<string[]> {
    await this.initialize();
    
    try {
      const files = await fs.promises.readdir(this.baseDir);
      return files
        .filter(file => file.endsWith('.jsonl'))
        .map(file => file.replace('.jsonl', ''));
    } catch (error) {
      return [];
    }
  }
}
