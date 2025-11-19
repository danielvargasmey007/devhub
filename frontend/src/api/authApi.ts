import type { User, LoginCredentials, SignupData } from '../types';
import { API_BASE_URL } from '../config';

// Helper to handle fetch responses
async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const error = await response.text();
    throw new Error(error || `HTTP error! status: ${response.status}`);
  }

  // Check if response has content
  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return response.json();
  }

  // If no JSON content, return empty object only for 204 No Content
  if (response.status === 204) {
    return {} as T;
  }

  // For any other non-JSON response, throw an error
  throw new Error('Expected JSON response but got: ' + contentType);
}

export const authApi = {
  /**
   * Fetch current authenticated user
   */
  async fetchCurrentUser(): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/me`, {
      method: 'GET',
      credentials: 'include',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });
    return handleResponse<User>(response);
  },

  /**
   * Login user
   */
  async login(credentials: LoginCredentials): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/user_sessions`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        user_session: {
          email: credentials.email,
          password: credentials.password,
        },
      }),
    });

    // Authlogic redirects on success, returns error on failure
    if (!response.ok) {
      throw new Error('Invalid email or password');
    }
  },

  /**
   * Signup new user
   */
  async signup(data: SignupData): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        user: {
          name: data.name,
          email: data.email,
          password: data.password,
          password_confirmation: data.passwordConfirmation,
        },
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(text || 'Signup failed');
    }
  },

  /**
   * Logout user
   */
  async logout(): Promise<void> {
    // We need to get the session ID first, or we can try a different approach
    // For Authlogic, we'll make a DELETE request to user_sessions/current
    const response = await fetch(`${API_BASE_URL}/logout`, {
      method: 'DELETE',
      credentials: 'include',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error('Logout failed');
    }
  },
};