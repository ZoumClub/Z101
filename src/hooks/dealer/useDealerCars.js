import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { getDealerCars, updateCarStatus } from '@/lib/api/dealer';

export function useDealerCars(dealerId) {
  const [cars, setCars] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const loadCars = async () => {
    if (!dealerId) return;

    try {
      const data = await getDealerCars(dealerId);
      setCars(data);
    } catch (error) {
      console.error('Error loading cars:', error);
      toast.error('Failed to load inventory');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadCars();
  }, [dealerId]);

  const toggleCarStatus = async (car) => {
    try {
      await updateCarStatus(car.id, !car.is_sold);
      setCars(cars.map(c => c.id === car.id ? { ...c, is_sold: !car.is_sold } : c));
      toast.success(`Car marked as ${!car.is_sold ? 'sold' : 'available'}`);
    } catch (error) {
      console.error('Error updating car:', error);
      toast.error('Failed to update car status');
    }
  };

  return {
    cars,
    isLoading,
    toggleCarStatus,
    refresh: loadCars
  };
}