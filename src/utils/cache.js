// Simple in-memory cache
class Cache {
  constructor() {
    this.cache = new Map();
    this.ttls = new Map();
  }

  set(key, value, ttlSeconds = 300) {
    this.cache.set(key, value);
    
    // Set expiration
    const expiresAt = Date.now() + (ttlSeconds * 1000);
    this.ttls.set(key, expiresAt);
    
    // Auto-cleanup
    setTimeout(() => {
      this.delete(key);
    }, ttlSeconds * 1000);
  }

  get(key) {
    // Check if expired
    const expiresAt = this.ttls.get(key);
    if (expiresAt && Date.now() > expiresAt) {
      this.delete(key);
      return null;
    }
    
    return this.cache.get(key) || null;
  }

  delete(key) {
    this.cache.delete(key);
    this.ttls.delete(key);
  }

  clear() {
    this.cache.clear();
    this.ttls.clear();
  }

  has(key) {
    return this.cache.has(key) && Date.now() <= this.ttls.get(key);
  }

  size() {
    return this.cache.size;
  }
}

// Singleton instance
const cache = new Cache();

// Cache middleware
const cacheMiddleware = (durationSeconds = 300) => {
  return (req, res, next) => {
    // Only cache GET requests
    if (req.method !== 'GET') {
      return next();
    }

    const key = req.originalUrl;
    const cachedResponse = cache.get(key);

    if (cachedResponse) {
      console.log('✓ Cache hit:', key);
      return res.json({
        ...cachedResponse,
        cached: true,
        cachedAt: new Date().toISOString()
      });
    }

    // Store original json function
    const originalJson = res.json.bind(res);

    // Override json function to cache response
    res.json = (data) => {
      if (res.statusCode === 200) {
        cache.set(key, data, durationSeconds);
        console.log('✓ Cached:', key);
      }
      return originalJson(data);
    };

    next();
  };
};

module.exports = { cache, cacheMiddleware };
