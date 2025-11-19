import { useSelector } from 'react-redux';
import type { RootState } from '../store';

export const useAuth = () => {
  const { currentUser, isAuthenticated, isAdmin, loading, error } = useSelector(
    (state: RootState) => state.auth
  );

  return {
    currentUser,
    isAuthenticated,
    isAdmin,
    loading,
    error,
  };
};