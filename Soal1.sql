-- Membuat Database Kosmetik
CREATE DATABASE database_kosmetik;
USE database_kosmetik;

-- Membuat Tabel Pelanggan
CREATE TABLE pelanggan (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    no_telepon VARCHAR(15) NOT NULL,
    alamat TEXT NOT NULL,
    tanggal_daftar DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Membuat Tabel Produk Kosmetik
CREATE TABLE produk_kosmetik (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_produk VARCHAR(150) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    skin_type ENUM('Semua Jenis', 'Kering', 'Berminyak', 'Kombinasi', 'Sensitif', 'Berjerawat') NOT NULL DEFAULT 'Semua Jenis',
    harga DECIMAL(12, 2) NOT NULL CHECK (harga >= 0),
    stok INT NOT NULL DEFAULT 0 CHECK (stok >= 0)
);

-- Membuat Tabel Pesanan
CREATE TABLE pesanan (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    jumlah INT NOT NULL CHECK (jumlah > 0),
    total_harga DECIMAL(12, 2) NOT NULL CHECK (total_harga >= 0),
    status_pesanan ENUM('Menunggu Pembayaran', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan') NOT NULL DEFAULT 'Menunggu Pembayaran',
    tgl_pesanan DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pesanan_pelanggan 
        FOREIGN KEY (customer_id) REFERENCES pelanggan(customer_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_pesanan_kosmetik 
        FOREIGN KEY (product_id) REFERENCES produk_kosmetik(product_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);
