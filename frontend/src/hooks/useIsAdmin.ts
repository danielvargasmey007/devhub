import { useAuth } from './useAuth';

export const useIsAdmin = (): boolean => {
  const { isAdmin } = useAuth();
  return isAdmin;
};