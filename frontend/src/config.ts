/**
 * Application configuration
 * Uses environment variables from Vite
 */

// API base URL - defaults to localhost for development
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

// GraphQL endpoint
export const GRAPHQL_URL = `${API_BASE_URL}/graphql`;

// Export for convenience
export const config = {
  apiBaseUrl: API_BASE_URL,
  graphqlUrl: GRAPHQL_URL,
} as const;