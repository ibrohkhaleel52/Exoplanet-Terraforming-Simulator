import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mint(name: string, description: string, exoplanetId: number, imageUrl: string, terraformingMilestone: string, creator: string) {
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    name,
    description,
    creator,
    exoplanetId,
    imageUrl,
    terraformingMilestone,
    timestamp: Date.now()
  });
  tokenOwners.set(tokenId, creator);
  return tokenId;
}

function transfer(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Exoplanet NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new exoplanet NFT', () => {
    const tokenId = mint('Kepler-186f', 'First Earth-sized planet in habitable zone', 1, 'https://example.com/kepler-186f.png', 'Atmospheric composition stabilized', 'discoverer1');
    expect(tokenId).toBe(1);
    expect(tokenOwners.get(tokenId)).toBe('discoverer1');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.name).toBe('Kepler-186f');
    expect(metadata.exoplanetId).toBe(1);
  });
  
  it('should transfer an NFT', () => {
    const tokenId = mint('Proxima Centauri b', 'Closest known exoplanet to Solar System', 2, 'https://example.com/proxima-b.png', 'Water detected on surface', 'discoverer2');
    expect(transfer(tokenId, 'discoverer2', 'collector1')).toBe(true);
    expect(tokenOwners.get(tokenId)).toBe('collector1');
  });
  
  it('should not allow unauthorized transfer', () => {
    const tokenId = mint('TRAPPIST-1e', 'Potentially habitable exoplanet', 3, 'https://example.com/trappist-1e.png', 'Magnetic field established', 'discoverer3');
    expect(() => transfer(tokenId, 'unauthorized_user', 'collector2')).toThrow('Not authorized');
  });
  
  it('should store correct metadata', () => {
    const imageUrl = 'https://example.com/gliese-667cc.png';
    const tokenId = mint('Gliese 667 Cc', 'Super-Earth in triple star system', 4, imageUrl, 'Greenhouse effect initiated', 'discoverer4');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.imageUrl).toBe(imageUrl);
    expect(metadata.creator).toBe('discoverer4');
    expect(metadata.terraformingMilestone).toBe('Greenhouse effect initiated');
    expect(metadata.timestamp).toBeLessThanOrEqual(Date.now());
  });
});

