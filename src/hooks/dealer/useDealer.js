import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { validateDealer } from '@/lib/api/dealer';

export function useDealer() {
  const router = useRouter();
  const [dealerId, setDealerId] = useState(null);
  const [dealerName, setDealerName] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const checkDealer = async () => {
      try {
        const id = localStorage.getItem('dealer_id');
        const name = localStorage.getItem('dealer_name');

        if (!id) {
          router.replace('/dealer');
          return;
        }

        const data = await validateDealer(id);
        setDealerId(id);
        setDealerName(name || data.name);
      } catch (error) {
        console.error('Error validating dealer:', error);
        router.replace('/dealer');
      } finally {
        setIsLoading(false);
      }
    };

    checkDealer();
  }, [router]);

  const logout = () => {
    localStorage.removeItem('dealer_id');
    localStorage.removeItem('dealer_name');
    router.replace('/dealer');
  };

  return {
    dealerId,
    dealerName,
    isLoading,
    logout
  };
}