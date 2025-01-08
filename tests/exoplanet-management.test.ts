import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let exoplanetCount = 0;
const exoplanets = new Map();

// Simulated contract functions
function registerExoplanet(name: string, description: string, parameters: number[], discoverer: string) {
  const exoplanetId = ++exoplanetCount;
  exoplanets.set(exoplanetId, {
    discoverer,
    name,
    description,
    parameters,
    habitabilityScore: 0,
    terraformingStatus: 'untouched'
  });
  return exoplanetId;
}

function updateHabitabilityScore(exoplanetId: number, newScore: number, updater: string) {
  const exoplanet = exoplanets.get(exoplanetId);
  if (!exoplanet) throw new Error('Invalid exoplanet');
  if (updater !== 'CONTRACT_OWNER' && updater !== exoplanet.discoverer) throw new Error('Not authorized');
  exoplanet.habitabilityScore = newScore;
  exoplanets.set(exoplanetId, exoplanet);
  return true;
}

function updateTerraformingStatus(exoplanetId: number, newStatus: string, updater: string) {
  const exoplanet = exoplanets.get(exoplanetId);
  if (!exoplanet) throw new Error('Invalid exoplanet');
  if (updater !== 'CONTRACT_OWNER' && updater !== exoplanet.discoverer) throw new Error('Not authorized');
  exoplanet.terraformingStatus = newStatus;
  exoplanets.set(exoplanetId, exoplanet);
  return true;
}

describe('Exoplanet Management Contract', () => {
  beforeEach(() => {
    exoplanetCount = 0;
    exoplanets.clear();
  });
  
  it('should register a new exoplanet', () => {
    const exoplanetId = registerExoplanet('Kepler-186f', 'Earth-sized planet in the habitable zone', [1, 2, 3, 4, 5], 'user1');
    expect(exoplanetId).toBe(1);
    expect(exoplanets.size).toBe(1);
    const exoplanet = exoplanets.get(exoplanetId);
    expect(exoplanet.name).toBe('Kepler-186f');
    expect(exoplanet.terraformingStatus).toBe('untouched');
  });
  
  it('should update habitability score', () => {
    const exoplanetId = registerExoplanet('Proxima Centauri b', 'Closest known exoplanet to Solar System', [2, 4, 6, 8, 10], 'user2');
    expect(updateHabitabilityScore(exoplanetId, 75, 'CONTRACT_OWNER')).toBe(true);
    const exoplanet = exoplanets.get(exoplanetId);
    expect(exoplanet.habitabilityScore).toBe(75);
  });
  
  it('should update terraforming status', () => {
    const exoplanetId = registerExoplanet('TRAPPIST-1e', 'Potentially habitable exoplanet', [3, 6, 9, 12, 15], 'user3');
    expect(updateTerraformingStatus(exoplanetId, 'in-progress', 'user3')).toBe(true);
    const exoplanet = exoplanets.get(exoplanetId);
    expect(exoplanet.terraformingStatus).toBe('in-progress');
  });
  
  it('should not allow unauthorized habitability score updates', () => {
    const exoplanetId = registerExoplanet('HD 40307g', 'Super-Earth exoplanet', [5, 10, 15, 20, 25], 'user4');
    expect(() => updateHabitabilityScore(exoplanetId, 90, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow unauthorized terraforming status updates', () => {
    const exoplanetId = registerExoplanet('Gliese 667 Cc', 'Super-Earth in the habitable zone', [1, 3, 5, 7, 9], 'user5');
    expect(() => updateTerraformingStatus(exoplanetId, 'completed', 'unauthorized_user')).toThrow('Not authorized');
  });
});

