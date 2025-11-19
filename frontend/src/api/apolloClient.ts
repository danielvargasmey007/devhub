import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client';
import { GRAPHQL_URL } from '../config';

const httpLink = createHttpLink({
  uri: GRAPHQL_URL,
  credentials: 'include', // Send cookies with requests
});

export const apolloClient = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'network-only',
    },
    query: {
      fetchPolicy: 'network-only',
    },
  },
});