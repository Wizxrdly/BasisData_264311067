-- Memasukkan 3 Data Dummy ke Tabel Pelanggan
INSERT INTO pelanggan (nama_lengkap, email, no_telepon, alamat) VALUES
('Anita Makswin', 'anitamakswin@email.com', '081243568709', 'Jl. Duku No. 12, Surakarta'),
('Bella Rahma', 'bellarahma@email.com', '086574839201', 'Jl. Duwet No. 45, Semarang'),
('Clara Citra', 'claracitra@email.com', '085647382910', 'Jl. Malioboro No. 8, Yogyakarta');

-- Memasukkan 3 Data Dummy ke Tabel Produk Kosmetik
INSERT INTO produk_kosmetik (nama_produk, brand, skin_type, harga, stok) VALUES
('Face Serum', 'Emina', 'Semua Jenis', 149000.00, 50),
('Cleanser', 'Wardah', 'Berjerawat', 45000.00, 700),
('Eyeshadow', 'Make Over', 'Sensitif', 89000.00, 60);

-- Memasukkan 3 Data Dummy ke Tabel Pesanan
INSERT INTO pesanan (customer_id, product_id, jumlah, total_harga, status_pesanan) VALUES
(1, 1, 2, 298000.00, 'Selesai'),
(2, 2, 1, 45000.00, 'Diproses'),
(3, 3, 3, 267000.00, 'Menunggu Pembayaran');

-- Memunculkan Hasil Tabel Produk Kosmetik
SELECT * FROM produk_kosmetik;

-- Mengubah Data dari Kolom Status Pesanan di Tabel Pesanan
UPDATE pesanan 
SET status_pesanan = 'Selesai' 
WHERE order_id = 2;

-- Menghapus salah satu Data dari Tabel Pesanan
DELETE FROM pesanan 
WHERE order_id = 3;
