/*
Tahap 1: Pemodelan Konseptual
1. Latar Belakang Masalah Bisnis & Kebutuhan Transformasi:
   Pada operasional awal platform e-commerce produk kosmetik, transaksi pesanan 
   langsung mencatat status tanpa adanya entitas yang mengelola bukti dan proses 
   transaksi finansial secara mandiri. Hal ini memicu risiko penipuan transaksi, 
   ketidakjelasan batas waktu pelunasan (expired payment), serta kendala menyesuaikan
   keuangan toko terhadap berbagai metode pembayaran digital. Untuk menjawab tantangan 
   tersebut, sistem bertransformasi dengan menambahkan sub-sistem Payment Gateway 
   yang memisahkan pencatatan pesanan belanja dengan bukti eksekusi pembayarannya 
   secara aman dan terpercaya.

2. Identifikasi Entitas dan Atribut:
   - Entitas Induk Terkait (PESANAN):
     Menyimpan identitas pesanan barang oleh pelanggan (order_id, customer_id, 
     product_id, total_harga, status_pesanan, tgl_pesanan).
   - Entitas Baru (PEMBAYARAN):
     Merekam jejak audit pelunasan pesanan dengan atribut:
     * payment_id        : Pengenal unik internal untuk setiap transaksi pembayaran.
     * order_id          : Kunci rujukan ke pesanan yang dibayarkan.
     * metode_pembayaran : Tempat pembayaran yang dipilih pembeli (Transfer Bank, 
                           Virtual Account, E-Wallet, Kartu Kredit, COD).
     * nomor_referensi   : Nomor invoice unik eksternal atau kode settlement gateway.
     * jumlah_bayar      : Nominal uang yang disetorkan pembeli.
     * status_pembayaran : Status mutasi dana (Pending, Berhasil, Gagal, Kedaluwarsa).
     * tgl_bayar         : Stempel waktu saat dana terverifikasi masuk ke sistem.

3. Aturan Bisnis (Business Rules):
   - Setiap transaksi pembayaran wajib merujuk pada satu nomor pesanan yang valid.
   - Satu transaksi pesanan hanya memiliki maksimal satu catatan pembayaran yang sah.
   - Nilai pembayaran tidak boleh bernilai negatif (CHECK >= 0).
   - Nomor referensi transaksi dari penyedia jasa keuangan harus unik global (UNIQUE).

4. Kardinalitas & Derajat Partisipasi Relasi (ERD):
   - Kardinalitas: 1 : 1 (One-to-One).
   - Partisipasi : PESANAN berpartisipasi opsional ke PEMBAYARAN (pesanan baru belum 
     tentu langsung dibayar), sedangkan PEMBAYARAN berpartisipasi wajib (mandatory) 
     ke PESANAN (tidak ada pembayaran tanpa pesanan).
   - Representasi Notasi Relasi:
     [ PESANAN ] (1,0) ------------- (1,1) [ PEMBAYARAN ]
*/
/*
Tahap 2: Pemodelan Logis dan Normalisasi
1. Transformasi ERD ke Skema Relasional:
   Dalam relasi One-to-One (1:1) dengan derajat partisipasi berbeda, Primary Key 
   dari sisi induk (PESANAN) ditempatkan sebagai Foreign Key pada sisi anak 
   (PEMBAYARAN) dengan menambahkan batasan UNIQUE untuk menjamin integritas 1:1:

   pembayaran (
       payment_id [PK], 
       order_id [FK, UNIQUE], 
       metode_pembayaran, 
       nomor_referensi [UNIQUE], 
       jumlah_bayar, 
       status_pembayaran, 
       tgl_bayar
   )

2. Uji Penerapan Normalisasi Bertingkat:
   - Bentuk Normal Pertama (1NF):
     Seluruh kolom bernilai atomik (satu nilai tunggal per sel). Tidak ada grup 
     berulang atau multi-nilai (misal: kolom metode_pembayaran hanya memuat satu 
     metode terpilih), serta memiliki Primary Key definitif (payment_id).
   
   - Bentuk Normal Kedua (2NF):
     Memenuhi 1NF dan tidak memiliki ketergantungan fungsional sebagian (Partial 
     Dependency) karena Primary Key bertipe tunggal (single-attribute payment_id). 
     Seluruh atribut non-kunci bergantung penuh pada payment_id:
     payment_id -> {order_id, metode_pembayaran, nomor_referensi, jumlah_bayar, 
                    status_pembayaran, tgl_bayar}
   
   - Bentuk Normal Ketiga (3NF):
     Memenuhi 2NF dan tidak memiliki ketergantungan transitif (Transitive Dependency). 
     Atribut identitas pembeli atau rincian produk tidak diduplikasi ke dalam tabel 
     pembayaran, melainkan dirujuk melalui order_id. Dengan demikian, atribut non-kunci 
     hanya bergantung secara langsung pada payment_id tanpa perantara atribut lain.
*/
/* Tahap 3: Pemodelan Fisik*/
USE database_kosmetik;

-- 1. Pemodelan Fisik (DDL)
CREATE TABLE IF NOT EXISTS pembayaran (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    metode_pembayaran ENUM('Transfer Bank', 'Virtual Account', 'E-Wallet', 'Kartu Kredit', 'COD') NOT NULL,
    nomor_referensi VARCHAR(50) NOT NULL UNIQUE,
    jumlah_bayar DECIMAL(12, 2) NOT NULL CHECK (jumlah_bayar >= 0),
    status_pembayaran ENUM('Pending', 'Berhasil', 'Gagal', 'Kedaluwarsa') NOT NULL DEFAULT 'Pending',
    tgl_bayar DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pembayaran_pesanan 
        FOREIGN KEY (order_id) REFERENCES pesanan(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2. Operasi Data Dummy (DML)
INSERT INTO pembayaran (order_id, metode_pembayaran, nomor_referensi, jumlah_bayar, status_pembayaran) VALUES
(1, 'Virtual Account', 'VA-BCA-20261019001', 298000.00, 'Berhasil'),
(2, 'E-Wallet', 'EWL-GOPAY-20261019002', 45000.00, 'Berhasil');

-- 3. Bukti Data Tabel Pembayaran
SELECT * FROM pembayaran;

-- 4. Bukti Integritas Relasi
-- Menggabungkan pembayaran -> pesanan -> pelanggan -> produk_kosmetik
SELECT 
    pb.payment_id,
    ps.order_id,
    pl.nama_lengkap AS nama_pelanggan,
    pk.nama_produk,
    pb.metode_pembayaran,
    pb.nomor_referensi,
    pb.jumlah_bayar,
    pb.status_pembayaran
FROM pembayaran pb
JOIN pesanan ps ON pb.order_id = ps.order_id
JOIN pelanggan pl ON ps.customer_id = pl.customer_id
JOIN produk_kosmetik pk ON ps.product_id = pk.product_id;
