import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import type { PayloadAction } from '@reduxjs/toolkit';
import { authApi } from '../api/authApi';
import type { User, LoginCredentials, SignupData } from '../types';

interface AuthState {
  currentUser: User | null;
  isAuthenticated: boolean;
  isAdmin: boolean;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  currentUser: null,
  isAuthenticated: false,
  isAdmin: false,
  loading: false,
  error: null,
};

// Async thunks
export const fetchCurrentUser = createAsyncThunk(
  'auth/fetchCurrentUser',
  async (_, { rejectWithValue }) => {
    try {
      const user = await authApi.fetchCurrentUser();
      return user;
    } catch (error) {
      return rejectWithValue((error as Error).message);
    }
  }
);

export const login = createAsyncThunk(
  'auth/login',
  async (credentials: LoginCredentials, { rejectWithValue, dispatch }) => {
    try {
      await authApi.login(credentials);
      // After successful login, fetch the current user
      const result = await dispatch(fetchCurrentUser());
      if (fetchCurrentUser.fulfilled.match(result)) {
        return result.payload;
      }
      throw new Error('Failed to fetch user after login');
    } catch (error) {
      return rejectWithValue((error as Error).message);
    }
  }
);

export const signup = createAsyncThunk(
  'auth/signup',
  async (data: SignupData, { rejectWithValue }) => {
    try {
      await authApi.signup(data);
      return true;
    } catch (error) {
      return rejectWithValue((error as Error).message);
    }
  }
);

export const logout = createAsyncThunk(
  'auth/logout',
  async (_, { rejectWithValue }) => {
    try {
      await authApi.logout();
      return true;
    } catch (error) {
      return rejectWithValue((error as Error).message);
    }
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    // Fetch current user
    builder
      .addCase(fetchCurrentUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCurrentUser.fulfilled, (state, action: PayloadAction<User>) => {
        console.log('authSlice - fetchCurrentUser.fulfilled:', action.payload);
        state.loading = false;
        state.currentUser = action.payload;
        state.isAuthenticated = true;
        state.isAdmin = action.payload.admin;
      })
      .addCase(fetchCurrentUser.rejected, (state, action) => {
        console.log('authSlice - fetchCurrentUser.rejected:', action.payload);
        state.loading = false;
        state.currentUser = null;
        state.isAuthenticated = false;
        state.isAdmin = false;
        state.error = action.payload as string;
      });

    // Login
    builder
      .addCase(login.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action: PayloadAction<User>) => {
        console.log('authSlice - login.fulfilled:', action.payload);
        state.loading = false;
        state.currentUser = action.payload;
        state.isAuthenticated = true;
        state.isAdmin = action.payload.admin;
      })
      .addCase(login.rejected, (state, action) => {
        console.log('authSlice - login.rejected:', action.payload);
        state.loading = false;
        state.error = action.payload as string;
      });

    // Signup
    builder
      .addCase(signup.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(signup.fulfilled, (state) => {
        state.loading = false;
        state.error = null;
      })
      .addCase(signup.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });

    // Logout
    builder
      .addCase(logout.pending, (state) => {
        state.loading = true;
      })
      .addCase(logout.fulfilled, (state) => {
        state.loading = false;
        state.currentUser = null;
        state.isAuthenticated = false;
        state.isAdmin = false;
      })
      .addCase(logout.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearError } = authSlice.actions;
export default authSlice.reducer;