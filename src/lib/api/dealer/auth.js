import { supabase } from '@/lib/supabase';

export async function validateDealer(dealerId) {
  const { data, error } = await supabase
    .from('dealers')
    .select('id, name')
    .eq('id', dealerId)
    .single();

  if (error || !data) {
    throw new Error('Invalid dealer credentials');
  }

  return data;
}

export async function loginDealer(idNumber) {
  const { data, error } = await supabase
    .from('dealers')
    .select('id, name')
    .eq('id_number', idNumber.trim())
    .single();

  if (error || !data) {
    throw new Error('Invalid dealer ID');
  }

  return data;
}