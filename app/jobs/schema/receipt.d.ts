type Receipt = {
  merchant: {
    name: string;
    address?: string;
    phone?: string;
    email?: string;
    website?: string;
    vatNumber?: string;
    taxNumber?: string;
  };
  items: Array<{
    name: string;
    quantity: number;
    price: {
      amount: number;
      currency: string; // ISO 4217 currency code
    };
    taxRate: number; // VAT tax rate as a decimal (e.g., 0.20 for 20%)
    taxAmount: {
      amount: number;
      currency: string;
    };
  }>;
  total: {
    net: {
      amount: number;
      currency: string;
    };
    tax: Array<{
      rate: number;
      amount: {
        amount: number;
        currency: string;
      };
    }>;
    gross: {
      amount: number;
      currency: string;
    };
  };
  payment: {
    method: string;
    amount: {
      amount: number;
      currency: string;
    };
  };
  date: string; // ISO 8601 date format (YYYY-MM-DD)
  time?: string; // Time in HH:MM:SS format
  receipt_number?: string;
};